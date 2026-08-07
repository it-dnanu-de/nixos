# Inbox Placement Test Results

**Report Name:** Test Results
**Status:** Completed
**From Address:** hey@dnanu.de
**Created On:** Aug 06, 2026 03:35:24
**Received Emails:** 94 / 124

## Overall Placement Summary

| Metric  | Percentage | Count |
|---------|-----------|-------|
| Inbox   | 40%       | 50    |
| Spam    | 35%       | 44    |
| Missing | 24%       | 30    |

## Provider-Level Results

| # | Provider | Region | Inbox | Spam | Missing | Notes |
|---|----------|--------|-------|------|---------|-------|
| 1 | Gmail | Global | 0% | 0% | 100% | All 30 recipients missing |
| 2 | GMX USA | USA | 100% | 0% | 0% | 14/14 delivered to inbox |
| 3 | Zoho Mail | India | 100% | 0% | 0% | 10/10 delivered to inbox |
| 4 | Google Workspace | Global | 0% | 100% | 0% | 5/5 delivered to spam |
| 5 | Outlook | Global | 0% | 100% | 0% | 20/20 delivered to spam |
| 6 | Yandex | Global | 100% | 0% | 0% | 2/2 delivered to inbox |
| 7 | AOL | Global | 0% | 100% | 0% | 7/7 delivered to spam |
| 8 | Mail.ru | Global | 100% | 0% | 0% | 2/2 delivered to inbox |
| 9 | BlueTie | Global | 100% | 0% | 0% | 1/1 delivered to inbox |
| 10 | Interia | Global | 100% | 0% | 0% | 1/1 delivered to inbox |
| 11 | Libero | Global | 100% | 0% | 0% | 1/1 delivered to inbox |
| 12 | Centrum | Global | 100% | 0% | 0% | 1/1 delivered to inbox |
| 13 | Seznam | Global | 100% | 0% | 0% | 2/2 delivered to inbox |
| 14 | LaPoste | Global | 0% | 100% | 0% | 1/1 delivered to spam |
| 15 | Free.fr | Global | 100% | 0% | 0% | 1/1 delivered to inbox |
| 16 | SFR | Global | 100% | 0% | 0% | 1/1 delivered to inbox |
| 17 | Amazon WorkMail | Global | 100% | 0% | 0% | 2/2 delivered to inbox |
| 18 | AT&T | Global | 0% | 100% | 0% | 1/1 delivered to spam |
| 19 | Freenet | Germany | 100% | 0% | 0% | 1/1 delivered to inbox |
| 20 | Microsoft 365 | Global | 100% | 0% | 0% | 5/5 delivered to inbox |
| 21 | Web.de | Global | 100% | 0% | 0% | 1/1 delivered to inbox |
| 22 | T-Online | Global | 100% | 0% | 0% | 1/1 delivered to inbox |
| 23 | iCloud | Global | 0% | 100% | 0% | 1/1 delivered to spam |
| 24 | Yahoo | Global | 0% | 100% | 0% | 8/8 delivered to spam |
| 25 | GMX Germany | Germany | 100% | 0% | 0% | 1/1 delivered to inbox |
| 26 | Onet | Global | 100% | 0% | 0% | 2/2 delivered to inbox |
| 27 | Barracuda | Global | 0% | 100% | 0% | 1/1 delivered to spam |

## Providers Fully Landing in Inbox (100%)
GMX USA, Zoho Mail, Yandex, Mail.ru, BlueTie, Interia, Libero, Centrum, Seznam, Free.fr, SFR, Amazon WorkMail, Freenet, Microsoft 365, Web.de, T-Online, GMX Germany, Onet

## Providers Fully Landing in Spam (100%)
Google Workspace, Outlook, AOL, LaPoste, AT&T, iCloud, Yahoo, Barracuda

## Providers Fully Missing (100%)
Gmail — no delivery detected to any of the 30 Gmail test recipients (Inbox, Spam, or otherwise)

## Key Takeaways
- **Biggest problem: Gmail.** 100% of Gmail-bound test emails are missing — not even landing in spam. This suggests a delivery/authentication issue specific to Gmail (SPF/DKIM/DMARC alignment, blocklisting, or reputation issue) rather than a spam-filtering issue.
- **Major spam-folder placement:** Microsoft-family services (Outlook, Google Workspace less so — actually Google Workspace *is* in spam) and consumer webmail giants (Yahoo, AOL, iCloud) are routing all test mail to spam.
- **Strong performers:** Regional/international providers (Zoho, GMX, Yandex, Mail.ru, and most European ISPs) show clean 100% inbox placement, suggesting the sending domain/IP is not broadly blocklisted — the problem is concentrated in specific large mailbox providers (Gmail, Microsoft, Yahoo/AOL/Verizon Media, Apple).

*Sender IP addresses observed across the test: 54.240.3.x and 54.240.6.x range (Amazon SES infrastructure).*
