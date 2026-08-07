# OpenCode.md — nanulab/dnanu 20-Year NixOS Homelab

> **For the agent:** This document is the single source of truth.
> Build exactly what is specified here. When a choice is marked ✅ LOCKED, do not revisit it.
> When a choice was marked ⚠️ VERIFY, it has been checked against pinned `nixos-26.05` as of 2026-08-03 (see Changes.md for verification table).
> All options, packages, and module names below reflect the pinned channel — use them directly.
> Do not add services, containers, or dependencies not listed here.
> _the Rulings appendix amends the main body; where they conflict, rulings win_

## Intro
You will be provided with an local IPv4 Address you can connect to via ssh (or ssh-mcp) to tinker around with the nixOS installation ISO.

I will basicall do this:
1. Boot into the Live ISO
2. sudo -i
3. passwd nixos (and set the password to 123)
4. passwd root  (and set the password to 456)
5. sudo systemctl start sshd
6. and give you the credentials, which I will give you now ssh 10.0.0.2@nixos with password 123 or ssh 10.0.0.2@root with password 456
7. if something doesnt work please tell me

## Session Workflow (2026-08-06)

The human drives the session by annotating files in `~/nixos/` or invoking `/task`. The agent follows this flow:

1. **Human marks up files** — highlights issues, features, bugs, or questions in repo files (OpenCode.md, TODO.md, settings.nix, etc.) — or runs `/task`.
2. **Agent creates task file** in `inputs/[Task]-for-[Model].md` — summarizes what needs to be done, which files are affected
3. **Agent recommends a reasoning tier** based on complexity; **human approves or overrides**:
   | Tier | Model | Agent | For |
   |------|-------|-------|-----|
   | Low | DeepSeek V4 Flash / MiMo V2.5 | `planner-low` | small fixes, simple config, docs |
   | Medium | DeepSeek V4 Pro / MiMo V2.5 Pro | `planner-med` | module creation, multi-file, service config |
   | High | GLM 5.2 | `planner-high` | architecture, hard debugging, locking decisions |
   | Max | Kimi K3 | `planner-max` | security audits, major restructures |
4. **Reasoning model writes plan** in `outputs/[Task]-plan-by-[Model].md` — concrete, executable steps
5. **Human reviews plan** — can annotate the output file with changes
6. **`nixos-builder` (DeepSeek V4 Pro) executes** following the plan's instructions
7. **Orchestrator (Flash) troubleshoots** anything that breaks after execution

### `/` Commands

| Command | What it does | Agent |
|---------|-------------|-------|
| `/task` | **General-purpose workflow** — gather → inputs → planner (by tier) → plan → review → execute | orchestrator |
| `/deploy` | Deploy config to homelab (10.0.0.2), rebuild | deployer (Pro) |
| `/rebuild` | Rebuild NixOS from latest committed config | deployer (Pro) |
| `/verify` | Run §13 verification suite against running server | planner-low (Flash) |
| `/update` | Quarterly `nix flake update` (human-approved) | planner-high (GLM 5.2) |
| `/secrets` | Open sops secrets.yaml for editing | nixos-builder (Pro) |
| `/commit` | Stage + commit changes with descriptive message | nixos-builder (Pro) |
| `/pr` | Create or update a PR against the repo | nixos-builder (Pro) |
| `/status` | Report repo state, homelab health, toolchain | planner-low (Flash) |
| `/review` | Review uncommitted changes for bugs, security, structure | security-reviewer (Kimi K3) |
| `/init` | Full session start: probe env, route to model tiers, drive build order | orchestrator |

Special-purpose commands (`/deploy`, `/review`, `/init`, etc.) serve their specific jobs. **`/task` is the general-purpose command** for everything else.

## 1. Philosophy & Hard Rules

1. **99% Declarative Rule.** NixOS declares infrastructure: ZFS, networking, services, users, paths, secrets, TLS. The human configures application *state* once via web UIs (admin accounts, indexers, libraries). No bootstrap scripts poking APIs — they rot.
2. **Native NixOS modules only.** Zero containers in v1 (VPN via `VPN-Confinement` namespaces, not gluetun). If a service has no native module, it goes to Phase 2, not into podman.
3. **Zero open ports** except TCP 25 (inbound SMTP) forwarded to `10.0.0.2`.
4. **Stable channel, pinned flake.** `nixpkgs` follows `nixos-26.05` (or current stable). No auto-upgrades. Human runs `nix flake update` deliberately, 2–4×/year.
5. **Single-node monolith.** No clustering.
6. **Single-user system.** One human. One mailbox identity (`hey@dnanu.de`), one services admin (`admin@dnanu.de`).
7. **Secrets via `sops-nix` (age).** Private age key lives on a USB drive + password manager, never in the repo. Repo is public-safe.

## 2. Hardware Lifecycle

| Phase | Machine | CPU/RAM | Disk |
|-------|---------|---------|------|
| Test | Dell Latitude E5520 | i5-2520M / 6GB DDR3 | 250GB SSD, single-disk ZFS |
| Prod | Future build | 12th-gen i5 / 64GB | 1TB NVMe boot, 2×4TB SSD RAID1 (`fast`), 2×8TB HDD RAID1 (`slow`) |

**Migration contract:** the config references abstract paths `/fast` and `/slow` via `settings.nix` only. Moving to prod = new `hardware-configuration.nix`, new `disko.nix` (two pools, same mountpoints), bump `zfsArcMax`. Nothing else changes.

Dell-specific: `services.logind.lidSwitch = "ignore"` (lid closed ≠ suspend — the battery is a free UPS). Immich machine learning **disabled** on this CPU.

## 3. Network Architecture

### 3.1 Topology
- Router: Telekom Speedport Smart 4 @ `10.0.0.1`. **DHCPv4 must be disabled** (DHCPv6 disabled-if-possible, else harmless coexistence — Kea serves only ULA). IPv6 stays on (mail + modern infra need it — §3.5).
- Server: **static** `10.0.0.2/24`, gw `10.0.0.1`, ULA `fd10::2/64`, declared in NixOS (`networking.interfaces.<if>.ipv4.addresses`). No ARP tricks.
- **v4 user-block addressing (2026-08-06):** `users.nix` is the single source of truth for IP allocation. Blocks: admin (0-9, admin0=net addr, admin1=router, admin2=homelab=WG server, admin3-9=devices), dumitru (.10-19), adela (.20-29), tiberiu (.30-39), david (.40-49), ramona (.50-59), tibisor (.60-69), iza (.70-79), kerem (.80-89), hannah (.90-99). Naming: base=[user] (no number), then [user]1-9. guests (.100-200, Kea DHCP pool, no VPN), .201-.254 unassigned.
- **Kea** (`services.kea.dhcp4` + `services.kea.dhcp6`) is the LAN DHCP server. AdGuard Home is DNS-only. Kea dhcp4: pool `.100-.200`, 10 host reservations (real MACs only). Kea dhcp6: stateful ULA `fd10::/64`, pool `fd10::100-200`, DNS = `fd10::2`. GUA via Speedport SLAAC (accept_ra=1, no v6 forwarding). Server static ULA `fd10::2/64`.

