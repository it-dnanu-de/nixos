# TODO — 15 Phase 2 Backlog

**Status:** ⬜ documented, NOT built · **Owner:** deferred · Source: OpenCode.md §15

> These are explicitly NOT in v1. Do not build unless human promotes one.

## Documented backlog
- [ ] Nextcloud Talk (needs TURN + open ports → violates zero-port rule; **Phase 2 forever**)
- [ ] MeTube / Pinchflat (YouTube downloader)
- [ ] IPTV
- [ ] Headscale + headplane UI (both native, verified 26.05) — IF declarative WG peer mgmt ever becomes a burden; needs TCP 8443 forward, preauth keys or OIDC IdP, iOS via Tailscale app alternate-server
- [ ] Multi-user mailboxes
- [ ] DANE TLSA active once DS published at DENIC (cross-note to §3.7/04-Mail)
- [ ] Nextcloud Office powered by **Euro-Office** — different backend from Collabora (June 2026, ONLYOFFICE-based). Not in nixpkgs yet. Keep Collabora until Euro-Office DocumentServer lands in a pinned channel; revisit then. (Decision 2026-08-08: keep Collabora.)

## Installer project (human idea, 2026-08-08) — build AFTER v1 done
- [ ] `install.sh` run on the NixOS live ISO that:
  - [ ] forks/clones the repo and creates a GitHub repo on the user's account (IaC bootstrap)
  - [ ] interactively asks: # users, accounts, emails, aliases, which apps, media-server disk layout, Resend/Cloudflare/INWX API tokens, etc.
  - [ ] generates the config + writes secrets to sops
  - [ ] prints the manual steps the user must still do (DNSSEC/DS records at INWX, Speedport DHCP+port forwards, MACs, QR re-scan)
  - [ ] assumes the same service stack as this repo (Resend, Cloudflare, INWX, WireGuard, SNM, …)
- [ ] NOTE: Nextcloud/Vaultwarden accounts persist in their DBs across reboot AND rebuild (verified 2026-08-08) — installer only needs to CREATE accounts on first install, not maintain them

## Dependencies / watch
- Readarr archived upstream — monitor; migration path to rreading-glasses mirror documented
- Booklore container pinned tag — bump deliberately, never `:latest`
- Euro-Office DocumentServer packaging status in nixpkgs — watch for upstream addition
