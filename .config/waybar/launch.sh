#!/bin/bash

# Kill any existing instances of Waybar
killall waybar

# Change directory to where your Waybar configuration files are located
cd /home/idea/.config/waybar/pywal-float-without-background

# Launch Waybar with specified configuration and style
waybar -c config.jsonc -s style.css
