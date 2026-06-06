# Silence zoxide doctor warning in Claude Code / non-interactive shells.
# Snapshot-restored shells lose chpwd_functions hooks, causing false positives.
[[ -n "$CLAUDECODE" || ! -o interactive ]] && export _ZO_DOCTOR=0
