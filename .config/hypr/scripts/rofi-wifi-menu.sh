#!/usr/bin/env bash

notify-send "Getting list of available Wi-Fi networks..."

# Get the currently connected Wi-Fi SSID
current_connection=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2)
if [[ -n "$current_connection" ]]; then
    current_display="󰤨  Connected: $current_connection"
else
    current_display="󰤭  No active connection"
fi

# Get a list of available Wi-Fi connections with signal strength
nmcli --fields "SECURITY,SSID,SIGNAL" device wifi rescan &>/dev/null
wifi_list=$(nmcli --fields "SECURITY,SSID,SIGNAL" device wifi list | sed 1d | sed 's/  */ /g' | \
  sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d" | \
  awk '{printf "%s %s (%s%%)\n", $1, $2, $3}')

# Get Wi-Fi radio state
connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
    toggle="󰖪  Disable Wi-Fi"
elif [[ "$connected" =~ "disabled" ]]; then
    toggle="󰖩  Enable Wi-Fi"
fi

# Add refresh option
refresh_option="󰋑  Refresh Wi-Fi"

# Use rofi to select Wi-Fi network
chosen_network=$(echo -e "$current_display\n$toggle\n$refresh_option\n$wifi_list" | uniq -u | wofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " )

# Extract only the SSID (second column)
read -r chosen_id <<< "$(echo "$chosen_network" | awk '{print $2}')"

if [ -z "$chosen_network" ]; then
    exit
elif [ "$chosen_network" = "󰖩  Enable Wi-Fi" ]; then
    nmcli radio wifi on
elif [ "$chosen_network" = "󰖪  Disable Wi-Fi" ]; then
    nmcli radio wifi off
elif [ "$chosen_network" = "󰋑  Refresh Wi-Fi" ]; then
    exec "$0"
elif [[ "$chosen_network" =~ "Forget:" ]]; then
    nmcli connection delete id "$chosen_id"
    notify-send "Network Removed" "The Wi-Fi network \"$chosen_id\" has been forgotten."
else
    # Message to show when connection is activated successfully
    success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
    # Get saved connections
    saved_connections=$(nmcli -g NAME connection)
    if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
        nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
    else
        if [[ "$chosen_network" =~ "" ]]; then
            wifi_password=$(wofi -dmenu -p "Password: " )
        fi
        if ! nmcli device wifi connect "$chosen_id" password "$wifi_password"; then
            notify-send "Connection Failed" "Unable to connect to \"$chosen_id\". Please check your password."
        else
            notify-send "Connection Established" "$success_message"
        fi
    fi
fi

