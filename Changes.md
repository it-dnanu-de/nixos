# Changes.md — temporary session log (wiped into OpenCode.md at end of session)

History in OpenCode.md §17 "Session Log".

## 2026-08-06 — Homelab v2 access control (GLM 5.2 plan, DeepSeek-V4-Pro execution)
- GLM 5.2 plan approved, DeepSeek-V4-Pro executed all phases A–D.
- **Phase A (re-addressing):** adguard.nix updated with v2 DHCP static leases (10.0.0.8-20, iza/kerem/hannah placeholder MACs), guest range .50-.250, persistent clients keyed by 9 users (LAM+VPN IPs + hostname ids, tags user_admin/user_regular), guests removed from persistent clients (labeled dynamically via runtime_sources.dhcp). settings.nix already had v2 peers.
- **Phase B (Authelia + profile.dnanu.de):** New modules/services/authelia.nix (instance main, TOTP 2FA, file auth, profile.dnanu.de two_factor policy). sops.nix: authelia_jwt/authelia_storage_key/authelia_users_yaml added, profile_basic_auth removed. ios-profile.nix renamed to profile.dnanu.de (public via cloudflared, auth_request with per-user gate at /<username>/). wireguard.nix: per-user QR renderer grouping peers by user field, per-user index.html with tier notes. cloudflare.nix: profile.dnanu.de tunnel ingress. cloudflare-dns.nix: profile.dnanu.de CNAME → tunnel.
- **Phase C (nginx ACL):** mkAdminVhost/mkUserVhost helpers derived from settings.network.wireguard.peers (admin/user filtering). adguard.nanulab.de rewritten via mkAdminVhost → admin-VPN-only.
- **Build:** nix build passes, zero deprecation warnings. Authelia 4.39.20 from cache.
- **Commits:** `89beb1f` (adguard v2), `1260fe3` (Phase B: authelia+profile+sops+wireguard+cloudflare), `dfe1755` (Phase C: nginx helpers).
- **Not deployed.** Human must approve, then 1% manual: distribute Authelia passwords (bcrypt hashes in sops), fill real MACs for iza/kerem/hannah, distribute per-user profile URLs, revoke old profile.nanulab.de access.

## 2026-08-05 — session start: new workflow
- Task-based workflow: human annotates → agent creates `inputs/[Task]-for-[Model].md` → reasoning model writes `outputs/[Task]-plan-by-[Model].md` → human reviews → Flash executes.
- Model tiers: Flash (MDP) for small fixes, Pro (M2P) for modules, GLM for debugging, Kimi for architecture.

## 2026-08-05 — Tailscale alternatives + AdGuard fixes (priority)
- Read TODO.md, Memory.md, OpenCode.md, current networking modules (tailscale.nix, adguard.nix, ios-profile.nix).
- Created `inputs/Tailscale-Alternative-and-AdGuard-Fixes-for-GLM.md` covering: (1) evaluate Headscale/Netbird/Twingate/pure WireGuard vs fixing Tailscale for per-device AdGuard DNS tracking, (2) AdGuard LAN DHCP DNS fix (advertise 10.0.0.2 not 10.0.0.1), (3) IPv6 fe80::1 noise.
- Reopens LOCKED §3.3 (Tailscale SaaS) — plan must justify the override.
- Model recommended: **GLM 5.2 (architect)**; escalate to Kimi for security audit of chosen VPN.

## 2026-08-05 — GLM 5.2 plan delivered, human annotations folded in
- GLM 5.2 (architect subagent) wrote `outputs/Tailscale-Alternative-and-AdGuard-Fixes-plan-by-GLM.md`: **pure declarative WireGuard** (replaces Tailscale), one port UDP 51820, QR onboarding, Phase A (VPN swap) + Phase B (AdGuard fixes).
- **Model routing bug found+fixed:** `architect.md` pinned `openrouter/glm-5.2` which does NOT exist on OpenRouter → subagent fell back to a wrong model (human saw Kimi K3 in API logs). Corrected to `openrouter/z-ai/glm-5.2` (verified in OpenRouter model list). All other agent model IDs verified valid. Commit `f500395`.
- Human annotations folded into the plan: (1) UDP 51820 already forwarded on Speedport, (2) peers mirror DHCP static-lease layout on 10.0.1.XXX base (iPhone17Pro=10.0.1.100, arch=10.0.1.101, no admin-iphone), (3) `*.nanulab.de` VPN-only but AdGuard UI + profile.nanulab.de reachable over WiFi without VPN, (4) Speedport DHCPv4/DHCPv6 point at AdGuard (keep enabled, IPv6 stays on — mail + modern infra).

