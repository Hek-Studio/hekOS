#!/bin/bash
set -euo pipefail

# Import utility functions and colors
source "$(dirname "$0")/utils.sh"

get_flatpak_fallback() {
    case "$1" in
        "mongodb-compass") echo "com.mongodb.Compass" ;;
        "beekeeper-studio-bin") echo "io.beekeeperstudio.Studio" ;;
        "dbeaver") echo "io.dbeaver.DBeaverCommunity" ;;
        "bruno-bin") echo "com.usebruno.Bruno" ;;
        "postman-bin") echo "com.getpostman.Postman" ;;
        "code") echo "com.visualstudio.code" ;;
        *) echo "" ;;
    esac
}

print_info "Starting interactive developer applications installation..."

# 1. Official developer applications (Pacman)
pacman_apps=(
    "dbeaver:Universal database tool and SQL client for developers and administrators"
    "code:Free and open-source code editor developed by Microsoft (Code-OSS)"
    "cursor-bin:The AI-first code editor built for programming with AI assistance"
)
install_pacman_apps pacman_apps get_flatpak_fallback

# 2. AUR developer applications with Flatpak fallback
aur_apps=(
    "antigravity-ide:An agentic development platform from Google, evolving the IDE into the agent-first era"
    "beekeeper-studio-bin:Modern and easy-to-use SQL GUI client and database manager"
    "mongodb-compass:The official GUI for MongoDB database management"
    "bruno-bin:Fast and git-friendly open-source API client"
    "postman-bin:API platform for building and testing APIs"
)
install_aur_apps aur_apps get_flatpak_fallback

print_success "Developer applications installation completed."