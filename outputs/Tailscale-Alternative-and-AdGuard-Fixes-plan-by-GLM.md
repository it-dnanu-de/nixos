# Plan: Tailscale → declarative WireGuard + AdGuard client-tracking fixes

**Author:** GLM 5.2 (architect) · 2026-08-05 · **For:** DeepSeek-V4-Pro (execution)
**Task source:** `inputs/Tailscale-Alternative-and-AdGuard-Fixes-for-GLM.md`
**Status:** planning only — no code changed, no commits made.

---

## 0. Order-of-work conflict resolution

The task file contains both "solve the VPN alternative FIRST" (human ruling, line 9) and "AdGuard DHCP fix first" (line 23, staging suggestion). **The explicit human ruling wins: Phase A = VPN swap, Phase B = AdGuard fixes.** They are separate deliverables with separate commit checkpoints.

---

## 1. Verified facts against pinned `nixos-26.05`

Checked directly in the pinned channel checkout (`nixpkgs@nixos-26.05`):

| Thing | Status | Evidence |
|---|---|---|
| `networking.wireguard.interfaces.<name>` module | ✅ verified | `nixos/modules/services/networking/wireguard.nix`: `ips`, `listenPort`, `privateKeyFile`, `peers[].{publicKey, presharedKey, presharedKeyFile, allowedIPs, endpoint, persistentKeepalive}` |
| `services.headscale` module | ✅ verified | `headscale.nix`, pkg v0.28.0. Full settings schema: `server_url`, `noise.private_key_path`, `prefixes.v4/v6`, `dns.{magic_dns, base_domain, override_local_dns, nameservers.global, split, extra_records}`, `derp`, `oidc.{issuer, client_id, client_secret_path}`, `policy.{mode,path}`, `tls_*`, sqlite/postgres |
| `services.headplane` module | ✅ verified | `headplane.nix`, pkg v0.6.2 — "Feature-complete Web UI for Headscale" (`server.{host,port,base_url,cookie_secret_path}`, `headscale.*`) |
| `headscale-ui` (gurucomputing, requested by human) | ❌ **not packaged** | not in `pkgs/by-name`. Per human ruling #3: no container for it → moot, because **headplane is packaged natively and is the better UI** |
| `services.netbird` + server stack | ✅ verified | `netbird.nix` (client) + `netbird/{management,signal,dashboard,coturn,server}.nix`; pkgs `netbird{,-management,-signal,-relay,-dashboard,-ui}` |
| `services.twingate` | ✅ verified, client-only | `twingate.nix` = "Twingate Client daemon". Controller is SaaS-only — cannot self-host |
| `services.wg-access-server` | ✅ verified | `wg-access-server.nix`: freeform `settings` + `secretsFile` |
| `services.tailscale.authKeyParameters.baseURL` | ✅ verified | `tailscale.nix` line 105 — NixOS clients can point at a headscale control server natively (relevant to the fallback path) |
| `pkgs.qrencode` | ✅ verified | `pkgs/by-name/qr/qrencode` (for QR onboarding) |
| AdGuard Home DHCP DNS behavior | ✅ upstream behavior | AGH's DHCP server **always advertises its own host IP (10.0.0.2) as DHCP option 6 DNS**; there is no override knob. Our `adguard.nix` is already correct — the LAN problem is the Speedport still answering DHCP/RA, not our config |

**Consequence:** every option on the shortlist is implementable with native modules in the pinned channel. No new flake inputs are required for the recommended design.

---

## 2. Evaluation

Criteria from the task file: native module in pinned 26.05 · per-device DNS source-IP visibility in AdGuard · iOS client story · non-technical family UX ("account once, log in, traffic labeled") · 20-year maintainability · security posture · port exposure.

