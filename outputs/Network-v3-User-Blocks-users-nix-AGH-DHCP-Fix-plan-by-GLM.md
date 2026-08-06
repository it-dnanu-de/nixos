# Plan: Network v3 — user-block addressing, users.nix, AGH DHCP fix, WG 10.0.10.x

**Author:** GLM 5.2 (planner-high) · 2026-08-06 · **For:** DeepSeek-V4-Pro (nixos-builder)
**Task source:** `inputs/Network-v3-User-Blocks-users-nix-AGH-DHCP-Fix-for-GLM.md`
**Status:** planning only — no code changed, no commits made. OpenCode.md is NOT amended in this task (amendment list in §10, applied after approval).

---

## 0. Verified facts against pinned `nixos-26.05`

### 0.1 AGH static-lease bug — ROOT CAUSE FOUND (deliverable #2)

**Diagnosis:** AdGuardHome v0.107.78 (pinned in `pkgs/by-name/ad/adguardhome/package.nix`, `schema_version = 34`) **does NOT store static leases in the YAML config at all.** The `dhcp.ServerConfig` Go struct (`internal/dhcpd/config.go`) has these YAML fields only:

```go
type ServerConfig struct {
    Enabled       bool         `yaml:"enabled"`
    InterfaceName string       `yaml:"interface_name"`
    LocalDomainName string     `yaml:"local_domain_name"`
    Conf4 V4ServerConf         `yaml:"dhcpv4"`
    Conf6 V6ServerConf         `yaml:"dhcpv6"`
    // NO static_leases field — not now, not ever.
}
```

`V4ServerConf` (`yaml:"dhcpv4"`) also has no `static_leases` field — only `gateway_ip`, `subnet_mask`, `range_start`, `range_end`, `lease_duration`, `icmp_timeout_msec`, `options`.

**Static leases live in a separate JSON database file** (`internal/dhcpd/db.go`):
- File: `leases.json` in AGH's working directory (`/var/lib/AdGuardHome/leases.json`)
- Format: `{"version": 1, "leases": [{"expires": "", "ip": "10.0.0.3", "hostname": "admin3", "mac": "2c:9c:58:60:c8:25", "static": true}]}`
- Loaded by `server.dbLoad()` during `dhcpd.Create()` (before the DHCP server starts serving)
- Written by `server.dbStore()` on lease changes (static + dynamic sorted by hostname)

**Why the YAML `static_leases` key is silently dropped:** Go's `yaml.Unmarshal` ignores unknown fields by default. AGH loads the YAML into `ServerConfig` (which has no `static_leases` field), then `WriteDiskConfig()` writes the struct back to YAML — the unknown key is gone. This is not a bug in AGH; it's the designed behavior. The YAML `static_leases` key was likely valid in very old schema versions (< 20) and was removed when leases moved to the JSON DB. The NixOS module's `freeformType` accepts any YAML, so Nix doesn't catch the invalid key.

**Hypotheses ruled out:**
1. ❌ `dhcp.static_leases` vs `dhcp.dhcpv4.static_leases` — neither path exists in the struct. Both are silently ignored.
2. ❌ `schema_version` mismatch — schema 34 is the package default; no migration touches `static_leases` (checked `configmigrate/v28.go` through `v34.go` — none reference DHCP static leases).
3. ❌ `mutableSettings` interplay — with `mutableSettings = false`, the module's `preStart` does `installFresh` (copies Nix YAML to state dir). AGH then loads it, ignores `static_leases`, and rewrites without it. The `--check-config` in `configFile.checkPhase` also triggers a rewrite but only at build time, not runtime.

