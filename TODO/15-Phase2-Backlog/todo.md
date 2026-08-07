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

## Dependencies / watch
- Readarr archived upstream — monitor; migration path to rreading-glasses mirror documented
- Booklore container pinned tag — bump deliberately, never `:latest`
