#!/bin/bash
source "$(dirname "$0")/utils.sh"

if command -v paru &> /dev/null; then
    print_info "Installing awww wallpaper daemon..."
    paru -S --needed --noconfirm awww
    print_success "awww installed."

    print_info "Setting initial wallpaper with awww..."
    if [ -f "$HOME/.config/hypr/wallpapers/wallpaper-001.png" ]; then
        # Check if awww-daemon is running, start it temporarily if not
        if ! pgrep -x "awww-daemon" > /dev/null; then
            print_info "Starting awww-daemon temporarily..."
            awww-daemon &
            sleep 1
        fi

        if awww img "$HOME/.config/hypr/wallpapers/wallpaper-001.png"; then
            print_success "Initial wallpaper applied."
        else
            print_warning "Could not set wallpaper (is a Wayland session active?). It will apply automatically once you log into Hyprland."
        fi
    else
        print_warning "Wallpaper file not found at expected path, skipping initial set."
    fi
else
    print_warning "Paru is not installed. Skipping awww."
fi