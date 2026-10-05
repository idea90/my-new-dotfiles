#!/usr/bin/env bash
#
# Dotfiles setup for Arch Linux + Hyprland.
#
#   ./install.sh               full setup (packages, links, wallpapers, extras)
#   ./install.sh --links-only  only symlink configs
#   ./install.sh --dry-run     print what would happen, change nothing
#   ./install.sh --help        all options
#
# Existing configs are moved to ~/.dotfiles-backup/<timestamp>/ before linking,
# so running this again (or on a machine with configs) is safe.

set -euo pipefail

REPO="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
WALLPAPER_DIR="${WALLPAPERS_DIR:-$HOME/wallpapers}"

DRY_RUN=0
ASSUME_YES=0
DO_PACKAGES=1
DO_OPTIONAL=1
DO_LINKS=1
DO_WALLPAPERS=1
DO_EXTRAS=1

# Core: everything the configs and scripts in this repo call
PACKAGES=(
    # compositor + session
    hyprland hypridle hyprlock xdg-desktop-portal-hyprland sddm
    # bar, launcher, notifications, logout, osd
    waybar rofi swaync wlogout swayosd
    # theming
    swww matugen imagemagick papirus-icon-theme nwg-look qt5ct qt6ct
    bibata-cursor-theme-bin ttf-roboto ttf-roboto-mono-nerd
    # gtk: theme matugen colors target, settings backend, dark mode portal
    adw-gtk-theme gsettings-desktop-schemas dconf xdg-desktop-portal-gtk
    # terminal + shell
    alacritty fish starship fastfetch
    # files
    nemo gvfs
    # scripts: screenshots, audio, brightness, network, notifications
    grim slurp wl-clipboard playerctl pavucontrol brightnessctl
    networkmanager network-manager-applet libnotify jq
    python python-gobject
    # editor
    vim
)

# Optional: apps referenced by keybinds/autostart but not required to boot
OPTIONAL_PACKAGES=(
    firefox kdeconnect spotify mpv python-pywalfox linutil-bin
)

# --------------------------------------------------------------------------

if [[ -t 1 ]]; then
    C_BLUE=$'\e[34m' C_GREEN=$'\e[32m' C_YELLOW=$'\e[33m' C_RED=$'\e[31m' C_RESET=$'\e[0m'
else
    C_BLUE='' C_GREEN='' C_YELLOW='' C_RED='' C_RESET=''
fi

info() { printf '%s::%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '%s::%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s::%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()  { printf '%s::%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

# Run a command, or just print it in dry-run mode
run() {
    if (( DRY_RUN )); then
        printf '   [dry-run] %s\n' "$*"
    else
        "$@"
    fi
}

confirm() {
    (( ASSUME_YES )) && return 0
    local reply
    read -rp "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  -y, --yes          answer yes to all prompts
  -n, --dry-run      show what would be done without changing anything
      --links-only   only symlink configs (skip packages, wallpapers, extras)
      --no-packages  skip package installation
      --no-optional  skip optional apps (${OPTIONAL_PACKAGES[*]})
      --no-wallpapers  skip copying wallpapers to $WALLPAPER_DIR
      --no-extras    skip shell change, sddm and initial theme generation
  -h, --help         show this help
EOF
}

parse_args() {
    while (( $# )); do
        case "$1" in
            -y|--yes)        ASSUME_YES=1 ;;
            -n|--dry-run)    DRY_RUN=1 ;;
            --links-only)    DO_PACKAGES=0; DO_WALLPAPERS=0; DO_EXTRAS=0 ;;
            --no-packages)   DO_PACKAGES=0 ;;
            --no-optional)   DO_OPTIONAL=0 ;;
            --no-wallpapers) DO_WALLPAPERS=0 ;;
            --no-extras)     DO_EXTRAS=0 ;;
            -h|--help)       usage; exit 0 ;;
            *)               usage; die "Unknown option: $1" ;;
        esac
        shift
    done
}

preflight() {
    (( EUID != 0 )) || die "Run as your normal user, not root. sudo is used where needed."
    [[ -d "$REPO/.config" ]] || die "Can't find $REPO/.config. Run this from the dotfiles repo."
    if (( DO_PACKAGES )); then
        command -v pacman >/dev/null || die "pacman not found. Package install only supports Arch; use --no-packages."
    fi
}

# --------------------------------------------------------------------------

aur_helper() {
    local helper
    for helper in paru yay; do
        command -v "$helper" >/dev/null && { echo "$helper"; return; }
    done
}

install_aur_helper() {
    info "No AUR helper found, installing yay"
    if (( DRY_RUN )); then
        run sudo pacman -S --needed git base-devel
        run git clone https://aur.archlinux.org/yay-bin.git
        run makepkg -si
        return
    fi
    sudo pacman -S --needed --noconfirm git base-devel
    local tmp
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
}

install_packages() {
    local helper
    helper="$(aur_helper)"
    if [[ -z "$helper" ]]; then
        install_aur_helper
        helper=yay
    fi

    local pkgs=("${PACKAGES[@]}")
    if (( DO_OPTIONAL )); then
        pkgs+=("${OPTIONAL_PACKAGES[@]}")
    fi

    info "Installing ${#pkgs[@]} packages with $helper"
    local flags=(-Syu --needed)
    if (( ASSUME_YES )); then flags+=(--noconfirm); fi
    run "$helper" "${flags[@]}" "${pkgs[@]}"
}

# --------------------------------------------------------------------------