### 3.2 Ports & Exposure — ✅ LOCKED

| Flow | Path | Ports open on router |
|------|------|----------------------|
| Inbound SMTP (server→server) | Internet → `mail.dnanu.de` (public A, **grey cloud**, ddclient-updated) → router fwd → `10.0.0.2:25` | **25/tcp** |
| Public blogs + autoconfig | Internet → Cloudflare edge → `cloudflared` tunnel → nginx `10.0.0.2:8080` | none |
| Remote access (all devices) | Internet → `vpn.dnanu.de` (grey cloud, ddclient) → router fwd UDP 51820 → `10.0.0.2:51820` (WireGuard) | **51820/udp** |
| Everything else (Nextcloud, Jellyfin, IMAP 993, submission 465, all admin UIs) | Device → WireGuard tunnel → `10.0.0.2` (nginx 443 / mail 993+465 / admin UIs) | none |
| Outbound mail | Postfix → `smtp.resend.com:465` (SMTPS, user `resend`, pass = API key) | none |
| Torrent/Soulseek/Usenet | confined netns → AirVPN WireGuard | none |

Router column total: **25/tcp + 51820/udp only**.

### 3.3 WireGuard — remote-access VPN — ✅ LOCKED (2026-08-05, supersedes Tailscale SaaS; v4 2026-08-06)
- Kernel WireGuard, `networking.wireguard.interfaces.wg0`, server `10.0.10.2/24` (mirroring LAN 10.0.0.2). No SaaS control plane. **No exit node** (split-tunnel only) — kills the WhatsApp/adguard-reachability/blocking-rate issues.
- **97 peers fully pre-provisioned** (7 admin admin3-9-vpn + 90 user [user]+[user]1-9-vpn) with real keypairs. Spare slots: MAC=TODO, QR pre-rendered; claim = fill MAC + rebuild. Peers derived from `users.nix` helpers (wgPeers/wgPeerNames). Public keys in generated `wireguard-pubkeys.nix` (97 entries, committed). Private keys + PSKs in sops (`wireguard_peer_<hostname>-vpn_{private,psk}`, **194 keys**). Keygen via `scripts/gen-wg-keys.sh` (idempotent, two-pass v3→v4 rename).
- Endpoint `vpn.dnanu.de` (grey cloud, ddclient-managed) — router forwards **UDP 51820 → 10.0.0.2** (already done, human confirmed 2026-08-05). WireGuard silently drops unauthenticated packets: the port answers no scans; no TLS/HTTP/control-plane surface exists.
- Client configs push `DNS = 10.0.0.2` and `AllowedIPs = 10.0.0.0/24`: all DNS flows through the tunnel to AdGuard (per-device labels via static 10.0.10.x ids), internet traffic stays direct.
- Reachability split: `*.nanulab.de` service vhosts are **VPN-only** (nginx source allowlist derived from `users.nix` — admin LAN 10.0.0.1-9 + VPN 10.0.10.3-9, user LAN 10.0.0.10-99 + VPN 10.0.10.3-99). AdGuard UI is admin-tier (admin LAN/VPN only). `profile.dnanu.de` is reachable over LAN/WiFi **without VPN** (cloudflared tunnel + Authelia).
- Onboarding: activation oneshot (`wireguard-profile-render`) renders per-user `.conf` + QR PNGs → `/var/lib/mobileprofile/wg/<user>/`; served at `profile.dnanu.de/<user>/` behind Authelia. iOS = official WireGuard app → scan QR → enable On-Demand (WiFi+Cellular) once. No accounts — possession of the private key IS identity. Admin page shows 7 QRs (admin3-9-vpn), user pages show 10 QRs (all slots).
- Former lock rationale (OAuth non-expiry, zero ports) superseded: exit-node side effects + dynamic 100.x IPs broke per-device DNS labeling; sovereignty preferred over zero-port purity.
- Fallback: headscale + headplane (both native modules, verified in pinned 26.05: headscale 0.28.0, headplane 0.6.2) if self-service multi-device enrollment is ever needed — §15.

### 3.4 Split-Horizon DNS — ✅ LOCKED (this is what makes iOS work)
- **AdGuard DNS rewrites** (declarative, `mutableSettings = false`):
  - `*.nanulab.de` → `10.0.0.2`
  - `mail.dnanu.de` → `10.0.0.2`
  - everything else → upstream (quad9)
- Public Cloudflare DNS:
  - `*.nanulab.de` / bare `nanulab.de` → **no public A records** (deleted 2026-08-06 — services are VPN-only; resolving publicly leaks internal naming and reaches nothing). AdGuard rewrites serve LAN/VPN clients locally.
  - `vpn.dnanu.de` A → dynamic home IP (grey cloud, ddclient). WireGuard endpoint.
  - `mail.dnanu.de` A → dynamic home IP (grey cloud, ddclient). **Must stay unproxied or SMTP dies.**
- Result: on VPN or LAN, `mail.dnanu.de`/`*.nanulab.de` hit `10.0.0.2` directly; off VPN, only `:25` exists. iOS Mail syncs when WireGuard is on — accepted behavior.
- AdGuard UI (`adguard.nanulab.de`) is **admin-IP-only** (nginx allowlist: 10.0.0.1-9 + 10.0.10.3-9). All LAN/VPN devices use AdGuard as DNS on :53 irrespective of tier.
- **Dead-name handling:** `*.nanulab.de` wildcard rewrite kept (adguard + future services). nginx catch-all `default_server` on 0.0.0.0:443+:80 returns **404** — unmatched `*.nanulab.de` hosts (e.g. `profile.nanulab.de`) no longer leak the AdGuard dashboard. AGH DNS-only, `runtime_sources.dhcp=false` (Kea manages DHCP).

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
- **Kea DHCPv6** (stateful ULA `fd10::/64`) + Speedport DHCPv6 (GUA) coexist
  harmoniously — disjoint address spaces, both DNS → AdGuard. Android ignores
  DHCPv6 → covered by v4 DNS (10.0.0.2 from Kea dhcp4).

### 3.6 Cloudflare Tunnel (blogs only)
`services.cloudflared.tunnels."<id>"` with `credentialsFile` from sops; ingress: `dnanu.de`, `www.dnanu.de`, `autoconfig.dnanu.de`, `mta-sts.dnanu.de` → `http://127.0.0.1:8080`, `profile.dnanu.de` → `https://127.0.0.1:443` (`originRequest.noTLSVerify=true`), default `http_status:404`. Tunnel is **config_src=local** (declarative — ingress lives in the NixOS-generated `cloudflared.yml`, never the dashboard). The account-scoped `cloudflare_account_token` (Account > Cloudflare Tunnel > Edit) in sops allows full tunnel management via API without the dashboard. **Lesson (2026-08-07):** touching a tunnel in the CF dashboard flips it to remote-managed (`config_src=cloudflare`) and cloudflared then ignores the local config file (all hostnames dead, 404). `config_src` is only settable at tunnel creation — recovery = recreate the tunnel via API with `config_src=local`, update `settings.nix` tunnelId + sops `cloudflared_tunnel_cred`, rebuild.

