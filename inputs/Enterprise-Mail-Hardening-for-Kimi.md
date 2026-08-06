# Task: Enterprise-grade mail — harden SNM+Resend stack, $0, reliable — for Kimi K3 (Maximum reasoning planner)

Source: `/task` invoked by human 2026-08-06 ("the mail and figure everything out... harden it, make it secure, make it enterprise-grade with $0 required and reliable, you know what to do"). Created by Flash per Session Workflow.
**Tier: Max (Kimi K3, planner-max)** — security-hardening + reliability design for the highest-risk service. Execution after approval: nixos-builder (V4 Pro). Troubleshooting: Flash.

## Current mail state (verified 2026-08-06)
- **Stack running:** simple-nixos-mailserver (postfix/dovecot/rspamd) + Resend outbound relay. Services active, ports 25/465/587/993 listening on v4+v6.
- **Verified working:** inbound v4 mail to `hey@dnanu.de` (swaks from outside → `250 queued as 5AF19112E6`); RSPAMD greylisting active (first-contact 451 → retry passes — expected). Outbound via Resend relay confirmed (user round-tripped from Proton).
- **Already configured:** SNM with accounts `hey@` (8 aliases + sieve per-alias fileinto) + `admin@` (postmaster/hostmaster/etc.); `recipientDelimiter="+"`; `dkim.enable=true`; Resend SASL relay via sops template; autoconfig XML vhost on 127.0.0.1:8080; `lmtp_save_to_detail_mailbox=false`.
- **DNS today:** `mail.dnanu.de` A+AAAA (ddclient, grey cloud) · MX dnanu.de+nanulab.de → mail.dnanu.de · SPF `v=spf1 -all` · DMARC `p=quarantine; pct=100; adkim=r; aspf=r` · DKIM published · MTA-STS/TLS-RPT/DANE **NOT set up**.
- **Known gaps (from TODO):** MTA-STS, TLS-RPT, DANE/TLSA unconfigured · DMARC reporting mailbox unused · mail-tester score unknown · `cloudflare-dkim-sync.service` currently FAILS (needs verifying the DKIM record actually syncs) · no mail-queue/monitoring alert · `.mobileconfig` not built.

## The mandate (human, verbatim intent)
"Enterprise-grade, $0 required, reliable." Zero added cost (no new paid services — everything via SNM/Postfix/Resend/Dovecot/Rspamd/Cloudflare free tier). This means a mail stack that: passes mail-tester strongly, is hardened against spoofing/abuse (SPF/DKIM/DMARC strict + reject policies), publishes MTA-STS + TLS-RPT + DANE/TLSA, has monitoring (queue age + DMARC/TLS-RPT reports), and is documented. "I don't want to think about it anymore" — the plan should make mail a solved, set-and-forget subsystem.

## Deliverables the plan must cover (in full)
1. **SNM/postfix hardening options** — verify against pinned SNM 26.05 + nixpkgs 26.05:
   - `services.tlsrpt.enable` (nixpkgs module; postfix already does `smtp_tls_security_level = "dane"` — confirm DANE outbound + TLS-RPT inbound reporting wiring)
   - rspamd hardening: `reject_unknown`, `reject_non_fqdn_sender/helo` via smtpd `reject_*` rules, greylisting tuned, spam quarantine?, `localBl`/RBL policy (decide which RBLs — $0), `soft_reject`, `actions` (greylist→reject thresholds)
   - postfix `smtpd_sender_restrictions`, `smtpd_recipient_restrictions`, `smtpd_relay_restrictions`, `smtpd_helo_required`, `smtpd_client_restrictions` (decide the exact restrictive-but-not-breaking set)
   - `smtp_tls_security_level = dane` (outbound) + `smtpd_tls` already TLS; verify `tls_server_sni_maps`/cert permissive on inbound
   - header cleanup / privacy: `smtputf8`, `strict_rfc821_envelopes`, message_size_limit
