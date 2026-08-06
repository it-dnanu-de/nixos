# Network addressing — v4 plan (human-authored 2026-08-06, rulings folded in)

Single source of truth for IP allocation. Each user owns a 10-IP block:
base device = `[user]` (no number, the primary device / username), then `[user]1` … `[user]9`.
Device names are dropped entirely (human ruling A1: "[user]1-9 sounds much better").

| Range | Who | Access |
|---|---|---|
| LAN `10.0.0.0-9` + VPN `10.0.10.0-9` | **admin** | all webUIs + server config; static |
| LAN `10.0.0.10-99` + VPN `10.0.10.10-99` | **users** | media/immich/nextcloud etc.; static |
| LAN `10.0.0.100-200` | **guests** | AGH DNS only, no services; dynamic (pool .100-.200) |
| LAN `10.0.0.201-254` | — | do not exist, cannot be assigned |

## admin (LAN 10.0.0.0-9 / VPN 10.0.10.0-9, 10 slots)
| LAN | name | VPN | note |
|---|---|---|---|
| 10.0.0.0 | `admin` | 10.0.10.0 `admin-vpn` | network address / n/a |
| 10.0.0.1 | `admin1` | 10.0.10.1 `admin1-vpn` | router / n/a |
| 10.0.0.2 | `admin2` | 10.0.10.2 `admin2-vpn` | dell = WG server |
| 10.0.0.3 | `admin3` | 10.0.10.3 `admin3-vpn` | arch (`2c:9c:58:60:c8:25`) |
| 10.0.0.4-8 | `admin4-8` | 10.0.10.4-8 | spare (TBS MAC) |
| 10.0.0.9 | `admin9` | 10.0.10.9 `admin9-vpn` | spare — NOW EXISTS (human ruling) |

## users (LAN 10.0.0.X / VPN 10.0.10.X, base = .X, then [user]1-9)
| user | base LAN | base VPN | real devices |
|---|---|---|---|
| dumitru | 10.0.0.10 | 10.0.10.10 | dumitru=iPhone (`f6:5b:6b:f3:0e:87`) |
| adela | 10.0.0.20 | 10.0.10.20 | adela=iPhone (`fe:02:26:df:0c:50`); adela1=TV (`00:c3:f4:ea:fe:a6`); adela2=Air (`68:79:c4:29:1d:44`) |
| tiberiu | 10.0.0.30 | 10.0.10.30 | tiberiu=Galaxy (`da:08:7b:fe:cf:d7`) |
| david | 10.0.0.40 | 10.0.10.40 | david=iPhone (`76:6f:b2:93:10:ce`); david1=Xbox (`c4:9d:ed:c9:9a:13`) |
| ramona | 10.0.0.50 | 10.0.10.50 | ramona=iPhone (`56:ea:b4:79:06:61`) |
| tibisor | 10.0.0.60 | 10.0.10.60 | tibisor=iPhone (`26:05:a5:6c:e2:56`) |
| iza | 10.0.0.70 | 10.0.10.70 | all TBS |
| kerem | 10.0.0.80 | 10.0.10.80 | all TBS |
| hannah | 10.0.0.90 | 10.0.10.90 | all TBS |

VPN naming: `[user]-vpn` (base) + `[user]1-vpn` … `[user]9-vpn`. Base hostname `[user]` = Authelia login (confirmed).
**Full pre-provision (ruling A-Q-B):** ALL slots get real WG keypairs + QRs now — 7 admin peers (admin3-vpn..admin9-vpn; admin-vpn/.0, admin1-vpn/.1 n/a, admin2-vpn/.2 = WG server) + 90 user peers (10/users × 9) = **97 WG peers, 194 sops keys**. Spare slots: MAC=TODO, IP reserved, QR already rendered.
MACs confirmed: adela1 TV = `00:c3:f4:ea:fe:a6` (c3), david1 Xbox = `c4:9d:ed:c9:9a:13` (c4) — both match current users.nix.
DHCP decision (B): migrate to **Kea** (`kea-dhcp4-server` + `kea-dhcp6-server`); AGH stays DNS-only. Guest pool .100-.200. `.201-.254` unassigned.

