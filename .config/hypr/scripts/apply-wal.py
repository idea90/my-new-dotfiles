import os
import random
import argparse
import subprocess
from pathlib import Path

# Configuration
SCRIPT_PATH = Path(__file__).resolve().parent
WALLPAPERS_DIR = Path(os.environ.get("WALLPAPERS_DIR", "~/wallpapers")).expanduser()
CACHE_DIR = Path.home() / ".cache"
CURRENT_WALLPAPER_FILE = CACHE_DIR / "current_wallpaper"
ENV_FILE = SCRIPT_PATH / ".env"

# Ensure required directories
CACHE_DIR.mkdir(parents=True, exist_ok=True)
WALLPAPERS_DIR.mkdir(parents=True, exist_ok=True)

# Load environment settings
if ENV_FILE.exists():
    env_data = dict(line.strip().split("=", 1) for line in ENV_FILE.read_text().splitlines())
else:
    env_data = {}
MODE = env_data.get("MODE", "dark")
TYPE = env_data.get("TYPE", "scheme-tonal-spot")


def set_wallpaper(wallpaper: Path):
    if not wallpaper.exists():
        subprocess.run(["notify-send", "Error", f"Selected wallpaper not found: {wallpaper}"])
        return False
    
    CURRENT_WALLPAPER_FILE.write_text(str(wallpaper))
    subprocess.run(["swww", "img", str(wallpaper), "--transition-type", "center"])
    subprocess.run(["magick", str(wallpaper), "-resize", "1280x720", "-blur", "0x8", str(CACHE_DIR / "blurred-wallpaper.png")])
    
    # Apply color scheme
    subprocess.run(["matugen", "image", str(wallpaper), "-m", MODE, "-t", TYPE])
    subprocess.run(["notify-send", "Success", "Desktop configuration updated"])
    return True


def random_wallpaper():
    wallpapers = list(WALLPAPERS_DIR.glob("*") )
    return random.choice(wallpapers) if wallpapers else None


def main():
    parser = argparse.ArgumentParser(description="Unified desktop configuration script")
    parser.add_argument("--random", action="store_true", help="Set a random wallpaper without opening rofi menu")
    parser.add_argument("--image", type=str, help="Set a specific wallpaper without entering rofi menu")
    args = parser.parse_args()
    
    if args.random:
        wallpaper = random_wallpaper()
        if wallpaper:
            set_wallpaper(wallpaper)
        return
    
    if args.image:
        wallpaper = Path(args.image).expanduser()
        set_wallpaper(wallpaper)
        return

    # Default to Rofi menu if no flag is provided
    rofi_cmd = os.environ.get("ROFI_CMD", "rofi -dmenu -i -show-icons")
    all_options = "Switch Dark/Light Mode\nSelect Color Scheme Type\nRandom Choice\n" + "\n".join(
        f"{wp.name}\x00icon\x1f{wp}" for wp in sorted(WALLPAPERS_DIR.iterdir(), key=lambda p: p.stat().st_mtime, reverse=True)
    )
    choice = subprocess.run(rofi_cmd, input=all_options, text=True, shell=True, capture_output=True).stdout.strip()

    if choice == "Switch Dark/Light Mode":
        new_mode = "light" if MODE == "dark" else "dark"
        ENV_FILE.write_text(f"MODE={new_mode}\nTYPE={TYPE}\n")
        subprocess.run(["notify-send", "Mode Switched", f"Now using {new_mode} mode"])
    elif choice == "Select Color Scheme Type":
        scheme_options = "\n".join([
            "scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad",
            "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot"
        ])
        selected_scheme = subprocess.run(rofi_cmd, input=scheme_options, text=True, shell=True, capture_output=True).stdout.strip()
        if selected_scheme:
            ENV_FILE.write_text(f"MODE={MODE}\nTYPE={selected_scheme}\n")
            subprocess.run(["notify-send", "Color Scheme Updated", f"Now using {selected_scheme}"])
    elif choice == "Random Choice":
        wallpaper = random_wallpaper()
        if wallpaper:
            set_wallpaper(wallpaper)
    elif choice and (WALLPAPERS_DIR / choice).exists():
        set_wallpaper(WALLPAPERS_DIR / choice)

if __name__ == "__main__":
    main()

