#!/bin/bash
set -euo pipefail

# Import utility functions and colors
source "$(dirname "$0")/utils.sh"

get_flatpak_fallback() {
    case "$1" in
        "zoom") echo "us.zoom.Zoom" ;;
        "slack-desktop") echo "com.slack.Slack" ;;
        "zen-browser-bin") echo "app.zen_browser.zen" ;;
        "feishin") echo "io.github.jeffvli.feishin" ;;
        "bitwarden-bin") echo "com.bitwarden.desktop" ;;
        "brave-bin") echo "com.brave.Browser" ;;
        "spotify") echo "com.spotify.Client" ;;
        "solaar") echo "io.github.pwr_solaar.solaar" ;;
        *) echo "" ;;
    esac
}

print_info "Starting interactive user applications installation..."

pacman_apps=(
    "obs-studio:Free and open-source software for video recording and live streaming"
    "zen-browser-bin:Privacy-focused web browser built on Firefox"
    "brave-bin:Privacy-oriented web browser that blocks trackers by default"
    "bitwarden:Secure and free password manager for all of your devices"
    "solaar:Linux device manager for Logitech devices connected via USB or Bluetooth receiver"
)

install_pacman_apps pacman_apps get_flatpak_fallback

aur_apps=(
    "feishin:Modern self-hosted music player compatible with Subsonic APIs"
    "spotify:Digital music service providing access to millions of songs"
    "slack-desktop:Channel-based messaging platform for team collaboration"
    "zoom:Video conferencing and web conferencing software"
)
install_aur_apps aur_apps get_flatpak_fallback

print_success "User applications installation completed."