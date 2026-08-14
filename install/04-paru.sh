#!/bin/bash

# Import utility functions and colors
source "$(dirname "$0")/utils.sh"

print_info "Checking AUR helper (paru)..."

if command -v paru &> /dev/null; then
    print_success "Paru is already installed. Skipping installation."
else
    print_info "Paru not found. Installing AUR helper (paru)..."
    
    sudo pacman -S --needed --noconfirm base-devel git
    
    if git clone https://aur.archlinux.org/paru.git /tmp/paru; then
        cd /tmp/paru || exit 1
        makepkg -si --noconfirm
        cd - > /dev/null || exit 1
        rm -rf /tmp/paru
        print_success "Paru installed successfully."
    else
        print_error "Failed to clone paru repository."
        rm -rf /tmp/paru
        exit 1
    fi
fi