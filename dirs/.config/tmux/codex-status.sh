#!/usr/bin/env bash

# Show one Codex icon for each tmux window that owns an interactive Codex CLI
# process. Codex has no small, stable session-status directory equivalent to
# Claude's ~/.claude/sessions, so resolve the process to its tmux pane instead.

WINDOW_TARGET="${1:-}"
[ -n "$WINDOW_TARGET" ] || exit 0

get_tmux_option() {
  local option="$1"
  local default="$2"
  local value

  value="$(tmux show-option -gqv "$option" 2>/dev/null)"
  [ -n "$value" ] && printf '%s\n' "$value" || printf '%s\n' "$default"
}

CODEX_STATUS_ICON="$(get_tmux_option '@codex_status_icon' '◆')"
CLAUDE_STATUS_SPACE="$(get_tmux_option '@claude_status_space' ' ')"
CODEX_STATUS_STATE_DIR_DEFAULT="/tmp/tmux-codex-state-${USER:-unknown}"
CODEX_STATUS_STATE_DIR="$(get_tmux_option '@codex_status_state_dir' "$CODEX_STATUS_STATE_DIR_DEFAULT")"
CODEX_STATUS_COLOR_BUSY="$(get_tmux_option '@claude_status_color_busy' '#ff79c6')"
CODEX_STATUS_COLOR_IDLE="$(get_tmux_option '@claude_status_color_idle' '#6272a4')"
CODEX_STATUS_COLOR_WAITING="$(get_tmux_option '@claude_status_color_waiting' '#f1fa8c')"
CODEX_STATUS_COLOR_SHELL="$(get_tmux_option '@claude_status_color_shell' '#bd93f9')"
CODEX_STATUS_CACHE_DEFAULT="/tmp/tmux-codex-status-${USER:-unknown}"
CODEX_STATUS_CACHE_FILE="$(get_tmux_option '@codex_status_cache_file' "$CODEX_STATUS_CACHE_DEFAULT")"
CODEX_STATUS_CACHE_TTL="$(get_tmux_option '@codex_status_cache_ttl' '5')"

needs_refresh=1
if [ -f "$CODEX_STATUS_CACHE_FILE" ]; then
  now=$(date +%s)
  mtime=$(stat -c %Y "$CODEX_STATUS_CACHE_FILE" 2>/dev/null || stat -f %m "$CODEX_STATUS_CACHE_FILE" 2>/dev/null || echo 0)
  if [ $((now - mtime)) -lt "$CODEX_STATUS_CACHE_TTL" ]; then
    needs_refresh=0
  fi
fi

if [ "$needs_refresh" -eq 1 ]; then
  tmp="${CODEX_STATUS_CACHE_FILE}.$$"

  {
    tmux list-panes -a -F 'PANE #{session_name}:#{window_index} #{pane_index} #{pane_id} #{pane_pid}' 2>/dev/null
    printf '%s\n' 'ENDPANES'
    ps -eo pid=,ppid=,args= 2>/dev/null
  } | awk -v state_dir="$CODEX_STATUS_STATE_DIR" '
    /^PANE / {
      pane_window[$5] = $2
      pane_index[$5] = $3
      pane_id[$5] = $4
      next
    }
    /^ENDPANES$/ { next }
    {
      pid = $1 + 0
      parent[pid] = $2 + 0
      command = $0
      sub(/^[[:space:]]*[0-9]+[[:space:]]+[0-9]+[[:space:]]+/, "", command)

      # The wrapper and the native child are both named codex. Walking the
      # parent chain below collapses them back to the owning tmux pane and
      # excludes Codex processes launched outside tmux.
      if (command ~ /(^|[[:space:]\/])codex([[:space:]]|$)/)
        codex[pid] = 1
    }
    END {
      for (pid in codex) {
        current = pid
        for (i = 0; i < 50; i++) {
        if (current in pane_window) {
            current_pane = pane_id[current]
            if (current_pane in seen_pane)
              break
            seen_pane[current_pane] = 1
            status = "idle"
            state_file = state_dir "/" current_pane
            if ((getline state < state_file) > 0) {
              gsub(/[[:space:]]/, "", state)
              if (state == "busy" || state == "shell" || state == "waiting")
                status = state
              close(state_file)
            }
            print pane_window[current] " " pane_index[current] " " status
            break
          }
          if (!(current in parent) || parent[current] == current || current <= 1)
            break
          current = parent[current]
        }
      }
    }
  ' | sort -u >"$tmp"

  mv -f "$tmp" "$CODEX_STATUS_CACHE_FILE" 2>/dev/null
fi

if [ -f "$CODEX_STATUS_CACHE_FILE" ]; then
  output=""
  while IFS=' ' read -r window_target _pane_index status; do
    [ "$window_target" = "$WINDOW_TARGET" ] || continue
    case "$status" in
      busy) color="$CODEX_STATUS_COLOR_BUSY" ;;
      shell) color="$CODEX_STATUS_COLOR_SHELL" ;;
      waiting) color="$CODEX_STATUS_COLOR_WAITING" ;;
      *) color="$CODEX_STATUS_COLOR_IDLE" ;;
    esac
    output="${output}#[fg=${color}]${CODEX_STATUS_ICON}"
  done <"$CODEX_STATUS_CACHE_FILE"
  [ -n "$output" ] && printf '%s%s#[fg=default]' "$CLAUDE_STATUS_SPACE" "$output"
fi
