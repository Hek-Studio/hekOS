#!/bin/bash
source "$(dirname "$0")/utils.sh"

print_info "Configuring SDDM display manager..."
sudo pacman -S --needed --noconfirm sddm

if command -v paru &> /dev/null; then
    print_info "Installing sddm-astronaut-theme from AUR..."
    paru -S --needed --noconfirm sddm-astronaut-theme
    print_success "sddm-astronaut-theme installed."
else
    print_warning "Paru is not installed. Cannot install sddm-astronaut-theme automatically."
fi

print_info "Ensuring SDDM configuration directory exists..."
sudo mkdir -p /etc/sddm.conf.d

print_info "Linking hekOS.conf to SDDM system configuration..."
sudo ln -sf ~/hekOS/system/sddm/hekOS.conf /etc/sddm.conf.d/hekOS.conf

print_info "Enabling SDDM service..."
sudo systemctl enable sddm.service
print_success "SDDM configured and enabled."