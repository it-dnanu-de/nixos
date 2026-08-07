# Cloud Services Implementation Plan — Nextcloud + Collabora + Immich + Vaultwarden

**Planner**: DeepSeek V4 Pro (medium tier)
**Date**: 2026-08-07
**Task source**: `inputs/Cloud-Services-for-PlannerMed.md`
**Build step**: 5 (OpenCode.md §12 frozen build order)
**Target**: Dell Latitude E5520 (6GB RAM, i5-2520M) — RAM is the binding constraint

---

## 1. Verified Options — all checked against pinned nixos-26.05

All module files confirmed to exist in the pinned channel:

| Service | Module path | Key options verified | Status |
|---------|------------|---------------------|--------|
| Nextcloud | `nixos/modules/services/web-apps/nextcloud.nix` | `services.nextcloud.enable`, `hostName`, `maxUploadSize`, `database.createLocally`, `config.dbtype`, `config.adminpassFile`, `configureRedis`, `extraApps`, `poolSettings`, `https`, `package` | ✅ verified |
| Collabora | `nixos/modules/services/web-apps/collabora-online.nix` | `services.collabora-online.enable`, `port` (default 9980), `settings`, `aliasGroups` | ✅ verified |
| Immich | `nixos/modules/services/web-apps/immich.nix` | `services.immich.enable`, `mediaLocation`, `machine-learning.enable`, `database.enable`, `database.createDB`, `redis.enable`, `host`, `port` (default 2283) | ✅ verified |
| Vaultwarden | `nixos/modules/services/security/vaultwarden/default.nix` | `services.vaultwarden.enable`, `dbBackend` (default `"sqlite"`), `config` (env vars like `SIGNUPS_ALLOWED`, `ROCKET_ADDRESS`, `ROCKET_PORT`), `environmentFile`, `configureNginx` | ✅ verified |
| PostgreSQL backup | `nixos/modules/services/backup/postgresql-backup.nix` | `services.postgresqlBackup.enable`, `databases`, `location`, `backupAll` | ✅ verified |

### Option details (exact names for use in Nix)

**Nextcloud**:
- `services.nextcloud.enable = true`
- `services.nextcloud.hostName = "cloud.nanulab.de"`
- `services.nextcloud.https = true` — required: sets link generation + HSTS headers
- `services.nextcloud.maxUploadSize = "16G"` — also sets PHP `upload_max_filesize`, `post_max_size`, `memory_limit`, and nginx `client_max_body_size`
- `services.nextcloud.package = pkgs.nextcloud33` — default for `stateVersion = "26.05"` (verified at line 1244-1245 of nextcloud.nix; explicit for clarity)
- `services.nextcloud.config.dbtype = "pgsql"`
- `services.nextcloud.database.createLocally = true` — auto-creates `nextcloud` DB + user via `ensureDatabases`/`ensureUsers`
- `services.nextcloud.config.adminpassFile` = path to sops secret file
- `services.nextcloud.configureRedis = true` (default) — auto-configures redis server `nextcloud`
- `services.nextcloud.extraApps` — `inherit (pkgs.nextcloud33Packages.apps) mail calendar contacts;` (all three confirmed present in `33.json`)
- `services.nextcloud.poolSettings` — defaults are `pm=dynamic`, `max_children=120` (meant for 4GB servers). **Must lower for 6GB Dell** — see §5 RAM budget.

**Collabora Online**:
- `services.collabora-online.enable = true`
- `services.collabora-online.port = 9980` (default, explicit for clarity)
- `services.collabora-online.settings` — needed for Nextcloud WOPI allowlist (see §3 nginx)
- `services.collabora-online.aliasGroups` — to allow Nextcloud domain as WOPI host

**Immich**:
- `services.immich.enable = true`
- `services.immich.mediaLocation = "/fast/immich"`
- `services.immich.machine-learning.enable = false` — **Dell CPU too weak**
- `services.immich.host = "127.0.0.1"` — bind loopback only (nginx proxies)
- `services.immich.port = 2283` (default)
- `services.immich.database.enable = true` (default) — auto-enables postgres, adds pgvector+vchord extensions
- `services.immich.database.createDB = true` (default) — auto-creates `immich` DB + user
- `services.immich.redis.enable = true` (default) — creates `immich` redis server

