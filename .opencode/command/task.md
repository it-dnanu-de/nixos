---
description: "General-purpose workflow: gather info, write an inputs task file, route to a planner by complexity, get the plan reviewed, then execute with nixos-builder. Use for general work. /deploy, /review, /init etc. are special-purpose commands for their specific jobs."
---

# Task — the general workflow

You are the orchestrator. The human describes work (or you gather it from annotated files). Drive the four-stage pipeline:

**Stage 1 — Gather & write `inputs/`** (you, the orchestrator)
1. Understand what needs doing. Read the relevant files (OpenCode.md, TODO.md, Memory.md, current modules) if not already in context.
2. Judge complexity and **recommend a planner tier**:
   | Tier | Model | For |
   |------|-------|-----|
   | Low | planner-low (V4 Flash) | small fixes, single-file, docs |
   | Medium | planner-med (V4 Pro) | module creation, multi-file, service config |
   | High | planner-high (GLM 5.2) | architecture, hard debugging, locking decisions |
   | Max | planner-max (Kimi K3) | security audits, major restructures |
3. Write `inputs/[Task]-for-[Model].md`: goal, problem, deliverables, constraints, files affected, model recommendation. Follow the Session Workflow in OpenCode.md.
4. **Pause — ask the human to confirm/override the tier.** Do not continue until approved.

**Stage 2 — Planner writes `outputs/`**
5. Route to the approved planner via the `task` tool. The planner reads `inputs/` and writes `outputs/[Task]-plan-by-[Model].md`. It must verify ⚠️ VERIFY flags against pinned `nixos-26.05`.
6. Commit the inputs + outputs.

**Stage 3 — Human reviews the plan**
7. Present the plan summary. Wait for approval or requested changes. If changed, update the outputs file and recommit.

**Stage 4 — Execute**
8. Route execution to `nixos-builder` (V4 Pro), which reads `outputs/` and implements, building + committing per phase.
9. If anything breaks, you troubleshoot (you are the troubleshooter tier). Loop until clean.

## Rules
- Commit after each stage (inputs, plan, execution). Push when the human asks or a milestone ends.
- Public-safe: never commit secrets; Memory.md stays gitignored.
- `OpenCode.md` is the single source of truth. Respect ✅ LOCKED / ⚠️ VERIFY.
- For special-purpose work, use the dedicated commands instead: /deploy, /rebuild, /verify, /review, /init, /update, /secrets, /commit, /pr, /status.
