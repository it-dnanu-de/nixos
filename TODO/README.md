# TODO — Project work tracker

> Master index for the nanulab homelab. Each `NN-*/todo.md` covers one project area
> with per-service checklists. Source of truth for architecture = `OpenCode.md`.
> `OpenCode.md` §12 defines the frozen build order — this tracker mirrors it.

## Status legend
- `[x]` done and deployed
- `[~]` in progress / partially done
- `[ ]` pending

## Projects

| # | Project | Status | Progress |
|---|---------|--------|----------|
| 01 | [Foundation](01-Foundation/todo.md) | ✅ done | flake, settings, users, secrets |
| 02 | [Storage (ZFS + disko)](02-Storage/todo.md) | ✅ done (test box) | `/fast` `/slow`, ARC, hostId |
| 03 | [Networking](03-Networking/todo.md) | ✅ done | IP, firewall, DNS, WG, tunnel |
| 04 | [Mail](04-Mail/todo.md) | ✅ done + verified | SNM + Resend + hardening; mail-tester/MECSA/DANE green 2026-08-07 |
| 05 | [Identity & Access](05-Identity-Access/todo.md) | ✅ done | Authelia, WG peers, profiles |
| 06 | [Cloud Services](06-Cloud-Services/todo.md) | ✅ done | Nextcloud(+Office), Collabora, Immich, Vaultwarden (gen 81) |
| 07 | [Downloads & VPN](07-Downloads/todo.md) | ⬜ not started | qBit, SAB, slskd, confinement |
| 08 | [Arr Stack](08-Arr-Stack/todo.md) | ⬜ not started | Sonarr/Radarr/…, Seerr, soularr, beets |
| 09 | [Media Players](09-Media-Players/todo.md) | ⬜ not started | Jellyfin, Navidrome, ABS, Booklore |
| 10 | [Smart Home](10-Smart-Home/todo.md) | ⬜ not started | Home Assistant |
| 11 | [Monitoring & Backups](11-Monitoring-Backups/todo.md) | ⬜ not started | Beszel, Restic→B2 |
| 12 | [Websites](12-Websites/todo.md) | ⬜ not started | Hugo, dnanu.de |
| 13 | [Deployment](13-Deployment/todo.md) | ~ partial | installer, runbook, 1% manual |
| 14 | [Verification](14-Verification/todo.md) | ~ partial | §13 suite |
| 15 | [Phase 2 Backlog](15-Phase2-Backlog/todo.md) | ⬜ backlog | documented, NOT built |

## Next milestone (human-approved to build)
**Build step 5 (OpenCode.md §12): Cloud services** → `06-Cloud-Services/todo.md`
(Nextcloud + Collabora + Immich + Vaultwarden), then the media/download pipeline.

## Cross-cutting open items (blockers / manual)
- [ ] **IPv6 inbound/outbound through Speedport** — AAAA records published and resolving, but v6 connections time out (internet.nl mail 61% / dnanu 90% fail only on IPv6; dane.sys4 v6 timeout). 1% manual router pass-through (OpenCode.md §3.5, 03-Networking)
- [ ] iza / kerem / hannah MACs still `TODO` in `users.nix` (blocks Kea reservations)
- [ ] **Declarative Nextcloud account creation** — human requested; solution design pending (06-Cloud-Services)
- [ ] **Declarative file structure §5** — tree printed 2026-08-08, awaiting human approval
- [ ] Nextcloud 1% manual: link Mail app to IMAP, Office check, admin accounts (06-Cloud-Services)
- [ ] Switch dumitru iPhone off manual `10.0.0.3` → DHCP (Kea hands out `10.0.0.10`)
- [ ] Re-scan ALL WireGuard QRs post-v4 deploy (deployed gen is v2 `10.0.1.x`)
- [ ] Distribute Authelia passwords (10 users)
- [ ] Publish DS records at DENIC registrar (DNSSEC §3.7) — activates DANE (TLSA `3 1 1` already published + matching, verified 2026-08-07)
- [ ] Flip DMARC `p=quarantine` → `p=reject` after 30 clean days (current p=quarantine passing mail-tester 2026-08-07)
- [ ] `sshPubKey` placeholder in `settings.nix` — replace with real human key
- [ ] Prod migration: new hardware-configuration.nix + disko (2 pools) when hardware arrives
