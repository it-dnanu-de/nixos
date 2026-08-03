# OpenCode.md — nanulab/dnanu 20-Year NixOS Homelab

> **For the agent:** This document is the single source of truth.
> Build exactly what is specified here. When a choice is marked ✅ LOCKED, do not revisit it.
> When marked ⚠️ VERIFY, check the referenced nixpkgs option exists in the pinned channel before using it.
> Do not add services, containers, or dependencies not listed here.
> _the rulings document amends CLAUDE.md; where they conflict, rulings win_

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
- Router: Telekom Speedport Smart 4 @ `10.0.0.1`. **DHCP disabled** (v4). Disable IPv6/RA if the UI allows (see §3.5).
- Server: **static** `10.0.0.2/24`, gw `10.0.0.1`, declared in NixOS (`networking.interfaces.<if>.ipv4.addresses`). No ARP tricks.
- AdGuard Home on the server becomes LAN DHCP + DNS.

### 3.2 Ports & Exposure — ✅ LOCKED

| Flow | Path | Ports open on router |
|------|------|----------------------|
| Inbound SMTP (server→server) | Internet → `mail.dnanu.de` (public A, **grey cloud**, ddclient-updated) → router fwd → `10.0.0.2:25` | **25/tcp only** |
| Public blogs + autoconfig | Internet → Cloudflare edge → `cloudflared` tunnel → nginx `10.0.0.2:8080` | none |
| Everything else (Nextcloud, Jellyfin, IMAP 993, submission 465, all admin UIs) | Device → Tailscale → `10.0.0.2` (subnet route) or `100.x` → nginx 443 / direct | none |
| Outbound mail | Postfix → `smtp.resend.com:465` (SMTPS, user `resend`, pass = API key) | none |
| Torrent/Soulseek/Usenet | confined netns → AirVPN WireGuard | none |

### 3.3 Tailscale (official SaaS) — ✅ LOCKED
- `services.tailscale.enable = true; useRoutingFeatures = "server";`
- `--advertise-routes=10.0.0.0/24` (subnet router). Approve route once in admin console.
- Auth: Tailscale **OAuth client** credential (tagged `tag:server`) in sops → `services.tailscale.authKeyFile`. ⚠️ Pre-auth keys expire in ≤90 days; OAuth client secrets don't. Rebuilds years later must work.
- Tailscale admin console DNS: global nameserver = `10.0.0.2` (AdGuard), "Override local DNS" ON → ad-blocking everywhere. Add `1.1.1.1` as second global NS so a dead server doesn't kill client DNS entirely.

### 3.4 Split-Horizon DNS — ✅ LOCKED (this is what makes iOS work)
- **AdGuard DNS rewrites** (declarative, `mutableSettings = false`):
  - `*.nanulab.de` → `10.0.0.2`
  - `mail.dnanu.de` → `10.0.0.2`
  - everything else → upstream (quad9)
- Public Cloudflare DNS:
  - `*.nanulab.de` A → server's Tailscale `100.x` IP (grey cloud). Publishing a CGNAT IP is harmless and makes names resolve even when AdGuard is bypassed.
  - `mail.dnanu.de` A → dynamic home IP (grey cloud, ddclient). **Must stay unproxied or SMTP dies.**
- Result: on Tailscale, `mail.dnanu.de:993/465` hits `10.0.0.2` directly; off Tailscale, only `:25` exists. iOS Mail syncs when Tailscale is on — accepted behavior.

### 3.5 LAN IPv6 caveat
Speedport may still announce itself as IPv6 DNS. Devices using it bypass AdGuard. Mitigation: disable IPv6 on router if possible; otherwise accept bypass (services still resolve via public `*.nanulab.de` records → Tailscale IP).

### 3.6 Cloudflare Tunnel (blogs only)
`services.cloudflared.tunnels."<id>"` with `credentialsFile` from sops; ingress: `dnanu.de`, `www.dnanu.de`, `autoconfig.dnanu.de` → `http://127.0.0.1:8080`; default `http_status:404`. Tunnel routes created once in CF dashboard (1% manual) or via API.

