#!/usr/bin/env bash
TTL=10
CACHE="$HOME/.cache/tmux-hai-proxy-usage"
NOW=$(date +%s)

if [[ -f "$CACHE" ]]; then
  MTIME=$(stat -c %Y "$CACHE" 2>/dev/null || stat -f %m "$CACHE" 2>/dev/null)
  (( NOW - MTIME < TTL )) && { cat "$CACHE"; exit 0; }
fi

dim='#[fg=#6272a4]'
reset='#[default]'
cyan='#[fg=#8be9fd]'
yellow='#[fg=#f1fa8c]'

TOKEN=$(jq -r '.env.ANTHROPIC_AUTH_TOKEN' "$HOME/.claude/settings.json" 2>/dev/null)
HAI_PORT=${HAI_PROXY_PORT:-6666}
BASE="http://localhost:${HAI_PORT}/client-api/v1/me"

if [[ -z "$TOKEN" ]]; then
  OUT="${dim}HAI no token${reset}"
  echo -n "$OUT" > "$CACHE"; echo -n "$OUT"; exit 0
fi

COSTS=$(curl -sf --max-time 3 -H "Authorization: Bearer $TOKEN" "$BASE/costs" 2>/dev/null)
if [[ -z "$COSTS" ]]; then
  OUT="${dim}HAI off${reset}"
  echo -n "$OUT" > "$CACHE"; echo -n "$OUT"; exit 0
fi

CAPS=$(curl -sf --max-time 3 -H "Authorization: Bearer $TOKEN" "$BASE/caps" 2>/dev/null)

DAILY=$(  printf '%s' "$COSTS" | jq -r '.current_day_eur   // empty')
MONTHLY=$(printf '%s' "$COSTS" | jq -r '.current_month_eur // empty')
D_LIM=$(  printf '%s' "$CAPS"  | jq -r '.daily_limit_eur   // 50')
M_LIM=$(  printf '%s' "$CAPS"  | jq -r '.monthly_limit_eur // 500')

fmt() {
  python3 -c "v=float('${1:-0}'); print('{:.2f}'.format(v) if v<10 else '{:.1f}'.format(v) if v<100 else '{:.0f}'.format(v))"
}

dc=$cyan; mc=$cyan
(( $(echo "$DAILY   >= $D_LIM * 0.8" | bc -l) )) && dc=$yellow
(( $(echo "$MONTHLY >= $M_LIM * 0.8" | bc -l) )) && mc=$yellow

OUT="${dc}€$(fmt "$DAILY")${reset} ${mc}€$(fmt "$MONTHLY")${reset}"
echo -n "$OUT" > "$CACHE"; echo -n "$OUT"
