# Hypr Remote TODO

The work list, in build order. `AGENTS.md` is the constitution; this file is
the queue. Remove items as they land — do not check them off, do not let it
rot.

Authorized work only: the queue grants exactly the steps it lists, top-down,
and never overrides the constitution, `.llm/workflow.md`, or the domain notes
(see `AGENTS.md` → Instruction precedence).

Every step is one action with its own done-criteria. Work top-down, one step
at a time: implement it, prove it without breaking the live Hyprland session
(`bash -n` + `shellcheck`, `systemd-analyze verify` for the unit, dry logic
review of the `hyprctl` ordering — live commands only with a go-ahead), then
remove it. Never remove an unverified step; never batch multiple steps into
one change. Split work that spans the script, the unit, and the installer
into separate steps.

Sizes: S <1 day, M 1–3 days, L 3+ days.

## Open steps

- [ ] **1.2 settle pre-existing script/service edits** (S). Review and slice the working-tree changes on `hypr_remote.sh`, `hypr_remote.service`, `install.sh` (user-scope rewrite: `%h` paths, `graphical.target`, workspace 10, `HDMI-A-1`) — scripts onto `working`, docs per file on `master`. Done when: tree is clean or deltas are committed in slices and the service still verifies (`systemd-analyze verify`).
- [ ] **1.3 build install artifact in temp dir** (S). `install.sh` `cp` + `sed -i` on `./hypr_remote.service.working` dirties the repo with real values — build in `mktemp -d` with a trap-clean instead. Done when: running the substitution path leaves `git status` clean and the deployed unit verifies.
- [ ] **1.4 harden install.sh with strict mode** (S). Add `set -euo pipefail` and preflight checks for `wayvnc`/`hyprctl` so a failed copy never reports success. Done when: a simulated failure aborts before `daemon-reload` and `bash -n` + `shellcheck` are clean.
- [ ] **1.5 scope wayvnc cleanup to own session** (S). `pkill wayvnc` kills unrelated sessions and `trap ... EXIT` runs moves after startup failure — track `$!` or scope `pkill -f`, guard cleanup on successful start. Done when: dry-logic review shows only the owned server is stopped and failed starts leave monitors untouched.
- [ ] **1.6 parameterize monitor/workspace names** (S). `HEADLESS-2`, `10`, `HDMI-A-1` hardcoded — read `${VAR:-default}` overrides so per-host values never touch the repo. Done when: defaults reproduce current behavior and overrides flow through to `hyprctl` + `wayvnc` without editing tracked files.
