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

## 2026-08-05 — GLM 5.2 plan delivered, human annotations folded in
- GLM 5.2 (architect subagent) wrote `outputs/Tailscale-Alternative-and-AdGuard-Fixes-plan-by-GLM.md`: **pure declarative WireGuard** (replaces Tailscale), one port UDP 51820, QR onboarding, Phase A (VPN swap) + Phase B (AdGuard fixes).
- **Model routing bug found+fixed:** `architect.md` pinned `openrouter/glm-5.2` which does NOT exist on OpenRouter → subagent fell back to a wrong model (human saw Kimi K3 in API logs). Corrected to `openrouter/z-ai/glm-5.2` (verified in OpenRouter model list). All other agent model IDs verified valid. Commit `f500395`.
- Human annotations folded into the plan: (1) UDP 51820 already forwarded on Speedport, (2) peers mirror DHCP static-lease layout on 10.0.1.XXX base (iPhone17Pro=10.0.1.100, arch=10.0.1.101, no admin-iphone), (3) `*.nanulab.de` VPN-only but AdGuard UI + profile.nanulab.de reachable over WiFi without VPN, (4) Speedport DHCPv4/DHCPv6 point at AdGuard (keep enabled, IPv6 stays on — mail + modern infra).
