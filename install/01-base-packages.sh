#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Installing essential system packages..."
retry_command sudo pacman -S --needed --noconfirm \
  stow git base-devel \
  waybar rofi swaync wlogout chromium bluetui pavucontrol \
  hyprland kitty hypridle hyprlock brightnessctl playerctl hyprpolkitagent \
  yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick mpv imv \
  xdg-desktop-portal-hyprland nwg-look gnome-themes-extra\
  qt5-wayland qt6-wayland \
  gcc make ripgrep fd tree-sitter-cli unzip neovim lazygit \
  wl-clipboard grim slurp \
  ttf-jetbrains-mono-nerd
print_success "Base packages installed."

print_info "Checking and installing audio stack if missing..."
for pkg in pipewire wireplumber pipewire-pulse pipewire-alsa pavucontrol; do
    if ! pacman -Qs "$pkg" > /dev/null; then
        print_info "Installing $pkg..."
        retry_command sudo pacman -S --needed --noconfirm "$pkg"
    else
        print_info "$pkg is already installed, skipping."
    fi
done
print_success "Audio stack configured."