## 4. Mail Architecture

### 4.1 Stack — ✅ LOCKED
- **simple-nixos-mailserver** (Postfix + Dovecot + Rspamd): IMAP 993, submission 465 (SMTPS) + 587, LMTP, ManageSieve.
- **Nextcloud** provides CalDAV/CardDAV/WebDAV + Mail web app. Stalwart is **not** used.
- Inbound: port 25 direct. Outbound: Resend relay. No VPS relay. Accepted risk: Telekom inbound-25 flakiness → add Beszel/mail-queue health check.

### 4.2 Accounts — ✅ LOCKED
```nix
mailserver = {
  enable = true;
  fqdn = "mail.dnanu.de";
  domains = [ "dnanu.de" ];
  enableSubmission = true;     # 587
  enableSubmissionSsl = true;  # 465
  loginAccounts."hey@dnanu.de" = {
    hashedPasswordFile = config.sops.secrets.mail_hey.path;
    aliases = [ "it@" "health@" "wealth@" "creative@" "academic@"
                "accounts@" "contact@" "partners@" ]; # @dnanu.de
    sieveScript = '' ... per-alias fileinto :create ... ''; # ⚠️ VERIFY option exists in pinned SNM release
  };
  loginAccounts."admin@dnanu.de" = {
    hashedPasswordFile = config.sops.secrets.mail_admin.path;
    aliases = [ "postmaster@" "hostmaster@" "webmaster@" "abuse@" "security@" ];
  };
  certificateScheme = "manual"; # certs from security.acme DNS-01, group-readable by dovecot2/postfix
};
```
Sieve logic: `if address :is "to" "it@dnanu.de" { fileinto :create "IT"; stop; }` × 8; fallthrough → INBOX (only `hey@` lands there). Sub-addressing `hey+foo@` ⚠️ VERIFY `recipientDelimiter`.

### 4.3 Outbound relay (Resend) — ✅ LOCKED
SNM has no relay option; use Postfix directly:
```nix
services.postfix = {
  mapFiles."sasl_passwd" = sopsTemplate; # "[smtp.resend.com]:465 resend:re_APIKEY" — rendered from sops, mode 0600
  extraConfig = ''
    relayhost = [smtp.resend.com]:465
    smtp_sasl_auth_enable = yes
    smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
    smtp_sasl_security_options = noanonymous
    smtp_tls_wrappermode = yes
    smtp_tls_security_level = encrypt
  '';
};
```

### 4.4 DNS records (Cloudflare, grey cloud unless noted)

| Type | Name | Value |
|------|------|-------|
| A | `mail.dnanu.de` | home IP (ddclient-managed) |
| MX | `dnanu.de` | `mail.dnanu.de` prio 10 |
| MX | `nanulab.de` | `mail.dnanu.de` prio 10 |
| TXT | `dnanu.de` | `v=spf1 -all` (nothing sends with envelope @dnanu.de; Resend uses its `send.` subdomain) ⚠️ VERIFY against Resend's domain-verification records and copy theirs exactly |
| TXT/CNAME | per Resend dashboard | DKIM + SPF for `send.dnanu.de` |
| TXT | `_dmarc.dnanu.de` | `v=DMARC1; p=quarantine; rua=mailto:admin@nanulab.de` → `p=reject` after 1 month |
| A | `*.nanulab.de` | Tailscale `100.x` IP |
| CNAME | `dnanu.de`, `www`, `autoconfig` | `<tunnel-id>.cfargotunnel.com` (proxied ✅) |

`autoconfig.dnanu.de/mail/config-v1.1.xml`: static XML (Thunderbird auto-setup) served by the blogs nginx vhost.

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
├── secrets/secrets.yaml   # sops-encrypted, safe to commit
├── .sops.yaml             # age public key
├── hosts/
│   ├── homelab/{configuration.nix,hardware-configuration.nix,disko.nix}
│   └── installer/         # custom ISO w/ ssh key for nixos-anywhere
└── modules/
    ├── networking/{tailscale,cloudflare,nginx,ddclient,adguard}.nix
    ├── services/{mail,nextcloud,media,arr-stack,vpn,vaultwarden,smart-home,monitoring}.nix
    ├── system/{zfs,users,backups,sops}.nix
    └── mobile-profile.nix
