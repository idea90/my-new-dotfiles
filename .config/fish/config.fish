# Starship config lives in a folder so matugen can regenerate it with the wallpaper colors
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml

if status is-interactive
    set fish_greeting
    starship init fish | source
    fastfetch
end
