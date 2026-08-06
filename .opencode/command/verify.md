---
description: Run the §13 verification suite against the running homelab server and report results as a checklist. Routed to V4 Flash (planner-low) — a checklist task.
agent: planner-low
---

Run the verification suite from OpenCode.md §13 against the homelab server and report results.

$ARGUMENTS

Checks: `zpool status` · `dig @10.0.0.2 mail.dnanu.de` (-> 10.0.0.2) · `dig mail.dnanu.de @1.1.1.1` (-> home IP) · `swaks --to hey@dnanu.de --server <home-ip>` from outside · iOS send -> Resend dashboard · `curl -I https://cloud.nanulab.de` over Tailscale · qBittorrent IP-leak test · `restic check` · lid-close test · `systemctl --failed` empty.

Skip tests that depend on services not yet installed. Report each as PASS / FAIL / SKIPPED with the evidence.
