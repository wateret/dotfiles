#!/bin/sh
# Move to a neighboring pane while preserving zoom semantics.
# In a zoomed window, briefly reveal the full layout with pane indicators
# before re-zooming the newly selected pane. In a non-zoomed window,
# this just moves panes normally.
dir="$1"
duration_ms=500

if [ "$(tmux display-message -p '#{window_zoomed_flag}')" = "1" ]; then
  # Move to another pane unzoommed
  tmux select-pane "$dir"
  # Briefly reveal the full layout and pane indicators.
  tmux display-panes -d "$duration_ms"
  tmux resize-pane -Z
else
  # Normal pane movement outside zoom mode.
  tmux select-pane "$dir"
fi
