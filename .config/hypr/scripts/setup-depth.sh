#!/usr/bin/env bash
# One-time setup for the "clock behind the foreground" effect: a small Python environment with
# onnxruntime and the Depth Anything V2 small model (27 MB). Needs `uv`.
set -euo pipefail
DIR="$HOME/.local/share/kaleido/depth"
mkdir -p "$DIR"
cd "$DIR"
[[ -d venv ]] || uv venv -q venv
uv pip install -q --python venv/bin/python onnxruntime numpy pillow
[[ "$(stat -c%s depth_q.onnx 2>/dev/null || echo 0)" -gt 20000000 ]] ||
    curl -sL -C - -o depth_q.onnx https://huggingface.co/onnx-community/depth-anything-v2-small/resolve/main/onnx/model_quantized.onnx
rm -f u2netp.onnx
echo "depth effect ready"
