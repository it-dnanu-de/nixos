# TODO — 08 Arr Stack

**Status:** ⬜ not started (build step 6) · **Owner:** nixos-builder · **Modules:** `modules/services/arr-stack.nix`

> Media automation: request → download → organize → metadata → play (R1 "feels like Netflix"). All native `services.<name>` modules in pinned 26.05.

## Core *arrs
- [ ] **Sonarr** — TV: NFO + poster → Jellyfin
- [ ] **Radarr** — Movies: NFO + poster → Jellyfin
- [ ] **Lidarr** — Music: organizes → beets perfects → Navidrome
- [ ] **Prowlarr** — indexers, shared across *arrs
- [ ] **Bazarr** — subtitles
- [ ] **Readarr** ⚠️ archived upstream — pin package, metadata API → `rreading-glasses` mirror; migration note in README
- [ ] Connect all *arrs to qBittorrent/SABnzbd (1% manual)
- [ ] Prowlarr indexers (1% manual)
- [ ] Hardlink completion into `/slow/shared-media`

## Seerr (`services.seerr`)
- [ ] `requests.nanulab.de` (VPN-only) — user-facing request portal
- [ ] Connect to Sonarr/Radarr + Jellyfin (1% manual)

## beets (`pkgs.beets`)
- [ ] systemd service + YAML config (fully declarative in Nix)
- [ ] Music tag post-processor (Lidarr organizes, beets perfects)
- [ ] `/slow/shared-media/audio/music` as library

## soularr (systemd timer, Python)
- [ ] Bridges Lidarr ↔ slskd for missing album searches
- [ ] Timer + service units

## Shared
- [ ] nginx vhosts: `*.nanulab.de` per service (user-tier ACL)
- [ ] Restic include of app state
- [ ] Kometa **dropped** (ruling R1 — no Plex; *arrs write NFO directly)
