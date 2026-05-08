#!/usr/bin/env bash
# Outputs Claude Code icons for panes in a given tmux window.
# Usage: claude-icons.sh <session:window>
#
# Reads ~/.claude/sessions/<pid>.json for active sessions and their status,
# then maps each session PID to a tmux pane via PPID chain.

WINDOW_TARGET="$1"
[ -z "$WINDOW_TARGET" ] && exit 0

ICON="󰚩"
CACHE_FILE="/tmp/tmux-claude-icons-${USER}"
CACHE_TTL=5
SESSIONS_DIR="${HOME}/.claude/sessions"

COLOR_BUSY="#ff79c6"
COLOR_IDLE="#6272a4"

needs_refresh=1
if [ -f "$CACHE_FILE" ]; then
  now=$(date +%s)
  mtime=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
  if [ $((now - mtime)) -lt "$CACHE_TTL" ]; then
    needs_refresh=0
  fi
fi

if [ "$needs_refresh" -eq 1 ]; then
  tmp="${CACHE_FILE}.$$"

  # Build pane_pid -> window_target map, and parent lookup in one awk pass
  {
    tmux list-panes -a -F 'PANE #{session_name}:#{window_index} #{pane_pid}' 2>/dev/null
    echo "ENDPANES"
    ps -eo pid=,ppid= 2>/dev/null
  } | awk -v sessions_dir="$SESSIONS_DIR" '
    /^PANE / { pane_win[$3] = $2; next }
    /^ENDPANES$/ { next }
    { parent[$1+0] = $2+0 }
    END {
      # For each session file, walk up PPID chain to find owning pane
      cmd = "ls " sessions_dir "/*.json 2>/dev/null"
      while ((cmd | getline f) > 0) {
        # Extract PID from filename
        n = split(f, parts, "/")
        gsub(/\.json$/, "", parts[n])
        pid = parts[n] + 0
        if (pid == 0) continue

        # Walk up parent chain
        cur = pid
        for (i = 0; i < 50; i++) {
          if (cur in pane_win) {
            print pane_win[cur] " " pid
            break
          }
          if (!(cur in parent) || parent[cur] == cur || cur <= 1) break
          cur = parent[cur]
        }
      }
      close(cmd)
    }
  ' > "$tmp"

  mv -f "$tmp" "$CACHE_FILE" 2>/dev/null
fi

if [ -f "$CACHE_FILE" ]; then
  output=""
  while IFS=' ' read -r wt pid; do
    [ "$wt" != "$WINDOW_TARGET" ] && continue
    status=""
    kind=""
    if [ -f "${SESSIONS_DIR}/${pid}.json" ]; then
      status=$(sed -n 's/.*"status":"\([^"]*\)".*/\1/p' "${SESSIONS_DIR}/${pid}.json")
      kind=$(sed -n 's/.*"kind":"\([^"]*\)".*/\1/p' "${SESSIONS_DIR}/${pid}.json")
    fi
    [ "$kind" != "interactive" ] && continue
    if [ "$status" = "busy" ]; then
      output="${output}#[fg=${COLOR_BUSY}]${ICON}"
    else
      output="${output}#[fg=${COLOR_IDLE}]${ICON}"
    fi
  done < "$CACHE_FILE"
  if [ -n "$output" ]; then
    printf ' %s#[fg=default]' "$output"
  fi
fi