# Link $1 to $2, moving anything already at $2 into the backup dir
link() {
    local src="$1" dest="$2"

    if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
        printf '   ok      %s\n' "${dest/#$HOME/\~}"
        return
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        local backup="$BACKUP_DIR/${dest#"$HOME"/}"
        run mkdir -p "$(dirname "$backup")"
        run mv "$dest" "$backup"
        printf '   backup  %s -> %s\n' "${dest/#$HOME/\~}" "${backup/#$HOME/\~}"
    fi

    run mkdir -p "$(dirname "$dest")"
    run ln -s "$src" "$dest"
    printf '   link    %s\n' "${dest/#$HOME/\~}"
}

link_configs() {
    info "Linking configs into ${CONFIG_HOME/#$HOME/\~}"
    local src name
    for src in "$REPO"/.config/*; do
        name="$(basename "$src")"
        case "$name" in
            # Apps write their own files here (bookmarks, nwg-look state),
            # so link our files individually instead of taking the folder
            gtk-3.0|gtk-4.0)
                local file
                for file in "$src"/*; do
                    link "$file" "$CONFIG_HOME/$name/$(basename "$file")"
                done
                ;;
            *)
                link "$src" "$CONFIG_HOME/$name"
                ;;
        esac
    done

    if [[ -d "$REPO/.themes" ]]; then
        info "Linking GTK themes into ~/.themes"
        for src in "$REPO"/.themes/*; do
            link "$src" "$HOME/.themes/$(basename "$src")"
        done
    fi

    # Scripts must be executable for keybinds to work
    run find "$REPO/.config" -type f \( -name '*.sh' -o -name '*.py' -o -name 'apply-wal' \) -exec chmod +x {} +

    if [[ -d "$BACKUP_DIR" ]]; then
        warn "Old configs saved in ${BACKUP_DIR/#$HOME/\~}"
    fi
}

# --------------------------------------------------------------------------

copy_wallpapers() {
    [[ -d "$REPO/Wallpapers" ]] || { warn "No Wallpapers/ in repo, skipping"; return; }
    info "Copying wallpapers to ${WALLPAPER_DIR/#$HOME/\~} (existing files kept)"
    run mkdir -p "$WALLPAPER_DIR"
    run cp -r --update=none "$REPO/Wallpapers/." "$WALLPAPER_DIR/"
}

# Lock screen reads a blurred copy of the current wallpaper. Create one so
# hyprlock has a background before the first Super+W.
seed_lockscreen() {
    local blurred="$HOME/.cache/blurred-wallpaper.png"
    [[ -f "$blurred" ]] && return 0
    [[ -d "$WALLPAPER_DIR" ]] || return 0
    command -v magick >/dev/null || { warn "imagemagick missing, skipping lock screen background"; return 0; }

    local first
    first="$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | sort | head -n 1 || true)"
    [[ -n "$first" ]] || return 0

    info "Creating lock screen background from $(basename "$first")"
    run mkdir -p "$HOME/.cache"
    run cp "$first" "$HOME/.cache/normal-wallpaper.png"
    run magick "$first" -resize 1280x720 -blur 0x8 "$blurred"
    if (( ! DRY_RUN )); then echo "$first" > "$HOME/.cache/current_wallpaper"; fi
}

# Push theme/icons/cursor/font into gsettings (what GTK reads on Wayland) and
# let Flatpak apps see the generated GTK colors.
apply_gtk_settings() {
    local script="$REPO/.config/hypr/scripts/gtk-settings.sh"
    if command -v gsettings >/dev/null; then
        info "Applying GTK settings"
        run "$script" || warn "Couldn't write gsettings (no session bus?). It runs again on Hyprland start."
    fi

    if command -v flatpak >/dev/null; then
        info "Letting Flatpak apps read GTK colors"
        run flatpak override --user \
            --filesystem=xdg-config/gtk-3.0:ro \
            --filesystem=xdg-config/gtk-4.0:ro
    fi
}

set_fish_shell() {
    local fish_path user
    fish_path="$(command -v fish || true)"
    user="$(id -un)"
    [[ -n "$fish_path" ]] || return 0
    [[ "$(getent passwd "$user" | cut -d: -f7)" == "$fish_path" ]] && return 0

    if confirm "Make fish your default shell?"; then
        grep -qx "$fish_path" /etc/shells || run sudo sh -c "echo '$fish_path' >> /etc/shells"
        run chsh -s "$fish_path"
    fi
}

enable_services() {
    if systemctl list-unit-files NetworkManager.service >/dev/null 2>&1 \
        && ! systemctl is-enabled --quiet NetworkManager 2>/dev/null; then
        info "Enabling NetworkManager"
        run sudo systemctl enable --now NetworkManager
    fi

    if systemctl list-unit-files sddm.service >/dev/null 2>&1 \
        && ! systemctl is-enabled --quiet sddm 2>/dev/null; then
        if confirm "Enable sddm login manager? (disable any other display manager first)"; then
            run sudo systemctl enable sddm
        fi
    fi
}

# --------------------------------------------------------------------------

main() {
    parse_args "$@"
    preflight
    if (( DRY_RUN )); then warn "Dry run: nothing will be changed"; fi

    if (( DO_PACKAGES ));   then install_packages; fi
    if (( DO_LINKS ));      then link_configs; fi
    if (( DO_WALLPAPERS )); then copy_wallpapers; fi
    if (( DO_EXTRAS )); then
        seed_lockscreen
        apply_gtk_settings
        set_fish_shell
        enable_services
    fi

    ok "Done. Log out and pick Hyprland, then press Super+W to choose a wallpaper and generate colors."
}

main "$@"
