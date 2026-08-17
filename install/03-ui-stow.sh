#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Applying UI configurations via Stow..."

# Backup entire UI directories
backup_if_exists "$HOME/.config/hypr"
backup_if_exists "$HOME/.config/waybar"
backup_if_exists "$HOME/.config/rofi"
backup_if_exists "$HOME/.config/swaync"
backup_if_exists "$HOME/.config/wlogout"
backup_if_exists "$HOME/.config/gtk-3.0"
backup_if_exists "$HOME/.config/gtk-4.0"

stow -d "$REPO_ROOT" -t ~ ui/
print_success "UI configurations linked."