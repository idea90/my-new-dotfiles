#!/usr/bin/env bash
#
# The color files matugen writes (hypr/colors.conf, quickshell/colors.json, ...) are
# generated, not tracked. If any are missing, create them from a fixed color so
# Hyprland, Quickshell and the terminal always have a palette. Super+W replaces them.
#
#   seed-colors.sh [hex]    default #ea1a17

files=(
    "$HOME/.config/hypr/colors.conf"
    "$HOME/.config/alacritty/colors.toml"
    "$HOME/.config/gtk-3.0/colors.css"
    "$HOME/.config/gtk-4.0/colors.css"
    "$HOME/.config/starship/starship.toml"
    "$HOME/.config/quickshell/colors.json"
)

for f in "${files[@]}"; do
    [[ -f "$f" ]] || exec matugen color hex "${1:-#ea1a17}" -m dark --continue-on-error
done