```

## 7. Secrets Inventory (sops-nix)

`cloudflare_api_token`, `cloudflared_tunnel_cred`, `resend_api_key`, `mail_hey_hash`, `mail_admin_hash`, `tailscale_oauth`, `airvpn_wg_conf`, `b2_account_id`, `b2_account_key`, `restic_password`, `nextcloud_admin_pass`, `vaultwarden_admin_token`, `slskd_env` (`SLSKD_SLSK_USERNAME/PASSWORD`), `profile_basic_auth`, `mobileca_key`, `mobileca_cert`.

## 8. TLS

`security.acme` DNS-01 via Cloudflare (lego): `*.nanulab.de`, `*.dnanu.de`, `mail.dnanu.de`. Cert group readable by nginx, dovecot2, postfix; `reloadServices` set. No HTTP-01 (port 80 closed).

## 9. Service Map — all native modules ⚠️ VERIFY each exists in pinned 26.05

| Service | Module | URL (Tailscale only) | Notes |
|---|---|---|---|
| Nginx | `services.nginx` | — | reverse proxy, ACME integration |
| AdGuard Home | `services.adguardhome` | `adguard.nanulab.de` | `mutableSettings=false`; DHCP declarative; disable `systemd-resolved` (port 53 clash) |
| Tailscale | `services.tailscale` | — | §3.3 |
| ddclient | `services.ddclient` | — | protocol cloudflare, `passwordFile`=sops, interval 300s, `use=web` |
| cloudflared | `services.cloudflared` | — | §3.6 |
| Mail | SNM `mailserver.*` | `mail.dnanu.de` | §4 |
| Nextcloud | `services.nextcloud` | `cloud.nanulab.de` | native pg + redis; `extraApps`: mail, calendar, contacts; `adminpassFile`=sops; `maxUploadSize="16G"` |
| Immich | `services.immich` | `photos.nanulab.de` | `mediaLocation=/fast/immich`; ML off on Dell |
| Vaultwarden | `services.vaultwarden` | `vault.nanulab.de` | `SIGNUPS_ALLOWED=false` |
| Jellyfin | `services.jellyfin` | `watch.nanulab.de` | SNB iGPU: `intel-vaapi-driver`; prod: `intel-media-driver` |
| Navidrome | `services.navidrome` | `music.nanulab.de` | `MusicFolder=/slow/shared-media/audio/music` |
| Audiobookshelf | `services.audiobookshelf` | `listen.nanulab.de` | podcasts + audiobooks, manager AND player |
| Kavita | `services.kavita` | `read.nanulab.de` | books + comics + manga |
| Seerr | `services.seerr` | `requests.nanulab.de` | requests for movies/shows |
| Sonarr/Radarr/Lidarr/Readarr*/Prowlarr/Bazarr | `services.<name>` | `*.nanulab.de` | *Readarr pinned-archived + rreading-glasses mirror (Q1) |
| qBittorrent | `services.qbittorrent` | via VPN bridge IP | confined; listen port = AirVPN forwarded port |
| SABnzbd | `services.sabnzbd` | via VPN bridge IP | confined |
| slskd | `services.slskd` | via VPN bridge IP | confined; creds via `environmentFile`=sops; + soularr timer (Lidarr↔slskd bridge) |
| Home Assistant | `services.home-assistant` | `home.nanulab.de` | `trusted_proxies` for nginx |
| Beszel | `services.beszel.hub` + `.agent` | `status.nanulab.de` | agent monitors systemd units; mail-queue alert |
| Restic | `services.restic.backups.b2` | — | §11 |
| VPN | `vpnNamespaces.wg` (VPN-Confinement flake input) | — | `wireguardConfigFile`=sops; `portMappings` for web UIs; `openVPNPorts` = AirVPN forwarded port; `systemd.services.{qbittorrent,sabnzbd,slskd}.vpnConfinement` |

## 10. The `.mobileconfig` Generator — ✅ LOCKED design

1. Human generates a root CA **on the Mac** (`openssl` commands in README); key+cert stored in sops (`mobileca_*`). **Never** generate in a Nix build — `/nix/store` is world-readable. (I will not generate a root CA on my mac, mac's dead as of now, need to buy a new one, unsigned certs are also fine for now)
2. Systemd oneshot renders a static `.mobileconfig` (payloads: IMAP `mail.dnanu.de:993` SSL, SMTP `mail.dnanu.de:465` SSL, CalDAV + CardDAV → `cloud.nanulab.de/remote.php/dav`, embedded CA cert payload, **no passwords** — iOS prompts at install), signs it via `openssl smime -sign` with the CA, writes to `/var/lib/mobileprofile/`.
3. nginx serves it at `profile.nanulab.de` behind `auth_basic` (password in sops).
4. Flow: Tailscale on → open `profile.nanulab.de` → basic auth → download → Settings → install → enable trust for the CA → Mail/Calendar/Contacts work (while Tailscale is on). Service TLS is real Let's Encrypt — the CA exists only for the "Verified" badge.

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
**1% manual (~45 min):** approve Tailscale subnet route; create Nextcloud admin + link Mail app to local IMAP; Jellyfin/Navidrome/ABS/Kavita admin accounts + libraries; Prowlarr indexers; connect *arrs to qBittorrent/SABnzbd/slskd; Seerr↔Jellyfin; Vaultwarden admin; HA onboarding; Beszel agent key.

## 13. Verification Suite (run after install)

`zpool status` · `dig @10.0.0.2 mail.dnanu.de` (→10.0.0.2) · `dig mail.dnanu.de @1.1.1.1` (→home IP) · `swaks --to hey@dnanu.de --server <home-ip>` from outside · send via iOS → check Resend dashboard · `curl -I https://cloud.nanulab.de` over Tailscale · torrent IP-leak test in qBittorrent · `restic check` · lid-close test · `systemctl --failed` empty.

