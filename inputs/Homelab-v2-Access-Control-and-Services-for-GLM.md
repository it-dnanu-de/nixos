# Task: Homelab v2 — access control (two-tier VPN), re-addressing, service map, profile.dnanu.de with Authelia — for GLM 5.2 (architect)

Source: `Prompt for DeepSeek-V4-Flash-0731.md` (human's architecture prompt + ChatGPT readability pass) + human rulings 2026-08-06.
Created 2026-08-06 by Flash per Session Workflow. **OpenCode.md stays as-is until the plan is approved** (human ruling).

## Context / what changed vs the deployed system
The system currently runs: Tailscale→WireGuard swap (Phase A done, OpenCode.md §3.3), DHCP static leases at 10.0.0.100–109, WG peers 10.0.1.100–109 + guests 200/201, `profile.nanulab.de/wg/` behind shared basic auth, AdGuard UI LAN-reachable. The human now wants a **v2 architecture**: real users, two-tier VPN access, full re-addressing, per-user self-service profile page, and admin-only access to all management UIs. This supersedes several §9/§10 details — the plan must reconcile them.

## Human rulings (2026-08-06) — bake into the plan verbatim
1. **Two-tier VPN (one server, two access levels)** — one wg0 interface; peers tagged **admin vs user**; access control enforced at nginx + firewall **by peer IP range**. Admin range → all `*.nanulab.de` incl. admin UIs. User range → media/end-user services only. Not two separate WG servers.
2. **Re-address everything** to the new IP layout below (DHCP static leases + WG peers + AdGuard clients).
3. **Profile page moves to `profile.dnanu.de`** (public domain). Must be reachable from anywhere (users get their QR on cellular, before the tunnel is up). Secure with **Authelia** (`services.authelia`, native module — verified present in pinned 26.05): real per-user accounts + TOTP 2FA, nginx `auth_request`. NOT shared basic auth.
4. **Client naming:** AdGuard **persistent clients = the users** (dumitru, adela, iza, …). DHCP static-lease hostnames and WireGuard peer names = `[user]-[device]` (LAN) and `[user]-[device]-vpn` (same device's VPN). Guests get **no VPN, no persistent client, no WG peer**.
5. **Guests:** range `10.0.0.50–10.0.0.250` (kept separate from regular users), LAN-only, can use user-facing services on LAN.
6. **Requests services (Seerr/requests1-4) and soularr:** **dropped from this milestone** — "deal with requests services later" (soularr is a Lidarr↔slskd bridge, not a request UI; revisit in Phase 2).
7. **Beszel: keep** (`status.nanulab.de`) — native, cheap; drop the Prometheus/Grafana idea as overkill.
8. **Collabora dropped** (Nextcloud Office replaces it). **beets dropped. bazarr dropped.**
9. **No empty vhosts.** Admin subdomains with no real UI (`nginx`, `wg`, `ddns`, `cloudflare`, `restic`, `hugo`, `mail`) are documentation of ownership only — **do not create vhosts for them**. Only services that actually expose a UI get vhosts.
10. **`mail.nanulab.de` not public.** SNM has no web UI (it was an example) — so no vhost; the mail admin is via IMAP/ManageSieve/SSH. `mail.dnanu.de` remains the only public service.
11. MACs for **Iza, Kerem, Hannah missing** — placeholders, human adds later (document as TODO in the plan).

## New IP layout (authoritative)
- `10.0.0.1` router · `fe80::1` router · `10.0.0.2` homelab/Dell · `127.0.0.1`/`127.0.0.2`/`::1` loopback (::1 ownership uncertain — informational only)
- `10.0.0.3–10.0.0.7` reserved (future servers / macvlan)
- **Dumitru (Admin):** `10.0.0.8` iPhone17Pro · `10.0.1.8` VPN · `10.0.0.9` Arch PC · `10.0.1.9` VPN
- **Adela:** `10.0.0.10` iPhoneXS · `10.0.1.10` · `10.0.0.11` Samsung TV · `10.0.1.11` · `10.0.0.12` Philips Air · `10.0.1.12`
- **Tiberiu:** `10.0.0.13` GalaxyS22U · `10.0.1.13`
- **David:** `10.0.0.14` iPhone17ProMax · `10.0.1.14` · `10.0.0.15` Xbox One · `10.0.1.15`
- **Ramona:** `10.0.0.16` iPhone11 · `10.0.1.16`
- **Tibisor:** `10.0.0.17` iPhone14 · `10.0.1.17`
- **Iza:** `10.0.0.18` iPhone15 · `10.0.1.18` (MAC missing)
- **Kerem:** `10.0.0.19` iPhone16Pro · `10.0.1.19` (MAC missing)
- **Hannah:** `10.0.0.20` iPhone15Pro · `10.0.1.20` (MAC missing)
- **Guests:** `10.0.0.50–10.0.0.250`
- WG server: `10.0.1.1/24`, endpoint `vpn.dnanu.de:51820` (unchanged, already forwarded)

## VPN design (two-tier)
- One wg0 (`10.0.1.1/24`), endpoint `vpn.dnanu.de:51820`.
- **Admin peers:** dumitru-phone-vpn (10.0.1.8), dumitru-pc-vpn (10.0.1.9) — may reach ALL `*.nanulab.de`.
- **User peers:** all other users (10.0.1.10–20) — may reach only user-facing services.
- Enforcement: nginx `auth_request`/ACL or nginx-level source allowlist by IP range per vhost (admin vhosts: `allow 10.0.1.8/32; allow 10.0.1.9/32;` + optionally LAN for LAN-only UIs). Firewall: user-range to only service ports. Architect picks the cleanest native mechanism and states it explicitly.
- Guests: no WG peer.

## Service accessibility rules (authoritative)
- **Public:** only `mail.dnanu.de` (SMTP 25). Everything else private.
- **`*.nanulab.de` = private**; reachable by LAN / Admin VPN / User VPN depending on purpose.
- **AdGuard UI (`adguard.nanulab.de`): Admin VPN ONLY.** LAN devices keep using AdGuard as DNS (port 53 stays open to LAN) but must NOT reach the admin UI.
- **`profile.dnanu.de`: public via cloudflared tunnel** (users need it before the tunnel is up), behind **Authelia** (per-user accounts + TOTP). Per-user page at `/dumitru` (admin) or `/admin`, `/adela`, `/iza`, … each showing that user's own WG QR + config + install instructions. Users self-serve (no admin hand-holding). Admin page shows admin-tier config; user pages show user-tier config. **Every page carries that user's private key** → must be behind 2FA.

### User-facing services (LAN or User VPN)
| URL | Service |
|---|---|
| `photos.nanulab.de` | Immich |
| `vault.nanulab.de` | Vaultwarden |
| `home.nanulab.de` | Home Assistant |
| `music.nanulab.de` | Navidrome |
| `media.nanulab.de` | Jellyfin |
| `audio.nanulab.de` | Audiobookshelf |
| `books.nanulab.de` | Booklore |
*(requests1–4 dropped this milestone)*

### Admin-only services (Admin VPN)
| URL | Service |
|---|---|
| `cloud.nanulab.de` | Nextcloud (+ Office, replaces Collabora) |
| `status.nanulab.de` | Beszel |
| `adguard.nanulab.de` | AdGuard Home |
| `lidarr.nanulab.de` | Lidarr |
| `radarr.nanulab.de` | Radarr |
| `sonarr.nanulab.de` | Sonarr |
| `readarr.nanulab.de` | Readarr |
| `prowlarr.nanulab.de` | Prowlarr |
| `torrent.nanulab.de` | qBittorrent |
| `soulseek.nanulab.de` | slskd |
| `usenet.nanulab.de` | SABnzbd |

*(Documented ownership only, NO vhost: nginx, wg, ddns, cloudflare, restic, hugo, mail — they have no UI.)*

## Other changes
- `settings.nix`: new `network.wireguard.peers` (renamed + re-addressed, `[user]-[device]-vpn`, admin flag), new guest range, `domains.profile`? (profile.dnanu.de), remove guest-1/guest-2 peers.
- `modules/networking/adguard.nix`: DHCP static leases → new layout + `[user]-[device]` hostnames; persistent clients → users (dumitru, adela, …) keyed by their LAN+VPN IPs; keep DNS available to LAN.
- `modules/networking/wireguard.nix`: two-tier peer metadata (admin vs user) + QR renderer now writes per-user pages incl. the user's own key; **remove** rendering of admin keys to user pages.
- `modules/services/ios-profile.nix` → becomes the **profile.dnanu.de** vhost behind Authelia (`auth_request`), still serving WG configs/QRs per user.
- `modules/networking/nginx.nix`: admin vhosts get source allowlist; user vhosts allowed for LAN + user range; AdGuard UI admin-only.
- New: Authelia instance + user DB (in sops), nginx `auth_request`.
- Remove: `profile_basic_auth` shared basic auth on profile (replaced by Authelia) unless still needed elsewhere.
- **OpenCode.md §9/§10/§3.3/§3.4/§4.4/§12/§13 amendments come AFTER plan approval** (not in this task).

## Constraints
- Native NixOS modules only; single container exception = Booklore.
- Zero open ports on router except 25/tcp + 51820/udp (unchanged).
- Declarative only; secrets in sops; repo public-safe.
- Verify every option/module against pinned `nixos-26.05` before writing (esp. `services.authelia`, `auth_request` wiring).
- Don't deploy; build + verify closure only.

## Files affected (expected)
`settings.nix` · `modules/networking/{wireguard,adguard,base,nginx}.nix` · `modules/services/ios-profile.nix` (→profile) · new `modules/services/authelia.nix` · `modules/system/sops.nix` · `secrets/secrets.yaml` (authelia users) · possibly `flake.nix` (no new inputs expected)

## Model recommendation
**GLM 5.2 (architect)** — architecture/access-control design. No Kimi escalation (human ruling). Execution after approval: **DeepSeek-V4-Pro**.
