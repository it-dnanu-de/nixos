# Plan: Enable Public IPv6 GUA + mail.dnanu.de AAAA

**Planner:** Medium-Reasoning (DeepSeek V4 Pro)  
**Date:** 2026-08-06  
**For:** nixos-builder (V4 Pro)  
**Approval:** Human-approved task — proceed to execute after human reviews.

---

## 1. Root cause: exact NixOS option and evidence

### Evidence from the deployed system (gen 45)

The live server at `10.0.0.2` has:
```
# sysctl net.ipv6.conf.all.forwarding
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.enp10s0.forwarding = 1
```

The booted generation's `/run/booted-system/etc/sysctl.d/60-nixos.conf` contains:
```
net.ipv4.conf.all.forwarding=1
net.ipv6.conf.all.forwarding=1
```

These are **NOT** in the current repo config. The undeployed repo sysctl (verified with `nix eval '.#nixosConfigurations.homelab.config.boot.kernel.sysctl'`) shows:
```
net.ipv4.ip_forward = 1       # from wireguard.nix:145 — WG peers → LAN, MUST stay
net.ipv6.conf.enp10s0.accept_ra = 1  # from base.nix:31
# NO net.ipv6.conf.all.forwarding — no module in the current repo sets it
```

### Exact NixOS option that sets it

**`services.tailscale.useRoutingFeatures = "server"`** (or `"both"`) — in gen 45's Tailscale config, which maps to `boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = mkOverride 97 true` (source: `nixpkgs/nixos/modules/services/networking/tailscale.nix:254`).

### Why it's already fixed

The current repo config **removed Tailscale** (replaced by WireGuard in §3.3). No imported module in the current flake sets `net.ipv6.conf.all.forwarding`:

| Module checked | Sets v6 forwarding? | Evidence |
|---|---|---|
| `networking.nat` | Yes (mkOverride 99, if enabled) | nat.nix:210 — but `networking.nat.enable` is NOT used in this repo |
| `services.tailscale` | Yes (mkOverride 97) | tailscale.nix:254 — **was in gen 45, REMOVED from repo** |
| `services.babeld` | Yes (direct) | babeld.nix:98 — not used |
| `services.netbird` | Yes (mkOverride 97) | netbird.nix:521 — not used |
| `services.wg-access-server` | Yes (direct) | wg-access-server.nix:104 — not used |
| `networking.wireguard` | **No** | wireguard.nix — only uses "forwarding" in a comment |
| `networking.firewall` | **No** | firewall.nix — `filterForward` only affects nftables chains |
| Current repo `boot.kernel.sysctl` | **No** | wireguard.nix:145 only sets `net.ipv4.ip_forward` |

**Result:** After `nixos-rebuild switch` with the current repo, v6 forwarding will be 0 (kernel default). No code change needed for the forwarding fix.

### Belt-and-braces explicit disable (defense-in-depth)

Even though no module currently sets v6 forwarding, add an explicit disable to `base.nix` so any future module that enables it can't reintroduce SLAAC breakage:

```nix
# base.nix — add after the existing accept_ra sysctl
boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = false;
```

This is `mkDefault`-equivalent (regular assignment, not `mkOverride`). A future module using `mkOverride 97` would override it, but that's by design — override-aware modules (like Tailscale) would only do so intentionally. The explicit `false` protects against implicit enabling.

---

## 2. ddclient v6: already correct

The repo's `modules/networking/ddclient.nix` does not set `usev6`. The ddclient module in nixpkgs 26.05 defaults to:

```nix
usev6 = "webv6, webv6=ipify-ipv6";   # line 220 of ddclient.nix
usev4 = "webv4, webv4=ipify-ipv4";   # line 213
```

With `domains = [ "mail.dnanu.de" "vpn.dnanu.de" ]`, ddclient will:
1. Query `ipify-ipv6` to get the server's public GUA → update AAAA for both domains
2. Query `ipify-ipv4` → update A records (already working)

