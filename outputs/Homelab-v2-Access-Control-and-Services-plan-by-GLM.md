# Plan: Homelab v2 — two-tier VPN access control, re-addressing, profile.dnanu.de + Authelia

**Author:** GLM 5.2 (architect) · 2026-08-06 · **For:** DeepSeek-V4-Pro (execution)
**Task source:** `inputs/Homelab-v2-Access-Control-and-Services-for-GLM.md`
**Status:** planning only — no code changed, no commits made. OpenCode.md is NOT amended in this task (amendment list in §9, applied after approval).

---

## 0. Verified facts against pinned `nixos-26.05`

Checked directly in the pinned channel checkout (`nixpkgs@nixos-26.05`):

| Thing | Status | Evidence |
|---|---|---|
| `services.authelia.instances.<name>` module | ✅ verified | `nixos/modules/services/security/authelia.nix` — attrsOf submodule; per-instance `enable`, `package`, `user`, `group`, `secrets.{manual,jwtSecretFile,storageEncryptionKeyFile,sessionSecretFile,oidcHmacSecretFile,oidcIssuerPrivateKeyFile}`, `environmentVariables`, `settings` (freeform YAML + typed `theme`, `default_2fa_method ∈ {totp,webauthn,mobile_push}`, `server.address`, `log.*`, `telemetry.metrics.*`), `settingsFiles`. StateDirectory auto-created under `/var/lib/authelia-<name>/`. Systemd unit hardens (ProtectSystem=strict, NoNewPrivileges, etc.). Assertion forces jwtSecret + storageEncryptionKey unless `secrets.manual=true`. |
| Authelia user DB (file auth) | ✅ upstream | `authentication_backend.file.path` + `users.yaml` format (hashed bcrypt passwords, TOTP/Webauthn secrets per user). The file is rendered from sops at activation (see §3). |
| Authelia access control (per-domain policy) | ✅ upstream | `access_control.rules[]` with `domain`, `policy ∈ {bypass,one_factor,two_factor,deny}`, optional `subject` (group/user list). |
| nginx `auth_request` directive | ✅ verified | `pkgs/servers/http/nginx/generic.nix` line 128: `--with-http_auth_request_module` is in the **default** configureFlags (not optional). The `tailscale-auth.nix` NixOS module and `nixos/tests/nginx-auth.nix` both use `auth_request /auth;` via `locations.<name>.extraConfig`. No extra nginx module package needed. |
| nginx `auth_request_set` + `Remote-User`/`Remote-Groups` headers | ✅ upstream | Authelia emits `Remote-User`, `Remote-Name`, `Remote-Email`, `Remote-Groups` on 200; nginx forwards via `proxy_set_header`. |
| `services.nginx.virtualHosts.<name>.locations.<path>.extraConfig` | ✅ verified | `location-options.nix` line 126 — freeform string; this is where `auth_request /auth;` + `allow`/`deny` go. |
| `locations.<path>.basicAuthFile` | ✅ verified | `location-options.nix` line 28 — still present (we are removing its use on profile, not the option). |
| `networking.wireguard.interfaces.wg0` | ✅ verified (Phase A) | unchanged from deployed system |
| `services.adguardhome` DHCP `static_leases` + `clients.persistent[].ids` | ✅ verified (deployed) | already in use |

**Consequence:** every option needed for the v2 design is implementable with native modules in the pinned channel. No new flake inputs.

---

## 1. Two-tier VPN enforcement — chosen mechanism

### Decision: **nginx source-IP allowlist by peer range, PLUS Authelia `auth_request` on `profile.dnanu.de` only.**

Rationale:
- The two tiers (admin vs user) are **static IP ranges** declared in `settings.nix`. There is no dynamic role lookup needed for service vhosts — the peer IP *is* the role. An IP allowlist is the simplest, most auditable, zero-daemon mechanism. Authelia on every vhost would add a cookie/session round-trip per request and a single point of failure (Authelia down → all services down) for no security gain, because the trust boundary is already the WireGuard handshake.
- `profile.dnanu.de` is the **exception**: it is public (reachable via cloudflared before the tunnel is up) and serves per-user private keys. There the IP allowlist is useless (cellular IPs are unknown) and per-user identity is required → Authelia with TOTP 2FA.

### Rule sets (exact nginx snippets)

