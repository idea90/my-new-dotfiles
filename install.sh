#!/usr/bin/env bash
#
# Kaleido: dotfiles setup for Arch Linux + Hyprland.
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
SEED_COLOR="#ea1a17"   # starter theme until the first wallpaper is picked

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
    hyprland hypridle hyprlock xdg-desktop-portal-hyprland hyprpolkitagent sddm
    # bar, launcher, notifications, logout, osd
    quickshell upower
    # theming
    awww matugen imagemagick papirus-icon-theme nwg-look qt5ct qt6ct
    bibata-cursor-theme-bin ttf-roboto ttf-roboto-mono-nerd
    # gtk: theme matugen colors target, settings backend, dark mode portal
    adw-gtk-theme gsettings-desktop-schemas dconf xdg-desktop-portal-gtk
    # terminal + shell
    alacritty fish starship fastfetch
    # files
    thunar thunar-archive-plugin thunar-volman tumbler gvfs
    # scripts: screenshots, audio, brightness, network, notifications
    curl grim slurp wl-clipboard playerctl cliphist wtype hyprsunset power-profiles-daemon bluez bluez-utils pavucontrol brightnessctl btop
    pipewire pipewire-pulse wireplumber
    networkmanager network-manager-applet libnotify jq xdg-user-dirs xdg-utils
    python python-gobject
    # editor
    vim
)

# Optional: apps referenced by keybinds/autostart but not required to boot
OPTIONAL_PACKAGES=(
    firefox kdeconnect spotify mpv python-pywalfox linutil-bin
)

# --------------------------------------------------------------------------

# Colors only on a terminal, and never with NO_COLOR set (https://no-color.org)
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    C_BLUE=$'\e[34m' C_GREEN=$'\e[32m' C_YELLOW=$'\e[33m' C_RED=$'\e[31m' C_MAGENTA=$'\e[35m'
    C_CYAN=$'\e[36m' C_BOLD=$'\e[1m' C_DIM=$'\e[2m' C_RESET=$'\e[0m'
else
    C_BLUE='' C_GREEN='' C_YELLOW='' C_RED='' C_MAGENTA='' C_CYAN='' C_BOLD='' C_DIM='' C_RESET=''
fi

info() { printf '  %s•%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '  %s✔%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; WARNINGS=$((WARNINGS + 1)); }
die()  { printf '\n  %s✘ %s%s\n\n' "$C_RED$C_BOLD" "$*" "$C_RESET" >&2; exit 1; }

WARNINGS=0
STEP=0
STEPS=0

banner() {
    printf '\n'
    printf '%s _         _      _     _       %s\n' "$C_MAGENTA$C_BOLD" "$C_RESET"
    printf '%s| | ____ _| | ___(_) __| | ___  %s\n' "$C_MAGENTA$C_BOLD" "$C_RESET"
    printf '%s| |/ / _` | |/ _ \\ |/ _` |/ _ \\ %s\n' "$C_BLUE$C_BOLD" "$C_RESET"
    printf '%s|   < (_| | |  __/ | (_| | (_) |%s\n' "$C_BLUE$C_BOLD" "$C_RESET"
    printf '%s|_|\\_\\__,_|_|\\___|_|\\__,_|\\___/ %s\n' "$C_CYAN$C_BOLD" "$C_RESET"
    printf '\n  %sKaleido · a Hyprland + Quickshell desktop that follows your wallpaper%s\n' "$C_DIM" "$C_RESET"
    printf '  %s%s@%s · %s%s\n' "$C_DIM" "$(id -un)" "$(uname -n)" "${REPO/#$HOME/\~}" "$C_RESET"
}

# Numbered section header: step "Packages"
step() {
    STEP=$((STEP + 1))
    printf '\n%s[%d/%d]%s %s%s%s\n' "$C_MAGENTA$C_BOLD" "$STEP" "$STEPS" "$C_RESET" "$C_BOLD" "$1" "$C_RESET"
}

