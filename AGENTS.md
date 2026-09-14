# Hypr Remote

WayVNC on a Hyprland headless monitor, managed as a user systemd service.

The setup creates a virtual headless output (`HEADLESS-2`), moves a scratch
workspace onto it, and serves that output over VNC — so a remote client gets
a full desktop without disturbing the local monitors. `hypr_remote.sh` owns
the lifecycle (create output, place workspace, start `wayvnc`, clean up on
exit); `hypr_remote.service` runs it as a `--user` unit; `install.sh` deploys
both into the user's home (`~/.local/bin/`, `~/.config/systemd/user/`).

## Goal

One checkout yields a working remote headless display: script plus user
service plus installer, kept in sync, verified without ever breaking the
live Hyprland session that is editing it.

The work queue lives in `.llm/todo.md`, in build order. Work it top-down one
step at a time, on the working branch (see Repository workflow):

1. Implement the step, nothing more.
2. Prove it without breaking the live Hyprland session: statically check
   what you touched (`bash -n`, `shellcheck`, `systemd-analyze verify` for
   the unit) and reason through the live semantics (`hyprctl` output
   create/remove ordering, workspace placement, cleanup-trap behavior)
   without executing them. A step that parses but would misbehave at
   runtime is not done. If the done-criteria needs eyes on screen or a
   live VNC round-trip, hand the user the exact run-and-look commands and
   wait for their verdict — never substitute screenshots, and never run
   the live commands yourself without a go-ahead.
3. Re-read the topical notes under `.llm/` and update the matching file —
   but only if something is absolutely needed. `.llm/suggestions.md` is for
   agent-proposed, user-reviewed findings that may escalate to `todo.md`.
   Silence is a valid review outcome; never add noise to justify the read.
4. Only then remove the step from `.llm/todo.md`.
5. Commit in slices: the script/service change is one commit; every
   LLM-maintained markdown file (`.llm/todo.md`, `.llm/suggestions.md`,
   docs) gets its own commit. Markdown never shares a commit with code,
   and two markdown files never share a commit with each other.

Never remove an unverified step. A step is one action with one
done-criterion; split work that spans the script, the unit, and the
installer into separate steps. Never batch multiple steps into one change.
Never check steps off — remove them. Do not let the queue rot.

## What it is

- `hypr_remote.sh`: creates headless monitor `HEADLESS-2`, moves workspace
  10 onto it, starts `wayvnc 0.0.0.0 5900 HEADLESS-2`, and on exit kills
  only `wayvnc` and moves the workspace back to the real monitor
  (`HDMI-A-1`). See `.llm/service.md` for the current values.
- `hypr_remote.service`: a user systemd unit (`WantedBy=graphical.target`,
  `After=hyprland.service graphical.target`) running the script from
  `%h/.local/bin/hypr_remote.sh`. `RESU` is a placeholder for the user;
  `GDX` for the runtime dir — never committed with real values.
- `install.sh`: copies the unit and script into the user's home
  (`~/.config/systemd/user/`, `~/.local/bin/`), substituting the
  placeholders, then `systemctl --user daemon-reload`. User scope only —
  never system scope, never sudo.
- `README.md`: the user-facing description of the above.

## What it is not

- Not a system service. Nothing installs to `/etc/systemd/system` or
  `/usr/local/bin`, nothing runs `systemctl` outside `--user`, and sudo
  has no role here. Do not reintroduce system scope.
- Not a compositor config. This repo never touches Hyprland configuration,
  session targets, or the display manager — it drives a running session
  through `hyprctl` from a user unit.
- Not a VNC server implementation. WayVNC is a prerequisite binary; this
  repo only starts it against the headless output with the right
  lifecycle around it.
- Not a public store. The unit template carries `RESU`/`GDX` placeholders.
  Real usernames, runtime paths, IPs, ports exposed beyond documentation,
  and credentials are never committed.

## Instruction precedence

One explicit hierarchy, from most to least authoritative. A lower file never
overrides a higher one; on a conflict the higher file wins and the lower one
is corrected in the same session.

```text
AGENTS.md             authoritative rules — the constitution
.llm/workflow.md      process interpretation of those rules
.llm/*.md             domain knowledge and contracts
.llm/todo.md          currently authorized work, in build order
.llm/suggestions.md   non-authoritative observations
```

- `AGENTS.md` is authoritative. It answers what the project is and how every
  change is made.
- `.llm/workflow.md` interprets the process — branches, commits, phases — and
  never adds or bends a rule.
- `.llm/service.md` holds domain knowledge (virtual monitor + wayvnc + user
  service fit, current values, installer behavior) derived from the
  constitution.
- `.llm/todo.md` grants exactly the work it lists, top-down, one step at a
  time; a step never authorizes more than itself.
- `.llm/suggestions.md` is non-authoritative. Entries inform decisions but
  bind nothing until the user escalates them.

## Repository workflow

- `master` is the stable branch. Exactly one working branch, `working`, exists
  beside it and carries the script/service steps of the phase at the top of
  `.llm/todo.md` that still has steps. No other branches exist (no per-phase
  branches).
- Scripts and service land on `working`; markdown lands on `master`.
  `AGENTS.md`, every file under `.llm/`, and docs pages commit directly on
  `master`, immediately, one file per commit, and are pushed. After each
  markdown commit, merge `master` back into `working` so the tree keeps
  reading current docs.
