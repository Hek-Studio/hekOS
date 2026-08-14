#!/bin/bash

# Import utility functions and colors
source "$(dirname "$0")/utils.sh"

prompt_app_yn() {
    local prompt_text="$1"
    local default_val="${2:-y}"
    local yn_suffix="[Y/n]"
    local yn

    while true; do
        read -p "$(echo -e "${YELLOW}[?]${NC} $prompt_text $yn_suffix: ")" yn </dev/tty
        if [ -z "$yn" ]; then
            yn="$default_val"
        fi
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

get_flatpak_fallback() {
    case "$1" in
        "zoom") echo "us.zoom.Zoom" ;;
        "slack-desktop") echo "com.slack.Slack" ;;
        "zen-browser-bin") echo "app.zen_browser.zen" ;;
        "feishin") echo "io.github.jeffvli.feishin" ;;
        "bitwarden-bin") echo "com.bitwarden.desktop" ;;
        "brave-bin") echo "com.brave.Browser" ;;
        *) echo "" ;;
    esac
}

print_info "Starting interactive user applications installation..."

# 1. Official user applications (Pacman)
# Format: "package_name:Brief description"
pacman_apps=(
    "obs-studio:Free and open-source software for video recording and live streaming"
    "chromium:An open-source browser project that aims to build a safer, faster, and more stable way"
    "bitwarden:Secure and free password manager for all of your devices"
    "brave-bin:Privacy-oriented web browser that blocks trackers by default"
)

for item in "${pacman_apps[@]}"; do
    app="${item%%:*}"
    desc="${item#*:}"

    if prompt_app_yn "Do you want to install $app ($desc) via pacman?" "y"; then
        print_info "Installing $app..."
        if sudo pacman -S --needed --noconfirm "$app"; then
            print_success "$app installed."
        else
            print_warning "Failed to install $app via pacman."
        fi
    else
        print_warning "Skipping $app."
    fi
done

# 2. AUR user applications with Flatpak fallback
# Format: "package_name:Brief description"
aur_apps=(
    "spotify:Digital music service providing access to millions of songs"
    "slack-desktop:Channel-based messaging platform for team collaboration"
    "zoom:Video conferencing and web conferencing software"
    "zen-browser-bin:Privacy-focused web browser built on Firefox"
    "feishin:Modern self-hosted music player compatible with Subsonic APIs"
)

for item in "${aur_apps[@]}"; do
    app="${item%%:*}"
    desc="${item#*:}"

    if prompt_app_yn "Do you want to install $app ($desc) via paru (AUR)?" "y"; then
        print_info "Installing $app (review PKGBUILD if prompted)..."
        
        # Try installing via AUR
        if paru -S --needed "$app"; then
            print_success "$app installed via AUR."
        else
            print_warning "AUR installation for $app failed. Checking for Flatpak fallback..."
            
            flatpak_id=$(get_flatpak_fallback "$app")
            if [ -n "$flatpak_id" ]; then
                if prompt_app_yn "AUR failed. Do you want to install $app using Flatpak instead?" "y"; then
                    print_info "Installing $app via Flatpak ($flatpak_id)..."
                    flatpak install -y flathub "$flatpak_id"
                    print_success "$app installed successfully via Flatpak fallback."
                else
                    print_warning "Flatpak fallback skipped for $app."
                fi
            else
                print_warning "No Flatpak fallback configured for $app."
            fi
        fi
    else
        print_warning "Skipping $app."
    fi
done

print_success "User applications installation completed."