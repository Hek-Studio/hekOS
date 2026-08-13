#!/bin/bash
source "$(dirname "$0")/utils.sh"

print_info "Installing AUR helper (paru)..."
sudo pacman -S --needed --noconfirm base-devel git
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si --noconfirm
cd - && rm -rf /tmp/paru
print_success "Paru installed successfully."