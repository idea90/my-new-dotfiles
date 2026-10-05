#!/usr/bin/env bash
# Battery for hyprlock; prints nothing on machines without one

bat=$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' | head -n 1)
[[ -n "$bat" ]] || exit 0

capacity=$(<"$bat/capacity")
status=$(<"$bat/status")

icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂)
idx=$(( capacity / 11 ))
(( idx > 8 )) && idx=8

if [[ "$status" == "Charging" ]]; then
    icon="󰂄"
else
    icon="${icons[idx]}"
fi

echo "$icon  $capacity%"
