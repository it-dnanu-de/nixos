# Task: Network re-architecture v3 — user-block addressing, users.nix, admin+user tiers, AGH DHCP lease fix, WG 10.0.10.x — for GLM 5.2 (High reasoning planner)

Source: human-driven session 2026-08-06 (AdGuard Home issues + proposed new layout). Created by Flash per Session Workflow.
**Tier: High (GLM 5.2)** — human approved. Execution after plan approval: nixos-builder (DeepSeek V4 Pro).

## Context / why
1. **AGH DHCP is broken in practice**: devices get dynamic guest-range IPs (arch → 10.0.0.50) instead of static leases. **Root cause diagnosed by Flash (2026-08-06):** AGH 0.107.78 **rewrites its config on every startup and silently drops `static_leases`** from the YAML (reproduced in /tmp/aghtest: store config has static_leases, AGH's own rewritten output strips them). Persistent clients DO survive; static leases do not.
2. The v2 addressing (per-device, 10.0.0.8-20 / 10.0.1.100-109) is being replaced by a **user-block scheme** for cleaner management and future-proofing.
3. WireGuard subnet moves **10.0.1.0/24 → 10.0.10.0/24**.

## Human rulings (2026-08-06) — bake in verbatim
1. **One VPN IP per device** (Option A). Users with N devices get N VPN peers; no IP sharing.
2. **Dumitru is now a NORMAL user.** A separate **`admin` identity** exists (the human's admin role). Human's devices split: **arch (MAC `2c:9c:58:60:c8:25`) = `admin1`**; **iPhone (MAC `f6:5b:6b:f3:0e:87`) = `dumitru1`**.
3. **Login = username** (lowercase: `admin`, `dumitru`, `adela`, …). Profile page `/admin` serves **admin1-9** QRs; `/dumitru` serves **dumitru1-9**, etc. **admin ONLY sees admin[1-9]; users only see their own user[1-9].**
4. **`users.nix`** (Nix file, replaces the users.md idea): maps users → devices (hostname, mac, lan IP, vpn IP). **Committed to the repo for now** (dev builds; MACs are not secrets; may be gitignored later).
5. **Guests confirmed**: `10.0.0.100-10.0.0.250`, **no VPN peers**, **no media access** (DNS-only via AdGuard).
6. **DHCP fix approach = Option B**: investigate AGH's config schema so static leases survive its rewrite — fix at the config/schema level, NOT a hacky post-start re-copy oneshot.
7. Hostnames all-lowercase: `admin1`, `dumitru1`, `adela1`, `tiberiu1`, `david1`, `ramona1`, `tibisor1`, `iza1`, `kerem1`, `hannah1`, …

## New addressing layout (authoritative)

| User | Hostnames | LAN IPv4 | VPN IPv4 | Tier |
|---|---|---|---|---|
| admin | admin1-9 | 10.0.0.3-8 | 10.0.10.3-8 | admin |
| dumitru | dumitru1-9 | 10.0.0.9-19 | 10.0.10.9-19 | user |
| adela | adela1-9 | 10.0.0.20-29 | 10.0.10.20-29 | user |
| tiberiu | tiberiu1-9 | 10.0.0.30-39 | 10.0.10.30-39 | user |
| david | david1-9 | 10.0.0.40-49 | 10.0.10.40-49 | user |
| ramona | ramona1-9 | 10.0.0.50-59 | 10.0.10.50-59 | user |
| tibisor | tibisor1-9 | 10.0.0.60-69 | 10.0.10.60-69 | user |
| iza | iza1-9 | 10.0.0.70-79 | 10.0.10.70-79 | user |
| kerem | kerem1-9 | 10.0.0.80-89 | 10.0.10.80-89 | user |
| hannah | hannah1-9 | 10.0.0.90-99 | 10.0.10.90-99 | user |
| guests | — | 10.0.0.100-250 | none | guest |

**Current device→new-hostname mapping (MACs known):**
| Device | MAC | old hostname | NEW hostname | NEW LAN | NEW VPN |
|---|---|---|---|---|---|
| homelab | d0:67:e5:40:49:4e | homelab | (server, not a lease) | 10.0.0.2 | 10.0.10.2 (WG server) |
| router (Speedport) | — | — | (not a lease; no VPN) | 10.0.0.1 | none |
| Arch PC | 2c:9c:58:60:c8:25 | dumitru-pc | **admin1** | 10.0.0.3 | 10.0.10.3 |
| iPhone 17 Pro | f6:5b:6b:f3:0e:87 | dumitru-phone | **dumitru1** | 10.0.0.9 | 10.0.10.9 |
| iPhone XS | fe:02:26:df:0c:50 | adela-phone | **adela1** | 10.0.0.20 | 10.0.10.20 |
| Samsung TV | 00:c3:f4:ea:fe:a6 | adela-tv | **adela2** | 10.0.0.21 | 10.0.10.21 |
| Philips Air | 68:79:c4:29:1d:44 | adela-air | **adela3** | 10.0.0.22 | 10.0.10.22 |
| Galaxy S22U | da:08:7b:fe:cf:d7 | tiberiu-phone | **tiberiu1** | 10.0.0.30 | 10.0.10.30 |
| iPhone 17 Pro Max | 76:6f:b2:93:10:ce | david-phone | **david1** | 10.0.0.40 | 10.0.10.40 |
| Xbox One | c4:9d:ed:c9:9a:13 | david-xbox | **david2** | 10.0.0.41 | 10.0.10.41 |
| iPhone 11 | 56:ea:b4:79:06:61 | ramona-phone | **ramona1** | 10.0.0.50 | 10.0.10.50 |
| iPhone 14 | 26:05:a5:6c:e2:56 | tibisor-phone | **tibisor1** | 10.0.0.60 | 10.0.10.60 |
| iPhone 15 (iza) | **TODO** | iza-phone | **iza1** | 10.0.0.70 | 10.0.10.70 |
| iPhone 16 Pro (kerem) | **TODO** | kerem-phone | **kerem1** | 10.0.0.80 | 10.0.10.80 |
| iPhone 15 Pro (hannah) | **TODO** | hannah-phone | **hannah1** | 10.0.0.90 | 10.0.10.90 |

NOTE: the three TODO MACs stay as placeholders (human fills later via users.nix).

## Deliverables the plan must cover
1. **`users.nix`** (repo root or `modules/`): attrset `users.<name>` with tier (admin/user), and `devices = [ { hostname; mac; } ]`. **LAN and VPN IPs are DERIVED from the block layout** (hostname index → offset into the user's /10 range), so the human only edits hostname+mac. Committed to the repo. This becomes the source of truth consumed by adguard.nix, wireguard.nix, nginx.nix, and the QR renderer.
2. **DHCP static-lease fix** (the core bug): investigate AGH 0.107.78's config handling so `static_leases` survive AGH's rewrite. Hypotheses to test: (a) AGH expects `static_leases` under `dhcp.dhcpv4.static_leases` vs `dhcp.static_leases`; (b) a missing/incorrect `schema_version` triggers migration that drops it; (c) `mutableSettings` interplay. Deliver the correct YAML shape + verify leases persist after AGH restart (nix build + restart + grep).
3. **`adguard.nix`**: DHCP range 10.0.0.100-250 (guests), static leases generated from users.nix (all users), persistent clients keyed by user (admin + 9 users) with ids = their LAN+VPN IPs (drop hostname ids per human: "LAN IPv4 is enough to identify" — verify this against AGH, ids can be IP-only). Guests = no persistent client.
4. **`settings.nix`**: WG subnet → 10.0.10.0/24, **server 10.0.10.2** (human ruling: WG server on .2, mirroring the LAN server at 10.0.0.2; router is at 10.0.0.1 and needs no VPN), endpoint unchanged (vpn.dnanu.de:51820). Peers generated from users.nix (name = `<hostname>-vpn` e.g. admin1-vpn, admin flag from tier). Remove old hardcoded peer list.
5. **sops / wireguard.nix**: WG peer secret names become `wireguard_peer_<hostname>-vpn_{private,psk}`. **Re-use existing private keys** where the device is unchanged (rename sops keys; public keys unchanged). New keys only where a MAC was placeholder before (iza/kerem/hannah get real keypairs already exist from v2 — reuse). Renderer groups by user for profile pages.
6. **profile.dnanu.de / Authelia**: add **`admin` Authelia user** (10th account) + bcrypt password in sops users.yaml. `/admin` serves admin1-9 (admin tier note); `/dumitru` serves dumitru1-9, etc. User→peer mapping by username. Admin passwords: generate initial + store plaintext in Memory.md.
7. **nginx ACLs** (v3): admin vhosts allow admin LAN (10.0.0.3-8) + admin VPN (10.0.10.3-8); user vhosts allow user LAN (10.0.0.9-99) + all VPN (10.0.10.3-99); **guests (10.0.0.100-250) get NOTHING on LAN** (DNS-only). Rework mkAdminVhost/mkUserVhost ranges from users.nix.
8. **Docs**: OpenCode.md §3.1/§3.3/§3.4/§7/§9/§10/§12/§13, README, TODO (fill iza/kerem/hannah MACs), Changes.md, Memory.md. §16 refs unchanged.

## Constraints
- Native modules only. Zero open ports except 25/tcp + 51820/udp. Declarative. sops for secrets. Public-safe repo.
- Verify AGH schema against pinned 26.05 package (adguardhome 0.107.78) — the static-lease fix MUST be proven, not assumed.
- All-lowercase hostnames/usernames everywhere.
- Do NOT deploy until human approves; build + verify closure after each phase.
- The old WG peers at 10.0.1.x and old sops key names become obsolete — plan the rename/cleanup explicitly.

## Files affected (expected)
`users.nix` (new) · `settings.nix` · `modules/networking/{adguard,wireguard,nginx,base}.nix` · `modules/services/ios-profile.nix` (profile vhost, unchanged mostly) · `modules/services/authelia.nix` (admin user via sops) · `modules/system/sops.nix` · `secrets/secrets.yaml` (renamed WG keys, authelia admin user) · `OpenCode.md` · `README.md` · `Memory.md` (gitignored) · `TODO.md` (gitignored) · `Changes.md`

## Model recommendation
**GLM 5.2 (planner-high)** — multi-file re-architecture + a genuine AGH bug to diagnose. Human approved. Execution: nixos-builder (V4 Pro). No Kimi escalation.
