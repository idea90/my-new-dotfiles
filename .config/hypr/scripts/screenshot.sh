#!/usr/bin/env bash
#
# Screenshots: copy to clipboard, save to ~/Pictures/Screenshots, notify
# with a thumbnail and an "Open" action.
#
#   screenshot.sh --now      focused monitor
#   screenshot.sh --area     select a region
#   screenshot.sh --win      active window
#   screenshot.sh --in5      all monitors after 5s (also --in10)

dir="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Screenshots"
file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
mkdir -p "$dir"

# Selection colors follow matugen when colors.conf has them
colors="$HOME/.config/hypr/colors.conf"
hex() { sed -n "s/^\$$1 = rgba(\([0-9a-f]\{6\}\)ff)/\1/p" "$colors" 2>/dev/null | head -n 1; }
accent="$(hex primary)"; accent="${accent:-89b4fa}"
scrim="$(hex scrim)"; scrim="${scrim:-000000}"

countdown() {
    local sec
    for (( sec = $1; sec > 0; sec-- )); do
        notify-send -h string:x-canonical-private-synchronous:shot -t 1000 -i camera-timer "Screenshot in $sec"
        sleep 1
    done
}

capture() {
    case "$1" in
        --now)
            local monitor
            monitor="$(hyprctl -j activeworkspace | jq -r '.monitor')"
            grim -o "$monitor" "$file"
            ;;
        --area)
            local region
            region="$(slurp -b "${scrim}66" -c "${accent}ff" -s "${accent}22" -w 2)" || return 1
            sleep 0.1  # let the selection overlay fade before capturing
            grim -g "$region" "$file"
            ;;
        --win)
            local geometry
            geometry="$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')"
            [[ "$geometry" == "null"* ]] && return 1
            grim -g "$geometry" "$file"
            ;;
        --in5|--in10)
            countdown "${1#--in}"
            grim "$file"
            ;;
        *)
            echo "Usage: $0 --now | --area | --win | --in5 | --in10" >&2
            exit 1
            ;;
    esac
}

# Cancelled selection or failed capture: no file, no notification
capture "$1" || exit 0
[[ -s "$file" ]] || exit 0

wl-copy --type image/png < "$file"

action="$(notify-send -a Screenshot -i "$file" -h string:x-canonical-private-synchronous:shot \
    --action=open=Open --action=folder="Show in folder" \
    "Screenshot copied" "${file/#$HOME/\~}")"

case "$action" in
    open)   xdg-open "$file" ;;
    folder) xdg-open "$dir" ;;
esac
