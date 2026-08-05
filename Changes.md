# Changes.md — temporary session log (wiped into OpenCode.md at end of session)

History in OpenCode.md §17 "Session Log".

## 2026-08-05 — session start: new workflow
- Task-based workflow: human annotates → agent creates `inputs/[Task]-for-[Model].md` → reasoning model writes `outputs/[Task]-plan-by-[Model].md` → human reviews → Flash executes.
- Model tiers: Flash (MDP) for small fixes, Pro (M2P) for modules, GLM for debugging, Kimi for architecture.

## 2026-08-05 — Tailscale alternatives + AdGuard fixes (priority)
- Read TODO.md, Memory.md, OpenCode.md, current networking modules (tailscale.nix, adguard.nix, ios-profile.nix).
- Created `inputs/Tailscale-Alternative-and-AdGuard-Fixes-for-GLM.md` covering: (1) evaluate Headscale/Netbird/Twingate/pure WireGuard vs fixing Tailscale for per-device AdGuard DNS tracking, (2) AdGuard LAN DHCP DNS fix (advertise 10.0.0.2 not 10.0.0.1), (3) IPv6 fe80::1 noise.
- Reopens LOCKED §3.3 (Tailscale SaaS) — plan must justify the override.
- Model recommended: **GLM 5.2 (architect)**; escalate to Kimi for security audit of chosen VPN.
