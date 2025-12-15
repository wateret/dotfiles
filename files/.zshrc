# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
export TERM=xterm-256color

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="powerlevel10k/powerlevel10k"

#DEFAULT_USER="hanjoung"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

# User configuration

# export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export PATH=$HOME/.local/bin:$PATH
alias v='nvim'
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi


HISTSIZE=100000
SAVEHIST=1000000
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

FZF_CTRL_R_OPTS="--height 30% --preview 'echo {2..} | bat --color=always -pl sh' --preview-window 'wrap,down,5'"
unset MAILCHECK

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


######## Custom keybindings

# Delete from cursor to next separator (&&, ||, ;) including following spaces
kill_to_next_sep() {
  local buf="$BUFFER"
  local cur=$CURSOR
  local len=${#buf}

  # If cursor is at or beyond end of line, nothing to do
  (( cur >= len )) && return

  # Part of buffer after the cursor (1-based indexing in zsh)
  local after=${buf[cur+1,-1]}
  local after_len=${#after}

  local best_idx=-1    # position (1-based) of chosen separator within "after"
  local sep_len=0      # length of chosen separator
  local sep prefix pos

  # 1) Find the closest separator among: &&, ||, ;
  for sep in '&&' '||' ';'; do
    if [[ $after == *"$sep"* ]]; then
      prefix=${after%%"$sep"*}
      pos=$(( ${#prefix} + 1 ))  # first char position of this sep in "after"
      if (( best_idx == -1 || pos < best_idx )); then
        best_idx=$pos
        sep_len=${#sep}
      fi
    fi
  done

  # 2) If no separator found → delete to end of line (kill-line behavior)
  if (( best_idx == -1 )); then
    BUFFER="${buf[1,cur]}"
    CURSOR=$cur
    return
  fi

  # 3) Extend forward to include following spaces/tabs after the separator
  local i=$(( best_idx + sep_len ))
  local ch
  while (( i <= after_len )); do
    ch=${after[i]}
    [[ $ch == ' ' || $ch == $'\t' ]] || break
    (( i++ ))
  done

  # Delete from cursor to (cursor + i - 1) in the original buffer
  local abs_end=$(( cur + i - 1 ))

  # Keep: [1..cur] + [abs_end+1..end]
  BUFFER="${buf[1,cur]}${buf[abs_end+1,-1]}"
  CURSOR=$cur
}

# Delete from cursor backward to previous separator (&&, ||, ;) including leading spaces
kill_to_prev_sep() {
  local buf="$BUFFER"
  local cur=$CURSOR

  # If cursor is at start of line, nothing to do
  (( cur <= 0 )) && return

  # Part of buffer before the cursor (1-based indexing)
  local pre=${buf[1,cur]}
  local pre_len=${#pre}

  local best_idx=-1    # position (1-based) of chosen separator within "pre"
  local sep_len=0
  local sep prefix pos

  # 1) Find the closest separator to the left among: &&, ||, ;
  for sep in '&&' '||' ';'; do
    if [[ $pre == *"$sep"* ]]; then
      # last occurrence position
      prefix=${pre%$sep*}
      pos=$(( ${#prefix} + 1 ))  # first char position of this sep in "pre"
      if (( best_idx == -1 || pos > best_idx )); then
        best_idx=$pos
        sep_len=${#sep}
      fi
    fi
  done

  # 2) If no separator found → delete from line start to cursor (backward-kill-line)
  if (( best_idx == -1 )); then
    BUFFER="${buf[cur+1,-1]}"
    CURSOR=0
    return
  fi

  # 3) Extend backward to include leading spaces/tabs before the separator
  local left=$best_idx
  local ch
  while (( left > 1 )); do
    ch=${pre[left-1]}
    [[ $ch == ' ' || $ch == $'\t' ]] || break
    (( left-- ))
  done

  # Delete from "left" to "cur" (both inclusive) in the original buffer
  local keep_end=$(( left - 1 ))
  BUFFER="${buf[1,keep_end]}${buf[cur+1,-1]}"

  # Cursor goes to end of kept prefix
  CURSOR=$keep_end
}

zle -N kill_to_next_sep
zle -N kill_to_prev_sep

bindkey -r $'\eD' 2>/dev/null
bindkey -r $'\e\x7f' 2>/dev/null
bindkey $'\eD' kill_to_next_sep
bindkey $'\e\x7f' kill_to_prev_sep
