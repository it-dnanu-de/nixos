# Task: Enable public IPv6 (GUA) on the homelab + mail.dnanu.de AAAA — for planner-low (Flash) or planner-med (Pro)

Source: session troubleshooting 2026-08-06. Human wants real IPv6 (GUA) on the server so mail can use v6.
**Tier: Medium (V4 Pro, planner-med)** — touches sysctl/networking semantics; recommend med over low because "accept_ra vs forwarding" interplay is subtle. (Human said "let's open a task" — no tier preference; this is the recommendation.)

## Goal
Get the server a **public GUA** (SLAAC from the Speedport), then have ddclient publish **`mail.dnanu.de` AAAA** (and optionally `vpn.dnanu.de` AAAA). This makes IPv6 real for mail: outbound from a GUA, and (if the Speedport passes v6) inbound 25 reachable without port-forward.

## Root cause (already diagnosed — do NOT re-research, build on it)
- Server has only `fd10::2/64` (ULA) + `fe80::` link-local. **No GUA.**
- `ping -6 → "Network is unreachable"` — zero v6 internet connectivity.
- **`net.ipv6.conf.all.forwarding = 1`** in the NixOS sysctl (`60-nixos.conf`). **Linux ignores Router Advertisements for SLAAC when IPv6 forwarding is enabled on the interface.** So `accept_ra=1` + `autoconf=1` (both already set) never yield a GUA.
- The Speedport DOES offer v6: it reports the Dell's GUA `2003:c8:c742:641c:f61:247e:31d9:9d50` and arch (WiFi) happily SLAACs `2003:c8:c704:3584:...`. So the router side is fine — it's purely the server's forwarding flag.
- Something in the config sets `net.ipv6.conf.all.forwarding=1`. It is NOT in our modules (grep of modules/ shows only `net.ipv4.ip_forward`). It's likely a default from `networking.nat`/`networking.firewall.filterForward`/a leftover Tailscale-era setting — the plan must find the exact source option (check `networking.nat`, `services.tailscale` remnants, `networking.firewall`, `boot.kernel.sysctl` defaults) and disable only what's needed.

## What the plan must cover
1. **Identify what sets `net.ipv6.conf.all.forwarding=1`** (search the closure's `60-nixos.conf` source: `nix eval` the relevant options or grep nixpkgs defaults) and turn it OFF — but ONLY v6 forwarding; **v4 forwarding must stay** (`net.ipv4.ip_forward=1` is required for WireGuard peers → LAN, `wireguard.nix:145`).
   - Candidate culprits to check: `networking.nat.enable` (was removed with Tailscale but maybe reintroduced), `networking.firewall.filterForward`, `services.tailscale` leftovers, `boot.kernel.sysctl` in any module, or a `networking.defaultGateway6`/DHCP6 interaction. Verify with `nix eval` not guesswork.
   - Desired end state: `net.ipv6.conf.all.forwarding = 0` while `net.ipv4.ip_forward = 1` stays.
2. **Confirm SLAAC GUA appears** after the change: `ip -6 addr show enp10s0` → a `2003:c8:...` global dynamic address; `ping -6 2606:4700:4700::1111` works. (Test with a live `sysctl -w net.ipv6.conf.all.forwarding=0` first to prove the fix before committing config.)
3. **ddclient AAAA**: configure v6 detection for `mail.dnanu.de` (and `vpn.dnanu.de` if sensible). ddclient 4.0.0 supports `usev6=web, webv6=ipify-ipv6` or `usev6=ifv6, ifv6=enp10s0`. Choose the most robust (web-based ipify-ipv6 preferred — survives GUA renumber; must NOT fall back to the ULA `fd10::2`). Verify the AAAA record appears in Cloudflare and resolves publicly.
4. **Don't break the WG/networking**: the change must not regress WireGuard (v4 forwarding intact), Kea DHCP, AGH DNS, or mail over v4. Firewall: allow inbound `:25` on v6 (`::`) too if the Speedport passes it — decide whether to open v6 25 on the host firewall; note the Speedport v6 pass-through is router-UI territory (1% manual), don't assume it works.
5. **Docs**: OpenCode.md §3.5 (GUA now present; forwarding note), §4.4 (mail.dnanu.de AAAA), ddclient row; TODO; Changes; Memory.

## Constraints
- Native modules only. Declarative. sops for secrets. Public-safe.
- Do NOT enable v6 forwarding — the server is not a router. We only want it to be a v6 *client* (SLAAC).
- `fd10::2/64` ULA must stay (Kea v6 DNS anchor).
- Verify with `nix build` after each phase; no deploy until human approves.
- This is a networking-semantics fix: the executor (Pro) should test the sysctl live before committing to prove the mechanism, then encode it in Nix.

## Files affected (expected)
`modules/networking/base.nix` (or wherever the offending option lives) · `modules/networking/ddclient.nix` · `modules/networking/cloudflare-dns.nix` (optional vpn AAAA) · `modules/services/cloudflare-dns.nix`? · `OpenCode.md` §3.5/§4.4 · docs.

## Model recommendation
**planner-med (V4 Pro)** — requires tracing the sysctl source + live verification; low (Flash) is acceptable if med is busy, but med is safer for the forwarding/accept_ra semantics.
