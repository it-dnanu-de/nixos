# Changes.md — temporary session log (wiped into OpenCode.md at end of session)

## 2026-08-07 — Cloudflare tunnel restored to declarative (config_src=local)

### Problem
- The user added a "Published application" route in the Cloudflare dashboard for `profile.dnanu.de`.
- Cloudflare flipped the tunnel `62ab1635` to **remote-managed** (`config_src=cloudflare`).
- cloudflared then ignored the NixOS-declared `cloudflared.yml` and served only whatever the
  edge pushed. After the user deleted all dashboard routes, the remote config became
  `ingress: [http_status:404]` — all 5 public hostnames dead (404/502).
- profile got 502 because the dashboard route for it was `https://localhost:443` **without**
  `originRequest.noTLSVerify=true` (not expressible in the dashboard form) — cert is for
  `*.nanulab.de`, not `localhost`.

### Fix — recreate tunnel as local-config
- `config_src` is only settable at tunnel **creation** (no PATCH path; verified against the
  Cloudflare OpenAPI schema in `/tmp/opencode/cf_openapi.json`).
- Created new tunnel `734c3fa5-7b72-4cfb-8003-f1cab01743ee` (name `homelab`) with
  `config_src=local` + fresh 32-byte secret via account API. Zone-scoped token can't do it
  (Not authorized) — needed the new account-scoped `cloudflare_account_token`.