## 14. Update Policy

Quarterly: `nix flake update` → build → test → switch. Rollback via boot menu / `flake.lock` git history. No unattended upgrades.

## 15. Phase 2 Backlog (documented, NOT built)

Docmost (container, when packaged or accepted), Odoo (native), Kometa timer, Nextcloud Talk (needs TURN+ports), Nextcloud Office (Collabora), MeTube/Pinchflat, IPTV, Headscale (if Tailscale SaaS ever fails you), MTA-STS/TLS-RPT, multi-user mailboxes.

## 16. Key References

- SNM: https://nixos-mailserver.readthedocs.io/en/latest/ (options: `loginAccounts.<name>.{aliases,sieveScript}`, `enableSubmissionSsl`, relay workaround = GitLab issue #148)
- VPN-Confinement: https://github.com/Maroka-chan/VPN-Confinement · nixarr VPN docs: https://nixarr.com/wiki/vpn/ (AirVPN = static port forward, wg-quick)
- Resend SMTP: https://resend.com/docs/send-with-smtp (`smtp.resend.com:465`, user `resend`, pass = API key)
- Readarr retirement: https://github.com/readarr/readarr (mirror: rreading-glasses)
- disko: https://github.com/nix-community/disko · nixos-anywhere: https://github.com/nix-community/nixos-anywhere · sops-nix: https://github.com/Mic92/sops-nix
- Beszel/slskd/seerr modules: nixpkgs `services.beszel.{hub,agent}`, `services.slskd`, `services.seerr` (26.05)
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

Office stays, and it works **without containers**: nixpkgs has a native `services.collabora-online` module. Nextcloud's Office app points at the local coolwsd endpoint; nginx proxies it at `office.nanulab.de` (Tailscale-only). ⚠️ VERIFY module name in pinned channel. On the Dell's 6GB this will be the heaviest thing after Immich — accepted, it's a test box.

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
3. Networking: static IP, AdGuard, Tailscale, ddclient, cloudflared, nginx+ACME
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
