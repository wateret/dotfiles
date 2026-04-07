#!/bin/sh
w=$(tmux list-windows -F '#I #F' 2>/dev/null | grep '!' | cut -d ' ' -f 1 | head -n 1)
if [ -n "$w" ]; then
  tmux select-window -t "$w" 2>/dev/null || tmux display-message "Failed to switch to window $w"
else
  tmux display-message "No bell window"
fi
