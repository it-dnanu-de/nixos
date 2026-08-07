# TODO — 09 Media Players

**Status:** ⬜ not started (build step 6-7) · **Owner:** nixos-builder · **Modules:** `modules/services/media.nix` (+ booklore)

> Player tier of the pipeline. All VPN-only vhosts on `*.nanulab.de`.

## Jellyfin (`services.jellyfin`)
- [ ] `watch.nanulab.de`
- [ ] Libraries: `/slow/shared-media/video/{shows,movies}`
- [ ] GPU: SNB iGPU → `intel-vaapi-driver`; prod → `intel-media-driver`
- [ ] Admin account (1% manual)
- [ ] Reads *arr NFO/poster files natively

## Navidrome (`services.navidrome`)
- [ ] `music.nanulab.de`
- [ ] `settings.MusicFolder = /slow/shared-media/audio/music`
- [ ] Admin account (1% manual)

## Audiobookshelf (`services.audiobookshelf`)
- [ ] `listen.nanulab.de` — podcasts + audiobooks (manager AND player)
- [ ] Library root `/slow/shared-media/audio/{audiobooks,podcasts}`
- [ ] ABS built-in metadata

## Booklore — **the single sanctioned container** (ruling R2)
- [ ] OCI container `ghcr.io/booklore-app/booklore:<pinned-tag>` (never :latest)
- [ ] `services.mysql.package = pkgs.mariadb` (native MariaDB, container connects to host)
- [ ] `booklore_db_password` from sops
- [ ] `books.nanulab.de`
- [ ] Library root `/slow/shared-media/literature/{books,comics,manga}`
- [ ] MariaDB nightly dump → B2 (add to §11 list)
- [ ] Kavita **deleted** (replaced by Booklore)

## Shared
- [ ] nginx user-tier vhosts
- [ ] `media` group
- [ ] Restic include state
