# TODO — 05 Identity & Access

**Status:** ✅ done (deployed) · **Owner:** nginx/authelia/ios-profile modules · **File refs:** `modules/services/authelia.nix`, `modules/services/ios-profile.nix`

## Authelia (`authelia.nix`)
- [x] Single instance, 10 users (admin + 9 regular), users from sops `authelia_users_yaml` (bcrypt)
- [x] JWT + storage key from sops
- [x] Protects `profile.dnanu.de` (auth_request on nginx)
- [x] Logout fix: POST-only endpoint + inline JS (commits `1339005`, `3004661`)
- [ ] Distribute passwords to users (Memory.md has them)

## nginx ACL v4
- [x] Admin vhosts: LAN .1-.9 + VPN 10.0.10.3-9
- [x] User vhosts: LAN .10-.99 + VPN .3-.99
- [x] Guests (.100-.200): nothing (403)
- [x] Catch-all 404 on dead names

## Mobile profile / WG QR renderer (`ios-profile.nix`)
- [x] `wireguard-profile-render` oneshot → per-user .conf + QR PNGs to `/var/lib/mobileprofile/wg/<user>/`
- [x] Admin page shows 7 QRs (admin3-9-vpn), user pages 10 QRs
- [x] Served at `profile.dnanu.de/<user>/` behind Authelia
- [x] DNS no longer in mobileconfig (rides in WG configs; LAN via DHCP)
- [~] `.mobileconfig` signer: CA on Mac pending (unsigned OK for now — human ruling, Mac dead)
- [ ] Re-scan all WG QRs post-v4 deploy
- [ ] iOS: enable On-Demand (WiFi+Cellular) per device

## WireGuard peers
- [x] 97 peers pre-provisioned, keys in sops, pubkeys in wireguard-pubkeys.nix
- [ ] Spare slots claimed = fill MAC + rebuild
