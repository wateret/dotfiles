#!/bin/sh
CACHE="/tmp/tmux-yolo-status"
TTL=15

# Return cached result if fresh enough
if [ -f "$CACHE" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))
  if [ "$age" -lt "$TTL" ]; then
    cat "$CACHE"
    exit 0
  fi
fi

d="$HOME/.claude/plugins/data/cc-yolo-cc-plugins"
r=$(cat "$d/plugin_root" 2>/dev/null)
s="$r/scripts/cc_stats.py"
if [ -n "$r" ] && [ -f "$s" ]; then
  v=$(python3 "$s" --log-dir "$d" --today --field utilization 2>/dev/null)
  if [ -n "$v" ]; then
    pct10=$(printf '%.0f' "$(echo "$v * 10" | bc)")
    if [ "$pct10" -ge 1000 ]; then
      color="#8be9fd"
    elif [ "$pct10" -ge 500 ]; then
      color="#50fa7b"
    elif [ "$pct10" -ge 250 ]; then
      color="#f1fa8c"
    elif [ "$pct10" -ge 125 ]; then
      color="#ffb86c"
    else
      color="#ff5555"
    fi
    vfmt=$(printf '%#.3g' "$v" | sed 's/\.$//')
    result=$(printf '#[fg=%s]🔥 %s%%' "$color" "$vfmt")
  else
    result=$(printf '#[fg=#ff5555]🔥 --%%')
  fi
else
  result=$(printf '#[fg=#ff5555]🔥 --%%')
fi

printf '%s' "$result" > "$CACHE"
printf '%s' "$result"
