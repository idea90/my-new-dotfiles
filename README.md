# My Dotfiles 🖥️

Hyprland setup where everything follows the wallpaper: pick one with `Super+W` and matugen recolors
Hyprland, waybar, rofi, swaync, wlogout, hyprlock, alacritty, GTK and Qt apps.

![Screenshot_2025-03-01-16-06-36_8109](https://github.com/user-attachments/assets/79aad2b8-ee94-4da7-8098-56e5e31b613e)
![Screenshot_2025-03-01-15-41-54_708](https://github.com/user-attachments/assets/22865024-ddfd-4527-90ae-ac9ac079118d)

| Part | Tool |
| --- | --- |
| Compositor | Hyprland (+ hypridle, hyprlock, hyprpolkitagent) |
| Bar | waybar |
| Launcher / menus | rofi |
| Notifications | swaync |
| Power menu | wlogout |
| Wallpaper + colors | awww + matugen |
| Terminal / shell | alacritty, fish + starship |
| OSD | swayosd |

# Install 📦
Arch Linux only (uses pacman + an AUR helper; installs `yay` if you have none).

```
git clone https://github.com/idea90/my-new-dotfiles.git
cd my-new-dotfiles
./install.sh
```

What it does:
- installs every package the configs and scripts use
- symlinks every folder in `.config/` into `~/.config`
- moves anything it would overwrite into `~/.dotfiles-backup/<timestamp>/`
- prepares the lock screen background from `~/wallpapers` (copies `Wallpapers/` there if the repo has one)
- sets GTK theme/icons/cursor/fonts, points qt5ct/qt6ct at the matugen palette
- offers to set fish as your shell and enable sddm

Safe to run again. Useful flags:

```
./install.sh --dry-run      # show what would happen
./install.sh --links-only   # only (re)link configs
./install.sh --no-optional  # skip firefox, spotify, kdeconnect, ...
./install.sh --help
```

After install: put some images in `~/wallpapers`, log in to Hyprland and press `Super+W` to pick one and generate colors.

Optional: `./setup-git.sh` sets your global git name/email.

# Keybinds ⌨️

| Keys | Action |
| --- | --- |
| `Super+T` | Terminal |
| `Super+D` | App launcher |
| `Super+G` | File manager |
| `Super+Z` | Firefox |
| `Super+W` | Wallpaper + color scheme picker |
| `Super+Q` | Close window |
| `Super+F` / `Super+Shift+F` | Fullscreen / maximize |
| `Super+V` | Toggle floating |
| `Super+P` / `Super+J` | Pseudotile / toggle split |
| `Super+Arrows` | Move focus |
| `Super+Shift+Arrows` | Move window |
| `Super+1..0` | Switch workspace |
| `Super+Shift+1..0` | Move window to workspace |
| `Super+S` / `Super+Shift+S` | Scratchpad / send to scratchpad |
| `Print` or `Super+K` | Screenshot area |
| `Shift+Print` or `Super+Shift+K` | Screenshot monitor |
| `Alt+Print` | Screenshot window |
| `Super+Escape` | Power menu |
| `Super+Shift+M` | Exit Hyprland |

Waybar: left click / right click / scroll on modules do things (volume mute, wifi menu, calendar months, notification panel, DND).

# GTK and Qt
- GTK uses `adw-gtk3` + libadwaita, recolored through `~/.config/gtk-{3,4}.0/colors.css`.
- Theme, icons, cursor, font and dark/light live in gsettings (what GTK reads on Wayland).
  `~/.config/hypr/scripts/gtk-settings.sh` sets them on login, on dark/light switch and after each wallpaper change.
  Change fonts/icons/cursor at the top of that script rather than in nwg-look, or they get reset on next login.
- Qt apps use qt6ct/qt5ct with the matugen palette (`QT_QPA_PLATFORMTHEME=qt6ct`).
- Running GTK 4 apps only pick up new colors after a restart; dark/light switches apply live.

# Notes
- Generated color files (`hypr/colors.conf`, `waybar/colors.css`, `rofi/colors.rasi`, ...) are committed so a fresh
  install looks right before the first `Super+W`; matugen overwrites them.
- `hypr/scripts/.env` (dark/light + scheme choice) is local state and not tracked.
- Wallpapers are not tracked (they bloated the repo); older ones are still in git history.