### 3.7 DNSSEC — ✅ LOCKED (Cloudflare-managed, zero NixOS config)
- Enable DNSSEC on both Cloudflare zones (`dnanu.de`, `nanulab.de`). Algorithm: ECDSAP256SHA256 (CF-managed). Nameservers unchanged.
- Publish the DS record (one per zone) at the `.de` registrar's DENIC interface. **1% manual**, added to §12.
- Order: enable signing at Cloudflare first, **then** publish DS at registrar. Never withdraw signing while DS exists (bogus domain, full resolution failure).
- No conflicts: grey-cloud `mail.dnanu.de` (dynamic IP) is re-signed automatically by Cloudflare; DNSSEC signs names, not IPs. Proxied records sign fine. `*.nanulab.de` has no public records (2026-08-06) — nothing to sign there. AdGuard split-horizon rewrites are unsigned local answers (standard private-view behaviour, accepted).
- Phase-2 hook: DANE/TLSA for SMTP (joins MTA-STS/TLS-RPT in §15).
- Verification: `dig +dnssec +adflag dnanu.de @9.9.9.9` (AD bit set), `delv dnanu.de`, dnsviz.net spot check.

## 4. Mail Architecture

### 4.1 Stack — ✅ LOCKED
- **simple-nixos-mailserver** (Postfix + Dovecot + Rspamd): IMAP 993, submission 465 (SMTPS) + 587, LMTP, ManageSieve.
- **Nextcloud** provides CalDAV/CardDAV/WebDAV + Mail web app. Stalwart is **not** used.
- Inbound: port 25 direct. Outbound: Resend relay. No VPS relay. Accepted risk: Telekom inbound-25 flakiness → add Beszel/mail-queue health check.
- **Hardening (2026-08-06):** postfix helo/sender/recipient RFC-conformance restrictions; rspamd reject=12 + stock RBLs (spamhaus off — public resolver path); TLS-RPT (`mailserver.tlsrpt`) + DMARC reporting (`mailserver.dmarcReporting`) both enabled; outbound Resend path pinned to `verify` via static tls_policy ahead of tlspol; DANE TLSA 3 1 1 auto-synced from the ACME cert; queue watchdog alerts via Resend API.

### 4.2 Accounts — ✅ LOCKED
```nix
mailserver = {
  enable = true;
  fqdn = "mail.dnanu.de";
  domains = [ "dnanu.de" ];
  enableSubmission = true;     # 587
  enableSubmissionSsl = true;  # 465
  accounts."hey@dnanu.de" = {
    hashedPasswordFile = config.sops.secrets.mail_hey.path;
    aliases = [ "it@" "health@" "wealth@" "creative@" "academic@"
                "accounts@" "contact@" "partners@" ]; # @dnanu.de
    sieveScript = '' ... per-alias fileinto :create ... ''; # ✅ verified in pinned SNM 26.05
  };
  accounts."admin@dnanu.de" = {
    hashedPasswordFile = config.sops.secrets.mail_admin.path;
    aliases = [ "postmaster@" "hostmaster@" "webmaster@" "abuse@" "security@" ];
  };
  x509.useACMEHost = "mail.dnanu.de"; # cert from security.acme DNS-01, group-readable by dovecot2/postfix
};
```
Sieve logic: `if address :is "to" "it@dnanu.de" { fileinto :create "IT"; stop; }` × 8; fallthrough → INBOX (only `hey@` lands there). Sub-addressing `hey+foo@` ✅ `recipientDelimiter` verified.

### 4.3 Outbound relay (Resend) — ✅ LOCKED
SNM has no relay option; use Postfix directly:
```nix
services.postfix = {
  mapFiles."sasl_passwd" = sopsTemplate; # "[smtp.resend.com]:465 resend:re_APIKEY" — rendered from sops, mode 0600
  # Static TLS policy — verify (CA+hostname) beats the tlspol socketmap for the relay.
  mapFiles."tls_policy" = pkgs.writeText "tls_policy" ''
    [smtp.resend.com]:465 verify
    smtp.resend.com verify
  '';
  settings.main = {
    relayhost = "[smtp.resend.com]:465";
    smtp_sasl_auth_enable = "yes";
    smtp_sasl_password_maps = "hash:/etc/postfix/sasl_passwd";
    smtp_sasl_security_options = "noanonymous";
    smtp_tls_wrappermode = "yes";
    # REMOVED: smtp_tls_security_level = "encrypt";  (global level now "dane" via SNM+tlspol; per-destination TLS via tls_policy+tlspol)
    smtp_tls_policy_maps = lib.mkBefore [ "hash:/var/lib/postfix/conf/tls_policy" ];
  };
};
```

### 4.4 DNS records (Cloudflare, grey cloud unless noted)

| Type | Name | Value |
|------|------|-------|
| A | `mail.dnanu.de` | home IP (ddclient-managed) |
| AAAA | `mail.dnanu.de` | home IPv6 GUA (ddclient-managed) |
| A | `vpn.dnanu.de` | home IP (ddclient-managed, grey cloud) — WireGuard endpoint §3.3 |
| AAAA | `vpn.dnanu.de` | home IPv6 GUA (ddclient-managed — dual-stack WG endpoint) |
| MX | `dnanu.de` | `mail.dnanu.de` prio 10 |
| MX | `nanulab.de` | `mail.dnanu.de` prio 10 |
| TXT | `dnanu.de` | `v=spf1 -all` (nothing sends with envelope @dnanu.de; Resend uses its `send.` subdomain) ⚠️ VERIFY against Resend's domain-verification records and copy theirs exactly |
| TXT/CNAME | per Resend dashboard | DKIM + SPF for `send.dnanu.de` |
| TXT | `_dmarc.dnanu.de` | `v=DMARC1; p=quarantine; rua=mailto:admin@dnanu.de` → `p=reject` after 1 month |
| TXT | `_mta-sts.dnanu.de` | `v=STSv1; id=20260806T000000` — MTA-STS policy lookup (RFC 8461) |
| CNAME | `mta-sts.dnanu.de` | `<tunnel-id>.cfargotunnel.com` (proxied) — serves .well-known/mta-sts.txt |
| TXT | `_smtp._tls.dnanu.de` | `v=TLSRPTv1; rua=mailto:admin@dnanu.de` — TLS-RPT reporting (RFC 8460) |
| TLSA | `_25._tcp.mail.dnanu.de` | `3 1 1 <auto-synced SPKI hash>` — DANE EE (RFC 6698), auto-updated via cloudflare-tlsa-sync |
| — | `*.nanulab.de` / `nanulab.de` | **no public A records** (VPN-only; AdGuard rewrites locally — §3.4) |
| CNAME | `dnanu.de`, `www`, `autoconfig`, `mta-sts` | `<tunnel-id>.cfargotunnel.com` (proxied ✅) |

