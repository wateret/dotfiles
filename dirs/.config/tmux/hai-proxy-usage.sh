#!/usr/bin/env bash
# usage: hai-proxy-usage.sh [--ttl N] [--daily-warn N] [--monthly-warn N]
TTL=30; D_THRESH=40; M_THRESH=800
while [[ $# -gt 0 ]]; do
  case $1 in
    --ttl)          TTL=$2;        shift 2 ;;
    --daily-warn)   D_THRESH=$2;   shift 2 ;;
    --monthly-warn) M_THRESH=$2;   shift 2 ;;
    *) shift ;;
  esac
done

CACHE="$HOME/.cache/tmux-hai-proxy-usage"
NOW=$(date +%s)

if [[ -f "$CACHE" ]]; then
  MTIME=$(stat -c %Y "$CACHE" 2>/dev/null || stat -f %m "$CACHE" 2>/dev/null)
  if (( NOW - MTIME < TTL )); then
    cat "$CACHE"
    exit 0
  fi
fi

dim='#[fg=#6272a4]'
reset='#[default]'

if ! tmux has-session -t hai-proxy 2>/dev/null; then
  OUT="${dim}HAI Proxy off${reset}"
  echo -n "$OUT" > "$CACHE"
  echo -n "$OUT"
  exit 0
fi

RAW=$(tmux capture-pane -t hai-proxy:1.1 -p 2>/dev/null)

DAILY=$(printf '%s\n' "$RAW"   | grep -oP 'Daily\s+€\K[0-9.]+(?=\s*/\s*€[0-9.]+)')
MONTHLY=$(printf '%s\n' "$RAW" | grep -oP 'Monthly\s+€\K[0-9.]+(?=\s*/\s*€[0-9.]+)')

if [[ -z "$DAILY" && -z "$MONTHLY" ]]; then
  OUT="${dim}HAI Proxy err${reset}"
  echo -n "$OUT" > "$CACHE"
  echo -n "$OUT"
  exit 0
fi

cyan='#[fg=#8be9fd]'
yellow='#[fg=#f1fa8c]'

fmt() {
  python3 -c "v=float('${1:-0}'); print('{:.2f}'.format(v) if v<10 else '{:.1f}'.format(v) if v<100 else '{:.0f}'.format(v))"
}

dc=$cyan
mc=$cyan
(( $(echo "$DAILY >= $D_THRESH"   | bc -l) )) && dc=$yellow
(( $(echo "$MONTHLY >= $M_THRESH" | bc -l) )) && mc=$yellow

OUT="${dc}€$(fmt "$DAILY")${reset} ${mc}€$(fmt "$MONTHLY")${reset}"
echo -n "$OUT" > "$CACHE"
echo -n "$OUT"
