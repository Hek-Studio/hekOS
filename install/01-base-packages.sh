#!/bin/bash
source "$(dirname "$0")/utils.sh"

print_info "Installing essential system packages..."
sudo pacman -S --needed --noconfirm \
  stow git base-devel \
  waybar rofi swaync wlogout \
  hyprland hypridle hyprlock brightnessctl \
  yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick \
  xdg-desktop-portal-hyprland nwg-look gnome-themes-extra
print_success "Base packages installed."