#!/usr/bin/env bash

setfg() { printf '\e[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
setbg() { printf '\e[48;2;%d;%d;%dm' "$1" "$2" "$3"; }
rst()   { printf '\e[0m'; }
bld()   { printf '\e[1m'; }

# Dracula palette
BG=(40 42 54)
SEL=(68 71 90)
FG=(248 248 242)
CMT=(98 114 164)
GREEN=(80 250 123)

bar() {
  local label=$1 cr=$2 cg=$3 cb=$4

  # status-left (green bg, dark fg)
  setfg "${BG[@]}"; setbg "${GREEN[@]}"; bld
  printf "  mysession "
  rst; setfg "${CMT[@]}"; setbg "${BG[@]}"
  printf " "

  # inactive window
  setfg "${FG[@]}"; setbg "${SEL[@]}"
  printf " 1 zsh "
  rst; setfg "${CMT[@]}"; setbg "${BG[@]}"
  printf " "

  # current window (candidate color)
  setfg "${BG[@]}"; setbg "$cr" "$cg" "$cb"; bld
  printf " 2 nvim "
  rst; setfg "${CMT[@]}"; setbg "${BG[@]}"
  printf " "

  # inactive window
  setfg "${FG[@]}"; setbg "${SEL[@]}"
  printf " 3 bash "
  rst

  # label at end
  setfg "${CMT[@]}"; setbg "${BG[@]}"
  printf "   %s" "$label"
  rst
  printf "\n"
}

# full-width bg fill per row
row() {
  local label=$1 cr=$2 cg=$3 cb=$4
  setbg "${BG[@]}"
  printf "  "
  bar "$label" "$cr" "$cg" "$cb"
  rst
  printf "\n"
}

printf "\n"
setfg "${FG[@]}"
printf "  Dracula · current-window bg preview\n"
printf "  "
printf '%0.s─' {1..54}
printf "\n\n"
rst

row "#5ab3c8  (original)"   90 179 200
row "#bd93f9  purple  ◀ now" 189 147 249
row "#8be9fd  cyan"          139 233 253
row "#50fa7b  green"          80 250 123
row "#ff79c6  pink"          255 121 198
row "#f1fa8c  yellow"        241 250 140

printf "\n"
