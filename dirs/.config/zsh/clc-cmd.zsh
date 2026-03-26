# Claude Code powered command generator for zsh
# Requires: claude(Claude Code CLI), tmux (optional, for terminal context), timeout (optional, from coreutils)
#
# Setup (add to .zshrc after sourcing this file):
#   bindkey '^G' _clc_cmd_generate # Ctrl+G for example

# ── config ────────────────────────────────────────────────────────────────────
: ${CLC_CMD_CONTEXT_LINES:=50}  # how many tmux scrollback lines to send
: ${CLC_CMD_HISTORY_LINES:=50}   # how many recent history entries to send
: ${CLC_CMD_TIMEOUT:=15}         # seconds before giving up
: ${CLC_CMD_LOG_DIR:=""}         # log directory (empty = no logging)
: ${CLC_CMD_CANDIDATES:=5}      # max candidates when multiple requested

# ── core widget ───────────────────────────────────────────────────────────────
_clc_cmd_generate() {
  setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR
  local user_input="$BUFFER"
  [[ -z "$user_input" ]] && return

  # ── build context ──────────────────────────────────────────────────────────
  local context=""

  # tmux scrollback (strip ANSI escape codes)
  if [[ -n "$TMUX" ]]; then
    context=$(tmux capture-pane -p -S -${CLC_CMD_CONTEXT_LINES} 2>/dev/null \
      | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
      | sed '/^[[:space:]]*$/d' \
      | tail -n ${CLC_CMD_CONTEXT_LINES})
  fi

  # current directory + git branch if available
  local cwd="$PWD"
  local git_info=""
  if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    local branch=$(git branch --show-current 2>/dev/null)
    local gst=$(git status --short 2>/dev/null | head -5)
    git_info="git branch: ${branch}${gst:+\ngit status (short):\n${gst}}"
  fi

  # recent history
  local hist=$(fc -l -${CLC_CMD_HISTORY_LINES} 2>/dev/null | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//')

  # ── build prompt ───────────────────────────────────────────────────────────
  local prompt
  prompt="You are a shell command generator. Output ONLY the shell command — no explanation, no markdown fences, no comments.

Context:
- Shell: zsh
- CWD: ${cwd}
${git_info:+- ${git_info}}
- Recent history:
${hist}
${context:+
- Terminal output (last ${CLC_CMD_CONTEXT_LINES} lines):
${context}}

User request: ${user_input}

Output rules:
- If the request is straightforward, output exactly 1 command.
- If the user asks for alternatives or multiple options, output up to ${CLC_CMD_CANDIDATES} candidates, one per line, ordered by relevance (best match first).
- No numbering, no explanation, no markdown fences."

  # ── log prompt ────────────────────────────────────────────────────────────
  if [[ -n "$CLC_CMD_LOG_DIR" ]]; then
    mkdir -p "$CLC_CMD_LOG_DIR" 2>/dev/null
    local logfile="${CLC_CMD_LOG_DIR}/$(date +%Y%m%d_%H%M%S).log"
    echo "$prompt" > "$logfile"
  fi

  # ── show spinner while waiting ─────────────────────────────────────────────
  # save current buffer, show "thinking..." indicator
  local saved_buffer="$BUFFER"
  local saved_cursor="$CURSOR"
  BUFFER="⏳ asking claude...${user_input:+ \"$user_input\"}"
  CURSOR=${#BUFFER}
  zle -R

  # ── call claude CLI ────────────────────────────────────────────────────────
  local result exit_code _claude_pid _cancelled=0
  local start_time=$EPOCHREALTIME
  local _tmpfile="/tmp/clc_cmd_$$"
  local _infile="/tmp/clc_cmd_in_$$"
  echo "$prompt" > "$_infile"

  claude -p "" --no-streaming < "$_infile" > "$_tmpfile" 2>/dev/null &
  _claude_pid=$!
  trap "_cancelled=1; kill $_claude_pid 2>/dev/null" INT
  wait $_claude_pid
  exit_code=$?
  trap - INT
  rm -f "$_infile"

  if (( _cancelled )); then
    rm -f "$_tmpfile"
    BUFFER="$saved_buffer"; CURSOR=$saved_cursor; zle redisplay; return
  fi
  result=$(cat "$_tmpfile" 2>/dev/null); rm -f "$_tmpfile"

  # fallback: try passing prompt as argument if stdin mode failed
  if [[ $exit_code -ne 0 ]] || [[ -z "$result" ]]; then
    claude -p "$prompt" > "$_tmpfile" 2>/dev/null &
    _claude_pid=$!
    trap "_cancelled=1; kill $_claude_pid 2>/dev/null" INT
    wait $_claude_pid
    exit_code=$?
    trap - INT

    if (( _cancelled )); then
      rm -f "$_tmpfile"
      BUFFER="$saved_buffer"; CURSOR=$saved_cursor; zle redisplay; return
    fi
    result=$(cat "$_tmpfile" 2>/dev/null); rm -f "$_tmpfile"
  fi

  local elapsed=$(( EPOCHREALTIME - start_time ))

  # ── log elapsed time ─────────────────────────────────────────────────────
  if [[ -n "$CLC_CMD_LOG_DIR" ]] && [[ -n "$logfile" ]]; then
    printf '\n--- elapsed: %.2fs, exit: %d ---\nresult: %s\n' "$elapsed" "$exit_code" "$result" >> "$logfile"
  fi

  # ── parse result ───────────────────────────────────────────────────────────
  if [[ $exit_code -eq 0 ]] && [[ -n "$result" ]]; then
    # strip markdown code fences and blank lines
    result=$(echo "$result" \
      | sed '/^```/d' \
      | sed 's/^[[:space:]]*//' \
      | sed 's/[[:space:]]*$//' \
      | sed '/^$/d')

    local lines=$(echo "$result" | wc -l)
    local selected
    if (( lines > 1 )); then
      selected=$(echo "$result" | fzf --height=~${CLC_CMD_CANDIDATES} --reverse --no-sort --prompt="cmd> ")
    else
      selected="$result"
    fi

    if [[ -n "$selected" ]]; then
      BUFFER="$selected"
      CURSOR=${#BUFFER}
    else
      BUFFER="$saved_buffer"
      CURSOR=$saved_cursor
    fi
  else
    # restore original input on failure
    BUFFER="$saved_buffer"
    CURSOR=$saved_cursor
    zle -M "clc-cmd: failed (exit ${exit_code})"
  fi

  POSTDISPLAY=""
  zle redisplay
}

zle -N _clc_cmd_generate
