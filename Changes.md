# Changes.md — temporary session log (wiped into OpenCode.md at end of session)

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
