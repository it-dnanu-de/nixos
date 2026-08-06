# Mail Security Audit — Kimi K3 (security-reviewer)

**Date:** 2026-08-07 · **Scope:** post-hardening mail stack (commits `2a3b978`…`4b69638`, docs `e2d1bc3`)
**Method:** full file reads + pinned-channel source review (SNM, nixpkgs postfix/sops-nix) + **live runtime verification on 10.0.0.2** (listeners, nftables, journal forensics, TLS handshakes, permission probes).

---

## Executive summary

The hardening execution is fundamentally sound. **No critical vulnerabilities found.** Secrets hygiene is clean (sops-only, no store/log leaks), there is **no open relay** (live-confirmed `mynetworks_style = host`), postfix restrictions are correctly ordered, rspamd was strengthened not weakened, and the DKIM/TLSA shell scripts are idempotent and injection-safe. Live forensics prove the full mail path works: inbound LMTP delivery ✓, outbound Resend relay `status=sent` with **Trusted (verified) TLS** ✓, submission auth from LAN clients ✓, TLSv1.3 on 25/465/587/993 ✓.

The one real exposure gap is the **host firewall**: ports 465/587/993/53/80/443 are open on *all* interfaces including the public IPv6 GUA — only the router (v4 NAT + Speedport v6 firewall) keeps them off the internet. That contradicts the locked §3.2 posture ("host declares zero open ports except 25 + 51820") and leaves **AdGuard one router-misconfiguration away from being a public open resolver**.

Two initial suspicions were investigated and **cleared by live evidence** (documented in §C so nobody re-chases them).

---

## A. Findings

### 1. MEDIUM — Submission/IMAP/DNS/HTTP(S) bound and firewalled on all interfaces, incl. public IPv6 GUA
**Files:** `modules/networking/base.nix:44-46`, live `ss` output.
`allowedTCPPorts = [ 25 53 80 443 465 587 993 ]` applies to every interface, v4 **and** v6. Live: all of 25/80/443/465/587/993 listen on `0.0.0.0` **and** `[::]`; `:53` on `*`.
- **v4:** safe in practice — the router forwards only 25/tcp + 51820/udp, NAT hides the rest.
- **v6:** the server holds a public GUA (`2003:c8:…`). There is no NAT in v6 — the *only* barrier is the Speedport's v6 firewall, where §3.5 documents a **manual** :25 pass-through. If that UI is ever broadened (or a future router defaults to permissive), 465/587/993 become internet-reachable — and **:53 becomes a public open recursive resolver** (amplification DDoS vector, the classic homelab-own-goal). The locked §3.2 posture says IMAP/submission are VPN-only; the host should enforce that itself, not rely on the router.
**Fix:** keep 25 global; scope the rest by source. Either `networking.firewall.extraInputRules` (nftables), e.g. accept tcp 465/587/993/53/80/443 only from `10.0.0.0/24`, `fd10::/64`, `fe80::/64` (+ udp 53/67/547 likewise), or per-interface rules (`wg0` is already `trustedInterfaces`). Verify afterwards from the WG and from a guest lease.

### 2. MEDIUM — `cloudflare-dns-sync` upsert clobbers multi-record names
**File:** `modules/services/cloudflare-dns.nix:18-35` (the `while read id; PATCH …` loop).
When ≥2 records match `type+name`, **every** match is PATCHed to identical content. Scenario: apex `dnanu.de` TXT currently = SPF; the day any second apex TXT exists (Resend/Google/`cf-verification` token, anything), the next run rewrites **both** to `v=spf1 -all`, silently destroying the other record. Same hazard for any future multi-value name.
**Fix:** singleton semantics — PATCH the first matching ID, `DELETE` the remainder (the `deleteRecord` helper already exists); or match by content before touching anything.