2. **DNS records (Cloudflare, declarative in `cloudflare-dns.nix`)**:
   - MTA-STS: TXT `_mta-sts.dnanu.de` = `v=STSv1; id=...;` + a static HTTPS policy at `mta-sts.dnanu.de/.well-known/mta-sts.txt` (mode `enforce` — but must serve on 443/8080 via nginx; decide HTTPS host since port 80/443 to internet is via cloudflared→nginx 8080 loopback → can serve from the dnanu.de vhost)
   - TLS-RPT: TXT `_smtp._tls.dnanu.de` = `v=TLSRPTv1; rua=mailto:...`
   - DANE/TLSA: `_25._tcp.mail.dnanu.de` TLSA 3 1 1 <sha256 of cert pubkey> (needs to match the LE cert; self-maintaining problem — LE rotates every 90d; DECIDE strategy: either 3 1 1 against the currently-issued cert + a doc note to update on rotation, or pin the static key if the ACME account key is stable; recommend the least-fragile $0 approach and say so explicitly)
   - DMARC: `p=quarantine` → note path to `p=reject` after a clean monitoring window; rua/ruf → admin@dnanu.de (already) — ensure the mailbox actually receives/processes reports
   - SPF: keep `-all`; confirm Resend's `send.dnanu.de` subdomain records (their dashboard)
   - DKIM: verify `mail._domainkey.dnanu.de` TXT is actually present + matches the SNM-generated key (this is why cloudflare-dkim-sync fails — diagnose + fix so it's declarative/idempotent)
3. **Fix `cloudflare-dkim-sync.service`** — currently failing (exit 6 NOTCONFIGURED, mail not fully built). Diagnose: does SNM's dkim key file exist on disk? Where does the sync script read it? Make the DKIM record sync idempotent + reliable so it stops failing.
4. **Monitoring/reliability (set-and-forget):**
   - Mail queue age alert (Beszel is the planned monitor; but Beszel isn't built — decide a minimal $0 approach: a small systemd timer `postfix queue age check` that alerts via... what channel? mail-to-self via Resend relay (hey@dnanu.de) or a beszel agent metric; recommend concrete minimal approach)
   - DMARC + TLS-RPT report consumption: rspamd-dmarc-reporter (SNM `dmarcReporting.enable` — verify option) writing reports to admin mailbox? decide
   - `systemd.timers` for rspamd-dmarc-reporter + TLSRPT aggregation
5. **Verification suite (prove it):**
   - mail-tester.com scoring steps (what the human runs; target 10/10)
   - `swaks` inbound/outbound round-trip
   - `dig` all records (SPF/DKIM/DMARC/MTA-STS/TLS-RPT/TLSA)
   - `postfix queue` empty + `mailq`
   - external check via one of the free mail-security testers (internet.nl / mail-tester / DANE checker) — note which are $0
   - `systemctl --failed` → only truly-fixable-or-explainable units
6. **Docs**: OpenCode.md §4 (add MTA-STS/TLS-RPT/DANE rows to DNS table, hardening notes), TODO (close mail items), README, Changes, Memory.

## Constraints
- $0 — no paid mail-security SaaS. Everything via SNM/nixpkgs/Cloudflare free tier/Resend.
- Native modules only. Declarative. sops for secrets. Public-safe repo.
- Do NOT break the working v4 mail path. Greylisting must stay (it's working).
- Verify EVERY option/module against pinned SNM + nixpkgs 26.05 before writing (esp. `services.tlsrpt`, `dmarcReporting`, postfix restriction keywords, TLSA approach).
- The `hey@`/`admin@` accounts + aliases + sieve MUST NOT change (locked §4.2).
- Do not deploy until human approves; build + verify after each phase.
- Zero new flake inputs expected (all native/SNM/nixpkgs).

## Files affected (expected)
`modules/services/mail.nix` (postfix/rspamd hardening, tlsrpt, dmarc reporting) · `modules/services/cloudflare-dns.nix` (MTA-STS/TLS-RPT/DANE TXT+TLSA records) · `modules/services/cloudflare-dns.nix` or a new `mta-sts.nix` (serve .well-known policy) · `modules/networking/nginx.nix` (mta-sts host on the 8080 loopback vhost) · new systemd timer for queue check · `secrets/secrets.yaml` (only if a new secret needed — prefer none) · `OpenCode.md` §4 · docs.

## Model recommendation
**Kimi K3 (planner-max)** — security-hardening design for the highest-risk service, $0 mandate, several subtle decisions (DANE pinning strategy, RBL selection, restrictive postfix rules that must not break legit mail). Human approved the /task flow; this is the Max-tier job. Execution: nixos-builder (V4 Pro).
