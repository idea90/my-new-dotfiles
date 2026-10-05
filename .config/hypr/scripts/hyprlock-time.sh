#!/usr/bin/env bash
# Greeting line for hyprlock

hour=$(date +%H)
hour=${hour#0}

if   (( hour >= 5  && hour < 12 )); then greeting="Good morning"
elif (( hour >= 12 && hour < 18 )); then greeting="Good afternoon"
elif (( hour >= 18 && hour < 22 )); then greeting="Good evening"
else                                     greeting="Good night"
fi

echo "$greeting, $USER"
