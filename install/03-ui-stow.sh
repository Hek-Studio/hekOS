#!/bin/bash
source "$(dirname "$0")/utils.sh"

print_info "Applying UI configurations via Stow..."

backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        print_warning "Existing folder found at $target. Backing it up..."
        mkdir -p "$HOME/hekOS/backups"
        mv "$target" "$HOME/hekOS/backups/"
        print_success "Backed up $(basename "$target") to hekOS/backups/"
    fi
}

# Backup entire UI directories
backup_if_exists "$HOME/.config/hypr"
backup_if_exists "$HOME/.config/waybar"
backup_if_exists "$HOME/.config/rofi"
backup_if_exists "$HOME/.config/swaync"
backup_if_exists "$HOME/.config/wlogout"
backup_if_exists "$HOME/.config/gtk-3.0"
backup_if_exists "$HOME/.config/gtk-4.0"

stow -d . -t ~ ui/
print_success "UI configurations linked."