**The fix (declarative, native, uses AGH's own loading mechanism):**

1. **Remove `static_leases` from the YAML config** in `adguard.nix` — it's ignored and causes confusion.
2. **Add a `systemd.services.adguardhome.preStart` fragment** that generates `leases.json` from `users.nix` data and writes it to `$STATE_DIRECTORY/leases.json` BEFORE AGH starts. The NixOS module's `preStart` is typed as `lines` (multiple definitions concatenated), so our fragment appends cleanly after the module's `installFresh`.
3. AGH starts → `Create()` → `dbLoad()` reads `leases.json` → static leases are in memory. ✓

**Why this doesn't violate the 99%-declarative rule:** the source of truth is `users.nix` (Nix). The `preStart` script is a declarative renderer (Nix-generated, deterministic, idempotent) that writes a file AGH expects to find. It is NOT a bootstrap script poking an API — it's the same pattern as `wireguard-profile-render` or `cloudflare-dns-sync` (Nix generates a file, a service consumes it). AGH's own `dbLoad()` is the consumer.

**Runtime behavior:** AGH will write `leases.json` on lease changes (adding dynamic leases). On next restart, our `preStart` overwrites with static-only; dynamic leases are lost, devices re-request. This is correct — dynamic leases are transient.

**Verification step (executor must run after deploy):**
```bash
# 1. Build passes
nix build .#nixosConfigurations.homelab.config.system.build.toplevel

# 2. After deploy + AGH restart:
ssh ... 'systemctl restart adguardhome'
ssh ... 'cat /var/lib/AdGuardHome/leases.json | jq ".leases[] | select(.static == true)"'
# Must show all 13 static leases with correct MAC/IP/hostname.

# 3. AGH YAML no longer has static_leases (confirm it was removed):
ssh ... 'grep static_leases /var/lib/AdGuardHome/AdGuardHome.yaml || echo "OK: no static_leases in YAML"'
```

### 0.2 Other verified facts

| Thing | Status | Evidence |
|---|---|---|
| `services.adguardhome` module | ✅ verified | `nixos/modules/services/networking/adguardhome.nix` — `mutableSettings`, `settings` (freeform YAML + `schema_version`), `preStart` typed as string (lines merge). `DynamicUser = true`, `StateDirectory = "AdGuardHome"`, `--work-dir /var/lib/AdGuardHome/`. |
| AGH `leases.json` format | ✅ verified | `internal/dhcpd/db.go`: `dataLeases{Version, Leases[]*dbLease}`, `dbLease{Expiry string "expires", IP netip.Addr "ip", Hostname string "hostname", HWAddr string "mac", IsStatic bool "static"}`. Static leases have `expires: ""`. |
| AGH persistent clients `ids` accept IP-only | ✅ verified | AGH `clients.persistent[].ids` are plain strings — IP or hostname. IP-only ids work (the current config already uses IPs alongside hostnames). Dropping hostname ids is safe. |
| `networking.wireguard.interfaces.wg0` | ✅ verified | unchanged from deployed system; just new IPs/subnet. |
| Authelia file auth + `users.yaml` | ✅ verified | already deployed (v2); adding 10th user = append to sops `authelia_users_yaml`. |
| nginx `allow`/`deny` + `auth_request` | ✅ verified | already deployed (v2). |
| NixOS `preStart` `lines` merge | ✅ verified | `systemd` module types `preStart` as `lines`; multiple definitions concatenate. Our fragment appends after the module's `installFresh`. |

---

## 1. `users.nix` — design (deliverable #1)

**Location:** repo root (`/home/dnanu/nixos/users.nix`) — imported by `flake.nix` via `specialArgs` (alongside `settings`).

**Shape:**
```nix
# users.nix — single source of truth for users, devices, and IP allocation.
# Consumed by: adguard.nix (DHCP leases + persistent clients), wireguard.nix
# (WG peers + QR renderer), nginx.nix (ACL allowlists), authelia.nix (user list).
#
# IP allocation (derived, not hardcoded):
#   admin   → LAN 10.0.0.1-8   · VPN 10.0.10.3-8 (admin0=10.0.0.0 net addr,
#             admin1=router 10.0.0.1, admin2=homelab 10.0.0.2 = WG server 10.0.10.2;
#             admin3-8 = VPN devices, name↔IP aligned)
#   dumitru → LAN 10.0.0.9-19  · VPN 10.0.10.9-19
#   adela   → LAN 10.0.0.20-29 · VPN 10.0.10.20-29
#   tiberiu → LAN 10.0.0.30-39 · VPN 10.0.10.30-39
#   david   → LAN 10.0.0.40-49 · VPN 10.0.10.40-49
#   ramona  → LAN 10.0.0.50-59 · VPN 10.0.10.50-59
#   tibisor → LAN 10.0.0.60-69 · VPN 10.0.10.60-69
#   iza     → LAN 10.0.0.70-79 · VPN 10.0.10.70-79
#   kerem   → LAN 10.0.0.80-89 · VPN 10.0.10.80-89
#   hannah  → LAN 10.0.0.90-99 · VPN 10.0.10.90-99
#   guests  → LAN 10.0.0.100-250 · no VPN
#
# The human only edits `hostname` + `mac` per device. IPs are DERIVED from
# the user's block offset + device index (1-based).

{
  # User block base offsets (LAN = base, VPN = base + 10.0.10.x mirroring)
  blocks = {
    admin   = { lan = 3;  vpn = 3;  };  # admin3-8 → .3-.8 (admin0/1/2 = net/router/homelab, no VPN)
    dumitru = { lan = 9;  vpn = 9;  };  # dumitru1-11 → .9-.19
    adela   = { lan = 20; vpn = 20; };
    tiberiu = { lan = 30; vpn = 30; };
    david   = { lan = 40; vpn = 40; };
    ramona  = { lan = 50; vpn = 50; };
    tibisor = { lan = 60; vpn = 60; };
    iza     = { lan = 70; vpn = 70; };
    kerem   = { lan = 80; vpn = 80; };
    hannah  = { lan = 90; vpn = 90; };
  };

  users = {
    admin = {
      tier = "admin";
      devices = [
        { hostname = "admin3"; mac = "2c:9c:58:60:c8:25"; }  # Arch PC
      ];
    };
    dumitru = {
      tier = "user";
      devices = [
        { hostname = "dumitru1"; mac = "f6:5b:6b:f3:0e:87"; }  # iPhone 17 Pro
      ];
    };
    adela = {
      tier = "user";
      devices = [
        { hostname = "adela1"; mac = "fe:02:26:df:0c:50"; }  # iPhone XS
        { hostname = "adela2"; mac = "00:c3:f4:ea:fe:a6"; }  # Samsung TV
        { hostname = "adela3"; mac = "68:79:c4:29:1d:44"; }  # Philips Air
      ];
    };
    tiberiu = {
      tier = "user";
      devices = [
        { hostname = "tiberiu1"; mac = "da:08:7b:fe:cf:d7"; }  # Galaxy S22U
      ];
    };
    david = {
      tier = "user";
      devices = [
        { hostname = "david1"; mac = "76:6f:b2:93:10:ce"; }  # iPhone 17 Pro Max
        { hostname = "david2"; mac = "c4:9d:ed:c9:9a:13"; }  # Xbox One
      ];
    };
    ramona = {
      tier = "user";
      devices = [
        { hostname = "ramona1"; mac = "56:ea:b4:79:06:61"; }  # iPhone 11
      ];
    };
    tibisor = {
      tier = "user";
      devices = [
        { hostname = "tibisor1"; mac = "26:05:a5:6c:e2:56"; }  # iPhone 14
      ];
    };
    iza = {
      tier = "user";
      devices = [
        { hostname = "iza1"; mac = "TODO"; }  # iPhone 15 — TODO MAC
      ];
    };
    kerem = {
      tier = "user";
      devices = [
        { hostname = "kerem1"; mac = "TODO"; }  # iPhone 16 Pro — TODO MAC
      ];
    };
    hannah = {
      tier = "user";
      devices = [
        { hostname = "hannah1"; mac = "TODO"; }  # iPhone 15 Pro — TODO MAC
      ];
    };
  };

  # Guest DHCP range (no VPN, no persistent client)
  guests = {
    lanStart = "10.0.0.100";
    lanEnd   = "10.0.0.250";
  };
}
```

**IP derivation logic** (implemented as a Nix helper in each consuming module, or as a shared `lib` function in `users.nix` itself):

```nix
# Given a user name + device index (1-based), derive LAN and VPN IPs.
# Example: userToIps "adela" 2 → { lan = "10.0.0.21"; vpn = "10.0.10.21"; }
userToIps = userName: idx:
  let block = blocks.${userName};
  in {
    lan = "10.0.0.${toString (block.lan + idx - 1)}";
    vpn = "10.0.10.${toString (block.vpn + idx - 1)}";
  };
```

**TODO MAC handling:** `mac = "TODO"` entries are skipped by the `leases.json` renderer (no DHCP lease generated). The WG peer is still created (VPN is independent of MAC). When the human fills the real MAC, the lease appears on next rebuild. This is cleaner than placeholder `00:00:00:00:00:00` (which AGH might reject or create a bogus lease for).

**flake.nix change:** add `users = import ./users.nix;` to `specialArgs`.

---

## 2. AGH DHCP fix — implementation (deliverable #2)

### `modules/networking/adguard.nix` changes

1. **Remove `dhcp.static_leases`** from `settings` entirely (it's ignored by AGH).
2. **Add `systemd.services.adguardhome.preStart`** that writes `$STATE_DIRECTORY/leases.json` from `users.nix` data. The JSON is generated in Nix (via `builtins.toJSON`) and written by the script. Only devices with real MACs (not `"TODO"`) are included.

```nix
# In adguard.nix, after the services.adguardhome block:
systemd.services.adguardhome.preStart = let
  # Build the leases.json content from users.nix
  staticLeases = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1); in
      lib.optionalString (dev.mac != "TODO") {
        expires = "";
        ip = ips.lan;
        hostname = dev.hostname;
        mac = dev.mac;
        static = true;
      }
    ) userData.devices
  ) users.users);
  leasesJson = builtins.toJSON {
    version = 1;
    leases = staticLeases;
  };
in ''
  # Write declarative static leases to leases.json (AGH loads this on start).
  # AGH 0.107.78 does NOT read static_leases from YAML — they live in leases.json.
  # See internal/dhcpd/db.go: dbLoad().
  echo '${leasesJson}' > "$STATE_DIRECTORY/leases.json"
  chmod 600 "$STATE_DIRECTORY/leases.json"
'';
```

**Note on `preStart` ordering:** the NixOS module sets `preStart` with `lib.optionalString` (priority 100). Our `systemd.services.adguardhome.preStart = ...` also has default priority. With `lines` type, they concatenate: module's `installFresh` runs first (copies YAML), then our script writes `leases.json`. Both run as the DynamicUser. Correct order. ✓

### Persistent clients (deliverable #3)

Replace the current 9-user persistent client list with one generated from `users.nix`. Each user gets a persistent client with:
- `ids` = their LAN IP(s) + VPN IP(s) only (drop hostname ids per human ruling: "LAN IPv4 is enough to identify")
- `tags` = `["user_admin"]` for admin, `["user_regular"]` for users
- Guests: no persistent client (labeled dynamically via `runtime_sources.dhcp`)

```nix
clients.persistent = lib.flatten (lib.mapAttrsToList (userName: userData:
  let
    ips = lib.flatten (lib.imap0 (idx: dev:
      let ip = users.userToIps userName (idx + 1); in [ ip.lan ip.vpn ]
    ) userData.devices);
    tag = if userData.tier == "admin" then "user_admin" else "user_regular";
  in [{
    name = userName;
    ids = ips;
    tags = [ tag ];
    use_global_settings = true;
  }]
) users.users);
```

### DHCP range (deliverable #3)

```nix
dhcpv4 = {
  gateway_ip = settings.network.gateway;
  subnet_mask = "255.255.255.0";
  range_start = users.guests.lanStart;   # "10.0.0.100"
  range_end   = users.guests.lanEnd;     # "10.0.0.250"
  lease_duration = 86400;
  icmp_timeout_msec = 1000;
};
# NO static_leases here — they go in leases.json (see preStart above).
```

---

## 3. WireGuard v3 — 10.0.10.0/24 (deliverables #4, #5)

### `settings.nix` changes

Replace the hardcoded `network.wireguard.peers` list with a derivation from `users.nix`. The `settings.nix` WG section becomes:

```nix
network.wireguard = {
  port = 51820;
  subnet = "10.0.10.0/24";
  address = "10.0.10.2";      # WG server mirrors LAN server at 10.0.0.2
  endpoint = "vpn.dnanu.de";
  # peers are now DERIVED from users.nix — see below.
};
```

**Peer derivation:** `settings.nix` can't import `users.nix` (circular: `flake.nix` imports both). Instead, the peer list is generated in `wireguard.nix` itself (which receives both `settings` and `users` via `specialArgs`). The `settings.nix` WG section only carries `port`, `subnet`, `address`, `endpoint`. The peer list moves to `wireguard.nix`:

```nix
# In wireguard.nix:
peers = lib.flatten (lib.mapAttrsToList (userName: userData:
  lib.imap0 (idx: dev:
    let ips = users.userToIps userName (idx + 1); in {
      name = "${dev.hostname}-vpn";     # e.g. "admin3-vpn"
      ip = ips.vpn;
      admin = userData.tier == "admin";
      user = userName;
      publicKey = peerPublicKeys.${dev.hostname} or "REPLACE_ME";
    }
  ) userData.devices
) users.users);
```

**Public keys:** stored in a `peerPublicKeys` attrset in `settings.nix` (or a separate `keys.nix`). Public keys are not secret. The mapping old→new hostname is 1:1:

| Old peer name | New hostname | Public key (unchanged) |
|---|---|---|
| dumitru-pc-vpn | admin3 | `iMocXpOjXHN0dEyOZqoPU0WHk99DZlEGs7vJePwfHgo=` |
| dumitru-phone-vpn | dumitru1 | `hgUar95LcXopyebZfGRDbe0lZndqDfHDp/1CiSg1qlo=` |
| adela-phone-vpn | adela1 | `IKGIZcEp5jXPPhjD1y0yhH8NctiJOlCC0WEto6hNC2U=` |
| adela-tv-vpn | adela2 | `WppvW2HLCQEl+7Q5CmSSKk9XOzAgf3wImZvGTGTGF1o=` |
| adela-air-vpn | adela3 | `mLGb/B4MTy7lebFCtSsPLyZet2g/7RhVs2VGYw5lTFw=` |
| tiberiu-phone-vpn | tiberiu1 | `021YHQrkW0jelFHbRaAYhMXr13XkC52MYFCTlMac3h8=` |
| david-phone-vpn | david1 | `N/+2L7/gr4cNXh5QWlHlU/HP3JELEPq3yRqJiHRdm2A=` |
| david-xbox-vpn | david2 | `vvL7s3DRtfeQPWFNG6rdh0g9+aCb2EuAePA9ytfo6iE=` |
| ramona-phone-vpn | ramona1 | `4FNungU+bh000Xl1iK9M/IF6nyogsExGBxijnEQfIDc=` |
| tibisor-phone-vpn | tibisor1 | `ACCujN9Qv0tt9TGW70faDP9lnMck7EFHa5dk/T5UMDU=` |
| iza-phone-vpn | iza1 | `nBHQHSFHU/24IeKEJ0rFsV2xJTZCc4sRW/sI5/if+kc=` |
| kerem-phone-vpn | kerem1 | `zSoQM300aEExAnjUDwjHZi9r5tfrwsm4drEtrqVp90c=` |
| hannah-phone-vpn | hannah1 | `iRSXSbB/aiqXxRUyMLc2zfaJ+uARS9Jh5WOBwfQYkwU=` |

### sops key rename (deliverable #5)

Old sops key names → new sops key names (13 peers × 2 = 26 keys renamed):

| Old sops key | New sops key |
|---|---|
| `wireguard_peer_dumitru-pc-vpn_{private,psk}` | `wireguard_peer_admin3-vpn_{private,psk}` |
| `wireguard_peer_dumitru-phone-vpn_{private,psk}` | `wireguard_peer_dumitru1-vpn_{private,psk}` |
| `wireguard_peer_adela-phone-vpn_{private,psk}` | `wireguard_peer_adela1-vpn_{private,psk}` |
| ... | ... (pattern: `<hostname>-vpn` replaces `<user>-<device>-vpn`) |

**The private key VALUES are unchanged** — only the sops key names change. The executor must:
1. `sops secrets/secrets.yaml`
2. For each of the 13 peers: copy the old key's value to the new key name, then delete the old key.
3. Save.

The `wireguard.nix` `peerSecretAttrs` already derives secret names from `p.name`, so once `p.name` = `"admin3-vpn"` etc., the sops keys must match.

### QR renderer (deliverable #5)

The existing per-user renderer in `wireguard.nix` already groups by `p.user`. With the new peer names (`admin3-vpn`, `dumitru1-vpn`, etc.), the renderer writes:
- `/var/lib/mobileprofile/wg/admin/admin3-vpn.conf` + `.png` + `index.html`
- `/var/lib/mobileprofile/wg/dumitru/dumitru1-vpn.conf` + `.png` + `index.html`
- etc.

The `tierNote` already reads from `p.admin`. The `user` field in the peer attrset drives the grouping. No structural change needed — just the data flows from `users.nix` now.

**WG peer `.conf` changes:**
- `Address = 10.0.10.X/32` (was `10.0.1.X`)
- `AllowedIPs = 10.0.0.0/24` (unchanged — split-tunnel to LAN only)
- `DNS = 10.0.0.2` (unchanged)
- `Endpoint = vpn.dnanu.de:51820` (unchanged)

---

## 4. Authelia — add `admin` user (deliverable #6)

### `authelia_users_yaml` in sops

Add a 10th user `admin` to the Authelia users.yaml. The executor must:
1. `sops secrets/secrets.yaml`
2. Edit `authelia_users_yaml` to add the `admin` user entry (bcrypt hash + display name).
3. Generate a random initial password for `admin`, store plaintext in `Memory.md`.

The users.yaml structure (already deployed for 9 users):
```yaml
users:
  admin:
    displayname: "Admin"
    password: "$argon2id..."  # bcrypt hash
    email: admin@dnanu.de
    groups:
      - admin
  dumitru:
    displayname: "Dumitru"
    password: "$argon2id..."
    ...
  # ... 8 more users
```

**Profile page mapping:** `profile.dnanu.de/admin/` serves `admin3-vpn` QR; `profile.dnanu.de/dumitru/` serves `dumitru1-vpn` QR. The existing nginx `root /var/lib/mobileprofile/wg/$auth_user` + `try_files` already handles this — the renderer writes per-user dirs named after the `user` field (`admin`, `dumitru`, etc.). No nginx change needed.

### `authelia.nix` — no structural change

The Authelia config is unchanged. The `access_control.rules` already has `profile.dnanu.de` → `one_factor`. The 10th user is just data in the sops secret. The `admin` user gets `groups: [admin]` (for future ACL use, though current enforcement is IP-based).

---

## 5. nginx ACL v3 (deliverable #7)

### `modules/networking/nginx.nix` — rework helpers from `users.nix`

**Admin vhost ACL:** allow admin LAN (10.0.0.3-8) + admin VPN (10.0.10.3-8). Deny everything else (including user LAN/VPN, guests).

**User vhost ACL:** allow user LAN (10.0.0.9-99) + all VPN (10.0.10.3-99). Deny guests (10.0.0.100-250) and internet.

**Guests:** get NOTHING (DNS-only via AdGuard). No nginx vhost is reachable from 10.0.0.100-250.

```nix
# In nginx.nix:
let
  # Derive IP ranges from users.nix
  adminUsers = lib.filterAttrs (n: u: u.tier == "admin") users.users;
  regularUsers = lib.filterAttrs (n: u: u.tier == "user") users.users;

  # All admin device IPs (LAN + VPN)
  adminIps = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.flatten (lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1); in [ ips.lan ips.vpn ]
    ) userData.devices)
  ) adminUsers);

  # All user device IPs (LAN + VPN)
  userIps = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.flatten (lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1); in [ ips.lan ips.vpn ]
    ) userData.devices)
  ) regularUsers);

  # Admin allowlist: admin IPs only
  adminAllowlist = ''
    ${lib.concatStringsSep "\n    " (map (ip: "allow ${ip}/32;") adminIps)}
    deny all;
  '';

  # User allowlist: user IPs + admin IPs (admins see everything)
  # Guests (10.0.0.100-250) are NOT in any allow list → denied.
  userAllowlist = ''
    ${lib.concatStringsSep "\n    " (map (ip: "allow ${ip}/32;") (userIps ++ adminIps))}
    deny all;
  '';

  mkAdminVhost = fqdn: backend: { ... };  # unchanged structure
  mkUserVhost  = fqdn: backend: { ... };  # unchanged structure
in { ... };
```

**Key change from v2:** v2 allowed `10.0.0.0/24` (entire LAN including guests) for user vhosts. v3 explicitly lists only user + admin device IPs. Guests at 10.0.0.100-250 are denied. This is stricter and matches the human ruling "guests get NOTHING on LAN (DNS-only)".

**AdGuard vhost:** `adguard.nanulab.de` uses `mkAdminVhost` → admin IPs only. Unchanged from v2 (already admin-only), just the IP list changes from 10.0.1.8/9 to 10.0.0.3 + 10.0.10.3.

---

## 6. Firewall (`base.nix`)

No changes needed. Ports are unchanged:
- 25/tcp (SMTP), 53/tcp+udp (DNS), 67/udp (DHCP), 80/tcp (HTTP redirect), 443/tcp (nginx TLS), 465/587/993/tcp (mail), 51820/udp (WireGuard).
- `trustedInterfaces = [ "wg0" ]` — unchanged (wg0 is now 10.0.10.0/24 but the interface name is the same).

---

## 7. Secrets (sops) — summary of changes

### Rename (26 keys)
All 13 WG peer secrets: `wireguard_peer_<old-name>_{private,psk}` → `wireguard_peer_<new-hostname>-vpn_{private,psk}`. Values unchanged.

### Edit
`authelia_users_yaml` — add `admin` user entry (bcrypt hash + groups: [admin]).

### No additions, no removals
All other secrets unchanged. `wireguard_server_private` unchanged (server keypair is the same).

---

## 8. Ordered task list for nixos-builder (verbatim-executable)

**Precondition:** human has renamed WG peer keys in sops (or executor does it — see Phase D step). Executor must `nix build .#nixosConfigurations.homelab.config.system.build.toplevel` after each phase and commit per the git-workflow skill. Do NOT deploy until human approves.

### Phase A — `users.nix` + `flake.nix` + `settings.nix`

1. **Create `users.nix`** at repo root with the shape from §1. Include the `blocks` attrset, `users` attrset (10 users with devices/MACs from the task file mapping table), `guests` range, and a `userToIps` helper function. TODO MACs for iza/kerem/hannah. Commit: `users: new users.nix — single source of truth for users/devices/IPs`.

2. **Edit `flake.nix`**: add `users = import ./users.nix;` to `specialArgs` (alongside `settings`). Commit: `flake: pass users attrset via specialArgs`.

3. **Edit `settings.nix`**: 
   - Change `network.wireguard.subnet` to `"10.0.10.0/24"`, `address` to `"10.0.10.2"`.
   - Remove the hardcoded `peers` list from `network.wireguard` (peers are now derived in `wireguard.nix` from `users.nix`).
   - Add a `network.wireguard.peerPublicKeys` attrset mapping hostname → public key (from the table in §3). These are public (safe in git).
   - Remove `network.adminLan` (now derived from `users.nix` in `nginx.nix`).
   - Commit: `settings: WG 10.0.10.0/24, server .2, peer public keys map; remove hardcoded peers + adminLan`.

4. Build + eval. Fix any errors. Commit fixes if needed.

### Phase B — AGH DHCP fix + `adguard.nix`

5. **Edit `modules/networking/adguard.nix`**:
   - Add `{ users, lib, ... }` to the module function args (alongside `settings`).
   - Remove `dhcp.static_leases` entirely from `settings`.
   - Change `dhcpv4.range_start` to `users.guests.lanStart` (`"10.0.0.100"`), `range_end` to `users.guests.lanEnd` (`"10.0.0.250"`).
   - Replace `clients.persistent` with the `users.nix`-derived list (IP-only ids, no hostname ids). Use `lib.mapAttrsToList` + `lib.imap0` + `users.userToIps`.
   - Add `systemd.services.adguardhome.preStart` that writes `leases.json` from `users.nix` (§2). Use `builtins.toJSON` to generate the JSON in Nix, embed it in the script via `echo '${leasesJson}' > "$STATE_DIRECTORY/leases.json"`. Skip devices with `mac == "TODO"`.
   - Commit: `adguard: fix static leases via leases.json (AGH 0.107.78 drops YAML static_leases); v3 persistent clients from users.nix`.

6. Build + eval. Fix errors. Commit fixes.

### Phase C — WireGuard v3 + sops key rename

7. **Edit `modules/networking/wireguard.nix`**:
   - Add `users` to the module function args.
   - Replace the `peers` binding: derive from `users.users` + `users.userToIps` + `settings.network.wireguard.peerPublicKeys` (§3). Each peer: `name = "${dev.hostname}-vpn"`, `ip = ips.vpn`, `admin = userData.tier == "admin"`, `user = userName`, `publicKey = peerPublicKeys.${dev.hostname}`.
   - The `peerSecretAttrs`, `renderPeerBlock`, `userIndexBlock`, `peersByUser` all work unchanged (they read from `peers` which is now derived).
   - Update the WG peer `.conf` template: `Address = ${p.ip}/32` (now 10.0.10.X), `AllowedIPs = 10.0.0.0/24` (unchanged), `DNS = 10.0.0.2` (unchanged).
   - Commit: `wireguard: v3 peers from users.nix, 10.0.10.0/24, hostname-vpn naming`.

8. **Rename sops WG keys** (executor does this):
   - `sops secrets/secrets.yaml`
   - For each of the 13 peers: copy `wireguard_peer_<old-name>_<private|psk>` value to `wireguard_peer_<new-hostname>-vpn_<private|psk>`, then delete the old key.
   - Mapping table (old → new):
     - `dumitru-pc-vpn` → `admin3-vpn`
     - `dumitru-phone-vpn` → `dumitru1-vpn`
     - `adela-phone-vpn` → `adela1-vpn`
     - `adela-tv-vpn` → `adela2-vpn`
     - `adela-air-vpn` → `adela3-vpn`
     - `tiberiu-phone-vpn` → `tiberiu1-vpn`
     - `david-phone-vpn` → `david1-vpn`
     - `david-xbox-vpn` → `david2-vpn`
     - `ramona-phone-vpn` → `ramona1-vpn`
     - `tibisor-phone-vpn` → `tibisor1-vpn`
     - `iza-phone-vpn` → `iza1-vpn`
     - `kerem-phone-vpn` → `kerem1-vpn`
     - `hannah-phone-vpn` → `hannah1-vpn`
   - Commit: `sops: rename WG peer keys to <hostname>-vpn pattern (values unchanged)`.

9. Build + eval. Fix errors. Commit fixes.

### Phase D — Authelia admin user + nginx ACL v3

10. **Edit `secrets/secrets.yaml`** (via `sops`):
    - Edit `authelia_users_yaml`: add `admin` user entry with bcrypt hash + `groups: [admin]`. Generate initial password, store plaintext in `Memory.md`.
    - Commit: `sops: add admin Authelia user (10th account)`.

11. **Edit `modules/networking/nginx.nix`**:
    - Add `users` + `lib` to the module function args.
    - Replace the `adminVpnIps`/`userVpnIps` derivation with the `users.nix`-based derivation from §5.
    - Replace `adminAllowlist`: admin LAN + VPN IPs only (no `settings.network.adminLan` — derived from `users.nix`).
    - Replace `userAllowlist`: user LAN + VPN IPs + admin IPs. **No `allow 10.0.0.0/24`** — guests are denied.
    - `mkAdminVhost`/`mkUserVhost` structure unchanged.
    - AdGuard vhost still uses `mkAdminVhost`.
    - Commit: `nginx: v3 ACL helpers from users.nix — admin/user IP allowlists, guests denied`.

12. Build + eval. Fix errors. Commit fixes.

### Phase E — docs

13. **Edit `OpenCode.md`** per the §10 amendment list. Commit: `docs: OpenCode.md v3 amendments (user blocks, WG 10.0.10.x, AGH leases.json, nginx ACL v3)`.

14. **Edit `README.md`**: update Status (v3 user-block addressing, AGH DHCP fix, WG 10.0.10.x), agent-facing description. Commit: `docs: README v3 status update`.

15. **Edit `Changes.md`**: session entry summarizing v3. Commit: `docs: Changes.md v3 session log`.

16. **Edit `Memory.md`**: update WG section (10.0.10.0/24, new peer names, admin user), Authelia section (10th user `admin`), AGH fix note (leases.json). Commit: `docs: Memory.md v3 updates`.

17. **Edit `TODO.md`**: update iza/kerem/hannah MAC TODO, add "distribute new QR URLs (profile.dnanu.de/<user>/)" and "rename sops keys if executor didn't". Commit: `docs: TODO v3 items`.

18. Final report to human: build result, the §10 OpenCode.md amendment list, the 1%-manual steps (rename sops WG keys if not done by executor → generate admin Authelia password → deploy → distribute new per-user profile URLs → verify AGH leases.json), and the §13 verification commands.

### Explicit non-goals for the executor
- Do NOT deploy (`/deploy`) — human approves the closure first.
- Do NOT create vhosts for services that don't exist yet.
- Do NOT amend OpenCode.md until Phase E (after all code phases build clean).
- Do NOT touch mail, SSH, VPN-confinement, or service modules outside the files listed.
- Do NOT disable SSH password auth.
- No new flake inputs. No containers.

---

## 9. WG peer → sops key → profile page mapping (reference table)

| User | Tier | Hostname | LAN IP | VPN IP | sops key stem | Profile page |
|---|---|---|---|---|---|---|
| admin | admin | admin3 | 10.0.0.3 | 10.0.10.3 | `wireguard_peer_admin3-vpn_{private,psk}` | `/admin/` |
| dumitru | user | dumitru1 | 10.0.0.9 | 10.0.10.9 | `wireguard_peer_dumitru1-vpn_{private,psk}` | `/dumitru/` |
| adela | user | adela1 | 10.0.0.20 | 10.0.10.20 | `wireguard_peer_adela1-vpn_{private,psk}` | `/adela/` |
| adela | user | adela2 | 10.0.0.21 | 10.0.10.21 | `wireguard_peer_adela2-vpn_{private,psk}` | `/adela/` |
| adela | user | adela3 | 10.0.0.22 | 10.0.10.22 | `wireguard_peer_adela3-vpn_{private,psk}` | `/adela/` |
| tiberiu | user | tiberiu1 | 10.0.0.30 | 10.0.10.30 | `wireguard_peer_tiberiu1-vpn_{private,psk}` | `/tiberiu/` |
| david | user | david1 | 10.0.0.40 | 10.0.10.40 | `wireguard_peer_david1-vpn_{private,psk}` | `/david/` |
| david | user | david2 | 10.0.0.41 | 10.0.10.41 | `wireguard_peer_david2-vpn_{private,psk}` | `/david/` |
| ramona | user | ramona1 | 10.0.0.50 | 10.0.10.50 | `wireguard_peer_ramona1-vpn_{private,psk}` | `/ramona/` |
| tibisor | user | tibisor1 | 10.0.0.60 | 10.0.10.60 | `wireguard_peer_tibisor1-vpn_{private,psk}` | `/tibisor/` |
| iza | user | iza1 | 10.0.0.70 | 10.0.10.70 | `wireguard_peer_iza1-vpn_{private,psk}` | `/iza/` |
| kerem | user | kerem1 | 10.0.0.80 | 10.0.10.80 | `wireguard_peer_kerem1-vpn_{private,psk}` | `/kerem/` |
| hannah | user | hannah1 | 10.0.0.90 | 10.0.10.90 | `wireguard_peer_hannah1-vpn_{private,psk}` | `/hannah/` |

---

## 10. OpenCode.md amendment list (deferred — applied in Phase E)

| Section | Change |
|---|---|
| §3.1 | Replace v2 addressing (10.0.0.8-20 / 10.0.1.x) with v3 user-block layout: admin0-2 infra (net/router/homelab, no VPN), admin3-8, dumitru .9-19, adela .20-29, …, hannah .90-99, guests .100-250. WG subnet 10.0.10.0/24, server 10.0.10.2. Note `users.nix` as the single source of truth for IP allocation. |
| §3.3 | Update WG peer naming from `[user]-[device]-vpn` to `[hostname]-vpn` (e.g. `admin3-vpn`, `dumitru1-vpn`). Server is 10.0.10.2 (was 10.0.1.1). Peers derived from `users.nix`. Admin tier = `admin` user (separate from `dumitru` who is now a normal user). |
| §3.4 | AdGuard UI (`adguard.nanulab.de`) = admin IPs only (10.0.0.1-8 + 10.0.10.3-8). LAN devices still use AdGuard as DNS on :53. |
| §7 | Rename WG peer secrets to `wireguard_peer_<hostname>-vpn_{private,psk}`. Add `authelia` admin user (10th). No new secret names. |
| §9 | Mark AdGuard UI as admin-IP-only. Note AGH static leases via `leases.json` (not YAML). |
| §10 | `profile.dnanu.de/<user>/` serves per-user WG peers. `/admin/` serves admin3-vpn; `/dumitru/` serves dumitru1-vpn; etc. Authelia has 10 users (admin + 9 regular). |
| §12 | 1%-manual: rename sops WG keys (if executor didn't); generate admin Authelia password; distribute new profile URLs; fill iza/kerem/hannah MACs in `users.nix`. |
| §13 | Add: `cat /var/lib/AdGuardHome/leases.json | jq '.leases[] | select(.static==true)'` (verify static leases); `wg show` (peers at 10.0.10.x); `curl -I https://profile.dnanu.de/admin/` (admin sees admin3-vpn QR); nginx ACL: guest IP → 403 on all vhosts. |

---

## 11. Risks & rollback

- **Risk: AGH `preStart` can't write to `$STATE_DIRECTORY`.** Mitigation: `DynamicUser = true` + `StateDirectory = "AdGuardHome"` means the service user owns `/var/lib/AdGuardHome/`. The `preStart` runs as the same user. Verified in the NixOS module source. If it fails, the executor will see a permission error in `journalctl -u adguardhome` and can adjust with `serviceConfig.ExecStartPre` instead.

- **Risk: `leases.json` overwrite loses dynamic leases on restart.** Accepted — dynamic leases are transient; devices re-request within seconds. Static leases (the ones we care about) are always re-written from Nix.

- **Risk: WG subnet change (10.0.1.x → 10.0.10.x) breaks existing tunnels.** Mitigation: the server's `wg0` interface gets the new address on rebuild. Existing peer configs (on devices) still point to the old 10.0.1.x addresses — they won't connect until the user scans the new QR. This is expected: the human distributes new QRs as part of the 1%-manual step. Rollback: `git revert` Phase C → old 10.0.1.x config restored.

- **Risk: sops key rename orphans keys / breaks build.** Mitigation: the executor renames keys in sops BEFORE building Phase C. If the build fails because a sops key is missing, the error message names the exact key. Public keys are unchanged (just the sops key names). Rollback: `git revert` + restore old sops keys from git history.

- **Risk: `users.nix` `userToIps` produces wrong IPs.** Mitigation: the derivation is simple arithmetic (`block.lan + idx - 1`). The executor verifies by printing the derived peer list (`nix eval .#nixosConfigurations.homelab.config.networking.wireguard.interfaces.wg0.peers --json` or similar) and checking against the table in §9.

- **Risk: nginx ACL too strict — admin can't reach services.** Mitigation: admin IPs (10.0.0.3 + 10.0.10.3) are in both `adminAllowlist` and `userAllowlist`. If the human's device gets a different IP (e.g. DHCP gives 10.0.0.100 because the static lease didn't take), they're locked out. Mitigation: the AGH `leases.json` fix ensures static leases work. Fallback: SSH into the server and `nixos-rebuild switch` with a temporary `allow 10.0.0.0/24` in the nginx ACL.

- **Risk: TODO MACs for iza/kerem/hannah cause issues.** Mitigation: `mac = "TODO"` entries are skipped by the `leases.json` renderer (no DHCP lease). The WG peer is still created (VPN works without a LAN lease). When the human fills the real MAC, the lease appears on next rebuild. No error, no bogus lease.

- **Rollback (overall):** `git revert` the v3 commits → previous generation (v2, 10.0.1.x, shared basic auth on profile.nanulab.de) is restored. The server's boot menu also retains the previous generation. sops key renames are in git history (secrets.yaml is encrypted but version-controlled).

---

*(Plan ends. No code was modified; no commits created.)*