- `settings.nix`: tunnelId `62ab1635` → `734c3fa5`.
- sops: `cloudflared_tunnel_cred` → new TunnelID + TunnelSecret (kept as JSON string — sops
  `--set` first wrote it as a YAML map which cloudflared can't parse; re-set as string).
- sops: added `cloudflare_account_token` (`cfut_QKa1...`); `sops.nix` registers it.
- Deployed: server gen 71 → 72. Old tunnel deleted via API once new one verified healthy.
- **Verified live:** dnanu.de 200, www 200, autoconfig 200, mta-sts 200, profile 302 (Authelia).
  DNS CNAMEs all → `734c3fa5...cfargotunnel.com` (proxied). Local config now the source of truth.
- Commit: `59de856` (before server pull+rebuild).

---
(previous session history preserved below)

## 2026-08-07 — Kimi K3 Mail Security Audit — fix implementation (nixos-builder)

### Batch 1: MUST-FIX — Finding 1: Firewall scope
- `base.nix`: Global allowedTCPPorts → [25]; allowedUDPPorts → [51820].
- extraCommands (iptables backend): TCP 53,80,443,465,587,993 + UDP 53/67/547 source-scoped to LAN/ULA/link-local.
- Verified generated firewall script — rules land before final reject, NOT extraInputRules.
- Commit: `1cc615f`

### Batch 2: SHOULD-FIX — Findings 2+3: DNS upsert + visibility
- upsert() now PATCHes first match, DELETEs remaining (multi-record clobber guard).
- CURL() added --fail; removed stderr suppression; Restart=on-failure + daily timer.
- Commit: `2862d23`

### Batch 3: SHOULD-FIX — Finding 7: TLSA-sync failure alert
- cloudflare-tlsa-alert.service: Resend API alert on TLSA sync failure.
- OnFailure= wired on cloudflare-tlsa-sync.service.
- Commit: `b2f70eb`

### Batch 4: NICE-TO-HAVE — Findings 4,6,8,9,10
- F4: watchdog uses -H @tempfile (key off /proc/*/cmdline).
- F6: deleteRecord covers wildcard AAAA for *.nanulab.de.
- F8: sieve interpolates ${settings.domains.public} (not hardcoded dnanu.de).
- F9: sops template group=postfix, mode=0440 for postfix-sasl-passwd.
- F10: OpenCode.md §7 (mail_hey → mail_hey), §8 (cert group claim corrected).
- F5 (Cloudflare token argv): SKIPPED — LOW, sub-second oneshot, single-user box.
- Commit: `446b74d`

### Final build: exit 0, zero warnings.

## 2026-08-06 — Enterprise Mail Hardening (Kimi K3 plan, nixos-builder execution)

### Phase A: DNS records + MTA-STS serving + DKIM fix
- `cloudflare-dns.nix`: Added upserts for _mta-sts TXT, _smtp._tls TXT, mta-sts CNAME.
- `cloudflare-dns.nix`: Replaced cloudflare-dkim-sync — IDEMPOTENT grep-based parser (no paren bug),
  Restart=on-failure (survives boot DNS races), after=rspamd.service, PATCH-in-place (no delete gap).
- `cloudflare-dns.nix`: Added cloudflare-tlsa-sync service + timer (DANE 3 1 1, auto-synced from ACME cert).
- `cloudflare.nix`: Added mta-sts.dnanu.de → 127.0.0.1:8080 ingress rule.
- `mail.nix`: Added MTA-STS nginx vhost (world-readable, mode=enforce, serve via cloudflared).
- Build: exit 0, zero warnings. Commit: `2a3b978`

### Phase B: postfix/rspamd hardening
- `mail.nix`: Added systemContact, tlsrpt.enable, dmarcReporting.enable to mailserver.
- `mail.nix`: Static tls_policy map with `[smtp.resend.com]:465 verify` (upgraded from unverified encrypt).
- `mail.nix`: Removed `smtp_tls_security_level = lib.mkForce "encrypt"` (tlspol + tls_policy handle it now).
- `mail.nix`: RFC-conformance restrictions — helo_required + reject_non_fqdn_helo/invalid_helo/sender/recipient + unknown_sender/recipient_domain + unauth_pipelining. Minimal, FP-safe.
- `mail.nix`: rspamd locals — reject 15→12 (actions.conf), spamhaus disabled (rbl.conf, unreachable via public resolvers).
- Verified: services.tlsrpt.enable=true, dmarcReporting.enable=true, systemContact="admin@dnanu.de".
- Build: exit 0, zero warnings. Commit: `4897a60`

### Phase C: ACME TLSA hook
- `acme.nix`: Added pkgs to module args; certs.mail.dnanu.de.postRun triggers cloudflare-tlsa-sync (--no-block, || true).
- postRun fires only on actual renewal (nixpkgs checks for renewed marker dir).
- Build: exit 0, zero warnings. Commit: `f1acb1b`

### Phase D: Monitoring
- `mail.nix`: mail-queue-watch oneshot + timer (every 15 min). Checks: postfix/dovecot2/rspamd active, queue >2, oldest >30 min.
- Alerts via Resend HTTPS API (independent of local postfix). Rate-limited: one alert per 6h.
- Added pkgs.postfix to service path (postqueue binary).
- Build: exit 0, zero warnings. Commit: `4b69638`

### Phase E: Docs
- OpenCode.md: §4.1 hardening note, §4.3 updated relay config + tls_policy, §4.4 DNS table (MTA-STS/TLS-RPT/TLSA rows + DMARC rua fix), §4.5 new (D1-D7 hardening & monitoring notes), §12 1% manual (mail-tester/internet.nl + DMARC flip + DS/DANE activation note), §15 (remove MTA-STS/TLS-RPT from backlog, add DANE activation cross-note), §16 (RFC 8460/8461/6698/7489 references + Resend API).
- README: Updated status — mail hardening phase, expanded "what works" with new features.
- Changes.md: This session log.

---
(previous session history preserved below)

## 2026-08-06 — IPv6 GUA enabled + mail.dnanu.de AAAA

- **Root cause:** Deployed Tailscale (gen 45) set `net.ipv6.conf.all.forwarding=1` which blocks SLAAC. Current repo has no Tailscale — v6 forwarding gone.
- **`base.nix`:** Added explicit `boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = false` as defense-in-depth.
- **ddclient:** Defaults `usev6=webv6,webv6=ipify-ipv6` — auto-publishes AAAA for `mail.dnanu.de` + `vpn.dnanu.de` once GUA is present.
- **Firewall:** No change — nftables `inet` family already covers v6 :25.
- **Cloudflare:** AAAA records created manually (ddclient needs pre-existing records to update). `mail.dnanu.de AAAA` → `2003:c8:c704:3584:...` resolves publicly.
- **Deploy note:** After `nixos-rebuild switch`, default v6 route arrives from Speedport RA within ~30s. ddclient needs the default route to reach ipify-ipv6.

## 2026-08-06 — Network v4 executed: [user]1-9 naming, 97-peer WG, Kea DHCP, AGH DNS-only

### Phase A: users.nix v4 + 97-peer keygen + settings/wireguard v4
- `users.nix` v4: 10 explicit device entries per user (100 total), base=[user] + [user]1-9. Blocks shifted: admin=0, dumitru=10, adela=20, ... hannah=90. admin0/1/2 have role=infra/server (not WG peers). Guests .100-.200.
- Helpers in pure builtins: `isPeer`, `wgPeers` (97), `wgPeerNames`, `dhcpReservations` (10 real-MAC entries). `userToIps` unchanged.
- `scripts/gen-wg-keys.sh`: idempotent two-pass v3→v4 rename (12 pairs × 2 suffixes = 20 keys staged/renamed, values preserved) + generate 84 missing peers (168 keys). Self-checks: 194 sops keys, 97 pubkeys.
- `wireguard-pubkeys.nix`: 97 entries generated, committed (public keys are not secret).
- `settings.nix`: peerPublicKeys = import ./wireguard-pubkeys.nix. Comment refreshed for v4.
- `wireguard.nix`: peers = users.wgPeers (97). Strict publicKey lookup (no REPLACE_ME fallback).
- Build: exit 0, zero new warnings. Commit: `9d5a473`

### Phase B: Kea DHCP migration (Decision B)
- New `modules/networking/kea.nix`: services.kea.dhcp4 (pool .100-.200, 10 host reservations from users.nix dhcpReservations, options routers/domain-name-servers/domain-name) + services.kea.dhcp6 (ULA fd10::/64, pool fd10::100-200, dns-servers=fd10::2, domain-search=lan). Option names verified: NO -server suffix.
- `adguard.nix`: removed dhcp block + leases.json preStart. bind_hosts += "::". runtime_sources.dhcp = false. Persistent clients rebuilt via isPeer filter + infra entry (router 10.0.0.1, server 10.0.0.2 + 10.0.10.2).
- `base.nix`: ULA fd10::2/64 on enp10s0, accept_ra=1 sysctl (keep SLAAC GUA), firewall UDP 547.
- `configuration.nix`: import kea.nix.
- Build: exit 0, zero new warnings. Gates: kea.dhcp4.enable=true, 10 subnet4 reservations, AGH no dhcp key. Commit: `694ccc9`

### Phase C: nginx ACL v4 + dead-name catch-all
- `nginx.nix`: ACL allowlists derived via isPeer filter. Admin: LAN .1-.9 + VPN 10.0.10.3-9. User: LAN .1-.99 + VPN 10.0.10.3-99.
- Catch-all vhost: serverName "_", default=true on 0.0.0.0:443+80, addSSL with *.nanulab.de cert, return 404. Fixes dead-name fall-through (profile.nanulab.de was leaking AdGuard dashboard).
- ios-profile.nix / authelia.nix verified consistent: per-user renderer shows all peers (admin=7 QRs, users=10 QRs).
- Build: exit 0, zero new warnings. Commit: `46992dc`

### Phase D: Docs
- OpenCode.md: §3.1 (Kea DHCP, v4 blocks, ULA), §3.3 (97 peers, full pre-provision), §3.4 (AGH DNS-only, catch-all 404), §3.5 (Kea DHCPv6, ULA), §6 (users.nix v4, wireguard-pubkeys.nix, scripts/), §7 (194 WG keys), §9 (Kea row, AGH DNS-only), §10 (profile pages list all slots), §12 (deploy: disable Speedport DHCPv4, iPhone DHCP, QR re-scan), §13 (Kea verification, catch-all 404, 97 peers check).
- README: v4 status update.
- Memory.md: v4 facts (naming, 97 peers, renames, Kea option-name correction, ULA fd10::/64, iPhone-manual-IP, AGH-DHCP-retired, sops set/unset workflow).
- Changes.md: this file.

---
(previous session history preserved below)

## 2026-08-06 — Network v4 post-deploy fixes (verification round)
- **Logout 405 fixed:** Authelia `/api/logout` is POST-only; the link was a GET. Fixed in two passes: (1) form→POST, (2) since Authelia needs `{"targetURL":...}` in the POST body (returns only `safeTargetURL`, frontend JS does the redirect), reverted an invalid `error_page 200` nginx approach (nginx only accepts 300-599) and instead added a tiny inline JS logout (`fetch` POST with targetURL body → redirect to root). Commits `1339005`, `11cde3b` (reverted), `3004661`.
- **Verified end-to-end:** logout → `{"status":"OK","data":{"safeTargetURL":true}}`, session cleared, next request 302 → login. nginx healthy.
- **Step-10 verification all green:** Kea leases (arch 10.0.0.3, iPhone 10.0.0.10) · adguard 200 on LAN+WG for admin · profile admin=7 QRs / dumitru=10 QRs · dead name 404 · guest 403 · iPhone cellular adblock via WG · WG handshake <5s.
- **Arch client:** needed `pacman -S openresolv` for wg-quick DNS (resolvconf) — now up as admin3-vpn.
