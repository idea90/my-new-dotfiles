#!/usr/bin/env python3
"""Serves the current matugen colors and wallpaper to the Kaleido start page extension.

Listens on 127.0.0.1 only. Endpoints:
  /colors.json     ~/.config/quickshell/colors.json
  /wallpaper       the current wallpaper (path in ~/.cache/current_wallpaper)
  /meta.json       { wallpaper: <mtime>, user: <name> } so the page knows when to reload
"""
import json
import mimetypes
import os
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOME = os.path.expanduser("~")
PORT = int(os.environ.get("KALEIDO_STARTPAGE_PORT", "7391"))
COLORS = os.path.join(HOME, ".config/quickshell/colors.json")
CURRENT = os.path.join(HOME, ".cache/current_wallpaper")


def wallpaper_path():
    try:
        with open(CURRENT) as f:
            p = f.read().strip()
        return p if os.path.isfile(p) else None
    except OSError:
        return None


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def send_bytes(self, code, body, ctype, extra=None):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        extra = extra or {}
        if "Cache-Control" not in extra:
            self.send_header("Cache-Control", "no-cache")
        for k, v in extra.items():
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(body)

    def do_HEAD(self):
        self.do_GET()

    def do_GET(self):
        path = self.path.split("?")[0]
        if path == "/colors.json":
            try:
                with open(COLORS, "rb") as f:
                    self.send_bytes(200, f.read(), "application/json")
            except OSError:
                self.send_bytes(404, b"{}", "application/json")
        elif path == "/wallpaper":
            p = wallpaper_path()
            if not p:
                self.send_bytes(404, b"", "text/plain")
                return
            with open(p, "rb") as f:
                self.send_bytes(200, f.read(), mimetypes.guess_type(p)[0] or "image/jpeg",
                                {"Cache-Control": "public, max-age=31536000, immutable"})  # the page asks for ?v=<mtime>
        elif path == "/meta.json":
            p = wallpaper_path()
            meta = {"wallpaper": int(os.path.getmtime(p)) if p else 0, "name": os.path.basename(p) if p else "",
                    "user": os.environ.get("USER", "")}
            self.send_bytes(200, json.dumps(meta).encode(), "application/json")
        else:
            self.send_bytes(404, b"not found", "text/plain")


if __name__ == "__main__":
    try:
        ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
    except OSError as e:
        print("startpage server:", e, file=sys.stderr)
        sys.exit(1)
