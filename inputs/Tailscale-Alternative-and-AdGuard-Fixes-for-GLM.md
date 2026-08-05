# Task: Tailscale → VPN alternative + AdGuard client-tracking fixes — for GLM 5.2 (architect)

Source: TODO.md priority ("Tailscale → VPN alternative", "AdGuard"), Memory.md known issues, OpenCode.md §3.3/§3.4/§10.
Created 2026-08-05 by Flash per Session Workflow.

## Goal
Replace the Tailscale exit-node/"VPN for all devices" approach with a solution that gives **per-device DNS tracking in AdGuard query logs** (no more `127.0.0.1`, `fe80::1`, `10.0.0.2` noise), and fix the LAN AdGuard client-tracking issues. This **reopens a ✅ LOCKED decision** (OpenCode.md §3.3 Tailscale SaaS) — the plan must explicitly justify overriding it.

## Problem statement (what the human is unhappy with)
1. **AdGuard client tracking broken on LAN** — queries show `fe80::1`, `127.0.0.1`, `10.0.0.2` because devices use the Speedport router (`10.0.0.1`) as DNS, which proxies to `10.0.0.2`. TODO: "each device needs `10.0.0.2` as direct DNS" via DHCP advertising `10.0.0.2` (not `10.0.0.1`).
2. **IPv6 `fe80::1` noise** — Speedport announces itself as IPv6 DNS; mitigation = disable IPv6/RA on router (1% manual) or accept bypass.
3. **Tailscale exit node side-effects** — WhatsApp delayed (rare, reconnecting fixes), `adguard.nanulab.de` unreachable on iOS WiFi+exit node, ad blocking drops to 9–15% with exit node active. Client tracking only shows Tailscale IPs (100.x) which are dynamic.
4. **Desired UX** (TODO): "user creates account once, logs into VPN, all traffic labeled with their device name in AdGuard query logs". Goal = pure tunnel-into-network approach: WireGuard-style VPN + a `.mobileconfig` profile that auto-configures iOS devices.

## What to deliver
A plan that:
1. **Evaluates alternatives** — Headscale (self-hosted Tailscale), Netbird, Twingate, pure WireGuard (wg-easy/wireguard-ui?), vs fixing Tailscale. Criteria: native NixOS module availability in pinned `nixos-26.05`, per-device DNS source-IP visibility in AdGuard, iOS client story (didn't appstore/native WireGuard), user management for non-technical family members (Dumitru, M, T, guests), 20-year maintainability, security posture, zero open ports.
2. **Recommends one**, with justification vs the LOCKED Tailscale decision (what changes in OpenCode.md §3.3/§3.4/§10).
3. **Fixes AdGuard LAN tracking** regardless of VPN choice — DHCP option to advertise `10.0.0.2` as DNS; AdGuard `clients.runtime_sources`; how to tag persistent clients so query logs show device names.
4. **Maps affected files** — `modules/networking/tailscale.nix`, `modules/networking/adguard.nix`, `modules/services/ios-profile.nix`, `settings.nix`, `flake.nix` (new inputs), OpenCode.md amendments, Memory.md/TODO.md updates.
5. **Stages the work** so the human can approve incrementally (AdGuard DHCP fix first — low risk, then the VPN swap).

## Constraints
- Zero open ports on router except 25/tcp (OpenCode.md §3.2).
- No containers unless sanctioned (Booklore is the only exception). VPN-confinement namespaces stay for torrent clients.
- Declarative only — no bootstrap scripts poking APIs.
- 99% of evaluation must be verifiable against pinned `nixos-26.05` (module names/options) before implementation.
- SSH password auth stays enabled (human ruling) — irrelevant here but don't touch.
- Family users are non-technical: setup must be "scan QR / click install", not `wg-quick` on the command line.

## Files affected (expected)
- `modules/networking/adguard.nix` — DHCP DNS advertisement, client tagging
- `modules/networking/tailscale.nix` — keep/replace/remove
- `modules/services/ios-profile.nix` — new VPN profile payload instead of/in addition to DNS-only
- `flake.nix` — possible new input (e.g. headscale)
- `settings.nix` — VPN/IP/domain values
- `OpenCode.md` §3.3/§3.4/§10 — lock decision updates
- `secrets/secrets.yaml` — any new secrets (sops)

## Model recommendation
**GLM 5.2 (architect)** — this is an architecture decision + research task (evaluate alternatives, override a LOCKED choice, security-relevant network design). Not a Flash/Pro execution task. Escalate to **Kimi K3** for a security audit of the final chosen VPN solution if the plan reveals deep exposure concerns.
