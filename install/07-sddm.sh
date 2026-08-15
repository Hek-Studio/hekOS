#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Configuring SDDM display manager..."
retry_command sudo pacman -S --needed --noconfirm sddm

if command -v paru &> /dev/null; then
    print_info "Installing sddm-astronaut-theme from AUR..."
    # If it's already "installed" per pacman but some files are missing or
    # corrupted (e.g. a truncated tar from an earlier interrupted run), drop
    # --needed so paru actually re-extracts it instead of skipping by version.
    theme_cmd=(paru -S --needed --noconfirm sddm-astronaut-theme)
    if pacman -Qq sddm-astronaut-theme &> /dev/null && ! pacman_app_healthy sddm-astronaut-theme; then
        print_warning "sddm-astronaut-theme is installed but some files are missing or corrupted; reinstalling..."
        theme_cmd=(paru -S --noconfirm sddm-astronaut-theme)
    fi

    if retry_command "${theme_cmd[@]}"; then
        print_success "sddm-astronaut-theme installed."
    else
        print_warning "sddm-astronaut-theme failed to install. SDDM will use its default theme instead."
    fi
else
    print_warning "Paru is not installed. Cannot install sddm-astronaut-theme automatically."
fi

print_info "Ensuring SDDM configuration directory exists..."
sudo mkdir -p /etc/sddm.conf.d

# hekOS.conf hardcodes the astronaut theme — only link it in if that theme is
# actually installed and intact, otherwise SDDM would try to load a
# missing/broken theme and fail at the greeter ("current theme can not be loaded").
if pacman_app_healthy sddm-astronaut-theme; then
    print_info "Linking hekOS.conf to SDDM system configuration..."
    sudo ln -sf "$REPO_ROOT/system/sddm/hekOS.conf" /etc/sddm.conf.d/hekOS.conf
else
    print_warning "sddm-astronaut-theme isn't installed (or is broken); skipping hekOS.conf so SDDM falls back to its built-in default theme."
fi

print_info "Enabling SDDM service..."
# --force overwrites the display-manager.service alias if it's already
# symlinked to another display manager (gdm, lightdm, etc.)
sudo systemctl enable --force sddm.service
print_success "SDDM configured and enabled."