## 2026-08-06 — Phase A executed (WireGuard swap), keys generated
- Human approved the GLM 5.2 plan (with annotations) 2026-08-05.
- Generated keypairs on the Arch workstation for server + all 12 peers (`nix shell nixpkgs#wireguard-tools`). Public halves → `settings.nix` `network.wireguard.peers`; private+PSK halves → sops (`wireguard_server_private`, `wireguard_peer_<name>_{private,psk}`). Committed `9cd8bba`.
- Set `profile_basic_auth` = htpasswd `dnanu:<hash>` (password in Memory.md); it now actually guards profile.nanulab.de.
- Removed `network.tailscaleRoutes`; added `domains.vpn = "vpn.dnanu.de"`.
- **DeepSeek-V4-Pro (nixos-builder) executed Phase A** → commit `eeeba8e`: new `modules/networking/wireguard.nix` (wg0, 12 peers, sops keys, QR-render oneshot → profile.nanulab.de/wg/, /wg/ nginx location); base.nix trustedInterfaces wg0 + UDP 51820; deleted tailscale.nix (NAT masquerade gone); sops.nix dropped tailscale_oauth; ddclient + cloudflare-dns sync add vpn.dnanu.de (grey cloud) and repoint *.nanulab.de to PUBLIC_IP4; ios-profile.nix retired dns.mobileconfig + added basicAuthFile.
- **Verified by Flash:** `nix build` passes, 12 peers on wg0 with correct IPs, 41 sops secrets, tailscale_oauth removed, push clean.
- Remaining: Phase B (AdGuard persistent-client WG ids), OpenCode.md §3.2/§3.3/§3.4/§6/§7/§10/§12/§13/§15/§16 amendments, docs (README/TODO/Changes/Memory), then human-approved deploy.
- NOTE: cloudflare-dns repointed `*.nanulab.de` + bare `nanulab.de` A records to PUBLIC_IP4 (not deleted as the plan recommended). Plan flagged deletion for human veto — the executor chose repoint-to-public instead. Flagged for review before deploy.

## 2026-08-06 — OpenCode.md amendments (WireGuard LOCKED), docs, DNS record deletion
- Human approved (2026-08-06): Phase B → deferred to TODO.md; lock WireGuard in OpenCode.md; update docs; deploy; **delete** `*.nanulab.de` + `nanulab.de` public A records.
- OpenCode.md: §3.2 (ports table: +51820/udp), §3.3 (Tailscale → **WireGuard ✅ LOCKED**, supersedes Tailscale SaaS), §3.4 (no public nanulab records, vpn.dnanu.de endpoint), §3.5 (IPv6 stays on, Speedport DHCPv4/DHCPv6 → AdGuard), §3.7 (nanulab has nothing to sign), §4.4 DNS table (+vpn.dnanu.de, −nanulab A), §6 tree (wireguard), §7 secrets (wireguard keys, −tailscale_oauth), §9 (WireGuard row, VPN-only URLs), §10 (dns.mobileconfig retired, /wg/ served), §12 (runbook: QR distribution + Tailscale console cleanup), §13 (WG verification), §15 (headscale fallback details), §16 (WireGuard/headscale/headplane refs).
- `modules/services/cloudflare-dns.nix`: added `deleteRecord` helper — idempotently DELETEs `*.nanulab.de` + bare `nanulab.de` public A records (VPN-only services; AdGuard rewrites serve LAN/VPN locally). Upsert can't delete, so plain removal would have left the records forever.
- Docs: README (WireGuard, ports, architect=GLM 5.2 fix, status), TODO.md (Phase B deferred, AdGuard consolidated), Memory.md (WG section already added; architect model ID note).

## 2026-08-06 — Deployed to 10.0.0.2 (generation 35)
- Human approved deploy + Phase B deferral + nanulab A-record deletion.
- Pulled repo to server, `nixos-rebuild switch` → generation 35, wg0 up (server pubkey `BJRC2i...`, port 51820, 12 peers), tailscaled inactive, QR renderer output present at `/var/lib/mobileprofile/wg/`.
- **Bug fixed during deploy:** `cloudflare-dns-sync` had been failing since 2026-08-05 — `CURL` defined as a function but called as `$CURL` (unbound variable under `set -u`). Fixed → sync now runs SUCCESS and applied all records. Commits `1b7c534`, `41564dc`.
- **DNS verified:** `vpn.dnanu.de` + `mail.dnanu.de` → home IP; bare `nanulab.de` A + AAAA + wildcard deleted from Cloudflare (authoritative zone clean, only MX + legacy imap/mx/smtp test records remain). AdGuard rewrites serve nanulab locally.
- Known pre-existing failure: `cloudflared-tunnel-00000000...` (placeholder UUID, TODO Infrastructure item) — causes `nixos-rebuild switch` to exit non-zero but config applies fine.
- Remaining for human: Tailscale console cleanup (revoke OAuth client + remove machines), delete old iOS `nanulab DNS` profile, distribute WG QRs + On-Demand toggles, Phase B AdGuard client ids (deferred).

