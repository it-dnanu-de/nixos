# Changes.md — temporary session log (wiped into OpenCode.md at end of session)

## 2026-08-06 — Network v3 executed (user-block addressing, users.nix, AGH DHCP fix, WG 10.0.10.x)

### Phase A: `users.nix` + `flake.nix` + `settings.nix`
- Created `users.nix` at repo root — single source of truth for 10 users, blocks, devices (hostname + MAC), `userToIps` helper.
- `flake.nix`: `users = import ./users.nix;` in `specialArgs`.
- `settings.nix`: WG subnet `10.0.10.0/24`, server `10.0.10.2`, `peerPublicKeys` map (hostname→public key), removed hardcoded `peers` + `adminLan`.

### Phase B: AdGuard DHCP fix + `adguard.nix`
- **AGH 0.107.78 root cause:** static_leases silently dropped from YAML (Go struct has no field).
- **Fix:** removed `dhcp.static_leases`; added `systemd.services.adguardhome.preStart` writing `leases.json` from `users.nix` via `builtins.toJSON`. Only devices with real MACs (not `"TODO"`).
- DHCP guest range: `10.0.0.100-250`.
- Persistent clients: IP-only ids from `users.nix` (LAN+VPN), `user_admin`/`user_regular` tags.

### Phase C: WireGuard v3 + sops rename
- `wireguard.nix`: peers derived from `users.nix` (hostname-vpn naming: `admin3-vpn`, `dumitru1-vpn`, etc.), WG subnet `10.0.10.0/24`.
- sops: 26 keys renamed (13 peers × 2), values preserved.

### Phase D: Authelia admin + nginx ACL v3
- `authelia_users_yaml`: added 10th user `admin` (bcrypt hash, groups: [admin]). Password in Memory.md.
- `nginx.nix`: ACL helpers derive admin/user allowlists from `users.nix`. Admins: 10.0.0.3-8 + 10.0.10.3-8. Users: 10.0.0.9-99 + 10.0.10.9-99. Guests denied.

### Phase E: Docs
- OpenCode.md §3.1, §3.3, §3.4, §6, §7, §9, §10, §12, §13 — v3 amendments.
- README: status update. Memory.md: WG v3 + admin password. Changes.md (this file).

**Build:** clean `nix build` exit 0, zero deprecation warnings.
**Commit:** `bc4d815` — all 5 phases in one commit.

---
(previous session history preserved below)
