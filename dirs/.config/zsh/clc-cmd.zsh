# Claude Code powered command generator for zsh
# Requires:
#   claude (Claude Code CLI)
#   fzf (optional, for multi-candidate selection)
#   tmux (optional, for terminal context)
#
# Setup (add to .zshrc after sourcing this file):
#   bindkey '^G' _clc_cmd_generate # Ctrl+G for example

# ── config ────────────────────────────────────────────────────────────────────
: ${CLC_CMD_CONTEXT_LINES:=50}  # how many tmux scrollback lines to send
: ${CLC_CMD_HISTORY_LINES:=50}   # how many recent history entries to send
: ${CLC_CMD_LOG_DIR:=""}         # log directory (empty = no logging)
: ${CLC_CMD_CANDIDATES:=5}      # max candidates when multiple requested
: ${CLC_CMD_SPINNER:=braille}   # spinner style: braille, ascii
: ${CLC_CMD_VERBOSE:=0}        # 1 = show elapsed time and cancel hint
: ${CLC_CMD_SPINNER_COLOR:=animated} # spinner color: animated, plain, or a color name/number

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
      | sed -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' -e '/^[[:space:]]*$/d' \
      | tail -n ${CLC_CMD_CONTEXT_LINES} \
      | tail -c $(( CLC_CMD_CONTEXT_LINES * 200 )))
  fi

  # current directory + git branch if available
  local cwd="$PWD"
  local git_info=""
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git branch --show-current 2>/dev/null)
    local gst=$(git status --short 2>/dev/null | head -5)
    git_info="git branch: ${branch}${gst:+\ngit status (short):\n${gst}}"
  fi

  # recent history
  local hist=$(fc -l -${CLC_CMD_HISTORY_LINES} 2>/dev/null \
    | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' \
    | tail -c $(( CLC_CMD_HISTORY_LINES * 200 )))

  # ── build prompt ───────────────────────────────────────────────────────────
  local _prompt
  _prompt="You are a shell command generator. Output ONLY the shell command — no explanation, no markdown fences, no comments. Respond as fast as possible with minimal tokens.

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
- If you cannot generate a valid command, output the user request as-is.
- No numbering, no explanation, no markdown fences."

  # ── log prompt ────────────────────────────────────────────────────────────
  if [[ -n "$CLC_CMD_LOG_DIR" ]]; then
    mkdir -p "$CLC_CMD_LOG_DIR" 2>/dev/null
    local logfile="${CLC_CMD_LOG_DIR}/$(date +%Y%m%d_%H%M%S).log"
    echo "$_prompt" > "$logfile"
  fi

  # ── show spinner while waiting ─────────────────────────────────────────────
  local saved_buffer="$BUFFER"
  local saved_cursor="$CURSOR"
  POSTDISPLAY=""

  # ── call claude CLI ────────────────────────────────────────────────────────
  local result exit_code _cancelled=0
  local start_time=$EPOCHREALTIME
  local _tmpfile="/tmp/clc_cmd_$$"
  local _infile="/tmp/clc_cmd_in_$$"
  printf '%s' "$_prompt" > "$_infile"

  setsid claude -p --bare --no-session-persistence < "$_infile" > "$_tmpfile" 2>/dev/null &
  local _pid=$!
  trap "_cancelled=1; kill $_pid 2>/dev/null; wait $_pid 2>/dev/null" INT

  # animate spinner while waiting
  local _spin_chars
  case "$CLC_CMD_SPINNER" in
    braille) _spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏') ;;
    *)       _spin_chars=('/' '-' '\' '|') ;;
  esac
  local _n=${#_spin_chars[@]}
  local _anim_colors=(39 38 44 43 49 48 84 83 119 118 154 153 189 188 183 182 177 176 171 170 135 134 99 98 63 62)
  local _nc=${#_anim_colors[@]}
  local _spin_i=0
  while kill -0 $_pid 2>/dev/null; do
    local _sc=${_spin_chars[$(( _spin_i % _n + 1 ))]}
    local _msg="${_sc} Asking Claude"
    if (( CLC_CMD_VERBOSE )); then
      _msg+=" (^C to cancel) $(printf '%4.1f' $(( EPOCHREALTIME - start_time )))s"
    fi
    POSTDISPLAY=$'\n'"${_msg}"
    local _pstart=${#BUFFER}
    local _pend=$(( _pstart + ${#POSTDISPLAY} ))
    case "$CLC_CMD_SPINNER_COLOR" in
      animated) region_highlight=("${_pstart} ${_pend} fg=${_anim_colors[$(( _spin_i % _nc + 1 ))]}") ;;
      plain)    region_highlight=("${_pstart} ${_pend} fg=default") ;;
      *)        region_highlight=("${_pstart} ${_pend} fg=${CLC_CMD_SPINNER_COLOR}") ;;
    esac
    zle -R
    _spin_i=$(( _spin_i + 1 ))
    sleep 0.1 &
    wait $! 2>/dev/null
  done

  wait $_pid 2>/dev/null
  exit_code=$?
  trap - INT
  rm -f "$_infile"

  if (( _cancelled )); then
    rm -f "$_tmpfile"
    BUFFER="$saved_buffer"; CURSOR=$saved_cursor; POSTDISPLAY=""; zle redisplay; return
  fi
  result=$(<"$_tmpfile")
  rm -f "$_tmpfile"

  local elapsed=$(( EPOCHREALTIME - start_time ))

  # ── log elapsed time ─────────────────────────────────────────────────────
  if [[ -n "$CLC_CMD_LOG_DIR" ]] && [[ -n "$logfile" ]]; then
    printf '\n--- elapsed: %.2fs, exit: %d ---\nresult: %s\n' "$elapsed" "$exit_code" "$result" >> "$logfile"
  fi

  # ── parse result ───────────────────────────────────────────────────────────
  if [[ $exit_code -eq 0 ]] && [[ -n "$result" ]]; then
    # strip markdown code fences and blank lines
    result=$(echo "$result" \
      | sed -e '/^```/d' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^$/d')

    local lines=$(echo "$result" | wc -l)
    local selected
    if (( lines > 1 )) && (( $+commands[fzf] )); then
      selected=$(echo "$result" | fzf --height=~${CLC_CMD_CANDIDATES} --reverse --no-sort --prompt="cmd> ")
    else
      selected=$(echo "$result" | head -1)
    fi

    if [[ -n "$selected" ]]; then
      BUFFER="$selected"
      CURSOR=${#BUFFER}
    else
      BUFFER="$saved_buffer"
      CURSOR=$saved_cursor
    fi
  else
    BUFFER="$saved_buffer"
    CURSOR=$saved_cursor
  fi

  POSTDISPLAY=""
  zle redisplay
}

zle -N _clc_cmd_generate
