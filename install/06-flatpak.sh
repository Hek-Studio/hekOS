#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Configuring Flatpak and Flathub..."
retry_command sudo pacman -S --needed --noconfirm flatpak
retry_command flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
print_success "Flatpak configured."