#!/bin/bash

# Kill any existing instances of Waybar
killall waybar

# Change directory to where your Waybar configuration files are located
cd "$(dirname "$(readlink -f "$0")")" || exit 1

# Launch Waybar with specified configuration and style
waybar -c config.jsonc -s style.css