### 3. LOW-MEDIUM — DNS sync failures are silent; no periodic convergence
**File:** `modules/services/cloudflare-dns.nix:9-13, 23-34, 125-138`.
`CURL()` has no `--fail`, so HTTP 4xx/5xx exit 0 and `set -euo pipefail` never trips; PATCH/POST output is discarded (`> /dev/null 2>&1`). The unit has no `Restart=on-failure` (unlike its DKIM/TLSA siblings) and runs only at boot/activation — a bad token, API outage, or manual dashboard edit leaves zone drift invisible indefinitely. The `upsert`s at lines 58-71 (MX/SPF/DMARC/MTA-STS/TLS-RPT/CNAME) also run even when the v4 lookup failed (`PUBLIC_IP4=0.0.0.0`), which is fine, but compounds the "did it actually work?" opacity.
**Fix:** add `--fail` to `CURL()` (then `set -e` works as intended), stop discarding stderr, add `Restart=on-failure` + a daily timer like `cloudflare-tlsa-sync` has.

### 4. LOW — Resend API key exposed in `curl` argv (watchdog)
**File:** `modules/services/mail.nix:156-159`.
`-H "Authorization: Bearer $(cat "$CREDENTIALS_DIRECTORY/resend_api_key")"` puts the key in the curl process's command line — readable via `/proc/<pid>/cmdline` to any local user for the ~1 s the request runs. Not in the URL, not via `-u`, not in logs (verified: script echoes only statuses, no `set -x`) — so on this single-user box the practical risk is minimal, but argv is the one channel that *is* world-readable while the process lives.
**Fix:** render a header file via a second sops template (`content = "Authorization: Bearer ${config.sops.placeholder.resend_api_key}"`, `mode = "0400"`) loaded alongside via `LoadCredential`, then `curl -H @"$CREDENTIALS_DIRECTORY/resend_header"`. Same pattern applies to finding 5.

### 5. LOW — Cloudflare token in `curl` argv (three sync scripts)
**Files:** `modules/services/cloudflare-dns.nix:13, 106, 168`.
Same transient-argv exposure as finding 4 (`-H "Authorization: Bearer $TOKEN"`). The token is otherwise handled correctly: `LoadCredential` from sops, never written to store/logs. Same fix as finding 4 (header-from-file), or accept-and-document given the single-user threat model.

### 6. LOW — `deleteRecord` misses wildcard AAAA for `*.nanulab.de`
**File:** `modules/services/cloudflare-dns.nix:76-78`.
Deletes wildcard **A**, apex A, apex AAAA — but not wildcard **AAAA**. Nothing creates one today, so this is latent: if a `*.nanulab.de` AAAA ever exists (manual experiment, legacy), the "no public records for internal names" rule (§3.4) is silently violated.
**Fix:** add `deleteRecord "$Z_NANULAB" AAAA "*.${settings.domains.internal}"`.

