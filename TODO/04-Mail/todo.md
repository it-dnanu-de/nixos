# TODO — 04 Mail

**Status:** ✅ done (deployed, audited) · **Owner:** mail-stack skill · **File refs:** `modules/services/mail.nix`, `modules/services/cloudflare-dns.nix`

## Stack (simple-nixos-mailserver)
- [x] SNM: Postfix + Dovecot + Rspamd, fqdn `mail.dnanu.de`
- [x] IMAP 993, submission 465 (SMTPS) + 587, ManageSieve, LMTP
- [x] `openFirewall=false` (ports scoped by host firewall, audit F1)

## Accounts (OpenCode.md §4.2)
- [x] `hey@dnanu.de`: 8 aliases (it/health/wealth/creative/academic/accounts/contact/partners) + sieve fileinto rules
- [x] `admin@dnanu.de`: postmaster/hostmaster/webmaster/abuse/security aliases
- [x] `recipientDelimiter` sub-addressing (`hey+foo@`)
- [x] hashedPasswordFile from sops

## Outbound relay (Resend)
- [x] Postfix `smtp.resend.com:465` SMTPS, user `resend`, pass = API key (sops)
- [x] Static tls_policy `verify` (CA+hostname verified) — beats tlspol socketmap
- [x] `smtp_tls_wrappermode = yes`

## DNS records (Cloudflare, declarative sync)
- [x] MX both zones → mail.dnanu.de prio 10
- [x] SPF `v=spf1 -all` (nothing sends as @dnanu.de)
- [x] Resend DKIM/SPF for `send.dnanu.de` (per dashboard)
- [x] DMARC `p=quarantine` (rua admin@) → [ ] flip to `p=reject` after 30 clean days
- [x] MTA-STS TXT + mta-sts.dnanu.de CNAME + policy host (mode enforce, max_age 86400)
- [x] TLS-RPT TXT (`_smtp._tls`)
- [x] DANE TLSA `3 1 1` auto-synced from ACME cert (daily + renewal + boot)
- [ ] DANE activates once DS published at DENIC (OpenCode.md §3.7)

## Hardening (audit)
- [x] postfix RFC-conformance checks (helo/non-FQDN/unknown domain/unauth pipelining)
- [x] rspamd reject=12, stock RBLs, spamhaus disabled
- [x] TLS-RPT + DMARC reporting enabled
- [x] MTA-STS enforce mode

## Monitoring (D6)
- [x] `mail-queue-watch` timer (15 min): postfix/dovecot/rspamd down, queue >2, oldest >30 min → Resend API → hey@
- [x] 6h cooldown, independent of local postfix
- [x] TLSA-sync failure alert (OnFailure → Resend)

## Verification
- [ ] `swaks --to hey@dnanu.de --server <home-ip>` from outside
- [ ] iOS send via Resend dashboard
- [ ] mail-tester.com + internet.nl after final deploy
- [ ] `dig mail.dnanu.de @1.1.1.1` → home IP