`autoconfig.dnanu.de/mail/config-v1.1.xml`: static XML (Thunderbird auto-setup) served by the blogs nginx vhost.

### 4.5 Hardening & monitoring notes

**DANE TLSA (D1):** `3 1 1` (DANE-EE / SPKI / SHA-256), fully automated via `cloudflare-tlsa-sync` — computes cert SPKI hash, upserts TLSA record via CF API. Triggers: ACME `postRun` (renewal), daily persistent timer, boot. Gap: TTL 120s, DANE-enforcing senders tempfail+retry. **DANE only activates once the zone's DS record is published at DENIC** — until then, the unsigned zone means TLSA is ignored (safe to publish now).

**RBL policy (D2):** rspamd-side only. Stock free lists (mailspike, dnswl, spameatingmonkey, blocklist.de, virusfree, SURBL/URIBL/DBL) active; spamhaus explicitly disabled (unreachable via public resolvers). No `reject_rbl_client` in postfix (duplicates rspamd, risks false-positives from block codes).

**MTA-STS (D3):** Dedicated `mta-sts.dnanu.de` vhost on nginx 127.0.0.1:8080, fronted by cloudflared tunnel. Policy: `mode: enforce, max_age: 86400`. World-readable.

**Postfix restrictions (D4):** RFC-conformance checks only — helo required, non-FQDN/invalid helo rejected, non-FQDN sender/recipient rejected, unknown sender/recipient domain rejected, unauth pipelining rejected. No `reject_unknown_helo_hostname` (legit-but-sloppy senders), no `strict_rfc821_envelopes`, no sender callout, no postscreen.

**Outbound TLS (D5):** Static `verify` policy for `[smtp.resend.com]:465` in `tls_policy` map (prepended before tlspol socketmap). Upgrade from unverified encryption to CA+hostname-verified TLS on the money path.

**Monitoring (D6):** `mail-queue-watch` timer (15 min) alerts via Resend HTTPS API to `hey@dnanu.de` if postfix/dovecot/rspamd down, queue >2, or oldest >30 min. Rate-limited (6 h cooldown). Independent of local postfix — works when queue IS the problem.

**DMARC (D7):** `p=quarantine` now; flip to `p=reject` after 30-day clean report window.

## 5. Storage (ZFS + disko)

- `disko` targets `/dev/sda` (test) — human verifies device path at install. GPT: 1G ESP `/boot` + rest ZFS `rpool`.
- Datasets: `rpool/nix` (/nix), `rpool/root` (/), `rpool/fast` → `/fast`, `rpool/slow` → `/slow`. Prod: pools `fast` (SSD mirror) + `slow` (HDD mirror), same mountpoints.
- **Mandatory:** `networking.hostId = "<8 hex>";` (generate once, keep forever) and `boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;`
- ARC cap: `boot.kernelParams = [ "zfs.zfs_arc_max=1073741824" ];` on Dell; `settings.nix` parameter.

Layout:
```
/fast/user/hey/{work/{audio,video,images,literature,documents}/{apple,windows,linux},academic,downloads}
/fast/immich            # Immich-managed, black box
/fast/mail              # Maildir
/fast/backups/postgres  # nightly dumps, restic source
/slow/shared-media/video/{shows,movies}
/slow/shared-media/audio/{music,audiobooks,podcasts}
/slow/shared-media/literature/{books}
/slow/downloads/{qbittorrent,sabnzbd,slskd}   # *arr hardlink source
```
All media services + nextcloud + immich get supplementary group `media`; dirs `root:media 2775` (setgid).

## 6. Repo Structure

```
nixos-homelab/
├── flake.nix              # inputs: nixpkgs(26.05), sops-nix, disko, vpn-confinement, simple-nixos-mailserver
├── settings.nix           # THE user file: domains, IPs, email, vpn.forwardedPort, zfsArcMax, sshPubKey, hostId
├── users.nix              # v4: single source of truth for users, devices, and IP allocation (100 explicit entries)
├── wireguard-pubkeys.nix  # GENERATED — 97 WG public keys (committed, not secret)
├── scripts/gen-wg-keys.sh # idempotent WG key management script
├── secrets/secrets.yaml   # sops-encrypted, safe to commit
├── .sops.yaml             # age public key
├── hosts/
│   ├── homelab/{configuration.nix,hardware-configuration.nix,disko.nix}
│   └── installer/         # custom ISO w/ ssh key for nixos-anywhere
└── modules/
    ├── networking/{wireguard,cloudflare,nginx,ddclient,adguard,kea}.nix
    ├── services/{mail,nextcloud,media,arr-stack,vpn,vaultwarden,smart-home,monitoring}.nix
    ├── system/{zfs,users,backups,sops}.nix
    └── mobile-profile.nix
```

## 7. Secrets Inventory (sops-nix)

`cloudflare_api_token`, `cloudflare_account_token`, `cloudflared_tunnel_cred`, `resend_api_key`, `mail_hey`, `mail_admin`, `airvpn_wg_conf`, `b2_account_id`, `b2_account_key`, `restic_password`, `nextcloud_admin_pass`, `vaultwarden_admin_token`, `slskd_env` (`SLSKD_SLSK_USERNAME/PASSWORD`), `authelia_jwt`, `authelia_storage_key`, `authelia_users_yaml` (10 users: admin + 9 regular), `mobileca_key`, `mobileca_cert`, `wireguard_server_private`, `wireguard_peer_<hostname>-vpn_private`, `wireguard_peer_<hostname>-vpn_psk` (97 peers × 2 = **194** WG keys; `[user]-vpn`/`[user]1-9-vpn` naming — §3.3).

## 8. TLS

`security.acme` DNS-01 via Cloudflare (lego): `*.nanulab.de`, `*.dnanu.de`, `mail.dnanu.de`. Cert dir owned `acme:acme`; only nginx is in the `acme` group. Postfix/Dovecot read certs during root-init before privilege drop — verified working end-to-end (live TLSv1.3 on all ports). `reloadServices` set. No HTTP-01 (port 80 closed).

## 9. Service Map — all native modules ⚠️ VERIFY each exists in pinned 26.05

