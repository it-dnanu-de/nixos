# TODO — 12 Websites

**Status:** ⬜ not started (build step 7) · **Owner:** Hugo · **File refs:** `websites/dnanu.de/`, `modules/networking/nginx.nix` (dnanu.de vhost)

> Ruling R4: **Hugo**, content inside this git repo, built at `nixos-rebuild` time → static files nginx serves on 127.0.0.1:8080 behind the cloudflared tunnel.

## Hugo site
- [ ] `hugo.toml`
- [ ] `content/_index.md` (portfolio landing)
- [ ] 5 sections mapping to email aliases: `wealth/`, `health/`, `it/`, `creative/`, `academic/` (each `_index.md` + `blog/*.md`)
- [ ] `layouts/` custom theme (desktop + mobile responsive)
- [ ] `static/` assets
- [ ] Activation script: `hugo build` → `/var/www/dnanu.de`
- [ ] Workflow: `hugo new it/blog/x.md` → write → git push → rebuild → live (no CI)

## Serving
- [x] nginx dnanu.de vhost placeholder exists (127.0.0.1:8080)
- [ ] Point it at Hugo output once built
- [ ] Tunnel ingress already routes dnanu.de/www/autoconfig/mta-sts → 8080 ✅

## autoconfig
- [ ] `autoconfig.dnanu.de/mail/config-v1.1.xml` static XML (Thunderbird auto-setup) served by this vhost — in the build plan; verify it exists in nginx.nix during step 4 wiring
