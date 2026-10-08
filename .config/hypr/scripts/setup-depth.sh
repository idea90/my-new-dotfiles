#!/usr/bin/env bash
# One-time setup for the "clock behind the subject" effect: a small Python environment with
# onnxruntime and a 5 MB salient-object model. Needs `uv`.
set -euo pipefail
DIR="$HOME/.local/share/kaleido/depth"
mkdir -p "$DIR"
cd "$DIR"
[[ -d venv ]] || uv venv -q venv
uv pip install -q --python venv/bin/python onnxruntime numpy pillow
[[ "$(stat -c%s u2netp.onnx 2>/dev/null || echo 0)" -gt 4000000 ]] || curl -sL -C - -o u2netp.onnx https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2netp.onnx
echo "depth effect ready"
