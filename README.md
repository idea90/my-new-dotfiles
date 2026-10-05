# My Dotfiles 🖥️

This repository contains my personal dotfiles, which are the customization files feel free to copy :)

# Install 📦
Arch Linux only (uses pacman + an AUR helper; installs `yay` if you have none).

```
git clone https://github.com/idea90/my-new-dotfiles.git
cd my-new-dotfiles
./install.sh
```

What it does:
- installs Hyprland, waybar, rofi, swaync, wlogout, matugen, alacritty, fish and the tools the scripts need
- symlinks every folder in `.config/` into `~/.config` (and the GTK theme into `~/.themes`)
- moves anything it would overwrite into `~/.dotfiles-backup/<timestamp>/`
- copies wallpapers to `~/wallpapers` and creates a lock screen background
- offers to set fish as your shell and enable sddm

Safe to run again. Useful flags:

```
./install.sh --dry-run      # show what would happen
./install.sh --links-only   # only (re)link configs
./install.sh --no-optional  # skip firefox, spotify, kdeconnect, ...
./install.sh --help
```

After install: log in to Hyprland and press `Super+W` to pick a wallpaper and generate colors.

# Screenshot 📸
![Screenshot_2025-03-01-16-06-36_8109](https://github.com/user-attachments/assets/79aad2b8-ee94-4da7-8098-56e5e31b613e)
![Screenshot_2025-03-01-15-41-54_708](https://github.com/user-attachments/assets/22865024-ddfd-4527-90ae-ac9ac079118d)




# Give This Repository a Star ⭐
I never get a star from any one not even one star so if you give this Repository
a star i will be really appreciate !! :)
