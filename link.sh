#!/bin/bash
# Symlink each entry of ./.config into ~/.config (existing targets are backed up as *.bak)

set -e
repo="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.config"

for src in "$repo"/.config/*; do
    dest="$HOME/.config/$(basename "$src")"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mv "$dest" "$dest.bak"
    fi
    ln -sfn "$src" "$dest"
    echo "linked $dest -> $src"
done

# Local runtime settings for apply-wal (ignored by git)
[ -f "$repo/.config/hypr/scripts/.env" ] || cp "$repo/.config/hypr/scripts/.env.example" "$repo/.config/hypr/scripts/.env"

echo "Put wallpapers in ~/wallpapers (used by apply-wal)."
