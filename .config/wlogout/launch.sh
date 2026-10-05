#!/usr/bin/env bash
# Power menu centered on the focused monitor.
# Running it again closes the menu.

pkill -x wlogout && exit 0

width=1920
height=1080
scale=1
if command -v hyprctl >/dev/null && command -v jq >/dev/null; then
    read -r width height scale < <(hyprctl monitors -j | jq -r '.[] | select(.focused) | "\(.width) \(.height) \(.scale)"')
fi

# Buttons are 180px wide (style.css) with 12px gaps and ~220px tall.
# Use one row of 6 when it fits, otherwise two rows of 3.
read -r per_row margin_x margin_y < <(awk -v w="$width" -v h="$height" -v s="$scale" 'BEGIN {
    lw = w / s; lh = h / s
    n = (lw >= 6 * 180 + 5 * 12 + 40) ? 6 : 3
    rows = 6 / n
    x = (lw - (n * 180 + (n - 1) * 12)) / 2
    y = (lh - (rows * 220 + (rows - 1) * 12)) / 2
    printf "%d %d %d\n", n, (x > 0 ? x : 0), (y > 0 ? y : 0)
}')

exec wlogout \
    --buttons-per-row "$per_row" \
    --column-spacing 12 \
    --row-spacing 12 \
    --margin-left "$margin_x" \
    --margin-right "$margin_x" \
    --margin-top "$margin_y" \
    --margin-bottom "$margin_y" \
    --protocol layer-shell
