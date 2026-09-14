# Hypr Remote suggestions

Agent-proposed, user-reviewed suggestions. If you see something the queue,
the constitution, or the script/service gets wrong — a stale monitor or
workspace value, a placeholder leak, a live-session hazard, a docs gap —
propose it here so the next session sees it. Standing rules and instructions
belong in `AGENTS.md`, not here.

Non-authoritative: entries inform decisions but bind nothing until the user
escalates them to `.llm/todo.md` (see `AGENTS.md` → Instruction precedence).

## Rules

- Entries must be **absolutely needed**: they prevent a future mistake,
  unblock queued work, or record a decision with its reason. Brainstorming,
  nice-to-haves, and restatements of `.llm/todo.md` do not belong here.
- One entry per issue. Keep it to five lines: what, where, why, and what
  to do about it.
- Append after every change: review the touched files for misses and add
  entries that meet the bar; findings never live only in the transcript.
- Remove an entry in the same change that resolves it — same discipline as
  `.llm/todo.md`.
- After finishing any `.llm/todo.md` step, re-read this file and update it,
  but only if something meets the bar above. No obligatory edits. Silence is
  a valid review outcome.
- At a phase boundary, walk every open entry with the user and settle its
  decision — keep, condense, move, escalate, or dismiss — before the next
  phase starts.

## Open suggestions

- VNC binds `0.0.0.0:5900` with no auth note: anyone on the LAN can connect. Decide: document LAN-only risk, default to `127.0.0.1` + SSH forward, or add wayvnc auth. Record the decision in `service.md`.
- Monitor/workspace/output names hardcoded (`HEADLESS-2`, `10`, `HDMI-A-1`): any second machine edits tracked files. Read `${VAR:-default}` overrides so per-host values never touch the repo.
