#!/bin/bash
#  ____
# |  _ \ _____      _____ _ __
# | |_) / _ \ \ /\ / / _ \ '__|
# |  __/ (_) \ V  V /  __/ |
# |_|   \___/ \_/\_/ \___|_|
#

case "$1" in
    exit)
        echo ":: Exit"
        sleep 0.5
        hyprctl dispatch exit
        ;;
    lock)
        echo ":: Lock"
        sleep 0.5
        hyprlock
        ;;
    reboot)
        echo ":: Reboot"
        sleep 0.5
        systemctl reboot
        ;;
    shutdown)
        echo ":: Shutdown"
        sleep 0.5
        systemctl poweroff
        ;;
    suspend)
        echo ":: Suspend"
        sleep 0.5
        systemctl suspend
        ;;
    hibernate)
        echo ":: Hibernate"
        sleep 1
        systemctl hibernate
        ;;
    *)
        echo "Usage: $0 {exit|lock|reboot|shutdown|suspend|hibernate}" >&2
        exit 1
        ;;
esac