# What the run will do, before anything changes
plan() {
    local mark
    mark() { (( $1 )) && printf '%s✔%s' "$C_GREEN" "$C_RESET" || printf '%s·%s' "$C_DIM" "$C_RESET"; }
    printf '\n  %sThis will:%s\n' "$C_BOLD" "$C_RESET"
    printf '    %s install packages %s\n' "$(mark "$DO_PACKAGES")" \
        "$( (( DO_PACKAGES )) && printf '%s(%d core%s)%s' "$C_DIM" "${#PACKAGES[@]}" \
            "$( (( DO_OPTIONAL )) && printf ' + %d optional' "${#OPTIONAL_PACKAGES[@]}")" "$C_RESET")"
    printf '    %s link configs into %s %s(old ones are backed up)%s\n' "$(mark "$DO_LINKS")" \
        "${CONFIG_HOME/#$HOME/\~}" "$C_DIM" "$C_RESET"
    printf '    %s copy wallpapers to %s\n' "$(mark "$DO_WALLPAPERS")" "${WALLPAPER_DIR/#$HOME/\~}"
    printf '    %s fonts, GTK/Qt theming, shell and login screen\n' "$(mark "$DO_EXTRAS")"
    if (( DRY_RUN )); then
        printf '\n  %sDry run: nothing will be changed.%s\n' "$C_YELLOW" "$C_RESET"
    fi
}

summary() {
    local secs=$((SECONDS))
    local line
    line="$(printf '─%.0s' {1..58})"
    printf '\n%s╭%s╮%s\n' "$C_GREEN" "$line" "$C_RESET"
    if (( DRY_RUN )); then
        printf '%s│%s  %-56s%s│%s\n' "$C_GREEN" "$C_BOLD" "Dry run finished, nothing was changed" "$C_RESET$C_GREEN" "$C_RESET"
    else
        printf '%s│%s  %-56s%s│%s\n' "$C_GREEN" "$C_BOLD" "All set! ($((secs / 60))m $((secs % 60))s)" "$C_RESET$C_GREEN" "$C_RESET"
    fi
    if (( WARNINGS )); then
        printf '%s│%s  %-56s%s│%s\n' "$C_GREEN" "$C_YELLOW" "$WARNINGS warning(s) above, worth a look" "$C_GREEN" "$C_RESET"
    fi
    printf '%s├%s┤%s\n' "$C_GREEN" "$line" "$C_RESET"
    printf '%s│%s  %-56s%s│%s\n' "$C_GREEN" "$C_RESET" "1. Log out and pick Hyprland" "$C_GREEN" "$C_RESET"
    printf '%s│%s  %-56s%s│%s\n' "$C_GREEN" "$C_RESET" "2. Super+W   pick a wallpaper (colors follow it)" "$C_GREEN" "$C_RESET"
    printf '%s│%s  %-56s%s│%s\n' "$C_GREEN" "$C_RESET" "3. Super+I   settings: looks, bar, launcher, lock..." "$C_GREEN" "$C_RESET"
    printf '%s│%s  %-56s%s│%s\n' "$C_GREEN" "$C_RESET" "   Super+D   apps,  Super+N   control center" "$C_GREEN" "$C_RESET"
    if [[ -d "$BACKUP_DIR" ]]; then
        printf '%s│%s  %-56s%s│%s\n' "$C_GREEN" "$C_DIM" "Old configs: ${BACKUP_DIR/#$HOME/\~}" "$C_RESET$C_GREEN" "$C_RESET"
    fi
    printf '%s╰%s╯%s\n\n' "$C_GREEN" "$line" "$C_RESET"
}

# Run a command, or just print it in dry-run mode
run() {
    if (( DRY_RUN )); then
        printf '    %s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"
    else
        "$@"
    fi
}

# confirm "Question?"       default no
# confirm "Question?" yes   default yes
confirm() {
    (( ASSUME_YES )) && return 0
    local reply hint="[y/N]"
    [[ "${2:-}" == yes ]] && hint="[Y/n]"
    printf '  %s?%s %s %s%s%s ' "$C_CYAN$C_BOLD" "$C_RESET" "$1" "$C_DIM" "$hint" "$C_RESET"
    read -r reply
    if [[ "${2:-}" == yes ]]; then
        [[ ! "$reply" =~ ^[Nn]$ ]]
    else
        [[ "$reply" =~ ^[Yy]$ ]]
    fi
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
        printf '    %s✔ ok    %s %s%s%s\n' "$C_DIM" "$C_RESET" "$C_DIM" "${dest/#$HOME/\~}" "$C_RESET"
        return
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        local backup="$BACKUP_DIR/${dest#"$HOME"/}"
        run mkdir -p "$(dirname "$backup")"
        run mv "$dest" "$backup"
        printf '    %s↺ backup%s %s %s→ %s%s\n' "$C_YELLOW" "$C_RESET" "${dest/#$HOME/\~}" "$C_DIM" "${backup/#$HOME/\~}" "$C_RESET"
    fi

    run mkdir -p "$(dirname "$dest")"
    run ln -s "$src" "$dest"
    printf '    %s→ link  %s %s\n' "$C_GREEN" "$C_RESET" "${dest/#$HOME/\~}"
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

    # Scripts must be executable for keybinds to work
    run find "$REPO/.config" -type f \( -name '*.sh' -o -name '*.py' -o -name 'apply-wal' \) -exec chmod +x {} +

    if [[ -d "$BACKUP_DIR" ]]; then
        info "Old configs saved in ${BACKUP_DIR/#$HOME/\~}"
    fi

    seed_colors
}

# Color files (hypr/colors.conf, quickshell/colors.json, ...) are generated by matugen
# and not tracked. Create a first set from a fixed color so everything starts
# themed; Super+W replaces it with colors from the chosen wallpaper.
seed_colors() {
    if ! command -v matugen >/dev/null; then
        warn "matugen missing, colors will be generated on the first Super+W"
        return 0
    fi
    info "Generating starter colors if any are missing"
    run "$REPO/.config/hypr/scripts/seed-colors.sh" "$SEED_COLOR" \
        || warn "matugen reported errors (hooks need a running session); colors were still written"
}

# --------------------------------------------------------------------------

copy_wallpapers() {
    [[ -d "$REPO/Wallpapers" ]] || { info "No Wallpapers/ folder in the repo, skipping"; return; }
    info "Copying wallpapers to ${WALLPAPER_DIR/#$HOME/\~} (existing files kept)"
    run mkdir -p "$WALLPAPER_DIR"
    run cp -r --update=none "$REPO/Wallpapers/." "$WALLPAPER_DIR/"
}

# Clock fonts for the Quickshell lock screen styles (Google Fonts, OFL). Downloaded into
# ~/.local/share/fonts/google; files already there are skipped, failures only warn.
GOOGLE_FONTS=(
    "outfit/Outfit[wght].ttf"
    "spacegrotesk/SpaceGrotesk[wght].ttf"
    "bebasneue/BebasNeue-Regular.ttf"
    "playfairdisplay/PlayfairDisplay[wght].ttf"
    "poppins/Poppins-Thin.ttf"
    "poppins/Poppins-Light.ttf"
    "poppins/Poppins-SemiBold.ttf"
    "poppins/Poppins-Black.ttf"
    "unbounded/Unbounded[wght].ttf"
    "sora/Sora[wght].ttf"
)

install_fonts() {
    command -v curl >/dev/null || { warn "curl missing, skipping fonts"; return 0; }
    local dir="$HOME/.local/share/fonts/google"
    local base="https://github.com/google/fonts/raw/main/ofl"
    local path name url added=0
    info "Installing clock fonts to ${dir/#$HOME/\~}"
    run mkdir -p "$dir"
    for path in "${GOOGLE_FONTS[@]}"; do
        name="${path##*/}"
        [[ -s "$dir/$name" ]] && continue
        url="$base/${path//\[/%5B}"
        url="${url//\]/%5D}"
        # .part + rename: a cut-off download never leaves a broken font behind
        if run curl -fsSL --retry 3 -m 240 -o "$dir/$name.part" "$url" && run mv -f "$dir/$name.part" "$dir/$name"; then
            added=1
        else
            run rm -f "$dir/$name.part"
            warn "Could not download $name (lock screen clock falls back to the default font)"
        fi
    done
    if (( added )); then
        run fc-cache -f "$dir"
        ok "Fonts installed"
    else
        ok "Fonts already installed"
    fi
}

# Lock screen reads a PNG copy of the current wallpaper (it blurs it itself). Create one so
# hyprlock has a background before the first Super+W.
seed_lockscreen() {
    local lock_image="$HOME/.cache/lockscreen.png"
    [[ -f "$lock_image" ]] && return 0
    [[ -d "$WALLPAPER_DIR" ]] || return 0
    command -v magick >/dev/null || { warn "imagemagick missing, skipping lock screen background"; return 0; }

    local first
    first="$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | sort | head -n 1 || true)"
    [[ -n "$first" ]] || return 0

    info "Creating lock screen background from $(basename "$first")"
    run mkdir -p "$HOME/.cache"
    run cp "$first" "$HOME/.cache/normal-wallpaper.png"
    run magick "$first" -resize "2560x2560>" "$lock_image"
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

# Point qt5ct/qt6ct at the matugen palette. Written once (needs absolute
# paths), so later changes made in the qt*ct GUIs are kept.
setup_qt() {
    local ver conf
    for ver in 5 6; do
        conf="$CONFIG_HOME/qt${ver}ct/qt${ver}ct.conf"
        [[ -f "$conf" ]] && continue
        info "Writing ${conf/#$HOME/\~}"
        if (( DRY_RUN )); then
            printf '    %s[dry-run]%s write %s\n' "$C_DIM" "$C_RESET" "$conf"
            continue
        fi
        mkdir -p "$(dirname "$conf")"
        printf '%s\n' \
            "[Appearance]" \
            "color_scheme_path=$CONFIG_HOME/qt${ver}ct/colors/matugen.conf" \
            "custom_palette=true" \
            "icon_theme=Papirus-Dark" \
            "standard_dialogs=default" \
            "style=Fusion" > "$conf"
    done
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

    local svc
    for svc in bluetooth power-profiles-daemon; do
        if systemctl list-unit-files "$svc.service" >/dev/null 2>&1 \
            && ! systemctl is-enabled --quiet "$svc" 2>/dev/null; then
            info "Enabling $svc"
            run sudo systemctl enable --now "$svc"
        fi
    done

    if systemctl list-unit-files sddm.service >/dev/null 2>&1 \
        && ! systemctl is-enabled --quiet sddm 2>/dev/null; then
        if confirm "Enable sddm login manager? (disable any other display manager first)"; then
            run sudo systemctl enable sddm
        fi
    fi

    if [[ -d /usr/share/sddm && ! -d /usr/share/sddm/themes/qs-theme ]] \
        && command -v magick >/dev/null && command -v jq >/dev/null; then
        if confirm "Install the login screen theme that matches the lock screen?"; then
            run "$HOME/.config/hypr/scripts/sddm-theme" install
        fi
    fi
}

# --------------------------------------------------------------------------

main() {
    parse_args "$@"
    banner
    preflight

    STEPS=$((DO_PACKAGES + DO_LINKS + DO_WALLPAPERS + DO_EXTRAS * 3))
    (( STEPS )) || die "Nothing to do with these options."
    plan
    printf '\n'
    if (( ! DRY_RUN )) && ! confirm "Start?" yes; then
        printf '  Cancelled, nothing changed.\n\n'
        exit 0
    fi

    if (( DO_PACKAGES ));   then step "Packages";   install_packages; fi
    if (( DO_LINKS ));      then step "Configs";    link_configs; fi
    if (( DO_WALLPAPERS )); then step "Wallpapers"; copy_wallpapers; fi
    if (( DO_EXTRAS )); then
        step "Fonts";             install_fonts
        step "Theming";           seed_lockscreen; apply_gtk_settings; setup_qt
        step "Shell and services"; set_fish_shell; enable_services
    fi

    summary
}

main "$@"
