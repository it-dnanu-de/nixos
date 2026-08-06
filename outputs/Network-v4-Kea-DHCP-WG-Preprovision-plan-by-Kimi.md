# Network v4 — Kea DHCP migration + 97-peer WG pre-provision + `[user]1-9` naming — implementation plan
**Planner:** Kimi K3 (planner-max) · **Executor:** nixos-builder (DeepSeek V4 Pro) · **Date:** 2026-08-06
**Task file:** `inputs/Network-v4-Kea-DHCP-WG-Preprovision-for-Kimi.md` · **Addressing authority:** `docs/network-addressing.md` (v4, human-authored)

---

## §0 Verified facts (checked against pinned `nixos-26.05`, evidence inline)

### 0.1 Kea module — ⚠️ VERIFY result: **OPTION NAMES DIFFER FROM TASK TEXT**

The task file and human rulings say `services.kea.dhcp4-server` / `services.kea.dhcp6-server`. **Those option names do not exist.** Verified in the pinned module
`nixos/modules/services/networking/kea.nix` (registered in `module-list.nix:1263`):

| What | Pinned 26.05 reality | Evidence |
|---|---|---|
| NixOS options | `services.kea.dhcp4.{enable,settings,configFile,extraArgs}` and `services.kea.dhcp6.{…}` — **no `-server` suffix** | `kea.nix:82` (`dhcp4 = lib.mkOption …`), `kea.nix:147` (`dhcp6 = …`) |
| systemd units | `kea-dhcp4-server.service`, `kea-dhcp6-server.service` (suffix lives **only** here) | `kea.nix:367`, `kea.nix:424` |
| Settings format | freeform JSON attrset wrapped under top-level `Dhcp4` / `Dhcp6` key; `settings` XOR `configFile` (assertion) | `kea.nix:21-25`, `kea.nix:358-363` |
| Unit hardening | `DynamicUser=true`, `User=kea`, `StateDirectory=kea` → leases at `/var/lib/kea/dhcp4.leases` writable | `kea.nix:276-291` (module example uses exactly this path, `kea.nix:125`) |
| Capabilities | dhcp4 gets `CAP_NET_BIND_SERVICE`+`CAP_NET_RAW`; dhcp6 `CAP_NET_BIND_SERVICE` | `kea.nix:401-408`, `458-463` |
| ctrl-agent / dhcp-ddns | exist, **not used** (no REST/DDNS surface — security posture) | `kea.nix:43`, `kea.nix:213` |
| Package | `pkgs.kea` = **3.0.3** ("only even minor versions are stable") | `pkgs/by-name/ke/kea/package.nix` |

**Plan correction (executor: use these, not the task text):** `services.kea.dhcp4.enable/settings` and `services.kea.dhcp6.enable/settings`. Kea 3.0.3 accepts the standard ARM v3 schema used below (`interfaces-config`, `lease-database` memfile, `subnet4[].reservations[]` with `hw-address`/`ip-address`/`hostname`, option names `routers`, `domain-name-servers`, `domain-name`, v6 `dns-servers`, `domain-search`).

### 0.2 nginx module — ✅ verified
A vhost with `addSSL = true` and no explicit `listen` listens on **both** `0.0.0.0:443` (ssl) and `0.0.0.0:80`; `default = true` emits `default_server` on its listen lines (`nginx/default.nix:335-360`, `:380`). SSL listeners exist iff `forceSSL || addSSL || onlySSL` (`:336`). Two `default_server`s on *different sockets* (e.g. `127.0.0.1:8080` for `dnanu.de` and `0.0.0.0:443` for the catch-all) coexist legally. The NixOS nginx module also runs `nginx -t` at build time (`checkConfig` default true) → Phase C build is a real syntax gate.

### 0.3 Local tooling — ✅ verified on this machine
`sops 3.13.3` with **`set` and `unset` subcommands present**; `wg` (`/usr/bin/wg`), `qrencode`, `jq` all installed; age key at `~/.config/sops/age/keys.txt` (Memory.md). No `nix shell` wrapper needed.

### 0.4 Current sops state — ✅ verified by reading `secrets/secrets.yaml` key names (values untouched)
**26 peer keys exist** (13 peers × 2), all in v3 naming: `admin3-vpn`, `dumitru1-vpn`, `adela1/2/3-vpn`, `tiberiu1-vpn`, `david1/2-vpn`, `ramona1-vpn`, `tibisor1-vpn`, `iza1-vpn`, `kerem1-vpn`, `hannah1-vpn` (+`wireguard_server_private`).