**No changes needed to `ddclient.nix`.** The `webv6` method is preferred over `ifv6` because:
- `ifv6` would see both the ULA (`fd10::2`) and GUA, risking it picking the ULA
- `webv6` uses the source address of the outbound connection, which is always the GUA (ULA can't reach the internet)
- Survives GUA renumber (privacy extensions rotate the address; ipify sees current outbound IP)

**`vpn.dnanu.de` AAAA:** Included automatically because it's in the `domains` list. This is sensible — dual-stack WireGuard, no downside.

---

## 3. Firewall: no change needed

The NixOS nftables firewall uses `family = "inet"` (nftables source: `firewall-nftables.nix:84`), which applies to both IPv4 and IPv6. The current `allowedTCPPorts = [ 25 ... ]` in `base.nix` already allows inbound `:25` on both v4 and v6.

**Speedport v6 pass-through** is a separate concern — the router must be configured (1% manual, §12) to allow inbound v6 to the server. This is outside NixOS scope.

---

## 4. Phased execution plan

### Phase 1: Live pre-deploy verification (prove the mechanism)

**Do this BEFORE any config changes or deploy.** SSH to 10.0.0.2.

```bash
# 1. Confirm current state: no GUA, forwarding=1
ip -6 addr show enp10s0 | grep 'inet6'
# Expected: only fd10::2/64 + fe80::/64

sysctl net.ipv6.conf.all.forwarding
# Expected: 1

# 2. Temporarily disable v6 forwarding (runtime-only, reboot-safe)
sysctl -w net.ipv6.conf.all.forwarding=0
sysctl -w net.ipv6.conf.enp10s0.forwarding=0

# 3. Wait 5-10 seconds for the next Router Advertisement to arrive
sleep 10

# 4. Check for GUA
ip -6 addr show enp10s0
# Expected: NEW line with 2003:c8:... global scope (SLAAC GUA from Speedport)

# 5. Verify v6 internet connectivity
ping -6 -c 3 2606:4700:4700::1111
# Expected: replies from Cloudflare DNS

# 6. Verify v4 forwarding still works (WG peers → LAN)
sysctl net.ipv4.ip_forward
# Expected: 1 — MUST NOT have changed

# 7. Verify WG is still up
wg show | head -3
# Expected: interface wg0, listening on 51820

# 8. Restore forwarding (revert the test — deploy will fix it properly)
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.enp10s0.forwarding=1
# GUA may persist until next RA timeout or interface flap — fine.
```

**Gate:** If step 4 shows a `2003:c8:...` GUA and step 5 gets replies, the mechanism is proven. Proceed to Phase 2. If not, **stop and report** — something else is blocking SLAAC.

### Phase 2: Add explicit forwarding disable + verify build

**File:** `modules/networking/base.nix`

Add after line 31 (after `accept_ra` sysctl):

```nix
  # Explicitly disable IPv6 forwarding so SLAAC Router Advertisements are honored.
  # WireGuard only needs v4 forwarding (net.ipv4.ip_forward=1 in wireguard.nix).
  # This also defends against any future module that might enable v6 forwarding.
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = false;
```

Build and verify:

```bash
nix build '.#nixosConfigurations.homelab.config.system.build.toplevel' --no-link
# Must exit 0 with zero new warnings.

# Re-confirm the sysctl value in the closure:
nix eval '.#nixosConfigurations.homelab.config.boot.kernel.sysctl."net.ipv6.conf.all.forwarding"'
# Expected: false

nix eval '.#nixosConfigurations.homelab.config.boot.kernel.sysctl."net.ipv4.ip_forward"'
# Expected: 1 (WG forwarding still intact)
```

**Commit:** `"fix: explicitly disable IPv6 forwarding to allow SLAAC GUA"`

### Phase 3: Deploy to homelab

```bash
nixos-rebuild switch --flake .#homelab --target-host nixos@10.0.0.2
# Wait for activation.
# SSH over IPv4 must survive. WireGuard must come back up.
```

### Phase 4: Post-deploy verification

On the server:

```bash
# 1. v6 forwarding must be 0
sysctl net.ipv6.conf.all.forwarding
# Expected: 0

# 2. v4 forwarding must stay 1
sysctl net.ipv4.ip_forward
# Expected: 1

# 3. GUA must appear
ip -6 addr show enp10s0 | grep '2003'
# Expected: at least one 2003:c8:... global dynamic address

# 4. v6 internet must work
ping -6 -c 3 2606:4700:4700::1111

# 5. All critical services
systemctl --failed  # expected: empty
systemctl status wg-quick-wg0 wireguard-wg0  # running
systemctl status nginx adguardhome kea-dhcp4-server kea-dhcp6-server  # running
systemctl status ddclient  # timer active

# 6. Verify ddclient updates (it may take up to 5min)
# Check Cloudflare dashboard for AAAA on mail.dnanu.de and vpn.dnanu.de
# Or: dig mail.dnanu.de AAAA @1.1.1.1  (may not show immediately)

# 7. WireGuard handshakes still good
wg show | grep -c "handshake"  # should be non-zero for active peers
```

**Gates:** All pass → proceed to docs. Any failure → rollback (Phase 6).

### Phase 5: Docs updates

**`OpenCode.md` §3.5** — replace the IPv6 caveat with the confirmed state:

```markdown
### 3.5 LAN IPv6
IPv6 **stays enabled** (human ruling 2026-08-05: needed for mail + modern infra;
Speedport cannot disable it anyway).

- **GUA (SLAAC):** Server receives a public `2003:c8:...` GUA from the Speedport's
  Router Advertisements. `net.ipv6.conf.all.forwarding=0` (explicitly set in
  `base.nix`, 2026-08-06) ensures RAs are processed. No v6 forwarding — the
  server is a v6 client, not a router.
- **ULA (static):** `fd10::2/64` for Kea DHCPv6 DNS anchor (§3.1).
- **DDNS:** ddclient publishes `mail.dnanu.de` + `vpn.dnanu.de` AAAA records
  via ipify-ipv6 (web-based detection survives GUA renumber / privacy-extension
  rotation). Default `usev6` in nixpkgs 26.05 — no custom config needed.
- **Speedport:** DHCPv6 points DNS at AdGuard (already). GUA via SLAAC unchanged.
- **Inbound v6 mail (`:25`):** Allowed in the host nftables firewall (inet family
  covers both v4/v6). Speedport v6 pass-through is 1% manual in the router UI.
```

**`OpenCode.md` §4.4** — add AAAA row to the DNS table:

```markdown
| AAAA | `mail.dnanu.de` | home IPv6 GUA (ddclient-managed) |
| AAAA | `vpn.dnanu.de` | home IPv6 GUA (ddclient-managed — dual-stack WG endpoint) |
```

**`Changes.md`** — add entry:

```markdown
## 2026-08-06 — IPv6 GUA enabled + mail.dnanu.de AAAA

- Root cause: deployed Tailscale (gen 45) set `net.ipv6.conf.all.forwarding=1`
  which blocks SLAAC. Current repo has no Tailscale — v6 forwarding gone.
- `base.nix`: added explicit `boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = false`
  as defense-in-depth.
- ddclient: defaults `usev6=webv6,webv6=ipify-ipv6` — auto-publishes AAAA for
  `mail.dnanu.de` + `vpn.dnanu.de` once GUA is present.
- Firewall: no change — nftables `inet` family already covers v6 :25.
```

**`Memory.md`** — add:

```markdown
## IPv6 GUA (2026-08-06)
- Server now gets SLAAC GUA from Speedport (2003:c8:...).
- `net.ipv6.conf.all.forwarding = false` set explicitly in base.nix.
- ddclient `usev6=webv6,webv6=ipify-ipv6` (default) auto-updates AAAA.
- Speedport v6 pass-through for inbound :25 is 1% manual in router UI.
- Privacy extensions (`use_tempaddr=2`, default) rotate the GUA used for
  outbound — ipify-ipv6 tracks the current outbound address.
```

**Commit:** `"docs: IPv6 GUA enabled, ddclient AAAA for mail+vpn, verification notes"`

---

## 5. Risk assessment and rollback

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Speedport stops sending RAs after prefix change | Low | Medium | Speedport behavior is independent of server; ddclient recovers |
| ULA clash with GUA (fd10::2 vs GUA on same link) | Very low | Low | ULAs are scoped — default source-address selection prefers GUA for internet |
| GUA privacy-extension rotation breaks inbound mail briefly | Low | Low | ddclient catches up within 5min; same race as v4 DDNS |
| v6 forwarding is re-enabled by a future flake input upgrade | Low | Medium | Explicit `false` in base.nix catches implicit cases; a module using mkOverride 97 would override intentionally — review on `nix flake update` |
| Speedport v6 firewall blocks inbound :25 | Medium | Medium | 1% manual: configure Speedport to allow v6 25; outside NixOS scope |

### Rollback

```bash
# If anything breaks: revert the commit and deploy previous generation
git revert <commit>   # OR: git reset --hard HEAD~2
nixos-rebuild switch --flake .#homelab --target-host nixos@10.0.0.2

# Emergency runtime rollback (if SSH is still up):
sysctl -w net.ipv6.conf.all.forwarding=1
# Then fix and deploy.
```

---

## 6. Summary

| What | Action |
|------|--------|
| v6 forwarding fix | Already fixed (Tailscale removed). Add explicit `false` in `base.nix` for defense-in-depth |
| ddclient AAAA | No change — defaults handle it |
| Firewall | No change — `inet` family covers both |
| Live test | Phase 1: `sysctl -w` first to prove mechanism |
| Deploy | Phase 3: `nixos-rebuild switch` |
| Docs | Phase 5: OpenCode.md §3.5, §4.4, Changes.md, Memory.md |

**Total lines of Nix changed: 2** (one comment + one sysctl in `base.nix`).  
**Total lines of docs changed: ~30** (across 4 files).

---

*Plan written 2026-08-06. Awaiting human review before execution.*