**Admin vhosts** (`cloud`, `status`, `adguard`, `lidarr`, `radarr`, `sonarr`, `readarr`, `prowlarr`, `torrent`, `soulseek`, `usenet`):
```nginx
# Allow only admin VPN peers (10.0.1.8, 10.0.1.9). Deny everything else
# (incl. LAN, user VPN, guests). No auth_request — the WG handshake IS the auth.
allow 10.0.1.8/32;
allow 10.0.1.9/32;
deny  all;
```
- AdGuard UI: admin-VPN only per human ruling (LAN devices still use AdGuard as DNS on :53, but cannot reach the admin web UI).
- All other admin vhosts: same rule. No LAN access. (If the human later wants LAN access to e.g. status from the couch, that's a one-line `allow 10.0.0.0/24;` add — documented in §9 amendment.)

**User vhosts** (`photos`, `vault`, `home`, `music`, `media`, `audio`, `books`):
```nginx
# LAN + user VPN range (10.0.1.10-20) + admin VPN range (admin sees everything).
allow 10.0.0.0/24;     # LAN (incl. guests 10.0.0.50-250)
allow 10.0.1.8/32;     # admin phone
allow 10.0.1.9/32;     # admin pc
allow 10.0.1.10/32;    # adela phone
allow 10.0.1.11/32;    # adela tv
allow 10.0.1.12/32;    # adela air
allow 10.0.1.13/32;    # tiberiu
allow 10.0.1.14/32;    # david phone
allow 10.0.1.15/32;    # david xbox
allow 10.0.1.16/32;    # ramona
allow 10.0.1.17/32;    # tibisor
allow 10.0.1.18/32;    # iza
allow 10.0.1.19/32;    # kerem
allow 10.0.1.20/32;    # hannah
deny  all;
```
- Implementation note: rather than hand-listing 13 `allow` lines, declare a Nix helper `userVpnRanges` in `nginx.nix` that generates the `allow` directives from `settings.network.wireguard.peers` filtered by `admin == false`. This keeps the IP list in one place (`settings.nix`). Admin peers are always added (admins see everything).

**`profile.dnanu.de`** (public via cloudflared):
```nginx
# No IP allowlist — must be reachable from cellular before tunnel is up.
# Authelia auth_request guards every location.
auth_request /auth;
auth_request_set $auth_user $upstream_http_remote_user;
proxy_set_header Remote-User $auth_user;
error_page 401 = @authelia_login;  # redirect to Authelia login flow
```
Plus an internal `/auth/` location proxying to Authelia's `/api/verify` endpoint.

### Why not Authelia on every vhost (rejected alternative)
- Adds a cookie session + per-request subrequest to every service. Authelia downtime = total outage.
- The WG peer IP already encodes the user's tier deterministically. IP allowlist is cheaper, stateless, and survives Authelia outages.
- Authelia is reserved for the one place where IP-based auth is impossible: the public profile page.

---

## 2. Re-addressing

### `settings.nix` — new `network.wireguard.peers` (replaces current 10.0.1.100-109 list)

Naming convention: `[user]-[device]-vpn`. Each peer carries an `admin` boolean. Public keys are NOT secret (safe in git). Private keys + PSKs remain in sops under the **new** key names — the old `wireguard_peer_<oldname>_{private,psk}` secrets become orphaned and are removed from sops (human re-generates or re-uses keys; see §7).

```nix
network.wireguard.peers = [
  # Admin (Dumitru) — may reach ALL *.nanulab.de incl. admin UIs
  { name = "dumitru-phone-vpn"; ip = "10.0.1.8";  admin = true;  publicKey = "REPLACE_ME"; }
  { name = "dumitru-pc-vpn";    ip = "10.0.1.9";  admin = true;  publicKey = "REPLACE_ME"; }
  # User peers — may reach user-facing services only
  { name = "adela-phone-vpn";   ip = "10.0.1.10"; admin = false; publicKey = "REPLACE_ME"; }
  { name = "adela-tv-vpn";      ip = "10.0.1.11"; admin = false; publicKey = "REPLACE_ME"; }
  { name = "adela-air-vpn";     ip = "10.0.1.12"; admin = false; publicKey = "REPLACE_ME"; }
  { name = "tiberiu-phone-vpn"; ip = "10.0.1.13"; admin = false; publicKey = "REPLACE_ME"; }
  { name = "david-phone-vpn";   ip = "10.0.1.14"; admin = false; publicKey = "REPLACE_ME"; }
  { name = "david-xbox-vpn";    ip = "10.0.1.15"; admin = false; publicKey = "REPLACE_ME"; }
  { name = "ramona-phone-vpn";  ip = "10.0.1.16"; admin = false; publicKey = "REPLACE_ME"; }
  { name = "tibisor-phone-vpn"; ip = "10.0.1.17"; admin = false; publicKey = "REPLACE_ME"; }
  { name = "iza-phone-vpn";     ip = "10.0.1.18"; admin = false; publicKey = "REPLACE_ME"; } # MAC TODO
  { name = "kerem-phone-vpn";   ip = "10.0.1.19"; admin = false; publicKey = "REPLACE_ME"; } # MAC TODO
  { name = "hannah-phone-vpn";  ip = "10.0.1.20"; admin = false; publicKey = "REPLACE_ME"; } # MAC TODO
];
# Guests: NO WG peers (removed guest-1/guest-2). Guest range 10.0.0.50-250, LAN-only.
```

### AdGuard DHCP static leases (`adguard.nix`) — new layout, `[user]-[device]` hostnames

```nix
static_leases = [
  { mac = "d0:67:e5:40:49:4e"; ip = "10.0.0.2";   hostname = "homelab"; }
  # Dumitru (admin)
  { mac = "f6:5b:6b:f3:0e:87"; ip = "10.0.0.8";   hostname = "dumitru-phone"; }
  { mac = "2c:9c:58:60:c8:25"; ip = "10.0.0.9";   hostname = "dumitru-pc"; }
  # Adela
  { mac = "fe:02:26:df:0c:50"; ip = "10.0.0.10";  hostname = "adela-phone"; }
  { mac = "00:c3:f4:ea:fe:a6"; ip = "10.0.0.11";  hostname = "adela-tv"; }
  { mac = "68:79:c4:29:1d:44"; ip = "10.0.0.12";  hostname = "adela-air"; }
  # Tiberiu
  { mac = "da:08:7b:fe:cf:d7"; ip = "10.0.0.13";  hostname = "tiberiu-phone"; }
  # David
  { mac = "76:6f:b2:93:10:ce"; ip = "10.0.0.14";  hostname = "david-phone"; }
  { mac = "c4:9d:ed:c9:9a:13"; ip = "10.0.0.15";  hostname = "david-xbox"; }
  # Ramona
  { mac = "56:ea:b4:79:06:61"; ip = "10.0.0.16";  hostname = "ramona-phone"; }
  # Tibisor
  { mac = "26:05:a5:6c:e2:56"; ip = "10.0.0.17";  hostname = "tibisor-phone"; }
  # Iza / Kerem / Hannah — MACs missing, placeholder leases kept so IPs are reserved
  # TODO: human fills real MACs (ruling #11). Lease with placeholder MAC = 00:00:00:00:00:00
  # is harmless (no device matches it) but reserves the IP in the table.
  { mac = "00:00:00:00:00:00"; ip = "10.0.0.18";  hostname = "iza-phone"; }      # TODO MAC
  { mac = "00:00:00:00:00:00"; ip = "10.0.0.19";  hostname = "kerem-phone"; }    # TODO MAC
  { mac = "00:00:00:00:00:00"; ip = "10.0.0.20";  hostname = "hannah-phone"; }   # TODO MAC
];
dhcpv4.range_start = "10.0.0.50";   # guests start at .50 (was .100)
dhcpv4.range_end   = "10.0.0.250";
```

**Decision on Iza/Kerem/Hannah MACs:** keep the static lease with placeholder MAC `00:00:00:00:00:00`. Rationale: (a) reserves the IP so a future real-MAC edit doesn't shift anyone, (b) AdGuard accepts it (no device will match), (c) the WG peer is independent of MAC — Iza/Kerem/Hannah can still onboard to VPN via QR without a LAN lease. TODO comment marks each for the human.

### AdGuard persistent clients — keyed by user, LAN + VPN IPs

```nix
clients.persistent = [
  { name = "dumitru"; ids = [ "10.0.0.8" "10.0.0.9" "10.0.1.8" "10.0.1.9" "dumitru-phone" "dumitru-pc" ]; tags = [ "user_admin" ]; use_global_settings = true; }
  { name = "adela";   ids = [ "10.0.0.10" "10.0.0.11" "10.0.0.12" "10.0.1.10" "10.0.1.11" "10.0.1.12" "adela-phone" "adela-tv" "adela-air" ]; tags = [ "user_regular" ]; use_global_settings = true; }
  { name = "tiberiu"; ids = [ "10.0.0.13" "10.0.1.13" "tiberiu-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
  { name = "david";   ids = [ "10.0.0.14" "10.0.0.15" "10.0.1.14" "10.0.1.15" "david-phone" "david-xbox" ]; tags = [ "user_regular" ]; use_global_settings = true; }
  { name = "ramona";  ids = [ "10.0.0.16" "10.0.1.16" "ramona-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
  { name = "tibisor"; ids = [ "10.0.0.17" "10.0.1.17" "tibisor-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
  { name = "iza";     ids = [ "10.0.0.18" "10.0.1.18" "iza-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
  { name = "kerem";   ids = [ "10.0.0.19" "10.0.1.19" "kerem-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
  { name = "hannah";  ids = [ "10.0.0.20" "10.0.1.20" "hannah-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
  { name = "guests";  ids = [ "10.0.0.50-10.0.0.250" ]; tags = [ "user_guest" ]; use_global_settings = true; } # range comment only — AGH ids are exact strings, see note
];
```
**Note on guests:** AdGuard `ids` are exact strings (IP or hostname), not ranges. The `guests` client with a range string won't match — instead, rely on `runtime_sources.dhcp = true` to label guest leases by their DHCP hostname dynamically. Drop the `guests` persistent client; document this. (Guests are transient; per-guest labeling is not worth the maintenance.)

---

## 3. profile.dnanu.de + Authelia design

### Architecture
```
cellular/laptop browser
    │  https://profile.dnanu.de  (public A → cloudflared → nginx 127.0.0.1:8080... 
    │  ... NO — see decision below)
    ▼
nginx vhost profile.dnanu.de (TLS, *.dnanu.de cert)
    │  auth_request /auth → Authelia 127.0.0.1:9091/api/verify
    │  (401 → redirect to Authelia login UI at /authelia/)
    ▼
Authelia (file user DB, TOTP 2FA, session cookie scoped to .dnanu.de)
    │  on success: 200 + Remote-User: <username>
    ▼
nginx location /<username>/  →  /var/lib/mobileprofile/wg/<username>/  (root:nginx 0640)
    │  only served if $auth_user == <username>  (enforced by nginx map — see below)
    ▼
user sees ONLY their own WG .conf + .png + install instructions
```

### Reachability decision for profile.dnanu.de
Two options:
- **(A) Public via cloudflared tunnel** (task file line 48: "users need it before the tunnel is up").
- **(B) LAN + VPN only** (like the old profile.nanulab.de).

**Chosen: (A) public via cloudflared.** The human's explicit rationale ("users get their QR on cellular, before the tunnel is up") is decisive. This adds `profile.dnanu.de` to the cloudflared tunnel ingress (alongside `dnanu.de`, `www`, `autoconfig`). Authelia + TOTP is the gate. Risk: profile.dnanu.de is now internet-reachable — accepted, because (a) Authelia 2FA is strong, (b) the only asset behind it is per-user WG configs (revoking a user = deleting their Authelia account + WG peer), (c) no other service is exposed.

### Authelia instance (`modules/services/authelia.nix`, new)
```nix
services.authelia.instances.main = {
  enable = true;
  secrets = {
    jwtSecretFile = config.sops.secrets.authelia_jwt.path;
    storageEncryptionKeyFile = config.sops.secrets.authelia_storage_key.path;
  };
  settings = {
    theme = "dark";
    default_2fa_method = "totp";
    server.address = "tcp://127.0.0.1:9091/";
    log.level = "info";
    authentication_backend = {
      file = {
        path = "/var/lib/authelia-main/users.yaml";  # rendered from sops at activation
        watch = false;
        reload = false;  # we restart the unit on changes instead
      };
      refresh_interval = "5m";
    };
    session = {
      domain = settings.domains.public;  # .dnanu.de — cookie scoped so it works through cloudflared
      name = "authelia_session";
      same_site = "lax";
      expiration = "1h";
      inactivity = "5m";
      remember_me = "1M";
    };
    storage.local.path = "/var/lib/authelia-main/db.sqlite3";
    access_control = {
      default_policy = "deny";
      rules = [
        { domain = "profile.${settings.domains.public}"; policy = "two_factor"; }
      ];
    }
    # totp: default issuer "nanulab"
    totp.issuer = "nanulab";
    # webauthn disabled for now (TOTP is enough, no hardware key requirement)
  };
};
```

### User DB (sops → rendered file)
- sops secret `authelia_users_yaml` = the full `users.yaml` content (bcrypt hashes + per-user TOTP secrets). Rendered to `/var/lib/authelia-main/users.yaml` via a sops secret with `owner = authelia-main`.
- Why sops-not-Nix: Authelia's `users.yaml` contains hashed passwords + TOTP seeds. Putting hashes in Nix puts them in the world-readable `/nix/store`. sops renders to a 0400 file owned by `authelia-main`. This matches the project's "secrets via sops" rule.
- **User → WG peer mapping:** by username convention. Authelia username = `dumitru`, `adela`, `tiberiu`, `david`, `ramona`, `tibisor`, `iza`, `kerem`, `hannah`. The QR renderer writes per-user dirs `/var/lib/mobileprofile/wg/<username>/` containing that user's peer(s). nginx serves `/var/lib/mobileprofile/wg/$auth_user/` at `/<username>/` — but **the path is derived from `$auth_user`, not from the URL**, so user A cannot read user B's dir by guessing the URL. Implementation:

```nginx
# profile.dnanu.de
location ~ ^/([a-z]+)/?$ {
  auth_request /auth;
  auth_request_set $auth_user $upstream_http_remote_user;
  # Only serve if the URL username matches the authenticated username.
  if ($auth_user != $1) { return 403; }
  alias /var/lib/mobileprofile/wg/$1/;
  try_files index.html =404;
  autoindex off;
  add_header Cache-Control "no-store";
}
# Internal Authelia verify endpoint
location = /auth {
  internal;
  proxy_pass http://127.0.0.1:9091/api/verify;
  proxy_pass_request_body off;
  proxy_set_header Content-Length "";
  proxy_set_header X-Original-URL $request_uri;
  proxy_set_header X-Original-Method $request_method;
  proxy_set_header X-Real-IP $remote_addr;
}
# Authelia login UI
location /authelia/ {
  proxy_pass http://127.0.0.1:9091/;
  proxy_set_header X-Forwarded-Proto $scheme;
  # ... standard proxy headers
}
# Root → redirect to /<auth_user>/ (requires JS or a small auth_request-based redirect;
# simplest: serve a tiny HTML page that reads Remote-User via a subrequest and redirects).
location = / {
  auth_request /auth;
  auth_request_set $auth_user $upstream_http_remote_user;
  return 302 /$auth_user/;
}
```

### Per-user page content
- `/dumitru/` (admin): both admin peers (`dumitru-phone-vpn`, `dumitru-pc-vpn`) — each peer's `.conf` + `.png` + a note "Admin tier — reaches all services including admin UIs". Plus install instructions (WireGuard app → scan → On-Demand).
- `/adela/` (user): all of adela's peers (`adela-phone-vpn`, `adela-tv-vpn`, `adela-air-vpn`) — each `.conf` + `.png` + "User tier — reaches photos, vault, home, music, media, audio, books". Same install instructions.
- Same pattern for every user. A user with one device sees one QR; a user with three sees three.

### QR renderer changes (`wireguard.nix`)
- Group peers by `user` (new field in `settings.nix` peer attrset: `user = "dumitru"` etc.).
- Output layout: `/var/lib/mobileprofile/wg/<user>/<peer-name>.conf` + `<peer-name>.png` + `index.html` (per-user index listing that user's peers only).
- The old shared `/wg/index.html` listing ALL peers is **deleted** — it was a privacy leak (any authed user saw every peer).
- `chown -R root:nginx /var/lib/mobileprofile/wg; chmod 750 per-user dir, 640 files`.
- Renderer reads each peer's private+PSK from sops as before; key names change to `wireguard_peer_<peer-name>_private` / `_psk` (peer-name now includes `-vpn` suffix).

### Remove `profile_basic_auth`
- The shared htpasswd `profile_basic_auth` secret is **obsolete** (replaced by Authelia). Remove from `sops.nix` and `secrets.yaml`. The old `profile.nanulab.de` vhost is renamed to `profile.dnanu.de` and loses `basicAuthFile`.

---

## 4. Service vhosts — built now vs deferred

**Rule: no empty vhosts (human ruling #9).** A vhost is created only when the service module exists and proxies to a real backend.

### Current repo state
Only these service modules exist: `mail.nix` (stub), `cloudflare-dns.nix`, `ios-profile.nix`. No Nextcloud, Immich, Jellyfin, Navidrome, ABS, Booklore, Vaultwarden, Beszel, Lidarr/Radarr/Sonarr/Readarr/Prowlarr, qBittorrent, slskd, SABnzbd modules yet.

### Decision: **build the vhost + ACL scaffolding now ONLY for services that exist; defer the rest.**
- Creating a vhost that proxies to `127.0.0.1:<port>` with no backend = 502 on every request = empty vhost = violates ruling #9.
- The ACL rules (admin vs user allowlist) are **declared once** in a Nix helper (`mkAdminVhost`, `mkUserVhost`) in `nginx.nix`, so when each service module lands in build steps 5–6 it just calls the helper. No rework.

### What this milestone builds
| Vhost | Built now? | Reason |
|---|---|---|
| `profile.dnanu.de` | ✅ yes | Authelia + per-user WG pages — the core deliverable |
| `adguard.nanulab.de` | ✅ yes (exists) | already in `nginx.nix`; **add admin-VPN allowlist** |
| `cloud/status/lidarr/radarr/sonarr/readarr/prowlarr/torrent/soulseek/usenet` | ❌ deferred | no service modules yet; vhost would 502 |
| `photos/vault/home/music/media/audio/books` | ❌ deferred | same |

### What this milestone DOES build for deferred services
- `modules/networking/nginx.nix` gains two helpers:
  ```nix
  mkAdminVhost = fqdn: backend: { forceSSL = true; useACMEHost = settings.domains.internal;
    locations."/".proxyPass = backend; extraConfig = adminAllowlist; };
  mkUserVhost  = fqdn: backend: { forceSSL = true; useACMEHost = settings.domains.internal;
    locations."/".proxyPass = backend; extraConfig = userAllowlist; };
  ```
- These are **defined but not invoked** for missing services. When build step 5 (Nextcloud) lands, it calls `mkAdminVhost "cloud.nanulab.de" "http://127.0.0.1:..."`. Zero rework.
- The AdGuard vhost is rewritten to use `mkAdminVhost` (it exists, so it gets the ACL now).

---

## 5. QR/profile renderer changes — summary (detailed in §3)
- Per-user output dirs `/var/lib/mobileprofile/wg/<user>/`.
- Per-user `index.html` (not shared).
- Admin user page lists admin-tier peers + admin-tier note.
- User page lists user-tier peers + user-tier note.
- Served behind Authelia at `profile.dnanu.de/<user>/`, URL-to-filesystem mapping gated by `$auth_user == $1`.
- Old shared `/wg/` location on `profile.nanulab.de` **removed**. The `profile.nanulab.de` vhost itself is **renamed to `profile.dnanu.de`** (public domain, served via cloudflared).

---

## 6. Firewall (`base.nix`)

| Port | Proto | Source | Purpose | Change vs current |
|---|---|---|---|---|
| 25 | tcp | any (router-fwd) | inbound SMTP | unchanged |
| 53 | tcp+udp | LAN (10.0.0.0/24) + wg0 | AdGuard DNS | unchanged (LAN needs DNS; wg0 trusted) |
| 67 | udp | LAN | AdGuard DHCP | unchanged |
| 80 | tcp | LAN | HTTP→HTTPS redirect | unchanged |
| 443 | tcp | LAN + wg0 | nginx TLS vhosts | unchanged (admin vhosts are nginx-ACL'd, not firewalled — see note) |
| 465/587/993 | tcp | LAN + wg0 | mail submission/IMAPS | unchanged |
| 51820 | udp | any (router-fwd) | WireGuard | unchanged |
| 8080 | tcp | 127.0.0.1 only | cloudflared → nginx (blogs + profile.dnanu.de) | unchanged |

**Note on admin vhosts + firewall:** admin vhosts are reachable at 443 from LAN (port is open to LAN). The nginx `allow 10.0.1.8/32; deny all;` block rejects LAN clients at the HTTP layer. This is correct and intentional — firewalling 443 per-vhost is impossible (all vhosts share :443 via SNI). The nginx ACL is the enforcement. No firewall change needed for the two-tier split.

**cloudflared ingress change:** add `profile.dnanu.de` to the tunnel ingress in `modules/networking/cloudflare.nix` → `http://127.0.0.1:8080` (or directly to the nginx TLS vhost on 443 — current pattern uses 8080 loopback; keep consistent). Wait: profile.dnanu.de needs TLS + Authelia. The current cloudflared setup routes `dnanu.de`/`www`/`autoconfig` to `127.0.0.1:8080` (the placeholder HTTP vhost). For `profile.dnanu.de` we need the TLS vhost with Authelia. **Decision:** cloudflared routes `profile.dnanu.de` → `https://127.0.0.1:443` (nginx terminates TLS, Authelia runs). Add `profile.dnanu.de` to the tunnel ingress and to the cloudflare-dns CNAME list (proxied, like the other tunnel names).

---

## 7. Secrets (sops)

### Add
- `authelia_jwt` — random 64+ char string, `owner = authelia-main`.
- `authelia_storage_key` — random 64+ char string, `owner = authelia-main`.
- `authelia_users_yaml` — full Authelia `users.yaml` content (bcrypt hashes + TOTP seeds for all 9 users), `owner = authelia-main`, `mode = 0400`. Rendered to `/var/lib/authelia-main/users.yaml`.

### Rename (peer keys change name)
- Old: `wireguard_peer_iPhone17Pro_{private,psk}` … `wireguard_peer_guest-2_{private,psk}` (12 peers × 2 = 24 keys).
- New: `wireguard_peer_dumitru-phone-vpn_{private,psk}` … `wireguard_peer_hannah-phone-vpn_{private,psk}` (13 peers × 2 = 26 keys).
- The human must re-run `sops secrets/secrets.yaml` and either (a) re-use the existing keypairs (rename the sops keys + update `publicKey` in settings.nix to match — public keys don't change when you rename) or (b) generate fresh keypairs. **Recommendation: re-use** — just rename the sops keys and keep the existing public keys (the human already has the private halves on the Arch box in Memory.md). The `publicKey` values in settings.nix stay the same; only the peer `name` field changes.

### Remove
- `profile_basic_auth` — obsolete (Authelia replaces it).
- Old guest peer keys `wireguard_peer_guest-1_*`, `wireguard_peer_guest-2_*` — guests have no VPN now.

### Keep
- All existing non-WG secrets (cloudflare, mail, resend, etc.).

---

## 8. Ordered task list for DeepSeek-V4-Pro (verbatim-executable)

**Precondition:** human has renamed WG peer keys in sops (or executor uses placeholder secrets and human fills before deploy). Executor must `nix build .#nixosConfigurations.homelab.config.system.build.toplevel` after each phase and commit per the git-workflow skill. Do NOT deploy until human approves.

### Phase A — re-addressing + naming
1. `settings.nix`: replace `network.wireguard.peers` with the 13-peer list from §2 (new names, new IPs, `admin` flag, `user` field). Keep existing `publicKey` values (re-used keys). Remove `guest-1`/`guest-2`. Add `network.guestRange = "10.0.0.50-10.0.0.250";` (or just update the adguard range directly — executor picks). Commit: `settings: v2 IP layout, [user]-[device]-vpn peer names, admin flag, drop guest peers`.
2. `modules/networking/adguard.nix`: replace `static_leases` with the §2 list (new hostnames `[user]-[device]`, new IPs 10.0.0.8-20, placeholder MACs for iza/kerem/hannah with TODO comments). Update `dhcpv4.range_start = "10.0.0.50"`. Replace `clients.persistent` with the §2 per-user list (9 users, LAN+VPN IPs + hostnames as ids; drop the old Dumitru/M/T/T/Guests entries; drop the `guests` persistent client — document that guests are labeled dynamically via `runtime_sources.dhcp`). Commit: `adguard: v2 DHCP leases + persistent clients keyed by user`.
3. `modules/networking/wireguard.nix`: update the `peers` binding to read `admin`/`user` from the new peer attrs (no functional change to the wg0 interface yet — just the data shape). The sops secret names now derive from the new peer `name` (includes `-vpn` suffix). Update `peerSecretAttrs` accordingly. Commit: `wireguard: peer registry uses v2 names + admin/user metadata`.
4. Build + eval. Fix any errors. Commit if fixes needed.

### Phase B — Authelia + profile.dnanu.de
5. `modules/services/authelia.nix` (new): the `services.authelia.instances.main` block from §3. Sops secrets `authelia_jwt`, `authelia_storage_key`, `authelia_users_yaml` declared here (locality). `users`/`groups` for `authelia-main` are auto-created by the module. Commit: `services: Authelia instance (file auth, TOTP, profile.dnanu.de policy)`.
6. `modules/system/sops.nix`: add `authelia_jwt`, `authelia_storage_key` (both `owner = "authelia-main"`), `authelia_users_yaml` (`owner = "authelia-main"; mode = "0400"`). Remove `profile_basic_auth`. Commit: `sops: Authelia secrets, remove profile_basic_auth`.
7. `modules/services/ios-profile.nix` → rename vhost to `profile.${settings.domains.public}` (i.e. `profile.dnanu.de`). Remove `basicAuthFile`. Add the Authelia `auth_request` locations from §3 (`= /auth` internal, `/authelia/` proxy, `~ ^/([a-z]+)/?$` per-user with `$auth_user == $1` gate, `= /` redirect). The vhost uses `useACMEHost = settings.domains.public` (the `*.dnanu.de` cert). Commit: `profile: rename to profile.dnanu.de, Authelia auth_request, per-user pages`.
8. `modules/networking/wireguard.nix`: rewrite `wireguard-profile-render` to group peers by `user` and write per-user dirs `/var/lib/mobileprofile/wg/<user>/{<peer>.conf,<peer>.png,index.html}`. Per-user `index.html` lists only that user's peers + tier note (admin vs user). Remove the shared `index.html`. Remove the old `/wg/` location on `profile.nanulab.de` (the vhost is renamed anyway). Add the `/wg/`-style serving via the per-user location in ios-profile.nix (already done in step 7). Commit: `wireguard: per-user QR renderer, drop shared /wg/ index`.
9. `modules/networking/cloudflare.nix`: add `profile.dnanu.de` to the cloudflared tunnel ingress → `https://127.0.0.1:443`. `modules/services/cloudflare-dns.nix`: add `profile.dnanu.de` CNAME → `<tunnel-id>.cfargotunnel.com` (proxied), mirroring the existing `dnanu.de`/`www`/`autoconfig` entries. Commit: `cloudflared: route profile.dnanu.de through tunnel`.
10. `hosts/homelab/configuration.nix`: add import `../../modules/services/authelia.nix`. Commit: `configuration: import authelia module`.
11. Build + eval. Fix errors. Commit fixes.

### Phase C — nginx ACL helpers + AdGuard vhost
12. `modules/networking/nginx.nix`: add `mkAdminVhost` and `mkUserVhost` helpers (§4). Add a `let` block deriving `adminVpnIps` and `userVpnIps` from `settings.network.wireguard.peers` (filter by `admin`). Generate the `allow`/`deny` strings. Rewrite the existing `adguard.nanulab.de` vhost to use `mkAdminVhost` (it exists, so it gets the ACL now). Keep the placeholder `dnanu.de` vhost on 8080 unchanged. Commit: `nginx: admin/user vhost ACL helpers, AdGuard vhost admin-VPN-only`.
13. Build + eval. Commit fixes.

### Phase D — docs
14. `Changes.md`: session entry summarizing v2 (re-address, Authelia, profile.dnanu.de, ACL helpers, deferred vhosts). `Memory.md`: add Authelia section (instance name `main`, port 9091, users.yaml path, user list, TOTP), profile.dnanu.de reachability (public via cloudflared), new WG peer naming, guest range. `README.md`: update Status (v2 access control built, pending deploy) and the agent-facing description (Authelia added, profile moved to dnanu.de). `TODO.md`: add 1%-manual items (rename sops WG keys, generate Authelia users.yaml with bcrypt hashes + TOTP seeds, distribute new QRs, revoke old QR access). Commit: `docs: v2 session updates (README/Changes/Memory/TODO)`.
15. Final report to human: build result, the §9 OpenCode.md amendment list (for human approval), the 1%-manual steps in order (rename sops WG keys → generate Authelia users.yaml → deploy → distribute new per-user QR URLs → revoke old profile.nanulab.de access), and the §13 verification commands to run after deploy.

### Explicit non-goals for the executor
- Do NOT create vhosts for services that don't exist yet (Nextcloud, Immich, Jellyfin, etc.) — only the helpers + AdGuard.
- Do NOT amend OpenCode.md (§9 list is delivered as a markdown section in the plan, applied after approval).
- Do NOT deploy (`/deploy`) — human approves the closure first.
- Do NOT touch mail, SSH, VPN-confinement, or service modules outside the table in §7 of the task file.
- Do NOT disable SSH password auth.
- No new flake inputs. No containers.

---

## 9. OpenCode.md amendment list (deferred — applied after plan approval)

| Section | Change |
|---|---|
| §3.1 | Add `10.0.0.3-7 reserved`, `10.0.0.8-20` named users, `10.0.0.50-250` guests. Note WG peers now `10.0.1.8-20` (was `.100-109`). |
| §3.3 | Add two-tier: admin peers (10.0.1.8/9) reach all `*.nanulab.de`; user peers (10.0.1.10-20) reach user-facing services only; enforcement = nginx source-IP allowlist per vhost. Guests have no WG peer. Peer naming = `[user]-[device]-vpn`. |
| §3.4 | AdGuard UI (`adguard.nanulab.de`) = admin-VPN only (was LAN-reachable). LAN devices still use AdGuard as DNS on :53. |
| §3.6 | cloudflared tunnel ingress adds `profile.dnanu.de` → `https://127.0.0.1:443`. |
| §7 | Add `authelia_jwt`, `authelia_storage_key`, `authelia_users_yaml`. Remove `profile_basic_auth`. Rename WG peer secrets to `wireguard_peer_<user>-<device>-vpn_{private,psk}`. Remove guest-1/guest-2 peer secrets. |
| §9 | Add Authelia row (`services.authelia.instances.main`, 127.0.0.1:9091, no public vhost — reached via `profile.dnanu.de` `/authelia/` subpath). Mark AdGuard UI as admin-VPN-only. Mark user-facing services (photos/vault/home/music/media/audio/books) as LAN+user-VPN. Mark admin services (cloud/status/lidarr/radarr/sonarr/readarr/prowlarr/torrent/soulseek/usenet) as admin-VPN-only. Drop Collabora, beets, bazarr, Seerr/requests (per human rulings #6/#8). |
| §10 | `profile.dnanu.de` (public via cloudflared) replaces `profile.nanulab.de`. Authelia (TOTP 2FA) replaces shared basic auth. Per-user pages `/<username>/` serve only that user's WG peers. Admin page = admin-tier config; user pages = user-tier. The `.mobileconfig` (mail/CalDAV/CardDAV) still served from the same vhost (future). |
| §12 | 1%-manual: rename sops WG keys to new peer names (or regenerate); generate Authelia `users.yaml` (bcrypt hashes + TOTP seeds per user); distribute per-user profile URLs (`profile.dnanu.de/<user>/`) instead of shared QR page; users self-onboard with 2FA. |
| §13 | Add: `curl -I https://profile.dnanu.de` from cellular → 401 (Authelia gate); login as user → see only own peers; admin vhost from LAN → 403; admin vhost from admin VPN → 200; user vhost from user VPN → 200; user vhost from admin VPN → 200. |
| §15 | Add: if Authelia becomes a burden, fallback = nginx `auth_basic` per vhost (less UX, zero daemons) or tailscale-auth module (already in nixpkgs). |

---

## 10. Risks & rollback

- **Risk: Authelia downtime locks everyone out of profile.dnanu.de.** Mitigation: Authelia is a single Go binary with sqlite, very stable; `Restart = always` in the module. If it dies, users can't get new QRs but **existing WG tunnels keep working** (WG is independent of Authelia). Rollback: `git revert` Phase B commits restores shared basic auth.
- **Risk: per-user page leaks another user's keys via URL guessing.** Mitigation: nginx `if ($auth_user != $1) { return 403; }` — the URL username must match the Authelia-authenticated username. Tested pattern (common in Authelia deployments).
- **Risk: cloudflared tunnel exposes profile.dnanu.de to the internet.** Accepted per human ruling. Authelia + TOTP is the gate. If compromised: revoke Authelia user → user can't login → their WG configs unreachable. WG itself is not compromised (keys are separate).
- **Risk: renaming WG peer keys in sops orphans the old keys / breaks existing tunnels.** Mitigation: public keys don't change (re-use); only sops key *names* change. Existing deployed tunnels keep working until the rebuild switches the server's peer list (which is just a rename, same keys). Rollback: `git revert` Phase A.
- **Risk: AdGuard UI becomes unreachable from LAN (admin-VPN only).** This is intentional (human ruling). The human must use the admin VPN to manage AdGuard. If the human wants LAN access back: one-line `allow 10.0.0.0/24;` add to the AdGuard vhost.
- **Risk: placeholder MACs (00:00:00:00:00:00) for Iza/Kerem/Hannah cause AdGuard config validation error.** Mitigation: executor verifies `nix build` passes; if AdGuard rejects placeholder MACs, fall back to omitting those three leases entirely (IP still reserved by convention; human adds real lease later). Document either way.
- **Risk: Authelia `users.yaml` format drift.** Mitigation: executor verifies the rendered file against Authelia's current schema (the pinned `authelia` package version's docs). The `users.yaml` is generated by the human (1% manual) using `authelia crypto hash generate bcrypt` + `authelia totp generate` — documented in the runbook.
- **Rollback (overall):** `git revert` the v2 commits → previous generation (gen 35, shared basic auth, old IPs) is restored. The server's boot menu also retains gen 35.

*(Plan ends. No code was modified; no commits created.)*