**Vaultwarden**:
- `services.vaultwarden.enable = true`
- `services.vaultwarden.dbBackend = "sqlite"` (default) — no postgres needed; nightly state-directory backup covers it
- `services.vaultwarden.config` = `{ ROCKET_ADDRESS = "127.0.0.1"; ROCKET_PORT = 8222; SIGNUPS_ALLOWED = false; ENABLE_WEBSOCKET = true; DOMAIN = "https://vault.nanulab.de"; }`
- `services.vaultwarden.environmentFile` = path to sops-generated env file containing `ADMIN_TOKEN=...`
- `services.vaultwarden.configureNginx = false` — we provide our own nginx vhost with ACL (see §3)

---

## 2. Database Layout — one shared PostgreSQL instance + one per-service Redis

### PostgreSQL
A single `services.postgresql` instance is enabled by multiple modules. NixOS merges these declarations:

| Declaring module | `ensureDatabases` | `ensureUsers` | Extensions added |
|---|---|---|---|
| Nextcloud (`database.createLocally = true`) | `nextcloud` | `nextcloud` (owns DB) | — |
| Immich (`database.enable = true` + `createDB = true`) | `immich` | `immich` (owns DB) | pgvector, vchord (+ postgresql-setup ExecStartPost for unaccent, uuid-ossp, etc.) |
| Vaultwarden | — (uses SQLite) | — | — |

**No conflict**: each module contributes separate `ensureDatabases`/`ensureUsers` entries; NixOS postgres module merges them all. Immich's extra extensions don't conflict with Nextcloud's clean default setup.

