#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Installing essential system packages..."
retry_command sudo pacman -S --needed --noconfirm \
  stow git base-devel tlp \
  waybar rofi swaync wlogout chromium bluetui pavucontrol \
  hyprland kitty hypridle hyprlock brightnessctl playerctl hyprpolkitagent \
  yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick mpv imv \
  xdg-desktop-portal-hyprland nwg-look gnome-themes-extra\
  qt5-wayland qt6-wayland \
  gcc make ripgrep fd tree-sitter-cli unzip neovim lazygit \
  wl-clipboard grim slurp cliphist libnotify \
  ttf-jetbrains-mono-nerd
print_success "Base packages installed."

print_info "Enabling power management (tlp)..."
# tlp and power-profiles-daemon both try to manage the same power settings and
# conflict — power-profiles-daemon ships enabled by default on many distros,
# which makes tlp.service fail to start ("Job for tlp.service canceled") until
# it's out of the way.
if systemctl is-active --quiet power-profiles-daemon 2>/dev/null || systemctl is-enabled --quiet power-profiles-daemon 2>/dev/null; then
    print_warning "power-profiles-daemon conflicts with tlp; disabling and masking it..."
    sudo systemctl disable --now power-profiles-daemon
    sudo systemctl mask power-profiles-daemon
fi

if sudo systemctl enable --now tlp.service; then
    print_success "tlp enabled."
else
    print_warning "Could not enable tlp. Run 'sudo systemctl enable --now tlp.service' manually."
fi

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