| Criterion | Fix Tailscale SaaS in place | **Headscale + headplane** | NetBird self-host | Twingate | **Pure WireGuard (declarative peers)** |
|---|---|---|---|---|---|
| Native module(s) | ✅ `services.tailscale` | ✅ `services.headscale` + `services.headplane` | ✅ 5 modules (mgmt/signal/relay/dashboard/coturn) | ⚠️ client only; controller is SaaS | ✅ `networking.wireguard` |
| Per-device DNS labels in AdGuard | ❌ 100.x IPs are dynamic (reinstall/re-key → new IP); exit node mangles DNS path | ⚠️ node IPs stable in headscale DB but **not declarative** — DB rebuild reshuffles → AdGuard id map drifts | ✅ per-peer IPs (mgmt-server assigned) | ❌ same SaaS/dynamic-IP issue | ✅ **static per-peer IPs declared in `settings.nix`** → AdGuard ids are declarative, stable forever |
| iOS client | ✅ Tailscale app (already installed) | ✅ Tailscale app; set "alternate control server" URL once (supported by current iOS app + MDM `ControlURL`), then log in | ✅ NetBird app | ✅ Twingate app | ✅ official WireGuard app; **scan QR → done**; On-Demand toggle in-app |
| Non-technical family UX | ✅ best (SaaS OAuth login) | ⚠️ good but: preauth keys (admin-issued) or OIDC (needs an IdP we don't run); hidden "alternate server" gesture is a friction point | ❌ needs an IdP (Zitadel/Keycloak/Authelia) → new unsanctioned service, heaviest option | ⚠️ SaaS accounts, free tier limits | ✅ **no account at all**: admin hands over a QR once; nothing to forget, nothing expires |
| 20-year maintainability | ⚠️ SaaS dependency (the original lock accepted this) | ✅ single Go binary + sqlite; active upstream (0.28 in 26.05); clients can repoint to SaaS or another headscale without app changes | ❌ 5 components + IdP = worst maintenance load of the set | ❌ pure SaaS lock-in | ✅ **kernel WireGuard + zero daemons**; config format stable; even if NixOS vanished, `wg-quick` reads the same files |
| Security posture | ✅ strong crypto, but keys/coordination metadata at a third party | ⚠️ self-hosted control plane must be **publicly reachable** (TLS endpoint + embedded DERP + DB + node-key lifecycle) | ⚠️ public mgmt/signal/relay + IdP surface | ⚠️ SaaS control plane | ✅ **single UDP port, silent-drop on unauthenticated packets** (invisible to scanners); no TLS stack, no HTTP endpoint, no DB; optional per-peer PSK = post-quantum hedge |
| Open ports needed | 0 (current lock rationale) | TCP 8443 (control+DERP) [+ opt. UDP 41641/3478] | several (443 mgmt/signal, TURN 3478, …) | 0 | **UDP 51820 only** |
| Solves reported pain (WhatsApp delay, `adguard.nanulab.de` unreachable, 9–15% blocking, `127.0.0.1`/`fe80::1`/`10.0.0.2` noise) | ❌ only if exit node abandoned; tracking still dynamic | ✅ (exit node simply not used; DNS pushed to 10.0.0.2) | ✅ | ⚠️ partial | ✅ all — split-tunnel only, DNS via tunnel, internet direct |

### Why not the others, in one line each
- **Fix Tailscale in place:** abandoning the exit node fixes the side effects, but dynamic 100.x IPs keep per-device AdGuard labels non-declarative, the SaaS dependency stays, and the human explicitly wants off it.
- **NetBird:** the self-host stack (management + signal + relay + dashboard + coturn + mandatory OIDC IdP) is the antithesis of this project's minimalism; five moving parts to give a family of four a tunnel.
- **Twingate:** controller cannot be self-hosted — it's Tailscale-SaaS with a different logo, plus per-user pricing pressure.
- **Headscale:** genuinely good, fully native, and the runner-up — but it needs a publicly exposed TLS control plane + DERP, its node IPs are not declarative (AdGuard mapping drifts on DB rebuild), and iOS enrollment via "alternate server URL + preauth key" is more fiddly than scanning a QR. Keep it as the documented fallback (§15).

---

## 3. Recommendation — pure declarative WireGuard

**Replace Tailscale SaaS entirely with kernel WireGuard (`networking.wireguard`), declarative per-device peers in `settings.nix`, keys/PSKs in sops, and QR onboarding rendered at activation and served on the existing `profile.nanulab.de` vhost.**

This is exactly the TODO's stated goal ("pure tunnel-into-network approach: WireGuard VPN + profile that auto-configures devices") and it is the only option that is simultaneously: fully declarative (peers, IPs, AdGuard labels), zero-daemon (kernel data path), minimal-exposure (one silent UDP port), and trivial for family members (scan QR once, enable On-Demand, forget).

### Justification for overriding ✅ LOCKED §3.3 (Tailscale SaaS)
The 2026-08-03 lock was made to get OAuth-non-expiring auth and zero open ports. Reality after deployment: the exit node breaks WhatsApp timing, `adguard.nanulab.de` on iOS, and drops blocking to 9–15%; Tailscale IPs are dynamic so AdGuard can never label devices declaratively; and the SaaS control plane is a sovereignty gap. The human ruling of 2026-08-05 explicitly authorizes opening the VPN port. The trade is: **one silent-drop UDP port in exchange for full sovereignty, declarative peer state, static per-device IPs, and removal of every reported symptom.** WireGuard's unauthenticated-packet behavior (no response whatsoever) makes the new port scanner-invisible, so the spirit of "zero open ports" (no attack surface) is preserved even though the letter changes to "two forwarded ports."

### Security posture (architect's own assessment, per human ruling #4 — no escalation)
- **New exposure:** UDP 51820 → 10.0.0.2 only. WireGuard silently drops unauthenticated packets — the port does not answer scans, banners, or probes. No TLS, no HTTP, no control plane, no DB. This is the smallest remotely-accessible VPN surface that exists.
- **Crypto:** Noise IK (Curve25519/ChaCha20-Poly1305), plus a **per-peer preshared key** (post-quantum hedge) stored in sops and wired via `presharedKeyFile`.
- **Peer private keys on the server:** needed to render the QR configs. At rest: sops/age-encrypted in `secrets.yaml` (safe in git). At runtime: `/run/secrets` mode 0400 root; rendered configs mode 0640 `root:nginx`, served only on `profile.nanulab.de` (resolves to 10.0.0.2 → LAN/VPN only) behind `auth_basic` (`profile_basic_auth` secret, already in the §7 inventory but currently unused — this plan puts it to work). Accepted risk within the family trust model; the paranoid alternative (generate keypairs on the Arch workstation, server never sees private keys, QRs made locally with `qrencode`) is documented in the runbook as an opt-in.
- **No exit node → no abuse path:** the server does not NAT for VPN clients (the current `networking.nat` masquerade block is deleted with `tailscale.nix`). Nobody can route their internet traffic through the home IP. `ip_forward` is enabled solely so peers can also reach other LAN hosts (same trust level as today's `trustedInterfaces = [ "tailscale0" ]`).
- **Revocation:** delete peer from `settings.nix` → rebuild → key is dead. No console, no state.
- **Rollback:** `git revert` the Phase A commits restores Tailscale exactly as today (OAuth secret untouched until the human revokes it in the Tailscale console).

### Port mapping (deliverable 4)
| Router forward | To | Purpose |
|---|---|---|
| **UDP 51820** | `10.0.0.2:51820` | WireGuard (only new port; human ruling 2026-08-05 authorizes it) |
| TCP 25 | `10.0.0.2:25` | unchanged (inbound SMTP) |

No TCP ports, no DERP, no STUN needed: peers are always clients, the server is always reachable at the forwarded port; cellular/CGNAT peers work because they initiate.

---

## 4. Phase A design — VPN swap

### 4.1 Architecture
```
phone/laptop (WireGuard app, 10.0.1.x)
    │  UDP 51820, split-tunnel AllowedIPs = 10.0.0.0/24, DNS = 10.0.0.2
    ▼
Speedport (port fwd UDP 51820) ──► homelab wg0 (10.0.1.1/24)
                                       │ trusted interface
                                       ▼
                              AdGuard :53 / nginx 443 / mail 993+465+587 …
                              query source = 10.0.1.x → labeled client
```
- New VPN subnet **10.0.1.0/24** (distinct from LAN 10.0.0.0/24 so firewall/AdGuard can tell the path apart).
- Server endpoint name: **`vpn.dnanu.de`** — grey-cloud A record, ddclient-managed exactly like `mail.dnanu.de` (same Cloudflare token, one extra domain in the existing ddclient unit + the cloudflare-dns sync).
- Onboarding: activation oneshot renders `/var/lib/mobileprofile/wg/<peer>.conf` + `<peer>.png` (via `pkgs.qrencode`), plus a tiny `index.html`; nginx serves `profile.nanulab.de/wg/` behind `auth_basic`.
- iOS: install WireGuard app → scan QR (at home on WiFi, or from a printout) → in app: Edit → **On-Demand → WiFi + Cellular**. From then on the tunnel is always on; DNS always via AdGuard; `*.nanulab.de` and mail work everywhere. The old `nanulab-dns.mobileconfig` is retired (delete from devices).
- Admin (the human) gets peers too (`admin-arch`, `admin-iphone`) — this preserves today's "reach everything over VPN" workflow including SSH, with Tailscale removed.

### 4.2 `settings.nix` — replace `network.tailscaleRoutes` with
```nix
network.wireguard = {
  port = 51820;
  subnet = "10.0.1.0/24";
  address = "10.0.1.1";          # server wg0 IP
  endpoint = "vpn.dnanu.de";     # grey-cloud A record, ddclient-managed
  peers = [
    # name = AdGuard label anchor; ip = static, declarative; publicKey filled by human (1% step)
    { name = "admin-arch";      ip = "10.0.1.2";   publicKey = "REPLACE_ME"; }
    { name = "admin-iphone";    ip = "10.0.1.3";   publicKey = "REPLACE_ME"; }
    { name = "dumitru-iphone";  ip = "10.0.1.10";  publicKey = "REPLACE_ME"; }
    { name = "dumitru-arch";    ip = "10.0.1.11";  publicKey = "REPLACE_ME"; }
    { name = "m-iphonexs";      ip = "10.0.1.12";  publicKey = "REPLACE_ME"; }
    { name = "t-galaxys22u";    ip = "10.0.1.13";  publicKey = "REPLACE_ME"; }
    { name = "guest-1";         ip = "10.0.1.200"; publicKey = "REPLACE_ME"; }
    { name = "guest-2";         ip = "10.0.1.201"; publicKey = "REPLACE_ME"; }
  ];
};
```
(Public keys are not secret — safe in `settings.nix`/git. Private keys + PSKs never enter the repo except via sops.)

### 4.3 Secrets (sops) — declared in `modules/networking/wireguard.nix` (locality), encrypted in `secrets/secrets.yaml`
- `wireguard_server_private` (restartUnits: `wireguard-wg0.service`)
- per peer: `wireguard_peer_<name>_private` (only the QR renderer reads it), `wireguard_peer_<name>_psk` (renderer **and** `presharedKeyFile`)
- remove: `tailscale_oauth` (from `sops.nix`; human revokes the OAuth client in the Tailscale console afterwards)
- Key generation (1% manual, documented in runbook): `wg genkey | tee priv | wg pubkey > pub`, `wg genpsk` per peer; privates/PSKs → `sops secrets/secrets.yaml`; publics → `settings.nix`.

### 4.4 New module `modules/networking/wireguard.nix` (replaces `tailscale.nix`)
- `networking.wireguard.interfaces.wg0 = { ips = [ "${address}/24" ]; listenPort; privateKeyFile = sops server key; peers = map (p: { inherit (p) publicKey; presharedKeyFile = config.sops.secrets."wireguard_peer_${p.name}_psk".path; allowedIPs = [ "${p.ip}/32" ]; persistentKeepalive = 25; }) peers; };`
- dynamic `sops.secrets` attrset built from the peer list (`listToAttrs`/`concatMap`).
- `boot.kernel.sysctl."net.ipv4.ip_forward" = 1;` (peers reaching other LAN hosts; comment explaining trust equivalence with former tailscale0).
- `systemd.services.wireguard-profile-render` oneshot: `after = [ "sops-nix.service" ]; wantedBy = [ "multi-user.target" ]; path = [ pkgs.wireguard-tools pkgs.qrencode pkgs.coreutils ];` — derives server pubkey (`wg pubkey < $SERVER_PRIV`), writes per-peer `.conf` (template below) + `.png` + `index.html` into `/var/lib/mobileprofile/wg/`, `chown root:nginx`, `chmod 640`.
- `services.nginx.virtualHosts."profile.nanulab.de"` gains `basicAuthFile = config.sops.secrets.profile_basic_auth.path;` (secret must be htpasswd-format) and `locations."/wg/" = { root = "/var/lib/mobileprofile"; }`. (Merging a vhost from two modules is legal; `ios-profile.nix` keeps the vhost skeleton.)

Client conf template (rendered per peer):
```ini
[Interface]
PrivateKey = <peer private>
Address    = <peer ip>/32
DNS        = 10.0.0.2

[Peer]
PublicKey           = <server pubkey>
PresharedKey        = <peer psk>
AllowedIPs          = 10.0.0.0/24
Endpoint            = vpn.dnanu.de:51820
PersistentKeepalive = 25
```

### 4.5 Other file changes (Phase A)
- `modules/networking/base.nix` — firewall: `trustedInterfaces = [ "wg0" ];` (replaces `tailscale0`), `allowedUDPPorts = [ 53 67 51820 ];`, update comments.
- `modules/networking/tailscale.nix` — **delete** (takes the NAT masquerade block with it).
- `modules/networking/ddclient.nix` — `domains = [ settings.domains.mail "vpn.dnanu.de" ];` (add a `domains.vpn = "vpn.dnanu.de"` to settings.nix and reference it).
- `modules/services/cloudflare-dns.nix` — mirror the existing `mail.dnanu.de` entry for `vpn.dnanu.de` (grey cloud, PATCH-upsert pattern already proven per Memory.md).
- `modules/services/ios-profile.nix` — remove the obsolete `dns.mobileconfig` profileDir + location (DNS now rides in the WG peer config); keep the vhost; add the same `basicAuthFile` here if vhost auth is defined in this file instead (executor picks one place — recommend `ios-profile.nix` owns the vhost incl. `basicAuthFile`, `wireguard.nix` only adds the `/wg/` location).
- `modules/networking/adguard.nix` — remove `@@||tailscale.com^$important` user rule (no longer relevant). *(Client-id additions belong to Phase B.)*
- `hosts/homelab/configuration.nix` — swap the import `tailscale.nix` → `wireguard.nix`.
- `modules/system/sops.nix` — drop `tailscale_oauth`.
- `flake.nix` — **no change** (all native; no new inputs).

---

## 5. Phase B design — AdGuard client-tracking fixes

**Root causes (now provable):** the declarative side is already right — AGH DHCP (`dhcp.enabled = true`, `dhcpv4.gateway_ip = 10.0.0.1`) advertises itself, i.e. `10.0.0.2`, as DNS option 6; this cannot be misconfigured because AGH has no DNS-override knob. The noise comes from the **Speedport still answering DHCPv4 and IPv6 RA/RDNSS**, handing out `10.0.0.1` / `fe80::1` as DNS; the router then proxies queries to 10.0.0.2, collapsing all clients into `10.0.0.1`/`fe80::1` source addresses. Fixes:

1. **1% manual (Speedport UI), enforcement of existing §3.1/§3.5 text:**
   - Disable DHCPv4 server on the Speedport (OpenCode.md §3.1 already mandates this — it was never verified).
   - Disable IPv6/RA on the Speedport (§3.5) → kills `fe80::1` RDNSS noise.
   - Renew leases on devices (toggle WiFi) → they get DNS `10.0.0.2` directly from AGH.
2. **Declarative verification additions** (runbook/§13, no config diff): `nmap --script broadcast-dhcp-discover -e enp10s0` on the server must list **only** 10.0.0.2 answering; a fresh client shows `DNS: 10.0.0.2`; AdGuard query log shows LAN device names (persistent clients already match the static-lease IPs 10.0.0.100–109).
3. **`adguard.nix` diff (small):** add WG peer IPs as ids to the existing person-clients so VPN-path queries get the same labels:
   - `Dumitru` ids += `[ "10.0.1.10" "10.0.1.11" ]`
   - `M` ids += `[ "10.0.1.12" ]`
   - `T` ids += `[ "10.0.1.13" ]`
   - `Guests` ids += `[ "10.0.1.200" "10.0.1.201" ]`
   - new client `Admin` ids `[ "10.0.1.2" "10.0.1.3" ]` (tag `user_regular`, global settings)
   - Leave `clients.runtime_sources` as-is (`arp = false` was correct; `rdns`/`dhcp`/`hosts` harmless for 10.0.1.x).
4. **No IPv6 filtering changes** (`aaaa_disabled` etc. deliberately not used — the noise is a source-address artifact, fixed at the router, not an AAAA problem).

---

## 6. OpenCode.md amendments (exact)

**§3.2 table:** add row — `Remote access (all devices) | Internet → vpn.dnanu.de (grey cloud, ddclient) → router fwd UDP 51820 → 10.0.0.2:51820 (WireGuard) | **51820/udp**`; rewrite the "Everything else" row to `Device → WireGuard tunnel → 10.0.0.2 (nginx 443 / mail 993+465 / admin UIs)`; router column header total: "25/tcp + 51820/udp only". Remove Tailscale/subnet-route wording.

**§3.3 — replace the entire Tailscale section with:**
> ### 3.3 WireGuard — remote-access VPN — ✅ LOCKED (2026-08-05, supersedes Tailscale SaaS)
> - Kernel WireGuard, `networking.wireguard.interfaces.wg0`, server `10.0.1.1/24`. No SaaS control plane. **No exit node** (split-tunnel only) — kills the WhatsApp/adguard-reachability/blocking-rate issues.
> - Peers fully declarative: names + static IPs + public keys in `settings.nix`; server private key, per-peer private keys and PSKs in sops.
> - Endpoint `vpn.dnanu.de` (grey cloud, ddclient-managed) — router forwards **UDP 51820 → 10.0.0.2** (human ruling 2026-08-05 authorizes this port). WireGuard silently drops unauthenticated packets: the port answers no scans; no TLS/HTTP/control-plane surface exists.
> - Client configs push `DNS = 10.0.0.2` and `AllowedIPs = 10.0.0.0/24`: all DNS flows through the tunnel to AdGuard (per-device labels via static 10.0.1.x ids), internet traffic stays direct.
> - Onboarding: activation oneshot renders per-peer `.conf` + QR PNGs → `profile.nanulab.de/wg/` behind `auth_basic`; iOS = official WireGuard app → scan QR → enable On-Demand (WiFi+Cellular) once.
> - Former lock rationale (OAuth non-expiry, zero ports) superseded: exit-node side effects + dynamic 100.x IPs broke per-device DNS labeling; sovereignty preferred over zero-port purity.
> - Fallback: headscale + headplane (both native modules, verified in pinned 26.05: headscale 0.28.0, headplane 0.6.2) if self-service multi-device enrollment is ever needed — §15.

**§3.4:** delete the "Tailscale admin console DNS" bullet (replaced by "WG peer configs push `DNS = 10.0.0.2`; LAN devices get it from AdGuard DHCP"). Public wildcard `*.nanulab.de` A record → **recommend deleting it** (its only job was resolving to a Tailscale IP that no longer exists; without a tunnel the names are unreachable anyway, so resolving them publicly buys nothing and leaks internal naming). ⚠️ *flagged for human veto — if kept, repoint to `10.0.0.2`.* Update the "Result:" paragraph: "on VPN or LAN, `mail.dnanu.de`/`*.nanulab.de` hit 10.0.0.2 directly; off VPN, only `:25` exists."

**§6 tree:** `tailscale.nix` → `wireguard.nix` in the networking list.

**§7 secrets:** remove `tailscale_oauth`; add `wireguard_server_private`, `wireguard_peer_<name>_private`, `wireguard_peer_<name>_psk` (per peer). (`profile_basic_auth` already present — now actually used by the profile vhost.)

**§10:** amend step 2/3: the standalone DNS mobileconfig is **retired** (DNS travels inside the WG peer config; on LAN, DHCP hands out AdGuard). `profile.nanulab.de` hosts (a) the signed mail/CalDAV/CardDAV `.mobileconfig` per original design (unsigned acceptable per human note) and (b) `/wg/` per-peer WireGuard configs/QRs; the whole vhost sits behind `auth_basic` (`profile_basic_auth`).

**§12 (1% manual):** replace "approve Tailscale subnet route" with: *forward UDP 51820 → 10.0.0.2 on the Speedport; disable Speedport DHCPv4 + IPv6/RA (enforces §3.1/§3.5); generate WG keypairs (`wg genkey`/`wg genpsk`), private halves + PSKs → `sops secrets/secrets.yaml`, public halves → `settings.nix`; rebuild; distribute QRs (print or AirDrop); enable On-Demand in each iOS WireGuard app; revoke the Tailscale OAuth client + remove machines in the Tailscale console; delete the old `nanulab DNS` profile from iOS devices.*

**§13:** replace Tailscale checks with: `wg show` (handshakes < 2 min old for active peers) · on cellular with tunnel up: `dig cloud.nanulab.de` → 10.0.0.2 and `curl -I https://cloud.nanulab.de` works · AdGuard query log shows `10.0.1.x` sources labeled with device names · LAN: `nmap --script broadcast-dhcp-discover` shows only AGH; fresh lease has DNS 10.0.0.2; no `fe80::1`/`127.0.0.1`/`10.0.0.1` entries in query log · torrent IP-leak test unchanged.

**§15:** amend the Headscale line: "Headscale + headplane UI (both native, verified 26.05) if declarative WG peer management ever becomes a burden — would need TCP 8443 forward (control+embedded DERP), preauth keys or an OIDC IdP; iOS via Tailscale app's alternate-server setting."

**§16:** add WireGuard (`man wg`, wireguard.com), headscale + headplane GitHub links; mark the Tailscale links "(historical, pre-2026-08-05)".

---

## 7. Files affected map

| File | Phase | Change |
|---|---|---|
| `modules/networking/wireguard.nix` | A | **new** — wg0 interface, sops peer secrets, QR-render oneshot, `/wg/` nginx location, ip_forward |
| `modules/networking/tailscale.nix` | A | **delete** (incl. NAT masquerade) |
| `modules/networking/base.nix` | A | `trustedInterfaces = [ "wg0" ]`, UDP 51820, comments |
| `modules/networking/ddclient.nix` | A | add `vpn.dnanu.de` |
| `modules/services/cloudflare-dns.nix` | A | add `vpn.dnanu.de` grey-cloud A record (mirror mail pattern) |
| `modules/services/ios-profile.nix` | A | remove dns.mobileconfig; keep vhost; add `basicAuthFile` |
| `modules/system/sops.nix` | A | remove `tailscale_oauth` |
| `hosts/homelab/configuration.nix` | A | import swap |
| `settings.nix` | A | −`tailscaleRoutes`, +`network.wireguard{...}`, +`domains.vpn` |
| `secrets/secrets.yaml` | A | sops: wireguard keys/PSKs (human generates) |
| `modules/networking/adguard.nix` | A+B | A: drop tailscale user_rule; B: WG ids in persistent clients |
| `OpenCode.md` | A+B | §3.2/§3.3/§3.4/§6/§7/§10/§12/§13/§15/§16 per §6 above |
| `README.md` / `Changes.md` / `Memory.md` / `TODO.md` | A+B | status updates per repo convention |
| `flake.nix` | — | **no change** |

---

## 8. Ordered task list for DeepSeek-V4-Pro (verbatim-executable)

**Precondition:** human has generated keypairs/PSKs and filled sops + `settings.nix` public keys — OR executor uses placeholder peers and the human fills keys before deploy. Executor must `nix flake check`/`nixos-rebuild build`-equivalent eval (`nix eval .#nixosConfigurations.homelab.config.system.build.toplevel` or `nix build .#nixosConfigurations.homelab.config.system.build.toplevel`) after each milestone and commit per the git-workflow skill. Do NOT deploy to 10.0.0.2 until the human approves the built closure.

### Phase A — VPN swap
1. `settings.nix`: remove `network.tailscaleRoutes`; add `domains.vpn = "vpn.dnanu.de";` and the `network.wireguard` block from §4.2 (publicKey placeholders). Commit: `settings: declarative WireGuard peer registry, drop tailscaleRoutes`.
2. `modules/networking/wireguard.nix`: create per §4.4 — `networking.wireguard.interfaces.wg0`, dynamic `sops.secrets` (`wireguard_server_private`, per-peer `wireguard_peer_<name>_{private,psk}`), `boot.kernel.sysctl."net.ipv4.ip_forward" = 1`, `systemd.services.wireguard-profile-render` (renders conf+PNG+index to `/var/lib/mobileprofile/wg/`, root:nginx 0640, after sops-nix), and `services.nginx.virtualHosts."profile.nanulab.de".locations."/wg/" = { root = "/var/lib/mobileprofile"; }`. Guard the renderer script against missing placeholder secrets (fail with a clear message listing missing keys).
3. `modules/networking/base.nix`: `trustedInterfaces = [ "wg0" ];` (replace `tailscale0`), `allowedUDPPorts = [ 53 67 51820 ];`, update the comment block (mention §3.3 supersession).
4. `modules/networking/tailscale.nix`: delete file. `hosts/homelab/configuration.nix`: replace the import with `../../modules/networking/wireguard.nix`.
5. `modules/system/sops.nix`: remove the `tailscale_oauth` entry.
6. `modules/networking/ddclient.nix`: `domains = [ settings.domains.mail settings.domains.vpn ];`. `modules/services/cloudflare-dns.nix`: add the `vpn.dnanu.de` A record mirroring the mail entry (grey cloud). 
7. `modules/services/ios-profile.nix`: delete the `profileDir` dns.mobileconfig definition and its `locations."/dns.mobileconfig"` block; keep the `profile.nanulab.de` vhost; add `basicAuthFile = config.sops.secrets.profile_basic_auth.path;` to the vhost.
8. `modules/networking/adguard.nix`: remove `"@@||tailscale.com^$important"` from `user_rules`.
9. Eval + build the full closure; fix any eval errors. Commit Phase A (one commit or logical series ending with): `networking: replace Tailscale SaaS with declarative WireGuard (OpenCode.md §3.3 superseded)`.
10. Add placeholder sops entries for all wireguard secrets (human runs `sops secrets/secrets.yaml` with real keys before deploy — document exact key names in the commit message and Changes.md).

### Phase B — AdGuard fixes
11. `modules/networking/adguard.nix`: extend `clients.persistent` per §5.3 (add `Admin` client; append WG IPs to Dumitru/M/T/Guests ids). Comment above the block: *"WG peers (10.0.1.x) map to the same person as their LAN IPs — labels follow the human, not the path."*
12. Eval/build; commit: `adguard: label WireGuard peer IPs as named persistent clients`.
13. `OpenCode.md`: apply §6 amendments verbatim (§3.2, §3.3 replacement, §3.4, §6, §7, §10, §12, §13, §15, §16). Commit: `docs: lock WireGuard §3.3, update ports/DNS/secrets/runbook/verification`.
14. `README.md`: update Status (phase note: "WireGuard replaces Tailscale; ports 25/tcp + 51820/udp") and the agent-facing description if it mentions Tailscale. `TODO.md`: tick the VPN-alternative + AdGuard items; move Speedport DHCP/IPv6 disable + key generation + QR distribution + Tailscale-console cleanup into the 1%-manual checklist. `Changes.md`: session entry. `Memory.md`: note new known facts (WG subnet 10.0.1.0/24, endpoint vpn.dnanu.de, profile.nanulab.de now auth_basic-protected, old dns.mobileconfig retired, headscale+headplane verified as fallback). Commit: `docs: session updates (README/TODO/Changes/Memory)`.
15. Final report to human: build result, the exact 1% manual steps in order (keys → sops → port forward → Speedport DHCP/IPv6 off → deploy → QR distribution → On-Demand toggles → Tailscale console cleanup → remove old iOS DNS profile), and the §13 verification commands to run after deploy.

### Explicit non-goals for the executor
- No headscale/headplane/netbird/wg-access-server code (evaluation only; fallback is documented, not built).
- No containers. No new flake inputs. No exit node / NAT for wg0. No `aaaa_disabled` or IPv6 filtering in AdGuard.
- Do not touch mail, SSH settings, VPN-confinement, or any service module outside the table in §7.
- Do not deploy (`/deploy`) — human approves the closure first.

---

## 9. Risks & rollback
- **Risk: human locks themselves out remotely** — deploy while on LAN; keep physical/SSH-via-LAN access; Tailscale stays functional until the rebuild switches (old closure remains in boot menu). Rollback = boot previous generation or `git revert` Phase A commits + rebuild.
- **Risk: peer private keys rendered server-side** — accepted (§3 posture); opt-in alternative documented (workstation-side keygen).
- **Risk: `profile_basic_auth` secret format mismatch** — it must be htpasswd format for nginx `basicAuthFile`; executor must note this in the sops key comment/Changes.md.
- **Risk: Speedport UI lacks full IPv6-off** — §3.5 fallback already accepted in OpenCode.md (bypass tolerated); LAN DNS fix (DHCP off) is independent and still works.

*(Plan ends. No code was modified; no commits created.)*
