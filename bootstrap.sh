#!/usr/bin/env bash
#
# One command on a fresh Arch install:
#
#   curl -fsSL https://raw.githubusercontent.com/idea90/kaleido/main/bootstrap.sh | bash
#
# Clones Kaleido to ~/kaleido (or updates it) and runs install.sh. Extra arguments go to
# install.sh, e.g.  ... | bash -s -- --yes
set -euo pipefail

REPO_URL="${KALEIDO_REPO:-https://github.com/idea90/kaleido.git}"
DEST="${KALEIDO_DIR:-$HOME/kaleido}"

command -v git >/dev/null || sudo pacman -S --needed --noconfirm git
if [[ -d "$DEST/.git" ]]; then
    git -C "$DEST" pull --ff-only || true
else
    git clone --depth 1 "$REPO_URL" "$DEST"
fi
exec "$DEST/install.sh" "$@"
