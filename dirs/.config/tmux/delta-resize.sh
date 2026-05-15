#!/bin/bash
# Re-run delta when tmux pane is resized
# Called by tmux after-resize-pane hook

PANE_ID="$1"
PANE_PID=$(tmux display-message -t "$PANE_ID" -p '#{pane_pid}')

# Check if delta is anywhere in the process tree of this pane
if pstree -p "$PANE_PID" 2>/dev/null | grep -qE '[-—]delta\('; then
    # Send 'q' to quit less (delta's pager), then re-run last command
    tmux send-keys -t "$PANE_ID" q
    sleep 0.1
    tmux send-keys -t "$PANE_ID" Up Enter
fi