- Never start a new phase without the user's explicit go-ahead in chat: no
  branch, no first step, until asked. Merging a finished phase likewise
  waits for confirmation.
- Commit every finished TODO step as a slice: one script/service commit on
  `working`, then one commit per touched markdown file on `master` (switch to
  `master`, commit, push, switch back, merge `master` into `working`). A step
  is finished only when it is implemented, proven (`bash -n` clean,
  `shellcheck` clean, `systemd-analyze verify` clean for the unit), and
  removed from `.llm/todo.md`. Markdown never shares a commit with code or
  with another markdown file.
- When a phase's steps are all landed and removed, merge `master` into
  `working` first so the PR carries code only, merge `working` into `master`
  through a pull request, then reset `working` to the updated `master` for
  the next phase. No branch is created per phase.
- Commits use the contributor's configured Git identity. Follow
  `scope: summary` in the imperative.
- `git add` only the intended file. Never `git commit -a` on `master` — a
  blanket commit would sweep the script/service or a second markdown file
  into a slice that must stay single-file.
- Any update to `AGENTS.md` itself is committed immediately on `master`, in
  its own commit, in the same session — a constitution change never sits
  uncommitted in the tree. The same applies to every file under `.llm/`.
- Keep the tree syntax-clean. Check what you touch (`bash -n` /
  `shellcheck`, `systemd-analyze verify`) before pushing.
- After every change, review the touched files for misses (stale monitor or
  workspace values, placeholder leaks, live-session hazards, docs gaps) and
  append anything that meets the bar to `.llm/suggestions.md`; findings never
  live only in the transcript.
- After each phase is merged, walk every open suggestion with the user and
  settle its decision — keep, condense, move, escalate, or dismiss — before
  the next phase starts.
- Networked Git/GitHub commands (`fetch`, `push`, `gh`) run outside any
  sandbox; sandboxed credential or network failures are not authoritative.

## Go-ahead gates

The following wait for the user's explicit confirmation in chat — never
assume them:

- Starting a phase: no branch, no first step, until asked.
- Running the installer or deploying anything (`install.sh`, copying the
  unit or script into live paths, `daemon-reload`).
- Restarting, enabling, or starting the live user service
  (`systemctl --user restart/enable/start hypr_remote.service`).
- Touching the live session at all (`hyprctl output create/remove`,
  moving workspaces, starting `wayvnc` against the real compositor).
- Merging a finished phase (`working` into `master`).

## Verify installers without executing

`install.sh` deploys into the live home directory and reloads systemd — it
is never run by the agent, not even "once to check". Verify it by reading
and by static checks against a sandbox copy:

- Copy the tree to a temp dir, strip the live entry point (replace the
  `systemctl --user daemon-reload` tail and any `cp` destinations with
  echoes, or point `HOME` at a temp dir), then `bash -n` and `shellcheck`
  the result.
- Validate the unit without installing it: `systemd-analyze verify` on the
  unit file (with placeholders substituted to dummy values in the temp
  copy, never the real `$USER`/`$XDG_RUNTIME_DIR` committed anywhere).
- Confirm placeholder discipline by inspection: `RESU`/`GDX` present in the
  template, no real username or runtime path in the diff.

Reading the script's `hyprctl` logic is verification; executing it is
deployment. The line between them is the go-ahead gate above.

## Privacy

- Refer to the user and runtime dir by placeholder (`RESU`, `GDX`) in every
  committed file — the pattern already in this repo. Never commit real
  usernames, home paths, runtime paths, IPs, or secrets.
- The installer substitutes placeholders at deploy time from the live
  environment. Substituted copies (e.g. `*.working` files carrying real
  values) are deploy artifacts: never commit them, and keep them out of
  `git status` clean-tree expectations by removing or ignoring them.

## Never break the live Hyprland session

The agent edits these files from inside the very session they control. Every
rule here follows from that.

- Never kill the compositor, log out, terminate session targets, reboot, or
  power off on the user's behalf. `pkill` during any verification covers
  only `wayvnc`/`hypr_remote` processes — never Hyprland, never the session.
- Never `hyprctl output create/remove`, move workspaces, or start `wayvnc`
  without a go-ahead. These commands reshape the running desktop; dry logic
  review is the default, live execution is the exception that waits for
  confirmation.
- Never run `install.sh`, `systemctl --user enable/start/restart`, or
  `daemon-reload` without a go-ahead. Prefer static verification (above)
  over reinstalling.
- When testing requires restarting the service, wait for explicit
  confirmation, restart only the `hypr_remote.service` user unit — never a
  compositor or session target — and say what will happen first.

## Verify

```sh
bash -n hypr_remote.sh install.sh            # shell syntax, no execution
shellcheck hypr_remote.sh install.sh         # when shellcheck is installed
systemd-analyze verify hypr_remote.service   # unit validity, no installation
```

Live checks (`hyprctl output create/remove`, workspace moves, `systemctl
--user restart hypr_remote.service`, a VNC client round-trip) run only with
a go-ahead, against the live session, one command at a time. When a change
cannot be verified headless, hand the user the exact run-and-look commands
and wait for their verdict instead of routing around it.