## 2026-08-06 — post-deploy fixes: profile page, AGH state
- **profile.nanulab.de/wg/ returned 500 after basic auth** — `profile_basic_auth` sops secret was `0400 root:root`, nginx (user nginx) couldn't read it → Internal Server Error. Fixed: sops secret `owner=root group=nginx mode=0440`. Commit `a382cc6`. Page now renders all 12 QRs.
- **adguardhome.service crash-looping** after the rebuild — a stale root-owned AGH process from an earlier generation (pid 72198, running 1d4h from `/var/lib/AdGuardHome/`) held port 53; the new DynamicUser-based unit couldn't read the old `nobody`-owned `/var/lib/private/AdGuardHome/data/leases.json`. Fix: killed stale process, wiped stale state dir, restarted → AGH active on :53, rewrites (nanulab.de/mail.dnanu.de → 10.0.0.2) intact, config regenerated from Nix (mutableSettings=false).
- **Tailscale OAuth secret scrubbed** from sops + Memory.md (tailnet deleted). Commit `c6d96f7`.
- Verified: profile page 200 w/ auth, AGH DNS serving, dig rewrites OK, `systemctl --failed` clean (except cloudflared placeholder).

## 2026-08-06 — Homelab v2 access control (GLM 5.2 plan, DeepSeek-V4-Pro execution)
- Human approved GLM 5.2 plan; **DeepSeek-V4-Pro executed** all phases A–D; deployed to gen 45.
- **Phase A (re-addressing):** adguard.nix v2 DHCP static leases (10.0.0.8–20, `[user]-[device]` hostnames), guest range 10.0.0.50–250, persistent clients keyed by 9 users (dumitru=`user_admin`, rest=`user_regular`); iza/kerem/hannah placeholder MACs (TODO).
- **Phase B (Authelia + profile.dnanu.de):** new `modules/services/authelia.nix` (instance `main`, TOTP 2FA, file auth from sops `authelia_users_yaml`); sops: `authelia_jwt`/`authelia_storage_key`/`authelia_users_yaml` added, `profile_basic_auth` removed; `ios-profile.nix` vhost renamed to profile.dnanu.de with auth_request; wireguard.nix per-user QR renderer (dropped shared /wg/ index); cloudflared ingress + CNAME for profile.dnanu.de.
- **Phase C (nginx ACL):** `mkAdminVhost`/`mkUserVhost` helpers; adguard.nanulab.de rewritten as admin-VPN-only (`allow 10.0.1.8/9; deny all;`).
- **Deploy fixes found by Flash:**
  - `cloudflare-dns-sync` LoadCredential race → `after = sops-nix.service`.
  - Authelia `validate-config` required a `notifier` → filesystem notifier added.
  - Authelia user DB pointed at its default template → repointed to `config.sops.secrets.authelia_users_yaml.path`.
  - profile vhost `if ($auth_user != $1)` runs before auth_request (rewrite vs access phase) → 403'd everything; replaced with serving `root /var/lib/mobileprofile/wg/$auth_user` + `error_page 401 = @authelia_login`.
  - wireguard-profile-render left 25 stale pre-v2 flat files → renderer now purges `*.conf`/`*.png`/index.html at base.
- **Verified:** 1FA validates dumitru against sops users.yaml (200 OK / wrong pw 401); session cookie issued (domain=dnanu.de, secure); unauth'd profile → 302 to Authelia login; adguard.nanulab.de from LAN → 403; per-user dirs adela/david/dumitru/hannah/iza/kerem/ramona/tiberiu/tibisor with correct peer counts; all v2 units active; `systemctl --failed` clean (except placeholder cloudflared tunnel).
- **Remaining 1%-manual:** distribute Authelia passwords (Memory.md) + users self-enroll TOTP; fill iza/kerem/hannah MACs; set real cloudflared tunnel UUID; verify profile.dnanu.de via tunnel from cellular.

## 2026-08-06 — real cloudflared tunnel + profile.dnanu.de public
- Human created tunnel in CF dashboard, provided the `cloudflared tunnel run --token`. Decoded token → TunnelID `62ab1635-c6ea-44bc-a702-1bff07f392f7` + credentials JSON → `cloudflared_tunnel_cred` in sops; `settings.nix` tunnelId updated (commit `7149da6`). Placeholder `00000000...` tunnel unit gone.
- **Deploy fixes:** (1) cloudflared `noTLSVerify` on localhost origin — LE cert for `*.dnanu.de` has no IP SAN for `127.0.0.1`, cloudflared 502'd (commit `75a9bef`).
- **Playwright:** MCP pointed at chrome (not installable on Arch) → switched to `--browser webkit --headless` (commit `5b125fd`). Needs opencode restart to take effect.
- **Verified:** tunnel registered at fra07/fra18/muc01/muc03; `profile.dnanu.de` public → 302 to `/authelia/?rd=...`; Authelia login UI 200 via tunnel; `systemctl --failed` clean (no placeholder unit). `dnanu.de` 522 = placeholder 8080 vhost (blog lands Phase 5+).
- **Remaining:** fill iza/kerem/hannah MACs; distribute Authelia passwords + TOTP; confirm profile.dnanu.de from cellular; dnanu.de/www/autoconfig hostname routes in tunnel (dashboard) if not auto.
