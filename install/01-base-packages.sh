#!/bin/bash
source "$(dirname "$0")/utils.sh"

print_info "Installing essential system packages..."
sudo pacman -S --needed --noconfirm \
  stow git base-devel \
  waybar rofi swaync wlogout \
  hyprland kitty hypridle hyprlock brightnessctl playerctl \
  yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick mpv imv \
  xdg-desktop-portal-hyprland nwg-look gnome-themes-extra \
  qt5-wayland qt6-wayland \
  gcc make ripgrep fd tree-sitter-cli unzip neovim \
  wl-clipboard grim slurp \
  ttf-jetbrains-mono-nerd 
print_success "Base packages installed."

print_info "Checking and installing audio stack if missing..."
for pkg in pipewire wireplumber pipewire-pulse pipewire-alsa pavucontrol; do
    if ! pacman -Qs "$pkg" > /dev/null; then
        print_info "Installing $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg"
    else
        print_info "$pkg is already installed, skipping."
    fi
done
print_success "Audio stack configured."