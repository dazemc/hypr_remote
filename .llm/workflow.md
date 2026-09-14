# Hypr Remote repository workflow

This file interprets `AGENTS.md` (see its Instruction precedence section) and
never overrides it; on a conflict the constitution wins and this file is
corrected.

- `master` is the stable branch. Exactly one working branch, `working`, exists
  beside it and carries the script/service steps of the phase at the top of
  `.llm/todo.md` that still has steps. No other branches exist (no per-phase
  branches).
- Scripts and service land on `working`; markdown lands on `master`.
  `AGENTS.md`, every file under `.llm/`, and docs pages commit directly on
  `master`, immediately, one file per commit, and are pushed. After each
  markdown commit, merge `master` back into `working` so the tree keeps
  reading current docs.
- Every step is one action with one done-criterion; split work that spans the
  script, the unit, and the installer into separate steps. Never batch
  multiple steps into one change.
- Commit every finished TODO step as a slice: one script/service commit on
  `working`, then one commit per touched markdown file on `master` (switch to
  `master`, commit, push, switch back, merge `master` into `working`). A step
  is finished only when it is implemented, proven (`bash -n` clean,
  `shellcheck` clean, `systemd-analyze verify` clean for the unit), and
  removed from `.llm/todo.md`. Markdown never shares a commit with code or
  with another markdown file.
- `git add` only the intended file. Never `git commit -a` on `master` — a
  blanket commit would sweep the script/service or a second markdown file
  into a slice that must stay single-file.
- Never start a new phase without the user's explicit go-ahead in chat: no
  branch, no first step, until asked. Merging a finished phase likewise
  waits for confirmation.
- When a phase's steps are all landed and removed, merge `master` into
  `working` first so the PR carries code only, merge `working` into `master`
  through a pull request, then reset `working` to the updated `master` for
  the next phase. No branch is created per phase.
- Commits use the contributor's configured Git identity. Follow
  `scope: summary` in the imperative.
- Any update to `AGENTS.md` itself is committed immediately on `master`, in
  its own commit, in the same session — a constitution change never sits
  uncommitted in the tree. The same applies to every file under `.llm/`.
- Keep the tree syntax-clean. Check what you touch (`bash -n` /
  `shellcheck`, `systemd-analyze verify` for the unit) before pushing.
- After every change, review the touched files for misses (stale monitor or
  workspace values, placeholder leaks, live-session hazards, docs gaps) and
  append anything that meets the bar to `.llm/suggestions.md`; findings never
  live only in the transcript.
- After each phase is merged, walk every open suggestion with the user and
  settle its decision — keep, condense, move, escalate, or dismiss — before
  the next phase starts.
- Networked Git/GitHub commands (`fetch`, `push`, `gh`) run outside any
  sandbox; sandboxed credential or network failures are not authoritative.

## Prove steps

Static checks first, always without executing:

```sh
bash -n hypr_remote.sh install.sh            # shell syntax, no execution
shellcheck hypr_remote.sh install.sh         # when shellcheck is installed
systemd-analyze verify hypr_remote.service   # unit validity, no installation
```

Live semantics are reasoned dry, never executed by the agent: `hyprctl`
output create/remove ordering, workspace placement, cleanup-trap behavior.

## Live checks (go-ahead only)

Each of these touches the running session and waits for the user's explicit
confirmation in chat, one command at a time:

- `hyprctl output create/remove` and workspace moves (`hyprctl dispatch
  moveworkspacetomonitor|workspace|focusmonitor`).
- Starting `wayvnc` against the real compositor, and any VNC client
  round-trip.
- `systemctl --user daemon-reload` and `enable/start/restart` of the
  `hypr_remote.service` user unit — never a compositor or session target.

When a step's done-criteria needs eyes on screen, hand the user the exact
run-and-look commands and wait for their verdict instead of routing around
it.

## Installer verification without executing

`install.sh` deploys into the live home and reloads systemd — never run it
to "check". Copy the tree to a temp dir, strip the live entry point
(replace the `systemctl --user daemon-reload` tail and `cp` destinations
with echoes, or point `HOME` at a temp dir), then `bash -n` + `shellcheck`
the copy and `systemd-analyze verify` the unit with dummy placeholder
values. Real usernames and runtime paths never land in a commit.

## Never break the live Hyprland session

The agent edits these files from inside the very session they control. Never
kill the compositor, log out, terminate session targets, reboot, or power
off. `pkill` during verification covers only `wayvnc`/`hypr_remote`
processes. Restart only the `hypr_remote.service` user unit, only with a
go-ahead, and say what will happen first.