**Arithmetic correction to the task file:** task says "10 reused, 87 new". Reality: **13 existing keypairs** (10 real-MAC + iza/kerem/hannah whose keypairs already exist despite TODO MACs) are **renamed, values preserved**; **84 are generated fresh**. 13 + 84 = **97 peers** ✓ · 97 × 2 = **194 sops keys** ✓.

### 0.5 DHCPv6 strategy — decision (SLAAC vs stateful), with reasoning
**Decision: GUA by SLAAC (Speedport RA) + stateful ULA pool by Kea dhcp6 + v6 DNS = ULA of the server.**
- The Speedport owns the Telekom prefix and **cannot stop sending RAs** (§3.5 LOCKED: IPv6 stays on; UI can't fully disable v6). Clients will SLAAC a GUA no matter what we declare — fighting that with "stateful-only GUA" requires RA flag control we don't have. Accept SLAAC for GUA.
- Telekom renumbers prefixes on reconnect → a GUA-based DNS address is fragile. A **ULA is ours forever**. Assign the server `fd10::2/64` statically; Kea dhcp6 serves pool `fd10::100 - fd10::200` (mirrors the v4 guest pool, memorable) and option `dns-servers = fd10::2`, `domain-search = lan`.
- This satisfies the human's "v6 assignment ability" (Kea genuinely assigns stateful ULA addresses, reservations possible later via DUID) with zero dependence on Telekom.
- Android ignores DHCPv6 entirely → covered by v4 DNS (10.0.0.2 from Kea dhcp4) + accepted `fe80::1` RDNSS noise (§3.5).
- **Coexistence:** if the Speedport's DHCPv6 server can't be disabled, it serves only the Telekom GUA namespace; Kea serves only ULA. No harmful conflict — both hand out DNS that ultimately lands on AdGuard. Disabling Speedport DHCPv6 remains the preferred 1% step.
- Server SLAAC survival: we do **not** enable v6 forwarding (`net.ipv4.ip_forward=1` is v4-only, unaffected) → `accept_ra=1` works. Plan adds it explicitly as belt-and-braces, since a static v6 address entry must not cost the server its GUA (outbound v6 is needed for mail, §3.5).

### 0.6 Dead-name `profile.nanulab.de` — decision
Wildcard rewrite `*.nanulab.de → 10.0.0.2` **stays** (adguard.nanulab.de + all future services need it). The fall-through bug is nginx's: with one 443 vhost, any unmatched nanulab name implicitly defaults to the AdGuard dashboard (and any :80 Host gets redirected to adguard — same bug, port 80). **Fix: explicit catch-all vhost** — `addSSL`, `default = true`, `useACMEHost = *.nanulab.de` wildcard cert (valid for any single-label sub), `return 404` on `/`. Dead names get a valid-cert 404 instead of leaking the dashboard. Unmatched `*.dnanu.de` names can't resolve on LAN (no rewrite, no public A records) → catch-all is practically nanulab-only.

---

## §1 `users.nix` v4 design (full replacement of the file)

Structure (same `rec` shape; `userToIps` **byte-identical** to v3 per ruling):

```nix
rec {
  blocks = {
    admin   = { lan = 0;  vpn = 0;  };   # .0-.9 (see roles below)
    dumitru = { lan = 10; vpn = 10; };
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
        { hostname = "admin";  mac = null;  role = "infra";  note = "network address"; }            # .0
        { hostname = "admin1"; mac = null;  role = "infra";  note = "router (Speedport)"; }         # .1
        { hostname = "admin2"; mac = null;  role = "server"; note = "dell homelab = WG server 10.0.10.2"; } # .2
        { hostname = "admin3"; mac = "2c:9c:58:60:c8:25"; note = "Arch PC"; }                       # .3
        { hostname = "admin4"; mac = "TODO"; }  # … through …
        { hostname = "admin9"; mac = "TODO"; }                                                      # .9
      ];
    };
    dumitru = { tier = "user"; devices = [
      { hostname = "dumitru";  mac = "f6:5b:6b:f3:0e:87"; note = "iPhone 17 Pro"; }  # base @ .10
      { hostname = "dumitru1"; mac = "TODO"; } # … through dumitru9 @ .19
    ]; };
    adela = { tier = "user"; devices = [
      { hostname = "adela";  mac = "fe:02:26:df:0c:50"; note = "iPhone XS"; }      # .20
      { hostname = "adela1"; mac = "00:c3:f4:ea:fe:a6"; note = "Samsung TV"; }     # .21 (MAC per ruling A2)
      { hostname = "adela2"; mac = "68:79:c4:29:1d:44"; note = "Philips Air"; }    # .22
      { hostname = "adela3"; mac = "TODO"; } # … through adela9 @ .29
    ]; };
    tiberiu = { tier = "user"; devices = [
      { hostname = "tiberiu"; mac = "da:08:7b:fe:cf:d7"; note = "Galaxy S22U"; }   # .30
      { hostname = "tiberiu1"; mac = "TODO"; } # … tiberiu9
    ]; };
    david = { tier = "user"; devices = [
      { hostname = "david";  mac = "76:6f:b2:93:10:ce"; note = "iPhone 17 Pro Max"; } # .40
      { hostname = "david1"; mac = "c4:9d:ed:c9:9a:13"; note = "Xbox One"; }          # .41 (MAC per ruling A2)
      { hostname = "david2"; mac = "TODO"; } # … david9
    ]; };
    ramona  = { tier = "user"; devices = [ { hostname = "ramona";  mac = "56:ea:b4:79:06:61"; note = "iPhone 11"; } { hostname = "ramona1"; mac = "TODO"; } /*…ramona9*/ ]; };
    tibisor = { tier = "user"; devices = [ { hostname = "tibisor"; mac = "26:05:a5:6c:e2:56"; note = "iPhone 14"; } { hostname = "tibisor1"; mac = "TODO"; } /*…tibisor9*/ ]; };
    iza     = { tier = "user"; devices = [ { hostname = "iza";     mac = "TODO"; note = "iPhone 15"; }      { hostname = "iza1";     mac = "TODO"; } /*…iza9*/     ]; };
    kerem   = { tier = "user"; devices = [ { hostname = "kerem";   mac = "TODO"; note = "iPhone 16 Pro"; }  { hostname = "kerem1";   mac = "TODO"; } /*…kerem9*/   ]; };
    hannah  = { tier = "user"; devices = [ { hostname = "hannah";  mac = "TODO"; note = "iPhone 15 Pro"; }  { hostname = "hannah1";  mac = "TODO"; } /*…hannah9*/  ]; };
  };

  guests = { lanStart = "10.0.0.100"; lanEnd = "10.0.0.200"; };   # v4: .201-.254 unassigned

  userToIps = userName: idx:    # UNCHANGED (block + idx-1)
    let block = blocks.${userName};
    in { lan = "10.0.0.${toString (block.lan + idx - 1)}";
         vpn = "10.0.10.${toString (block.vpn + idx - 1)}"; };

  # ── v4 helpers (single derivation point, consumed by wireguard/kea/adguard/nginx + gen script) ──
  isPeer = dev: (dev.role or "device") == "device";

  # All WG peers: every role=="device" entry → 7 admin (admin3-9) + 90 user = 97.
  wgPeers = lib-free-flatten-map over users:   # implement with builtins + lib via flake specialArgs…
    { hostname = dev.hostname; name = "${dev.hostname}-vpn"; ip = ips.vpn; lan = ips.lan;
      user = userName; admin = userData.tier == "admin"; };
  wgPeerNames = map (p: p.name) wgPeers;                       # 97 entries, sorted by block order

  # DHCP reservations: real MACs only → exactly 10:
  # admin3 .3 · dumitru .10 · adela .20 · adela1 .21 · adela2 .22 · tiberiu .30
  # david .40 · david1 .41 · ramona .50 · tibisor .60
  dhcpReservations = flatten-filter (isPeer && mac != "TODO" && mac != null):
    { inherit (dev) hostname mac; ip = ips.lan; };
}
```

Implementation notes for the executor:
- `users.nix` is imported as a plain value (`specialArgs`); it may use `lib` only if passed — **it currently isn't**. Write the flatten/imap0 logic with `builtins` only (`builtins.attrNames`, `builtins.map`, `builtins.filter`, `builtins.concatLists`, `builtins.genList`) or accept `{ lib ? null }` — simplest: keep the v3 pattern (no `lib` import needed in v3 file; mirror that with pure builtins).
- Generating 10 devices per user by hand is 100 lines of tedium; acceptable and **preferred** (human edits this file — explicit beats clever). Each spare = one line `{ hostname = "dumitru7"; mac = "TODO"; }`.
- Every consumer that today does its own `imap0` over `users.users` must switch to the helpers (or add `isPeer` filtering) — see §4/§5/§2.

---

## §2 Kea config design — new `modules/networking/kea.nix`

```nix
# Kea DHCP — LAN DHCPv4 + DHCPv6 (Decision B, 2026-08-06). AGH is DNS-only.
# Options verified against pinned nixos-26.05: services.kea.dhcp4 / services.kea.dhcp6
# (NOT dhcp4-server — that suffix is only in systemd unit names). Kea 3.0.3.
{ settings, users, ... }:
{
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config.interfaces = [ settings.network.interface ];
      lease-database = { type = "memfile"; persist = true; name = "/var/lib/kea/dhcp4.leases"; };
      valid-lifetime = 86400; renew-timer = 43200; rebind-timer = 75600;
      option-data = [
        { name = "routers";             data = settings.network.gateway; }   # 10.0.0.1
        { name = "domain-name-servers"; data = settings.network.address; }   # 10.0.0.2 (AGH)
        { name = "domain-name";         data = "lan"; }
      ];
      subnet4 = [{
        id = 1;
        subnet = settings.network.subnet;                                     # 10.0.0.0/24
        pools = [{ pool = "${users.guests.lanStart} - ${users.guests.lanEnd}"; }]; # .100-.200
        reservations = map (r: {
          hw-address = r.mac; ip-address = r.ip; hostname = r.hostname;
        }) users.dhcpReservations;                                            # 10 entries
      }];
    };
  };

  services.kea.dhcp6 = {
    enable = true;
    settings = {
      interfaces-config.interfaces = [ settings.network.interface ];
      lease-database = { type = "memfile"; persist = true; name = "/var/lib/kea/dhcp6.leases"; };
      valid-lifetime = 86400; preferred-lifetime = 43200;
      subnet6 = [{
        id = 1;
        subnet = "fd10::/64";                                                 # ULA — ours, Telekom-proof
        pools = [{ pool = "fd10::100 - fd10::200"; }];
        option-data = [
          { name = "dns-servers";  data = "fd10::2"; }                        # AGH on ULA
          { name = "domain-search"; data = "lan"; }
        ];
        # NO v6 reservations: DUID churn makes them brittle; identity lives in v4 reservations.
      }];
    };
  };
}
```

Companion changes:
- **`base.nix`**: add `ipv6.addresses = [{ address = "fd10::2"; prefixLength = 64; }]` to `enp10s0`; add `boot.kernel.sysctl."net.ipv6.conf.${settings.network.interface}.accept_ra" = 1;` (keep SLAAC GUA for outbound/mail; we do NOT enable v6 forwarding, so accept_ra=1 is honored); firewall `allowedUDPPorts` += `547` (dhcpv6-server), keep `67`; fix stale comment (`profile.nanulab.de` → `profile.dnanu.de`; DHCP is Kea now).
- **`adguard.nix`**: delete the entire `dhcp = {…}` settings block; delete `staticLeases`/`leasesJson` lets and the `systemd.services.adguardhome.preStart` writer; `dns.bind_hosts = [ "0.0.0.0" "::" ]` (answer v6/ULA queries); `clients.runtime_sources.dhcp = false` (no AGH lease DB to read anymore — guest labels degrade to IP-only via rdns; accepted, documented); persistent clients rebuilt from `isPeer`-filtered devices (admin ids = .3-.9 + 10.0.10.3-.9; users = their 10 lan + 10 vpn each) **plus one static `infra` client**: `{ name = "infra"; ids = [ "10.0.0.1" "10.0.0.2" "10.0.10.2" ]; tags = [ "user_admin" ]; use_global_settings = true; }` (router+server labeled in dashboard; planner decision, cheap and tidy).
- **`configuration.nix`**: add `../../modules/networking/kea.nix` to imports.
- Kea needs no firewall comment for internet exposure: 67/547 are LAN-side behind router NAT (router forwards only 25/tcp + 51820/udp — §3.2 unchanged). ctrl-agent and dhcp-ddns stay **off** (no REST/DDNS surface).

---

## §3 97-peer keygen — idempotent scripted approach

New committed script **`scripts/gen-wg-keys.sh`** (bash, `set -euo pipefail`, no secrets in repo — logic only). Run by executor **on this machine** (age key + sops + wg all present, §0.3).

**Algorithm:**
1. `cd` to repo root (script dir/..). `export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"`.
2. Peer list from the source of truth: `nix eval --raw --impure --expr 'builtins.concatStringsSep "\n" (import ./users.nix).wgPeerNames'` → 97 names. (Guard: count must equal 97, else abort.)
3. **Pass 1 — v3→v4 rename (order-independent two-pass; preserves values):**
   Rename table (12 pairs; `admin3-vpn` unchanged):
   ```
   dumitru1-vpn→dumitru-vpn  adela1-vpn→adela-vpn  adela2-vpn→adela1-vpn  adela3-vpn→adela2-vpn
   tiberiu1-vpn→tiberiu-vpn  david1-vpn→david-vpn  david2-vpn→david1-vpn  ramona1-vpn→ramona-vpn
   tibisor1-vpn→tibisor-vpn  iza1-vpn→iza-vpn      kerem1-vpn→kerem-vpn   hannah1-vpn→hannah-vpn
   ```
   Hazard: target names (`adela1-vpn`) are also source names → **two-pass** design removes all ordering risk:
   - 1a: for each pair×suffix(`private`,`psk`): if old key exists **and** new key missing → `sops decrypt --extract` old into a `mktemp -d` (umask 077, `trap 'rm -rf'` EXIT) file named by new key.
   - 1b: write each staged value: `sops set secrets/secrets.yaml '["wireguard_peer_<new>_<suffix>"]' "$(cat staged | jq -Rs .)"` (value must be JSON-encoded — `jq -Rs .` does it safely).
   - 1c: `sops unset` the old keys. (sops 3.13.3 `unset` verified present, §0.3.)
   - Idempotent: re-run finds no old keys → all three sub-passes no-op. Partial-failure recovery: staged-extract is re-derivable; `set` skips existing news.
4. **Pass 2 — generate missing:** for each of 97 names × {`private`,`psk`}: if `sops decrypt --extract '["wireguard_peer_<n>_<s>"]'` fails or is empty/`PLACEHOLDER` → generate (`wg genkey` / `wg genpsk`, captured in a shell var, never echoed) → `sops set … "$(printf %s "$v" | jq -Rs .)"`. Never overwrites an existing value.
5. **Pass 3 — public keys:** for each peer: `priv=$(sops decrypt --extract …_private)` → `wg pubkey <<<"$priv"` → accumulate `hostname = "pub";` lines (hostname = peername minus `-vpn`) → write **`wireguard-pubkeys.nix`** (repo root) atomically (tmp+mv), header `# GENERATED by scripts/gen-wg-keys.sh — do not hand-edit`. Deterministic → idempotent. Public keys are not secret; file is committed.
6. Final self-check: key count in secrets.yaml = 194 + server + non-WG keys; pubkeys file = 97 entries; print counts only (never values).

**sops CLI syntax verified locally:** `sops set <file> '<jsonpath>' '<json-value>'` · `sops unset <file> '<jsonpath>'` · `sops decrypt --extract '<jsonpath>' <file>`. `.sops.yaml` creation rule already covers `secrets/secrets.yaml` — re-encryption on set/unset needs no config change.

**Executor pre-flight + gates (must pass before Phase A build):**
```bash
bash scripts/gen-wg-keys.sh
sops decrypt secrets/secrets.yaml | grep -c '^wireguard_peer_'        # expect 194
grep -c 'vpn.*=$' wireguard-pubkeys.nix || nix eval --impure --expr \
  'builtins.length (builtins.attrNames (import ./wireguard-pubkeys.nix))'   # expect 97
```

---

## §4 `settings.nix` / `wireguard.nix` v4

**settings.nix:** replace the hand-written 13-entry `peerPublicKeys` attrset with
`peerPublicKeys = import ./wireguard-pubkeys.nix;` (97 entries, generated). Update comments: admin block `.0-.9` (admin0 net / admin1 router / admin2 server / admin3-9 devices), user bases `.10/.20/.../.90`, naming `[user]`+`[user]1-9`, dumitru moved `.9→.10`.

**wireguard.nix:**
- Replace the inline `peers` derivation with `peers = users.wgPeers;` (single derivation point in users.nix).
- **Strict public-key lookup:** `publicKey = wgSettings.peerPublicKeys.${p.hostname};` — delete the `or "REPLACE_ME"` fallback. With generated pubkeys covering all 97 peers, a missing key is an authoring bug and must fail at **eval time**, not silently render a broken peer that kills `wg` at runtime.
- sops secret attr derivation, interface config, and the per-user renderer are already generic over `peers`/`peersByUser` → **no structural change**; renderer automatically emits 7 QRs for `admin` (admin3-9-vpn) and 10 per user. Keep `persistentKeepalive = 25` (harmless; only active while a peer is connected).
- 97 peers on `wg0`: negligible kernel cost; activation restarts `wireguard-wg0.service` → sub-second VPN blip for connected peers (only during deploy).

---

## §5 nginx ACL v4 (`modules/networking/nginx.nix`)

- Derive allowlists from `isPeer`-filtered devices (admin devices → LAN `.3-.9` + VPN `10.0.10.3-9`; user devices → LAN `.10-.99` + VPN `.10-.99`).
- Keep the explicit lines (ruling "include router+dell? → **yes**, unchanged from v3"):
  `allow 10.0.0.1/32;  # router` · `allow 10.0.0.2/32;  # homelab` in both lists.
- Result matches ruling exactly: admin vhosts = LAN `.1-.9` + VPN `10.0.10.3-9`; user vhosts = LAN `.1-.99` (`.1`/`.2` explicit + `.3-.9` admin + `.10-.99` user) + VPN `10.0.10.3-99`; guests `.100-.200` fall to `deny all;`. Per-IP `/32` lines (~214 per vhost) — guest range isn't CIDR-aligned, per-IP derivation is self-updating; nginx handles this fine.
- **Catch-all (dead-name fix, §0.6):**
  ```nix
  virtualHosts."catchall" = {
    serverName = "_";
    default = true;            # default_server on 0.0.0.0:443 + :80
    addSSL = true;             # listen 80 AND 443 (no redirect)
    useACMEHost = settings.domains.internal;   # *.nanulab.de wildcard — valid cert for any sub
    locations."/".return = "404";
  };
  ```
  The existing `dnanu.de` vhost keeps `default = true` on its own `127.0.0.1:8080` socket — different socket, no conflict (§0.2). Build-time `nginx -t` is the gate.
- No changes to `ios-profile.nix` / `authelia.nix` (verify-only in Phase C: confirm per-user root still maps Authelia user → `/var/lib/mobileprofile/wg/<user>/` with 7/10-row index pages).

---

## §6 Authelia / profile pages
10 users unchanged; `admin` maps to the `admin` peer group → `/admin/` shows **7** QRs (admin3-9-vpn), `/dumitru/` shows **10** (dumitru-vpn + dumitru1-9-vpn), etc. Renderer + vhost already implement this generically — Phase C confirms by inspecting rendered output in the built closure (or post-deploy). Spare slots (MAC=TODO) still get QRs — by design (Q-B): a new device = fill MAC in users.nix → rebuild → lease appears; its QR was already printable.

---

## §7 Dead-name handling — summary
1. AGH wildcard rewrite `*.nanulab.de → 10.0.0.2` **kept** (adguard + future services).
2. nginx catch-all `default_server` (80+443, wildcard cert, `404`) — kills the adguard-dashboard fall-through on **both** ports.
3. `profile.nanulab.de` → resolves (wildcard) → TLS OK → **404**. Nothing else references it (only a stale comment in `base.nix`, fixed in Phase B).

---

## §8 Ordered task list for nixos-builder (execute verbatim; one commit per phase; build gate each)

Common: `source ~/.nix-profile/etc/profile.d/nix.sh` if needed; build = `nix build .#nixosConfigurations.homelab.config.system.build.toplevel` from repo root. **Do NOT deploy** — human approves after plan + build review.

### Phase A — users.nix v4 + keygen + settings/wireguard v4
1. Rewrite `users.nix` per §1 (all 100 device entries explicit; helpers `isPeer`/`wgPeers`/`wgPeerNames`/`dhcpReservations` in pure builtins; `userToIps` unchanged; `guests.lanEnd = "10.0.0.200"`).
2. Write `scripts/gen-wg-keys.sh` per §3 (two-pass rename w/ staged tempdir + trap, idempotent generate, atomic pubkey-file write; `chmod +x`).
3. Run gates from §3: script executes clean; **194** peer keys; **97** pubkeys; `nix eval --impure --expr 'builtins.length (import ./users.nix).wgPeerNames'` → `97`; `…dhcpReservations` length → `10`.
4. `settings.nix`: `peerPublicKeys = import ./wireguard-pubkeys.nix;` + comment refresh (§4).
5. `wireguard.nix`: `peers = users.wgPeers;` + strict pubkey lookup (§4).
6. **Build** → exit 0. Sanity: `nix eval .#nixosConfigurations.homelab.config.networking.wireguard.interfaces.wg0.peers --apply builtins.length` → `97`.
7. **Commit:** `network v4 phase A: users.nix [user]1-9 schema, 97-peer WG pre-provision (13 renamed/84 new), generated pubkeys`
   *Security:* script stages plaintext keys only in a 0700 tmpfs dir with trap-cleanup; secrets.yaml stays encrypted; pubkeys file is public-safe. *Rollback:* `git revert` + sops file is in git (encrypted) — old keys recoverable.

### Phase B — Kea DHCP migration (Decision B)
1. New `modules/networking/kea.nix` per §2 (exact option names `services.kea.dhcp4`/`dhcp6` — §0.1).
2. `configuration.nix`: import it.
3. `adguard.nix`: remove `dhcp` block + leases.json preStart + staticLeases lets; `bind_hosts` += `"::"`; `runtime_sources.dhcp = false`; persistent clients via `isPeer` + `infra` entry (§2).
4. `base.nix`: ULA `fd10::2/64`, accept_ra sysctl, UDP 547, comment fixes (§2).
5. **Build** → exit 0. Gates: `nix eval .#…config.services.kea.dhcp4.enable` → `true`; reservations in built subnet4 = 10 (`nix eval .#…config.services.kea.dhcp4.settings.subnet4 --apply 's: builtins.length (builtins.head s).reservations'`); AGH settings no longer contain `dhcp` (`nix eval .#…config.services.adguardhome.settings --apply 's: s ? dhcp'` → `false`).
6. **Commit:** `network v4 phase B: Kea DHCPv4+DHCPv6 (ULA fd10::/64), AdGuard DNS-only`
   *Security:* no new internet surface (67/547 LAN-side; router still forwards only 25+51820); ctrl-agent/DDNS off. *Risk:* Speedport DHCPv4 must be OFF at deploy or two servers race (human step, §10); rollback = boot previous generation (AGH DHCP config preserved in git history).

### Phase C — nginx ACL v4 + dead-name catch-all
1. `nginx.nix`: ACL derivations via `isPeer`; keep explicit `.1`/`.2` allows; add catch-all vhost (§5).
2. Verify-only: `ios-profile.nix`/`authelia.nix` unchanged and consistent with §6.
3. **Build** → exit 0 (nginx `-t` runs at build, §0.2).
4. **Commit:** `network v4 phase C: nginx ACL v4 ([user]1-9 blocks), catch-all 404 for unmatched names`
   *Security:* catch-all removes information leak (dashboard on dead names); guest range stays deny-by-default.

### Phase D — docs (§9 list)
1. Apply every OpenCode.md amendment from §9; README status; TODO.md; Changes.md session log; Memory.md (v4 facts: naming, 97 peers/rename map, Kea option-name correction, ULA `fd10::/64`, iPhone-must-leave-manual-IP, AGH-DHCP-retired, sops `set`/`unset` workflow).
2. **Commit:** `network v4 phase D: docs — OpenCode/README/TODO/Changes/Memory`

### Phase E — final gate + report (no deploy)
1. Full clean build exit 0, zero new warnings.
2. Re-run every gate from A/B/C; paste results table.
3. Confirm deliverables 1-8 from the task file are each covered; report to human with the §10 deploy runbook. **Stop here.**

---

## §9 OpenCode.md amendment list (Phase D edits these spots)
- **§3.1:** AdGuard = DNS-only; **Kea** is LAN DHCP (dhcp4 + dhcp6). Addressing table → v4: admin `.0-.9` (roles), user bases `.10-.90` step 10 with `[user]`+`[user]1-9`, guests `.100-.200`, `.201-.254` unassigned. Speedport: DHCPv4 disabled; DHCPv6 disabled-if-possible (else harmless coexistence — Kea serves only ULA). Server also holds ULA `fd10::2/64`.
- **§3.3:** peers = **97** (7 admin `admin3-9-vpn` + 90 user `[user]-vpn`/`[user]1-9-vpn`), **194 sops keys**; full pre-provision (spare slots: MAC=TODO, QR pre-rendered; claim = fill MAC + rebuild); keys provisioned by `scripts/gen-wg-keys.sh` (idempotent); pubkeys in generated `wireguard-pubkeys.nix`.
- **§3.4:** AGH DNS-only (rewrites/filters/persistent clients; `runtime_sources.dhcp` off); nginx catch-all returns **404** for unmatched `*.nanulab.de` (incl. dead `profile.nanulab.de`); AdGuard UI still admin-tier.
- **§3.5:** add: Kea dhcp6 stateful ULA pool `fd10::100-200`, v6 DNS = `fd10::2`; GUA via SLAAC unchanged.
- **§7:** secrets inventory — WG keys now `wireguard_peer_<hostname>-vpn_{private,psk}` × 97 = **194**; naming `[user]-vpn`/`[user]1-9-vpn`.
- **§9 service map:** add **Kea** (`services.kea.dhcp4`/`dhcp6` — note the option names carry no `-server` suffix); AdGuard row → "DNS-only (DHCP retired to Kea)".
- **§10:** profile pages list ALL of a user's slots (admin 7, users 10); spare QRs pre-rendered.
- **§12 runbook:** 1% manual additions — disable Speedport DHCPv4 (+DHCPv6 if UI allows); **switch dumitru iPhone off manual 10.0.0.3 → DHCP** (Kea reservation hands it 10.0.0.10); re-scan ALL WG QRs post-deploy (v4 names+IPs; deployed gen45 is still v2 10.0.1.x so every device re-imports anyway); optional `rm /var/lib/AdGuardHome/leases.json` (stale, harmless).
- **§13 verification:** add — `systemctl status kea-dhcp4-server kea-dhcp6-server`; arch lease = `10.0.0.3`, iPhone = `10.0.0.10`, Xbox = `10.0.0.41`, TV = `10.0.0.21` (Kea leases/`journalctl -u kea-dhcp4-server`); fresh guest ∈ `.100-.200`; `dig @fd10::2 cloud.nanulab.de` → `10.0.0.2`; `curl -k https://profile.nanulab.de` → **404**; `wg show` lists 97 peers; AGH query log still labels 10.0.10.x by device name. Remove leases.json check (Kea era).

---

## §10 Risks & rollback

| # | Risk | Mitigation / rollback |
|---|---|---|
| 1 | **Option-name trap** (`dhcp4-server` doesn't exist) | §0.1 evidence; executor uses `services.kea.dhcp4`/`dhcp6`. Eval fails loudly otherwise — caught at build gate. |
| 2 | sops-nix **activation fails** if any of 194 keys absent (render runs pre-activation) | Phase A gates: count=194 **before** any build; renderer's MISSING logic is only a secondary net. |
| 3 | Rename clobbering (`adela2-vpn→adela1-vpn` while `adela1-vpn` still holds the iPhone key) | Two-pass staged rename (§3.1a-c) is order-independent + idempotent; values only ever copied old→new when new is absent. |
| 4 | **DHCP race at deploy** (Speedport v4 server still on, or old gen's AGH DHCP overlap) | `nixos-rebuild switch` restarts AGH without DHCP in seconds; human pre-step: Speedport DHCPv4 OFF. Rollback: boot previous generation; worst case human re-enables Speedport DHCP (5 min) — documented §12. |
| 5 | dumitru iPhone stuck on **manual 10.0.0.3** → IP conflict with arch's reservation | Human step at deploy (§12): set iPhone to DHCP → gets 10.0.0.10. Until then arch and iPhone must not be on LAN together. |
| 6 | iOS **Private Wi-Fi Address** rotation breaks MAC reservation → device lands in guest pool (internet OK, services 403) | Pre-existing model risk (unchanged from v3). Fix path: disable rotation for this SSID or update MAC in users.nix. Documented in Memory.md. |
| 7 | Server loses SLAAC GUA after adding static ULA (would break outbound v6/mail) | Explicit `accept_ra=1` sysctl; no v6 forwarding enabled; post-deploy check `ip -6 addr show enp10s0` shows dynamic GUA + `fd10::2`. |
| 8 | Catch-all `default_server` grabs a name it shouldn't | server_name matching still wins for all real vhosts (adguard, profile); catch-all only receives unmatched names. `nginx -t` + build gate. |
| 9 | Speedport DHCPv6 **can't** be disabled → two v6 servers | Harmless by design (§0.5): disjoint namespaces (GUA vs ULA), both DNS answers → AdGuard. |
| 10 | 97-peer churn bugs (wg restart blip, renderer runtime ~seconds for 97 qrencodes) | Oneshot renderer is `RemainAfterExit`, runs at activation; blip only during deploy; peers idle-drop nothing (WG stateless). |
| 11 | Whole-plan abort | Every phase is a separate commit; `git revert` per phase; secrets.yaml encrypted history preserves all key material; AGH-DHCP config recoverable from git. |

**Deploy runbook (human, post-approval):** `/deploy` → then §12 steps (iPhone DHCP, Speedport checks, QR re-scans) → `/verify` with §13 additions.

---

*Plan ends. Executor: phases A→E in order, one commit each, build gates green before moving on. Questions → escalate to human, do not improvise outside locked rulings.*
