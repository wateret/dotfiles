#!/usr/bin/env bash

set -u

tmux_config_dir="${HOME}/.config/tmux"
status_parts=()

if [[ -x "${tmux_config_dir}/hai-proxy-usage.sh" ]]; then
    hai_proxy_usage="$("${tmux_config_dir}/hai-proxy-usage.sh" 2>/dev/null | sed -E 's/#\[[^]]*\]//g')"
    [[ -n "${hai_proxy_usage}" ]] && status_parts+=("${hai_proxy_usage}")
fi

host="$(hostname -s 2>/dev/null || hostname)"
status_parts+=("${host}")

cpu_script="${tmux_config_dir}/plugins/tmux-cpu/scripts/cpu_percentage.sh"
ram_script="${tmux_config_dir}/plugins/tmux-cpu/scripts/ram_percentage.sh"

cpu=""
ram=""
[[ -x "${cpu_script}" ]] && cpu="$("${cpu_script}" 2>/dev/null | tr -d '\r')"
[[ -x "${ram_script}" ]] && ram="$("${ram_script}" 2>/dev/null | tr -d '\r')"
if [[ -n "${cpu}" && -n "${ram}" ]]; then
    status_parts+=("󰍛${cpu} ${ram}")
elif [[ -n "${cpu}" ]]; then
    status_parts+=("󰍛${cpu}")
elif [[ -n "${ram}" ]]; then
    status_parts+=("${ram}")
fi

status_line=""
for part in "${status_parts[@]}"; do
    [[ -n "${status_line}" ]] && status_line+=" | "
    status_line+="${part}"
done
printf '%s\n' "${status_line}"