**PostgreSQL backup** — add to `configuration.nix`:
```nix
services.postgresqlBackup = {
  enable = true;
  location = "/fast/backups/postgres";
  databases = [ "nextcloud" "immich" ];
};
```
(No `booklore` yet — that's Phase 2 §15.)

### Redis
- Nextcloud: `services.redis.servers.nextcloud` (auto-created; `user = "nextcloud"`, unix socket)
- Immich: `services.redis.servers.immich` (auto-created; unix socket)

Separate redis instances, separate sockets — no conflict.

### Vaultwarden
Stays on SQLite (`dbBackend = "sqlite"`). Backup: its state directory `/var/lib/vaultwarden/` is covered by the global restic backup (Phase 2 step 8). No separate DB dump needed.

---

## 3. Nginx Vhosts — reuse `mkUserVhost` where possible; Nextcloud needs special handling

### Background: how `mkUserVhost` works
From `modules/networking/nginx.nix`:
```nix
mkUserVhost = fqdn: backend: {
  forceSSL = true;
  useACMEHost = settings.domains.internal;
  locations."/" = {
    proxyPass = backend;
    proxyWebsockets = true;
    extraConfig = userAllowlist;  # LAN .1-.99 + VPN 10.0.10.3-99
  };
};
```
It creates a `proxy_pass`-based vhost. Works for services that expose an HTTP backend on localhost.

### 3.1 Nextcloud — `cloud.nanulab.de`

**Cannot use `mkUserVhost`** — Nextcloud needs its own nginx locations (well-known rewrites, PHP fastcgi, static asset caching, `.htaccess`-equivalent blocks). The Nextcloud module auto-creates this vhost at `services.nginx.virtualHosts."cloud.nanulab.de"`.

**Plan**: Let the Nextcloud module create the vhost, then **merge** our settings on top:
```nix
services.nginx.virtualHosts."cloud.${settings.domains.internal}" = lib.mkMerge [
  # Nextcloud module creates: root, locations (well-known, php, static, etc.)
  # We add: forceSSL, useACMEHost, ACL
  {
    forceSSL = true;
    useACMEHost = settings.domains.internal;
    extraConfig = userAllowlist;  # concatenates with Nextcloud's extraConfig
  }
];
```

The `extraConfig` from both sources concatenates (Nix `types.lines` merge). Nextcloud already sets `client_max_body_size` from `maxUploadSize` at its vhost level — we don't duplicate that.

`services.nextcloud.https = true` must also be set (this is a separate Nextcloud option for internal link generation + HSTS).

### 3.2 Collabora Online — `office.nanulab.de`

Uses `mkUserVhost` (proxy-pass to coolwsd on localhost):

```nix
virtualHosts."office.${settings.domains.internal}" =
  mkUserVhost "office.${settings.domains.internal}" "http://127.0.0.1:9980";
```

Collabora needs WebSocket support — `proxyWebsockets = true` is already in `mkUserVhost`.

**WOPI allowlist**: Collabora must be told which Nextcloud host is allowed to connect:
```nix
services.collabora-online.settings = {
  storage.wopi."@allow" = true;
  storage.wopi.host = [ "cloud\\.${settings.domains.internal}" ];
};
services.collabora-online.aliasGroups = [{
  host = "https://cloud.${settings.domains.internal}";
  aliases = [];
}];
```

### 3.3 Immich — `photos.nanulab.de`

Uses `mkUserVhost`:

```nix
virtualHosts."photos.${settings.domains.internal}" =
  mkUserVhost "photos.${settings.domains.internal}" "http://127.0.0.1:2283";
```

**Immich proxy requirements**: Immich docs recommend `client_max_body_size` for uploads. The default nginx `client_max_body_size` is 1m, which is too small for photo uploads. We need to override just the body size for this vhost:

```nix
virtualHosts."photos.${settings.domains.internal}" = lib.recursiveUpdate
  (mkUserVhost "photos.${settings.domains.internal}" "http://127.0.0.1:2283")
  {
    extraConfig = ''
      client_max_body_size 500M;
    '';
  };
```

(Note: `lib.recursiveUpdate` ensures both `extraConfig` values survive — the `mkUserVhost` ACL goes into `locations."/".extraConfig`, while `client_max_body_size` goes into the vhost-level `extraConfig`. If this merge proves tricky, use `lib.mkMerge` or split into two separate vhost declarations — NixOS merges them.)

### 3.4 Vaultwarden — `vault.nanulab.de`

Uses `mkUserVhost` + WebSocket endpoint for live sync:

```nix
virtualHosts."vault.${settings.domains.internal}" = lib.recursiveUpdate
  (mkUserVhost "vault.${settings.domains.internal}" "http://127.0.0.1:8222")
  {
    locations = {
      "/notifications/hub" = {
        proxyPass = "http://127.0.0.1:8222";
        proxyWebsockets = true;
        extraConfig = userAllowlist;
      };
      "/notifications/anonymous-hub" = {
        proxyPass = "http://127.0.0.1:8222";
        proxyWebsockets = true;
        extraConfig = userAllowlist;
      };
    };
  };
```

Vaultwarden's built-in `configureNginx = true` is NOT used — we supply our own vhost with ACLs.

---

## 4. sops Secrets — what to add/update

### Already in `secrets/secrets.yaml` + `sops.nix`:
- `nextcloud_admin_pass` — exists (line 10 of secrets.yaml), registered in sops.nix (line 22)
- `vaultwarden_admin_token` — exists (line 11 of secrets.yaml), registered in sops.nix (line 23)

### What needs changing:

**A. `nextcloud_admin_pass`** — currently a placeholder value. Human must provide the real plaintext password. In the plan, flag this as:
> ⚠️ **Human step**: Edit `secrets/secrets.yaml` — replace the `nextcloud_admin_pass` value with a strong password (the one you'll use to log into Nextcloud as `root` after install). Re-encrypt with `sops updatekeys secrets/secrets.yaml`.

**B. `vaultwarden_admin_token`** — currently a placeholder value. Human must generate a token:
> ⚠️ **Human step**: Generate a token (`openssl rand -base64 48`), edit `secrets/secrets.yaml`, replace `vaultwarden_admin_token` with the token. Re-encrypt. This token lets you access the Vaultwarden `/admin` page.

**C. Vaultwarden needs `ADMIN_TOKEN` as an environment variable**, not just in config. The module reads it from `environmentFile`. Plan:
```nix
# In the vaultwarden module:
sops.templates."vaultwarden-env" = {
  content = "ADMIN_TOKEN=${config.sops.placeholder.vaultwarden_admin_token}";
  mode = "0400";
  owner = "vaultwarden";
};
services.vaultwarden.environmentFile = [ config.sops.templates."vaultwarden-env".path ];
```

**D. `sops.nix` registrations** — already correct (no owner/group needed for `nextcloud_admin_pass` — root:root 0400 default works; it's read by `nextcloud-setup.service` which runs as root). Need to keep both entries as-is.

**E. No new sops secrets needed** beyond what's already registered.

### Summary of sops changes (for nixos-builder):
1. Create sops template `vaultwarden-env` → maps `vaultwarden_admin_token` → `ADMIN_TOKEN=...`
2. Wire `services.vaultwarden.environmentFile` to the template path
3. Nothing else to add — both secrets already registered

---

## 5. Module Structure

### Decision: separate file per service

Four new files:
- `modules/services/nextcloud.nix`
- `modules/services/collabora.nix`
- `modules/services/immich.nix`
- `modules/services/vaultwarden.nix`

**Rationale**: Each ~50-100 lines, self-contained, easy to audit/revert individually. Matches existing pattern (`mail.nix`, `authelia.nix`, `ios-profile.nix`).

### Module signatures

Each follows the mail.nix pattern:
```nix
# modules/services/nextcloud.nix
{ config, lib, pkgs, settings, ... }:
let
  # Import helpers from nginx.nix's pattern (userAllowlist)
  # Either re-derive or pass as module arg
in
{
  # Service config + nginx vhost + secrets wiring
}
```

### How to wire ACLs into service modules

The `userAllowlist` and `mkUserVhost` are currently defined in `modules/networking/nginx.nix` as local `let` bindings — not exported. Two options:

**Option A (recommended)**: Move the ACL derivation logic to a small helper file `modules/networking/nginx-acl.nix` that both `nginx.nix` and the service modules can import. The service modules then import this shared helper.

**Option B**: Derive the ACLs independently in each service module using the same formulas from nginx.nix. More duplication but simpler.

**Recommendation: Option A** — create `modules/networking/nginx-helpers.nix`:

```nix
# modules/networking/nginx-helpers.nix
{ lib, settings, users }:
let
  adminUsers = lib.filterAttrs (n: u: u.tier == "admin") users.users;
  regularUsers = lib.filterAttrs (n: u: u.tier == "user") users.users;

  adminPeerIps = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.flatten (lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1);
      in if users.isPeer dev then [ ips.lan ips.vpn ] else [ ]
    ) userData.devices)
  ) adminUsers);

  userPeerIps = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.flatten (lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1);
      in if users.isPeer dev then [ ips.lan ips.vpn ] else [ ]
    ) userData.devices)
  ) regularUsers);

  adminAllowlist = ''...'';  # same as nginx.nix
  userAllowlist = ''...'';   # same as nginx.nix

  mkUserVhost = fqdn: backend: { ... };  # same as nginx.nix
in {
  inherit adminAllowlist userAllowlist mkUserVhost;
}
```

Then `nginx.nix` imports it:
```nix
{ pkgs, settings, lib, users, ... }:
let
  helpers = import ./nginx-helpers.nix { inherit lib settings users; };
in {
  # use helpers.mkUserVhost, helpers.userAllowlist, etc.
}
```

And service modules import it:
```nix
{ config, lib, pkgs, settings, users, ... }:
let
  helpers = import ../networking/nginx-helpers.nix { inherit lib settings users; };
in { ... }
```

### `configuration.nix` — add imports

Add after line 27 (`../../modules/services/authelia.nix`):
```nix
../../modules/services/nextcloud.nix
../../modules/services/collabora.nix
../../modules/services/immich.nix
../../modules/services/vaultwarden.nix
```

### Also add PostgreSQL backup

In `configuration.nix` or a small `modules/services/postgres-backup.nix`:
```nix
# In configuration.nix directly, or as a tiny module:
services.postgresqlBackup = {
  enable = true;
  location = "/fast/backups/postgres";
  databases = [ "nextcloud" "immich" ];
};
```

---

## 6. RAM Budget — the Dell has 6GB total, ZFS ARC capped at 1GB

### RAM consumers to watch (estimated):

| Component | Estimated RAM | Notes |
|---|---|---|
| ZFS ARC | 1 GB | Capped via `zfsArcMax` |
| Base system (systemd, nginx, postfix, etc.) | ~500 MB | Already running on gen 72 |
| PostgreSQL | ~200 MB | Shared buffers default small |
| Nextcloud (PHP-FPM) | **Heavy** — defaults `max_children=120` × ~70MB each → ~8.4GB theoretical max | **Must reduce** |
| Redis ×2 (nextcloud + immich) | ~100 MB combined | |
| Immich server | ~500 MB | node.js + transcoding (no ML) |
| Collabora Online | ~500 MB | LibreOffice in memory |
| Vaultwarden | ~100 MB | Rust binary, tiny |

### Tuning required before deploy:

**PHP-FPM pool settings for Nextcloud** — the default `pm.max_children = 120` is for 4GB+ servers. For the 6GB Dell with everything else running:

```nix
services.nextcloud.poolSettings = {
  "pm" = "ondemand";
  "pm.max_children" = "8";
  "pm.start_servers" = "2";
  "pm.min_spare_servers" = "1";
  "pm.max_spare_servers" = "3";
  "pm.max_requests" = "500";
};
```

This caps PHP-FPM at ~560 MB total for Nextcloud workers. `ondemand` mode spins down idle workers.

### Deploy strategy — service-by-service, verify RAM after each:

1. Deploy **Nextcloud** first (heaviest) → `free -h`, check for OOM
2. Deploy **Vaultwarden** (lightweight) → verify
3. Deploy **Immich** (medium) → `free -h`
4. Deploy **Collabora** last (heaviest after Nextcloud) → `free -h`

If RAM dips below 500 MB free at any point, lower `pm.max_children` further or accept that Immich transcoding + Collabora may not run simultaneously on the Dell (prod hardware solves this).

---

## 7. Deployment Order & Verification

### Pre-flight (human):
- ⚠️ Update `nextcloud_admin_pass` in sops with real password
- ⚠️ Update `vaultwarden_admin_token` in sops with real token (`openssl rand -base64 48`)

### Deploy order (nixos-builder, one at a time):

**Step 5a — Nextcloud**
```bash
nixos-rebuild build --flake .#homelab  # dry-run on builder machine
# If build succeeds:
nixos-rebuild switch --flake .#homelab --target-host nixos@10.0.0.2
```
Verify:
- `systemctl status postgresql` → active
- `systemctl status phpfpm-nextcloud` → active
- `systemctl status redis-nextcloud` → active
- `curl -kI https://cloud.nanulab.de` from VPN → 200 (or 302/503 during setup)
- `systemctl status nextcloud-setup` → completed (exit 0). Check logs if not.
- `free -h` → >500 MB free

**Step 5b — Vaultwarden**
```bash
nixos-rebuild switch --flake .#homelab --target-host nixos@10.0.0.2
```
Verify:
- `systemctl status vaultwarden` → active
- `curl -kI https://vault.nanulab.de` → 200 (or redirect to /login)
- `journalctl -u vaultwarden` → no errors, `ADMIN_TOKEN` loaded

**Step 5c — Immich**
```bash
nixos-rebuild switch --flake .#homelab --target-host nixos@10.0.0.2
```
Verify:
- `systemctl status immich-server` → active
- `systemctl status immich-machine-learning` → **inactive** (disabled)
- `systemctl status redis-immich` → active
- `curl -kI https://photos.nanulab.de` → 200
- `free -h` → >400 MB free

**Step 5d — Collabora Online**
```bash
nixos-rebuild switch --flake .#homelab --target-host nixos@10.0.0.2
```
Verify:
- `systemctl status coolwsd` → active
- `systemctl status coolwsd-systemplate-setup` → exited (oneshot, success)
- `curl -kI https://office.nanulab.de` → 200
- `free -h` → >300 MB free

### Post-deploy verification (full suite after all four up):

```bash
# 1. All service units alive
systemctl status nextcloud-setup phpfpm-nextcloud redis-nextcloud \
  vaultwarden immich-server redis-immich coolwsd coolwsd-systemplate-setup

# 2. PostgreSQL databases exist
sudo -u postgres psql -l | grep -E "nextcloud|immich"

# 3. nginx vhosts respond (from VPN/LAN)
curl -kI https://cloud.nanulab.de    # Nextcloud
curl -kI https://office.nanulab.de   # Collabora
curl -kI https://photos.nanulab.de   # Immich
curl -kI https://vault.nanulab.de    # Vaultwarden

# 4. ACL enforcement: guest IP → 403 on all four
# (from 10.0.0.150 or similar)

# 5. Collabora discovery endpoint
curl -k https://office.nanulab.de/hosting/discovery | head

# 6. Memory check
free -h

# 7. No failed units
systemctl --failed
```

### Human post-deploy (1% manual, OpenCode.md §12):
- Log into `https://cloud.nanulab.de` as root with the password from sops
- Enable mail/calendar/contacts apps if not auto-enabled
- Link Mail app to local IMAP (`mail.dnanu.de:993`, username `hey@dnanu.de`)
- Connect Nextcloud Office to `https://office.nanulab.de` in admin settings
- Visit `https://vault.nanulab.de/admin` with the admin token to configure Vaultwarden
- Create the initial Immich admin account via the web UI

---

## 8. Implementation Notes for nixos-builder

### 8.1 `nginx-helpers.nix` — create first

This is a prerequisite module. Extract from `modules/networking/nginx.nix` lines 14-76 (let bindings for adminUsers, adminPeerIps, userPeerIps, adminAllowlist, userAllowlist, mkAdminVhost, mkUserVhost). Export them as an attrset.

Then refactor `nginx.nix` to import from this helper (no behavior change — verify by checking generated nginx.conf has same ACLs).

### 8.2 Nextcloud module — key details

The Nextcloud module auto-creates its nginx vhost at `services.nginx.virtualHosts."cloud.nanulab.de"`. We need to **merge** our settings on top:
- `forceSSL = true` + `useACMEHost = settings.domains.internal` — these are not set by Nextcloud module
- `extraConfig = userAllowlist` — concatenates with Nextcloud's extraConfig (which sets `client_max_body_size` + security headers)

**Important**: The `services.nextcloud.hostName` must be `"cloud.nanulab.de"` (matches the vhost key). The `https` option must be `true`.

The `database.createLocally = true` + `config.dbtype = "pgsql"` combo triggers the module to auto-declare `services.postgresql.enable = true` + `ensureDatabases`/`ensureUsers`. No manual postgres config needed.

### 8.3 Immich — `/fast/immich` directory

The `mediaLocation = "/fast/immich"` directory must exist. The immich module does NOT auto-create it. Add:
```nix
systemd.tmpfiles.rules = [
  "d /fast/immich 0700 immich immich -"
];
```
(This may already be handled by the immich module's `systemd.tmpfiles.settings` — verify. At line 441-453 of immich.nix, the module sets tmpfiles for the mediaLocation with `user=immich, group=immich, mode=0700` — so it IS auto-created. No extra tmpfiles needed.)

### 8.4 Collabora — font/systemplate setup

The module auto-runs `coolwsd-systemplate-setup` (oneshot) which copies LibreOffice fonts/templates. This takes ~30 seconds on first boot and uses ~200MB of disk under `/var/lib/cool/`.

### 8.5 Vaultwarden — environment file

The `ADMIN_TOKEN` must be passed via `environmentFile` (not `config`). The sops template approach (§4C) creates a mode-0400 file with `ADMIN_TOKEN=...` and wires it to `environmentFile`. The `config.SIGNUPS_ALLOWED` goes in `services.vaultwarden.config` (not environmentFile).

### 8.6 Merge vs mkOrder

When merging vhost declarations, the order of `extraConfig` concatenation is determined by the module system merge. For safety, use `lib.mkOrder` or `lib.mkBefore`/`lib.mkAfter` if ACL denies must come after all other directives. In practice, nginx processes `allow`/`deny` in order regardless of surrounding directives, so plain concatenation is fine.

---

## 9. Summary of Files Touched

| File | Action |
|---|---|
| `modules/networking/nginx-helpers.nix` | **NEW** — extract ACL+mkVhost helpers |
| `modules/networking/nginx.nix` | **EDIT** — import from helpers instead of inline |
| `modules/services/nextcloud.nix` | **NEW** — service + merged nginx vhost + secrets wiring |
| `modules/services/collabora.nix` | **NEW** — service + nginx vhost |
| `modules/services/immich.nix` | **NEW** — service + nginx vhost |
| `modules/services/vaultwarden.nix` | **NEW** — service + nginx vhost + sops template for ADMIN_TOKEN |
| `hosts/homelab/configuration.nix` | **EDIT** — add 4 imports + postgresqlBackup |
| `secrets/secrets.yaml` | **EDIT** — human: update `nextcloud_admin_pass` + `vaultwarden_admin_token` |
| `modules/system/sops.nix` | **NO CHANGE** — already registers both secrets |