| Service | Module | URL (VPN only unless noted) | Notes |
|---|---|---|---|
| Nginx | `services.nginx` | — | reverse proxy, ACME integration |
| AdGuard Home | `services.adguardhome` | `adguard.nanulab.de` (admin-IP-only) | `mutableSettings=false`; DNS-only (DHCP retired to Kea — Decision B); binds `0.0.0.0` and `::`; persistent clients via isPeer + infra entry |
| Kea | `services.kea.dhcp4` + `services.kea.dhcp6` | — | LAN DHCPv4 + DHCPv6 (ULA `fd10::/64`); 10 host reservations; ctrl-agent/dhcp-ddns disabled; note: option names carry no `-server` suffix (that's only systemd unit names) |
| WireGuard | `networking.wireguard` | — | §3.3 |
| ddclient | `services.ddclient` | — | protocol cloudflare, `passwordFile`=sops, interval 300s, `use=web` |
| cloudflared | `services.cloudflared` | — | §3.6 |
| Mail | SNM `mailserver.*` | `mail.dnanu.de` | §4 |
| Nextcloud | `services.nextcloud` | `cloud.nanulab.de` | native pg + redis; `extraApps`: mail, calendar, contacts; `adminpassFile`=sops; `maxUploadSize="16G"` |
| Collabora Online | `services.collabora-online` | `office.nanulab.de` | native module; Nextcloud Office backend; VPN-only |
| Immich | `services.immich` | `photos.nanulab.de` | `mediaLocation=/fast/immich`; ML off on Dell |
| Vaultwarden | `services.vaultwarden` | `vault.nanulab.de` | `SIGNUPS_ALLOWED=false` |
| Jellyfin | `services.jellyfin` | `watch.nanulab.de` | SNB iGPU: `intel-vaapi-driver`; prod: `intel-media-driver` |
| Navidrome | `services.navidrome` | `music.nanulab.de` | `settings.MusicFolder=/slow/shared-media/audio/music` |
| Audiobookshelf | `services.audiobookshelf` | `listen.nanulab.de` | podcasts + audiobooks, manager AND player |
| Booklore | OCI container (`ghcr.io/booklore-app/booklore:<pinned-tag>`) | `books.nanulab.de` | single sanctioned container exception; MariaDB via `services.mysql.package = pkgs.mariadb` |
| Seerr | `services.seerr` | `requests.nanulab.de` | requests for movies/shows |
| Sonarr/Radarr/Lidarr/Readarr*/Prowlarr/Bazarr | `services.<name>` | `*.nanulab.de` | *Readarr pinned-archived + rreading-glasses mirror (Q1) |
| qBittorrent | `services.qbittorrent` | via VPN bridge IP | confined; listen port = AirVPN forwarded port |
| SABnzbd | `services.sabnzbd` | via VPN bridge IP | confined |
| slskd | `services.slskd` | via VPN bridge IP | confined; creds via `environmentFile`=sops; + soularr timer (Lidarr↔slskd bridge) |
| beets | `pkgs.beets` (systemd service) | — | CLI + YAML config; music tag post-processor (Lidarr organizes, beets perfects) |
| soularr | systemd timer (Python) | — | bridges Lidarr ↔ slskd for missing album searches |
| Home Assistant | `services.home-assistant` | `home.nanulab.de` | `trusted_proxies` for nginx |
| Beszel | `services.beszel.hub` + `.agent` | `status.nanulab.de` | agent monitors systemd units; mail-queue alert |
| Restic | `services.restic.backups.b2` | — | §11 |
| VPN | `vpnNamespaces.wg` (VPN-Confinement flake input) | — | `wireguardConfigFile`=sops; `portMappings` for web UIs; `openVPNPorts` = AirVPN forwarded port; `systemd.services.{qbittorrent,sabnzbd,slskd}.vpnConfinement` |

## 10. The `.mobileconfig` Generator — ✅ LOCKED design

1. Human generates a root CA **on the Mac** (`openssl` commands in README); key+cert stored in sops (`mobileca_*`). **Never** generate in a Nix build — `/nix/store` is world-readable. (I will not generate a root CA on my mac, mac's dead as of now, need to buy a new one, unsigned certs are also fine for now)
2. Systemd oneshot renders a static `.mobileconfig` (payloads: IMAP `mail.dnanu.de:993` SSL, SMTP `mail.dnanu.de:465` SSL, CalDAV + CardDAV → `cloud.nanulab.de/remote.php/dav`, embedded CA cert payload, **no passwords** — iOS prompts at install), signs it via `openssl smime -sign` with the CA, writes to `/var/lib/mobileprofile/`.
3. nginx serves it at `profile.dnanu.de` behind Authelia (`auth_request`). The standalone DNS `.mobileconfig` was **retired 2026-08-06** — DNS now rides in the WireGuard peer configs (on LAN, DHCP hands out AdGuard). The `profile.dnanu.de` vhost also serves per-user WireGuard configs + QR PNGs: `profile.dnanu.de/<user>/` (wireguard-profile-render oneshot). Profile pages list ALL of a user's slots: admin sees 7 QRs (admin3-9-vpn), users see 10 QRs (all 10 slots). Spare slots (MAC=TODO) get pre-rendered QRs. Authelia has 10 users (admin + 9 regular).
4. Flow: VPN or LAN on → open `profile.dnanu.de` → Authelia login → download → Settings → install → enable trust for the CA → Mail/Calendar/Contacts work (while WireGuard is on). Service TLS is real Let's Encrypt — the CA exists only for the "Verified" badge.

## 11. Backups (Restic → Backblaze B2)

- `services.postgresqlBackup` nightly: `nextcloud`, `immich` → `/fast/backups/postgres`.
- Restic nightly, source = ZFS snapshot (crash-consistent) + dumps:
  - **Include:** `/fast` (Nextcloud files, Immich, Maildir, dumps), `/var/lib` app state for every service in §9, `/etc/nixos` (the repo is also on GitHub).
  - **Exclude:** `/slow/shared-media`, `/slow/downloads`, caches.
- `passwordFile` + `environmentFile` (B2 creds) from sops. Prune: 7 daily / 4 weekly / 12 monthly.
- **Restore drill** (documented, tested once): new machine → `nixos-anywhere` → `restic restore` → reboot → done.

## 12. Deployment Runbook

**On the Mac (once):** generate age keypair (private → USB + password manager); generate mobile CA; clone repo; edit `settings.nix`; `sops secrets/secrets.yaml` to fill §7; commit.
**Install:** boot NixOS ISO on Dell (ethernet) → start sshd, set password → from Mac: `nix run github:nix-community/nixos-anywhere -- --flake .#homelab --extra-files <dir-with-age-key> root@<ip>` → disko formats, installs, reboots.
**1% manual (~45 min):** disable Speedport DHCPv4 (+DHCPv6 if UI allows); **switch dumitru iPhone off manual 10.0.0.3 → DHCP** (Kea reservation hands it 10.0.0.10 — arch and iPhone must not be on LAN together until this is done); verify UDP 51820 forward (done 2026-08-05); keep Speedport DHCPv4/DHCPv6 pointing at AdGuard + IPv6 enabled; fill iza/kerem/hannah MACs in `users.nix`; re-scan ALL WG QRs post-deploy (v4 names+IPs changed; deployed gen45 is v2 10.0.1.x so every device re-imports anyway); distribute Authelia passwords (10 users: admin + 9 regular); optional `rm /var/lib/AdGuardHome/leases.json` (stale, harmless in Kea era); revoke the Tailscale OAuth client + remove machines (Tailscale console); create Nextcloud admin + link Mail app to local IMAP; Jellyfin/Navidrome/ABS/Booklore admin accounts + libraries; Prowlarr indexers; connect *arrs to qBittorrent/SABnzbd/slskd; Seerr↔Jellyfin; Vaultwarden admin; HA onboarding; Beszel agent key; **run mail-tester.com + internet.nl after mail deploy; flip DMARC to `p=reject` after 30 clean days; publish DS records at registrar (both zones, §3.7, activates DANE).**

## 13. Verification Suite (run after install)

`zpool status` · `wg show` (handshakes < 2 min old for active peers, peers at 10.0.10.x, 97 peers listed) · `systemctl status kea-dhcp4-server kea-dhcp6-server` · Kea leases: arch=`10.0.0.3`, dumitru iPhone=`10.0.0.10`, Xbox=`10.0.0.41`, Samsung TV=`10.0.0.21` (`journalctl -u kea-dhcp4-server`) · `dig @10.0.0.2 mail.dnanu.de` (→10.0.0.2) · `dig mail.dnanu.de @1.1.1.1` (→home IP) · `dig vpn.dnanu.de @1.1.1.1` (→home IP) · `dig @fd10::2 cloud.nanulab.de` → 10.0.0.2 · cellular with tunnel up: `dig cloud.nanulab.de` → 10.0.0.2 and `curl -I https://cloud.nanulab.de` works · `curl -I https://profile.dnanu.de/admin/` (admin sees 7 QRs: admin3-9-vpn) · nginx ACL: guest IP → 403 on all vhosts · `curl -k https://profile.nanulab.de` → **404** (catch-all) · AdGuard query log shows 10.0.10.x sources labeled with device names · `swaks --to hey@dnanu.de --server <home-ip>` from outside · send via iOS → check Resend dashboard · LAN: fresh guest lease ∈ .100-.200 · torrent IP-leak test in qBittorrent · `restic check` · lid-close test · `systemctl --failed` empty · `dig +dnssec +adflag dnanu.de @9.9.9.9` (AD bit set) · `delv dnanu.de`.

## 14. Update Policy

Quarterly: `nix flake update` → build → test → switch. Rollback via boot menu / `flake.lock` git history. No unattended upgrades.

## 15. Phase 2 Backlog (documented, NOT built)

Nextcloud Talk (needs TURN+ports), MeTube/Pinchflat, IPTV, Headscale + headplane UI (both native, verified 26.05 — if declarative WG peer management ever becomes a burden; needs TCP 8443 forward, preauth keys or an OIDC IdP, iOS via Tailscale app's alternate-server setting), multi-user mailboxes. DANE TLSA active once DS published at DENIC (§3.7).

## 16. Key References

- SNM: https://nixos-mailserver.readthedocs.io/en/latest/ (options: `accounts.<name>.{aliases,sieveScript}`, `enableSubmissionSsl`, `x509.useACMEHost`, relay workaround = services.postfix directly)
- VPN-Confinement: https://github.com/Maroka-chan/VPN-Confinement · nixarr VPN docs: https://nixarr.com/wiki/vpn/ (AirVPN = static port forward, wg-quick)
- Resend SMTP: https://resend.com/docs/send-with-smtp (`smtp.resend.com:465`, user `resend`, pass = API key)
- Readarr retirement: https://github.com/readarr/readarr (mirror: rreading-glasses)
- disko: https://github.com/nix-community/disko · nixos-anywhere: https://github.com/nix-community/nixos-anywhere · sops-nix: https://github.com/Mic92/sops-nix
- Beszel/slskd/seerr modules: nixpkgs `services.beszel.{hub,agent}`, `services.slskd`, `services.seerr` (26.05)
- Booklore: https://github.com/booklore-app/booklore · soularr: https://github.com/mrusse/soularr · Hugo: https://gohugo.io · rreading-glasses mirror for Readarr metadata
- WireGuard: https://www.wireguard.com · headscale: https://github.com/juanfont/headscale · headplane: https://github.com/tale/headplane (Tailscale/100.x links historical, pre-2026-08-05)
- Mail hardening RFCs: RFC 8460 (TLS-RPT), RFC 8461 (MTA-STS), RFC 6698 (DANE TLSA), RFC 7489 (DMARC), RFC 7208 (SPF), RFC 6376 (DKIM)
- Rspamd: https://rspamd.com · SNM rspamd integration: https://nixos-mailserver.readthedocs.io/en/latest/
- Resend API (watchdog): https://resend.com/docs/api-reference/emails/send-email
# Ruling by Kimi K3 for Kimi K3 in Claude Code Harness
## Final Rulings (Blueprint v3)

### R1 — The "feels like Netflix" pipeline (answers A1 + A5)

Your requirement: *request → auto-download → auto-tag → auto-play, invisible plumbing.* This is the locked pipeline per media type:

| Type | Request via | Grabber | Manager/Metadata | Player |
|------|------------|---------|------------------|--------|
| Movies | Seerr | qBittorrent (AirVPN) | Radarr (writes NFO + poster) | Jellyfin |
| TV | Seerr | qBittorrent (AirVPN) | Sonarr (NFO + poster) | Jellyfin |
| Music | Lidarr UI | slskd via **soularr** + qBittorrent | Lidarr + **beets** (tagging service, config fully declared in Nix) | Navidrome |
| Audiobooks | Audiobookshelf UI | qBittorrent (AirVPN) | ABS built-in metadata | ABS |
| Podcasts | ABS UI (RSS search) | ABS built-in | ABS built-in | ABS |
| Books/Comics/Manga | Readarr¹ UI | qBittorrent (AirVPN) | Readarr + **Booklore** auto-metadata | **Booklore** |

¹ Readarr is archived/dead upstream but the nixpkgs package exists — we **pin it** (flakes excel at this) and point its metadata API at the `rreading-glasses` mirror. When it eventually breaks: migration note in the README. Nothing better exists natively.

**Kometa: dropped.** It's Plex-first; Sonarr/Radarr already write NFO/poster files that Jellyfin reads natively. One less moving part, same visual result.

**Beets: included**, native (it's just a CLI + YAML config — the most declarative tool in the whole stack). Lidarr organizes, beets perfects tags.

### R2 — Booklore replaces Kavita entirely (answers A6)

You pointed at it twice, so it's in — and it lets me **delete Kavita**: Booklore covers EPUB, PDF, comics, and manga, plus OPDS and KOReader/Kobo sync (huge if you ever buy an e-reader). One literature app instead of two.

**Cost:** Booklore is not in nixpkgs (Java Spring + Angular + MariaDB). Ruling:

```nix
# ⚠️ VERIFY first: if services.booklore exists in pinned 26.05, use it.
# Otherwise — the single sanctioned container exception:
virtualisation.oci-containers.containers.booklore = {
  image = "ghcr.io/booklore-app/booklore:<pinned-tag>"; # never :latest
  ...
};
services.mysql.package = pkgs.mariadb; # native MariaDB, container connects to host socket/IP
```

One pinned container, one native DB. Acceptable; the alternative (dropping the app you asked for twice) is worse. Library root: `/slow/shared-media/literature`. Its MariaDB gets a nightly dump → B2.

### R3 — Nextcloud Office stays, Talk goes (answers A7)

Talk needs a TURN server with open ports → violates the zero-port rule → **dropped, Phase 2 forever.**

Office stays, and it works **without containers**: nixpkgs has a native `services.collabora-online` module. Nextcloud's Office app points at the local coolwsd endpoint; nginx proxies it at `office.nanulab.de` (VPN-only). ⚠️ VERIFY module name in pinned channel. On the Dell's 6GB this will be the heaviest thing after Immich — accepted, it's a test box.

### R4 — The `dnanu.de` website stack (answers A10): **Hugo**

Decision made, here's the reasoning and the spec:

- **Why Hugo:** single native package (`pkgs.hugo`), content = plain Markdown files **inside your Git repo** (inherits your whole "clone → rebuild → works" philosophy), builds at `nixos-rebuild` time, output is dumb static files nginx can serve blindfolded. Zola is trendier, Astro/Next.js need Node buildchains — both fail the 20-year test harder than Hugo.
- **Writing a new entry = one file + one command:**

```
websites/dnanu.de/
├── hugo.toml
├── content/
│   ├── _index.md            # portfolio landing
│   ├── wealth/  { _index.md, blog/ *.md }
│   ├── health/  { _index.md, blog/ *.md }
│   ├── it/      { _index.md, blog/ *.md }
│   ├── creative/{ _index.md, blog/ *.md }
│   └── academic/{ _index.md, blog/ *.md }
├── layouts/                 # your AI-built theme (desktop+mobile responsive)
└── static/
```

- `hugo new it/blog/my-post.md` → write → `git push` → `nixos-rebuild switch` → live. An activation script runs `hugo build` into `/var/www/dnanu.de` (built on the server, no CI needed).
- The 5 section `_index.md` pages are your "show off what I do" pages — rarely-changing, exactly as you described. Blogs sit under each section. Taxonomy maps 1:1 to your email aliases (`it@`, `wealth@`…), which is tidy.
- Route spec for nginx/tunnel stays as before; only the content source changed from "plain files" to "Hugo output."

---

## Final Amendments to `OpenCode.md`

1. **§7 secrets:** add `booklore_db_password`. (soularr needs no secret — local API keys entered in the 1% phase.)
2. **§9 service map:** − Kavita, − Docmost, − Odoo, − Kometa; + Booklore (`books.nanulab.de`), + soularr (systemd timer, Lidarr↔slskd bridge), + beets (systemd service), + Collabora (`office.nanulab.de`). Every request path is: **Seerr** (movies/TV) or the native *arr/ABS/Readarr UIs.
3. **§5 storage:** add `/slow/shared-media/literature/{books,comics,manga}` as Booklore's root; add `mysql` (booklore) to the nightly dump list in §11.
4. **§3.6 tunnel ingress:** unchanged — Hugo output is served by the same nginx vhost.
5. **§16 references:** add booklore GitHub, Hugo docs, rreading-glasses, soularr.

### Final service count

**25 services, exactly one OCI container (Booklore), or more, everything else native.** RAM-heavy four on the Dell: Immich, Nextcloud+Collabora, Jellyfin, Booklore — with ZFS ARC capped at 1GB and 6GB total it'll be tight but bootable; that's what the test phase is for.

---

## Anything else? — No. Build order, frozen:

1. `flake.nix` + `settings.nix` + sops skeleton
2. `disko.nix` + ZFS + `hostId` + Dell quirks (lid, ARC)
3. Networking: static IP, AdGuard, WireGuard, ddclient, cloudflared, nginx+ACME
4. Mail (SNM + Resend relay + sieve + DNS table) ← **highest risk, verify earliest**
5. Nextcloud (+Office) + Immich + Vaultwarden
6. VPN-Confinement → downloaders → *arrs → players (incl. Booklore)
7. `.mobileconfig` signer + Hugo site
8. Restic + Beszel + verification suite

Hand the blueprint + these rulings to the build session and start at step 1. The only things that can still bite us are the ⚠️ VERIFY flags (module names in pinned 26.05, SNM's `sieveScript` option, Booklore packaging status) — all of which get checked in the first 10 minutes of the build. Go build it.
# Prompt 
```
Read OpenCode.md in full. It is the single source of truth — build exactly
what it specifies, nothing more. First task: pin nixpkgs, then verify every
⚠️ VERIFY flag against the pinned channel and report results as a table.
Do not write any other code until I approve the verification table.
Then we build phase 1 only.
```

## Additional info
I made a github repo: https://github.com/it-dnanu-de/nixos for this project and placed inside a README.md File, a License File and this document (OpenCode.md) and a .gitignore file, after every change you make please do a commit so everything is version controlled and can revert back whenever we fant to a previous configuration, make the use of Pull Requests if you want to, you can commit on my behalf instead of doing your own commits, everything is set up. Opencode is running on 7.1.5-arch1-2 archlinux x86_64 on this machine with 48GB of DDR5-6000MT/s CL30 Memory, AMD Ryzen 7 7900X3D, AMD Radeon RX7900XTX, 1TB NVMe Gen5 SSD, You are on a pretty powerfull machine running a pretty new version of arch linux, you can use my terminal on this machine, you can ssh into the server if you need anything, you can do everything you want just output me the server and do you OpenCode configurataion stuff on the machines.

One more thing I'd like to add is DNSSEC for the mail servers and websites, this should be pretty secure for intruders to have a hard time getting in so lots of stuff has to be configured.

Please do not disable ssh via password, I know its a security hazard but I'm fine with it. You can use an ssh key on this system but still allow ssh via password.

## Info about you and your harness

You are operating as part of a multi-model AI development harness.

The repository contains `OpenCode.md`, which is the single source of truth for this project. It defines the architecture, constraints, locked decisions, verification requirements, and implementation phases. Always follow it. Do not introduce services, dependencies, architectural changes, or alternatives that conflict with it.

Only read the sections of `OpenCode.md` relevant to the current task unless the full document is explicitly requested. The document is large and contains many historical decisions; avoid wasting context by repeatedly loading unrelated sections.

Your role depends on which model tier you are assigned to. Use the minimum capable model for each task. Higher reasoning models should be reserved for architecture, planning, and difficult decisions.

## Model capabilities

The available models are:

### Tier 1 — Fast execution and simple reasoning

Primary:
- DeepSeek V4 Flash

Fallback:
- MiMo V2.5

Use for:
- Small code changes
- Simple bug fixes
- Formatting
- Documentation updates
- Minor configuration changes
- Straightforward implementation tasks

Do not use this tier for:
- Architecture decisions
- Large refactors
- Multi-system changes
- Security-sensitive design

---

### Tier 2 — Advanced execution and medium reasoning

Primary:
- DeepSeek V4 Pro

Fallback:
- MiMo V2.5 Pro

Use for:
- Feature implementation
- Multi-file changes
- NixOS module creation
- Service configuration
- Debugging complex issues
- Implementing plans created by higher reasoning models

This tier is the default execution model for planned work.

---

### Tier 3 — Maximum reasoning and architecture

Primary:
- Kimi K3

Fallback:
- GLM 5.2

Use for:
- System architecture
- Large design decisions
- Complex debugging
- Security reviews
- Migration planning
- Cross-component reasoning
- Breaking down large milestones into smaller tasks

These models should primarily create plans, evaluate approaches, and resolve difficult decisions. They should not directly perform large amounts of repetitive implementation work when a Tier 2 model can execute the plan.

---

## Model routing principles

Always prefer the lowest capable model.

A simple request should not consume a high reasoning model.

Examples:

"Change this button color"
→ Tier 1

"Add a new service module"
→ Tier 2

"Redesign the network architecture"
→ Tier 3

"Implement a complete project milestone"
→ Tier 3 for planning, Tier 2 for execution

Escalate only when the task requires additional reasoning, planning, architectural decisions, or affects multiple systems.

---

## Available capabilities

This environment provides:

- Full terminal access on the development machine
- Git repository access
- Ability to inspect and modify project files
- Ability to run builds, tests, and verification commands
- SSH access to external machines when credentials and addresses are provided

Use available tools when they improve accuracy. Do not assume a command succeeded without verifying the result.

---

## Git workflow

Git is part of the development process.

After completing a coherent milestone:

1. Review all changes.
2. Run relevant verification commands.
3. Ensure no accidental files or secrets are committed.
4. Create a descriptive commit.

Commits should represent meaningful checkpoints that can safely be reverted.

Do not create commits containing broken, incomplete, or unverified work.

---

## Security rules

Never expose secrets, API keys, passwords, private keys, or sensitive configuration values.

Follow the security model defined in `OpenCode.md`.

Do not weaken security constraints unless explicitly instructed.

Password SSH authentication is intentionally allowed in this project. Do not disable it unless explicitly requested.

---

## Infrastructure rules

This project values:

- Declarative configuration
- Reproducibility
- Long-term maintainability
- Minimal unnecessary dependencies
- Verification before implementation

Before making architectural changes:

1. Check whether the decision is already locked in `OpenCode.md`.
2. If marked LOCKED, follow it.
3. If marked VERIFY, verify against the pinned environment.
4. If no decision exists, present options before committing to a design.

---

## Current project environment

Development machine:

- OS: Arch Linux
- CPU: AMD Ryzen 7 7900X3D
- RAM: 48GB DDR5-6000 CL30
- GPU: AMD Radeon RX 7900 XTX
- Storage: 1TB NVMe Gen5 SSD

Target system:

- NixOS homelab
- Configuration stored in this repository
- Deployment performed according to the instructions in `OpenCode.md`

The goal is not just to make the system work today, but to create a maintainable 20-year infrastructure platform.

## Changes you do
Please after every session load OpenCode.md, Readme.md, .gitignore, Changes.md, Memory.md, in every session you update the Readme.md, .gitignore, Changes.md, Memory.md.

### Opencode.md
This is this file, this doesnt need much explaining, this is you source of truth, you can change it however you like if needed, if we switch the way we do things and etc

### Readme.md
Is the file that explains the project to humans, make this look nice, should state what the system can do, what it cant, what bugs there are, what features are coming in the near future.

### .gitignoe
Self-explanatory, I don't need to explain this

### Changes.md
Here you store changes in this file, like everything we have done, this file is temporary, you wipe this file at end of session and write the changes into the OpenCode.md Project file

### Memory.md
Here you can store your memory, API Keys, Tokens you need, Credentials and everything else, this file it gitignored.

## AI capabilities and extensions

The AI harness may extend its capabilities through external knowledge sources, skills, MCP servers, and persistent memory.

Extensions should improve reliability and accuracy, not replace engineering judgement.

---

## Web access

The AI may use web search and documentation lookup when:

- verifying NixOS options
- checking package availability
- reading upstream documentation
- investigating errors
- validating security recommendations
- checking current versions or compatibility

Prefer primary sources:

1. Official documentation
2. Upstream repositories
3. NixOS/nixpkgs sources
4. Project documentation
5. Community discussions only when primary sources are unavailable

Do not rely on outdated information when a current source exists.

For NixOS work specifically, always verify options against the pinned nixpkgs version before implementation.

---

## Skills system

The AI may search for and load additional skills when a task requires specialized knowledge.

Examples:

- NixOS configuration
- ZFS administration
- networking
- security hardening
- mail server configuration
- Git workflows
- debugging
- documentation generation

Before using a skill:

1. Check what the skill does.
2. Verify it does not conflict with OpenCode.md.
3. Use only the minimum required capability.

Skills provide knowledge and workflows. They do not override project decisions.

---

## MCP servers

The AI may install and configure MCP servers when additional tools are required.

Examples:

- GitHub integration
- filesystem tools
- browser automation
- documentation search
- infrastructure tools
- monitoring tools

Before installing an MCP server:

1. Explain why it is required.
2. Verify the source is trustworthy.
3. Check permissions requested.
4. Avoid unnecessary dependencies.

Prefer official MCP implementations.

Installed MCP servers should be documented in the repository.

---

## Browser automation

The AI may use browser automation for tasks requiring interaction with web interfaces.

Examples:

- checking dashboards
- verifying DNS settings
- interacting with provider consoles
- testing web applications
- reading documentation

Browser automation should not be used when an API or CLI method exists.

Never expose credentials in screenshots, logs, or commits.

---

## Memory system

The AI may maintain persistent project memory.

Memory should contain:

- architectural decisions
- resolved problems
- important commands
- environment information
- lessons learned
- recurring issues

Memory should not contain:

- passwords
- API keys
- private keys
- personal secrets
- temporary debugging information

Important decisions should eventually be moved into OpenCode.md rather than existing only in memory.

---

## Learning from previous work

Before starting a major task:

Review:

- previous commits
- previous decisions
- existing architecture
- known problems
- previous failed approaches

Do not repeat previously rejected approaches without explaining why circumstances changed.

Failed attempts are valuable information. Record useful lessons.

---

## Self improvement

The AI may improve its workflows over time.

Examples:

- creating reusable skills
- improving documentation
- improving verification scripts
- adding automation
- refining development procedures

Self-improvement must preserve:

- reproducibility
- security
- declarative configuration
- project constraints

Never modify the core rules of the project without explicit approval.