### 7. LOW — TLSA-sync failure has no alert path
**Files:** `modules/networking/acme.nix:26` (`|| true`), `modules/services/cloudflare-dns.nix:144-189`.
Today the zone is unsigned, so a stale TLSA is harmless (ignored). **After the DS records land at DENIC (§12), a failed TLSA sync following cert renewal = hard delivery failures from DANE-enforcing senders**, and nothing would tell you: `postRun` swallows errors, the timer's failures are journal-only, and `mail-queue-watch` doesn't check TLSA freshness.
**Fix:** `OnFailure=` on `cloudflare-tlsa-sync.service` triggering a Resend-API alert (reuse the watchdog's channel), or add a TLSA-vs-cert comparison to `mail-queue-watch`.

### 8. LOW — Sieve script hardcodes the domain
**File:** `modules/services/mail.nix:33-40`.
The eight `address :matches "to" "it*@dnanu.de"` lines use literal `dnanu.de` while everything around them interpolates `settings.domains.public`. Not a security issue — a domain-change drift trap.
**Fix:** interpolate `${settings.domains.public}` (mind sieve string quoting) or add a comment pinning the literal.

### 9. LOW — Cosmetic postfix warnings; debugging friction from root-only maps
**Files:** `modules/services/mail.nix:57-60`, live journal.
- Recurring `warning: database /etc/postfix/sasl_passwd.db is older than source file` (mtime race between sops re-render and `postmap`; content identical — harmless noise, but it trains you to ignore postfix warnings).
- `sasl_passwd.db` is `0600 root:root`. **Runtime-verified fine** (postfix daemons open maps/certs during root init, before privilege drop — proven by live `status=sent` relays, see §C). Only downside: unprivileged debugging (`sudo -u postfix postmap -q …`) fails with a scary-looking `Permission denied`.
**Fix (optional):** `sops.templates."postfix-sasl-passwd" = { group = "postfix"; mode = "0440"; … }` — postmap preserves group-read → `0640 root:postfix` .db, enabling postfix-user lookups and marginally better defense-in-depth documentation. Not required for correctness.

### 10. INFO — Documentation drift vs. code (no runtime impact)
- `OpenCode.md §7` lists `mail_hey_hash` / `mail_admin_hash`; code uses `mail_hey` / `mail_admin` (`modules/system/sops.nix:15-16`, consistent end-to-end).
- `OpenCode.md §8` claims the ACME cert is "group readable by nginx, dovecot2, postfix". Live: `acme` group contains **only nginx**; cert dir is `0750 acme:acme`. It works anyway (see §C.2) — but the doc overstates the mechanism.
**Fix:** amend the two doc lines at next OpenCode.md touch.

### 11. INFO — Historical Resend 535s on Aug 4 (resolved)
Live journal: initial deploy relay attempts failed `535 5.7.8 authentication failed` (bad/absent API key at first boot), retried, and since Aug 5 all relays are `status=sent … 250`. No action; recorded so the deferred/bounced counters in early logs aren't misread later. Notably: had the watchdog been deployed then, it would have paged about the queue — validating its design.

### 12. INFO — Hardening is not yet deployed; public DNS artifacts unverifiable pre-deploy
`mta-sts.dnanu.de` does not resolve publicly yet (CNAME upsert + tunnel ingress + vhost all land with the pending hardening deploy); TLSA/DKIM(new parser) records likewise. The `_mta-sts` TXT + `mode: enforce` policy going live **before** the policy URL serves would be the only ordering hazard — but both ship in the same deploy, and no sender can have a cached enforce policy yet, so mail flow is not at risk.
**Fix:** after the hardening deploy, run the §13 DNS checks: `TLSA _25._tcp.mail.dnanu.de`, `TXT mail._domainkey.dnanu.de`, `curl https://mta-sts.dnanu.de/.well-known/mta-sts.txt` (expect the STSv1 policy, HTTP 200), `TXT _mta-sts.dnanu.de`.

### 13. INFO — Guest DHCP pool can reach submission/IMAP (by current design, auth+TLS gated)
Live logs show successful `sasl_username=hey@dnanu.de` auths from `10.0.0.100` and `10.0.0.150` (Kea guest range). Ports 465/587/993 are open LAN-wide; credentials + mandatory TLS are the gate. §3.2 describes mail access "via WireGuard tunnel" — LAN reachability is de-facto intended (iOS on home WiFi without WG). If you later want LAN guests excluded, finding 1's source-scoping fix is the place (allow 10.0.0.0/24 minus .100-.200, or move guests to a VLAN). No change recommended now.

### 14. INFO — Placeholders present, none in the mail path
`settings.nix:62` `sshPubKey = "ssh-ed25519 AAAA… placeholder"`, `settings.nix:42` `vpn.forwardedPort = 0` (Phase 6). `REPLACE_ME` survives only in historical `outputs/*.md` plans. No placeholder secrets, no hardcoded credentials anywhere in scope.

---

## B. Audit questions — explicit answers

1. **Secrets hygiene:** Clean. `secrets.yaml` is fully sops-encrypted (spot-verified); repo grep finds no keys/tokens/`REPLACE_ME` in active code. All scripts read via `$CREDENTIALS_DIRECTORY`/`LoadCredential`; no `set -x`; journal outputs contain statuses only. Residual: argv exposure (findings 4-5, LOW).
2. **Firewall exposure:** 465/587/993 are **not** WAN-reachable today — v4 NAT forwards only 25+51820; v6 blocked only by the Speedport firewall (manual :25 pinhole per §3.5). They **are** open on every local interface including the public GUA — host-level enforcement gap = finding 1 (MEDIUM). Port 25 exposure is intended (MX) and live-verified answering.
3. **Postfix hardening:** No bypass. `smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination` (SNM) with `mynetworks_style=host` (live `postconf`) → **no open relay, including from LAN/guests**. Our `mkAfter` restrictions append after SNM's cheap map checks; relay authorization is decided in relay_restrictions which are untouched. Submission ports (465/587) override with `permit_sasl_authenticated,reject` — auth-only. Relayhost + SASL + wrappermode + static `verify` tls_policy are correct and live-verified (`Trusted TLS … status=sent`).
4. **rspamd:** Strengthened, not weakened (reject 15→12; greylist/add_header unchanged). Spamhaus-disable is correct — it returns BLOCKED via public resolvers (AGH→quad9) and would score *wrongly*, not just neutrally. Remaining stock RBLs (mailspike/dnswl/sem/blocklist.de/virusfree/SURBL/URIBL/DBL) are sane. Milter is wired inbound via SNM (`smtpd_milters = unix:/run/rspamd/rspamd-milter.sock`).
5. **DKIM/TLSA scripts:** Injection-safe — dynamic values go through `jq -nc --arg`; all other interpolations are trusted `settings.nix` literals. DKIM parser (`grep -o '"[^"]*"' | tr -d '"\n'`) is format-agnostic and idempotent (content-compare before PATCH, in-place PATCH, no delete gap). TLSA `3 1 1` SPKI-SHA256 computation is correct (verified against RFC 6698 construction). `Restart=on-failure` covers boot DNS races. Gaps: findings 2, 3, 6, 7.
6. **Authelia/nginx on mta-sts:** Clean — the vhost (`mail.nix:219-230`) has no `auth_request`, no ACL; only `= /.well-known/mta-sts.txt` served, everything else 404. Tunnel ingress (`cloudflare.nix:19`) routes it; CF edge provides the public TLS the RFC requires. World-fetchable as intended.
7. **Watchdog key handling:** Not via `-u`, not in URL. Header-from-credential-file, rate-limited (6 h), independent of local postfix (HTTPS API) — correct design. Residual: argv (finding 4). Also verified: `postqueue -j` empty-queue edge handled (`jq -s 'length'` → 0); missing `set -e` is deliberate and safe here.
8. **Placeholders:** None in mail scope. See finding 14.

---

## C. Investigated and CLEARED (do not re-chase)

1. **`sasl_passwd.db` `0600 root:root` looked like it would break outbound.** It doesn't: Postfix daemon processes (both `smtpd` and `smtp`) open their maps and TLS chain files during root initialization, before dropping to the `postfix` user. Live proof: relays authenticate to Resend and deliver (`status=sent`, Aug 5 + Aug 6). A raw `sudo -u postfix postmap -q` failing with `Permission denied` is expected and is **not** a runtime fault. (Optional hardening: finding 9.)
2. **ACME cert dir `0750 acme:acme`, postfix/dovecot2 not in group** — same root-init loading behavior: TLSv1.3 handshakes with the real Let's Encrypt cert (`CN=dnanu.de`, issuer `YE2`) succeed on 25 (STARTTLS), 465, 587 and 993. Dovecot additionally loads certs via its root master process. IMAP auth is unaffected by sops perms because SNM renders account hashes into `/run/dovecot2/passwd` (`0600 dovecot2:dovecot2`, live-verified) via a root pre-start step.
3. **`mynetworks` LAN-relay worry** — nixpkgs pins `mynetworks_style = host`; live `postconf` shows only the server's own addresses. Guests cannot relay unauthenticated.
4. **Dovecot unit name** — `dovecot.service` exists on the deployed system, so `mail.nix:177-178` `restartUnits` are correct.

---

## Verdict

**Production-safe, with one must-fix.** The mail stack is functionally and cryptographically sound end-to-end (live-proven), secrets handling is clean, and the hardening did not weaken anything. Nothing found blocks the pending hardening deploy.

**Must-fix before calling it "done":**
- **Finding 1** — scope ports 53/80/443/465/587/993 (and udp 53/67/547) to LAN/ULA/wg0 at the host firewall; keep only 25 (+51820) world-facing. This restores §3.2's locked posture at the layer that survives router mistakes and kills the open-resolver scenario.

**Should-fix (same session or next):**
- Finding 2 (upsert multi-record clobber), Finding 3 (silent DNS-sync failures + no timer), Finding 7 (TLSA alert path — required *before* DS records are published at DENIC, which §12 already schedules).

**Nice-to-have:** findings 4-6, 8-9 (argv hygiene, wildcard-AAAA delete, sieve interpolation, map perms), doc touch-ups (10), and the post-deploy §13 DNS verification batch (12).
