#!/usr/bin/env bash
#
# Sync GTK theme, icons, cursor, font and dark/light preference.
#
# On Wayland GTK ignores settings.ini and reads gsettings (dconf), which is
# why nwg-look/lxappearance changes often "don't stick". This sets both.
#
#   gtk-settings.sh            use MODE from .env (written by apply-wal), default dark
#   gtk-settings.sh light      force a mode
#   gtk-settings.sh --reload   also make running GTK 3 apps reload colors.css

SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

ICON_DARK="Papirus-Dark"
ICON_LIGHT="Papirus-Light"
CURSOR_THEME="Bibata-Modern-Ice"
CURSOR_SIZE=24
FONT="Roboto 10"
MONO_FONT="RobotoMono Nerd Font 10"

MODE=""
RELOAD=0
for arg in "$@"; do
    case "$arg" in
        dark|light) MODE="$arg" ;;
        --reload)   RELOAD=1 ;;
        *) echo "Usage: $0 [dark|light] [--reload]" >&2; exit 1 ;;
    esac
done

if [[ -z "$MODE" ]]; then
    [[ -f "$SCRIPT_PATH/.env" ]] && MODE="$(sed -n 's/^MODE=//p' "$SCRIPT_PATH/.env")"
    MODE="${MODE:-dark}"
fi

if [[ "$MODE" == "light" ]]; then
    gtk_theme="adw-gtk3"
    icon_theme="$ICON_LIGHT"
    color_scheme="prefer-light"
else
    gtk_theme="adw-gtk3-dark"
    icon_theme="$ICON_DARK"
    color_scheme="prefer-dark"
fi

command -v gsettings >/dev/null || { echo "gsettings not found (install glib2)" >&2; exit 1; }

schema="org.gnome.desktop.interface"

# GTK 3 only re-reads gtk.css when the theme name changes, so bounce it
if (( RELOAD )); then
    gsettings set "$schema" gtk-theme "Adwaita"
    sleep 0.1
fi

gsettings set "$schema" gtk-theme "$gtk_theme"
gsettings set "$schema" color-scheme "$color_scheme"   # libadwaita / GTK 4 dark mode
gsettings set "$schema" icon-theme "$icon_theme"
gsettings set "$schema" cursor-theme "$CURSOR_THEME"
gsettings set "$schema" cursor-size "$CURSOR_SIZE"
gsettings set "$schema" font-name "$FONT"
gsettings set "$schema" document-font-name "$FONT"
gsettings set "$schema" monospace-font-name "$MONO_FONT"
