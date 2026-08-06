# Task: Network v4 — [user]1-9 naming, full WG pre-provision (97 peers), Kea DHCP migration, AGH DNS-only — for Kimi K3 (Maximum reasoning planner)

Source: human-authored addressing plan 2026-08-06 (saved at `docs/network-addressing.md`) + Q&A rulings. Created by Flash per Session Workflow.
**Tier: Max (Kimi K3)** — human explicitly chose Kimi this time. Execution after plan approval: nixos-builder (DeepSeek V4 Pro).

## Context / why v4
v3 shipped (users.nix, WG 10.0.10.x, nginx ACL v3, AGH leases.json preStart) but three things remain broken/undesired:
1. **AGH DHCP static leases don't apply at runtime** — leases.json has the 10 statics but AGH hands out guest IPs anyway (arch still on 10.0.0.103); AGH UI shows empty static-lease table. AGH 0.107.78 DHCP is unreliable here.
2. Naming wants a **simpler scheme**: drop `[user]-[device]`; use `[user]1-9` (base = `[user]`, no number).
3. The human wants the **full 10-slot-per-user block pre-provisioned**: every slot gets a WG keypair + QR now, so a new device only needs its MAC filled in users.nix.

## Human rulings (2026-08-06) — bake in verbatim
- **A1:** Drop `[device]` names. Base device = `[user]` (no number, = Authelia login), then `[user]1`…`[user]9`. Addresses shift: arch stays admin3 @ `.3`; each user's base starts one higher than v3 (dumitru base @ `10.0.0.10`, adela @ `.20`, tiberiu @ `.30`, david @ `.40`, ramona @ `.50`, tibisor @ `.60`, iza @ `.70`, kerem @ `.80`, hannah @ `.90`).
- **A2 (MAC corrections):** adela1 (TV) = `00:c3:f4:ea:fe:a6` (c3). david1 (Xbox) = `c4:9d:ed:c9:9a:13` (c4). (These match the CURRENT users.nix — the human's v4 doc had typos.)
- **Decision B:** Migrate DHCP **off AdGuard to Kea** (`services.kea.dhcp4-server` + `services.kea.dhcp6-server`). AGH becomes **DNS-only**. Need DHCPv4 AND DHCPv6.
- **Guests:** DHCP pool `10.0.0.100-200`. `.201-.254` unassigned. Guests: AGH DNS only, no services, dynamic, no VPN.
- **admin9 EXISTS:** admin block = 10 slots `.0-.9` (admin0=.0 network addr, admin1=.1 router, admin2=.2 dell=WG server, admin3=arch, admin4-9 spare). ACL covers LAN `.0-.9` + VPN `10.0.10.3-9` (peers; server is `.2`).
- **Q-A confirmed:** DHCP hostname base = `[user]` (same string as Authelia login). WG peer names = `[user]-vpn` + `[user]1-vpn`…`[user]9-vpn`.
- **Q-B = FULL PRE-PROVISION:** ALL slots get real WG keypairs + QRs now. Total: **97 WG peers** = 7 admin (admin3-vpn…admin9-vpn; admin-vpn/.0 and admin1-vpn/.1 are n/a, admin2-vpn/.2 = WG server itself) + 90 user peers (9 users × 10). = **194 sops keys** (private+psk per peer). Spare slots: MAC=`TODO`, IP reserved, QR already rendered. When a device claims a slot: fill MAC in users.nix → rebuild → AGH/Kea lease + existing QR now usable.
- **profile.nanulab.de is dead** — remove the `*.nanulab.de`→10.0.0.2 rewrite? NO — other nanulab services (adguard.nanulab.de) still need it. Only remove the specific old profile.nanulab.de handling (it was already renamed to profile.dnanu.de). Verify what nginx does with unmatched nanulab hosts (it currently falls through to adguard dashboard — that's wrong for a dead name; decide: delete DNS record or return 404).

## Addressing schema (authoritative — `docs/network-addressing.md`)
| Range | Who | Access |
|---|---|---|
| LAN `10.0.0.0-9` + VPN `10.0.10.0-9` | admin | all webUIs; static |
| LAN `10.0.0.10-99` + VPN `10.0.10.10-99` | users | media/immich/nc; static |
| LAN `10.0.0.100-200` | guests | DNS only, dynamic |
| `.201-.254` | — | unassigned |

admin: `.0` admin(0)/network · `.1` admin1 router · `.2` admin2 dell (=WG server `10.0.10.2`) · `.3` admin3 arch (`2c:9c:58:60:c8:25`) · `.4-9` admin4-9 spare.
users (base @ block start, then 1-9): dumitru `.10` base=iPhone(`f6:5b:6b:f3:0e:87`) · adela `.20` base=iPhone(`fe:02:26:df:0c:50`), adela1=TV(`00:c3:f4:ea:fe:a6`), adela2=Air(`68:79:c4:29:1d:44`) · tiberiu `.30` base=Galaxy(`da:08:7b:fe:cf:d7`) · david `.40` base=iPhone(`76:6f:b2:93:10:ce`), david1=Xbox(`c4:9d:ed:c9:9a:13`) · ramona `.50` base=iPhone(`56:ea:b4:79:06:61`) · tibisor `.60` base=iPhone(`26:05:a5:6c:e2:56`) · iza `.70` / kerem `.80` / hannah `.90` all TODO.

## Deliverables the plan must cover
1. **users.nix v4** — restructure: `blocks` shifted (admin base 0, dumitru 10, adela 20, … hannah 90, 10 slots each), `users.<name>.devices` = 10 entries each (hostname `[user]`, `[user]1`…`[user]9`; mac real or `TODO`). `userToIps` unchanged (lan/vpn = block + idx-1). Guests `{ lanStart="10.0.0.100"; lanEnd="10.0.0.200"; }`. Admin block: entries for admin0..admin9 with admin2 marked as the WG server (no peer), admin-vpn/admin1-vpn marked n/a.
2. **Kea DHCP migration (Decision B)** — `services.kea.dhcp4-server` + `services.kea.dhcp6-server` replacing AGH DHCP. Verify options in pinned 26.05 (`services.kea.*`). Config: interface enp10s0, v4 pool `.100-.200`, **host reservations** for all real-MAC devices (admin3, dumitru, adela/adela1/adela2, tiberiu, david/david1, ramona, tibisor) with their static IPs, DHCPv6 enabled (SLAAC or stateful? decide — the human wants v6 assignment ability). Remove AGH `dhcp` block + `leases.json` preStart (no longer needed). AGH keeps DNS (rewrites, filters, persistent clients).
3. **WG pre-provision (97 peers)** — generate keypairs for ALL 97 peers. 10 reused (real devices: admin3, dumitru, adela, adela1, adela2, tiberiu, david, david1, ramona, tibisor — reuse existing sops keys where possible) + 87 NEW spare peers (admin4-9 = 6, plus 81 user spares). All privates+PSKs → sops (`wireguard_peer_<hostname>-vpn_{private,psk}`), publics → settings/users. Profile renderer renders QRs for ALL slots.
4. **settings.nix / wireguard.nix** — peers fully from users.nix (all 97), server `10.0.10.2`, subnet `10.0.10.0/24`.
5. **nginx ACL v4** — admin vhosts: allow admin LAN `10.0.0.1-9` (server itself is local; include router+dell? decide) + admin VPN `10.0.10.3-9`. User vhosts: allow user LAN `10.0.10-99` + all VPN `10.0.10.3-99`. Guests `.100-.200` nothing. AdGuard UI: admin-tier.
6. **Authelia** — 10 users unchanged (admin + 9). Profile page `/admin/` shows 7 QRs (admin3-9), `/dumitru/` shows 10 (dumitru + dumitru1-9), etc. Verify per-user page lists ALL of that user's peers.
7. **profile.nanulab.de dead-name handling** — decide + implement (likely: keep `*.nanulab.de` rewrite for adguard, but ensure a dead name returns 404 not the adguard dashboard; or drop the wildcard and add per-service rewrites).
8. **Docs** — OpenCode.md §3.1/§3.3/§3.4/§7/§9/§10/§12/§13, README, docs/network-addressing.md (already updated), Changes.md, Memory.md, TODO.md.

## Constraints
- Native modules only. Kea/AGH/WG/nginx all native. Zero open ports except 25/tcp + 51820/udp.
- Declarative; sops for secrets; public-safe repo. MACs are not secret (users.nix committed per human ruling).
- Verify `services.kea` module + option names against pinned nixos-26.05 before writing.
- 97-peer keygen is a lot of sops writes — plan a scripted, idempotent approach (executor can run it), and specify how unused (TODO-MAC) peers behave on the profile page (QRs present but the config references a key that exists — fine).
- Do NOT deploy until human approves; build + verify closure after each phase.
- The iPhone is currently manually set to 10.0.0.3 (admin3) by the human for testing — the plan should note that after v4, dumitru's iPhone base = 10.0.0.10 (its real slot) and it should get DHCP from Kea, not a manual IP.

## Files affected (expected)
`users.nix` (restructure) · `docs/network-addressing.md` · `settings.nix` · `modules/networking/{adguard,wireguard,nginx,base}.nix` · new `modules/networking/kea.nix` (or fold into base) · `modules/system/sops.nix` · `secrets/secrets.yaml` (194 WG keys) · `modules/services/ios-profile.nix` · `modules/services/authelia.nix` · `flake.nix` · `OpenCode.md` · `README.md` · `Memory.md` · `TODO.md` · `Changes.md`

## Model recommendation
**Kimi K3 (planner-max)** — human explicitly requested Kimi this cycle. Execution: nixos-builder (V4 Pro). Troubleshooting: Flash.
