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

- [ ] **2.1 strict mode for hypr_remote.sh** (S). Add `set -euo pipefail` so a failed `hyprctl output create` aborts before workspace moves. Done when: a stubbed failing `hyprctl` aborts the run with nonzero exit and `bash -n` + `shellcheck` are clean.

