---
name: security-hardening
description: Use when configuring or auditing security — DNSSEC, TLS/ACME, firewall/ports, SSH policy, mail anti-abuse, or anything touching exposure to the internet.
---

# Security Hardening

## Zero-exposure model (OpenCode.md §3.2) — LOCKED
| Flow | Path | Ports open on router |
|------|------|----------------------|
| Inbound SMTP | Internet -> mail.dnanu.de -> router fwd -> 10.0.0.2:25 | **25/tcp only** |
| Public blogs + autoconfig | Cloudflare edge -> cloudflared tunnel -> nginx :8080 | none |
| Everything else | Device -> Tailscale -> 10.0.0.2 | none |
| Outbound mail | Postfix -> smtp.resend.com:465 | none |
| Downloads | confined netns -> AirVPN WireGuard | none |

- If you open a port that isn't in this table, stop and ask. The whole network architecture depends on it.

## TLS (OpenCode.md §8)
- `security.acme` DNS-01 via Cloudflare/lego for `*.nanulab.de`, `*.dnanu.de`, `mail.dnanu.de`.
- Cert group readable by nginx, dovecot2, postfix; `reloadServices` set. No HTTP-01 (port 80 closed).

## DNSSEC (requested)
- Enable DNSSEC on the Cloudflare zones for `dnanu.de` and `nanulab.de` (human action in the dashboard), then verify with `dig +dnssec ... SOA` (AD flag, RRSIG).
- Keep mail SPF/DKIM/DMARC records correct while DNSSEC is on — a mismatched chain breaks delivery.
- Reminder: `mail.dnanu.de` A record must stay grey-cloud/unproxied or SMTP breaks.

## SSH
- Password auth is **intentionally allowed** on the homelab. Never disable it.
- Keys are fine in addition; don't remove password support.

## DNS/Split-horizon
- AdGuard DNS rewrites: `*.nanulab.de` + `mail.dnanu.de` -> 10.0.0.2; everything else -> quad9 upstream. `mutableSettings = false` so rewrites stay declarative.
- Public `*.nanulab.de` -> Tailscale `100.x` IP (grey cloud) so names resolve even off AdGuard.

## Secret hygiene
- sops-nix only; age key on USB + password manager, never in repo or /nix/store. Repo is public-safe.
- Run the `security-reviewer` agent for any audit; it enforces the checklist above.
