#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Configuring Shell environment and Apps..."

if ! command -v starship &> /dev/null; then
    print_info "Installing Starship prompt..."
    if curl -sS https://starship.rs/install.sh | sh -s -- -y; then
        print_success "Starship installed."
    else
        print_warning "Starship installation failed. Continuing with shell setup..."
    fi
fi

if [ ! -f "shell/.gitconfig.local" ]; then
    read -p "Enter your Git name: " git_name
    read -p "Enter your Git email: " git_email
    echo -e "[user]\n    name = $git_name\n    email = $git_email" > shell/.gitconfig.local
    print_success "File shell/.gitconfig.local created."
else
    print_info "shell/.gitconfig.local already exists, skipping prompt."
fi

# Function to backup entire directories if they exist and are not symlinks
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        print_warning "Existing folder/file found at $target. Backing it up..."
        mkdir -p "$REPO_ROOT/backups"
        # Move the entire directory/file to backups
        mv "$target" "$REPO_ROOT/backups/"
        print_success "Backed up $(basename "$target") to $(basename "$REPO_ROOT")/backups/"
    fi
}

# Check entire configuration directories before stowing
backup_if_exists "$HOME/.config/kitty"
backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/yazi"
backup_if_exists "$HOME/.config/fish"

print_info "Cleaning up old Neovim share data..."
rm -rf ~/.local/share/nvim

print_info "Applying symlinks using Stow for shell and apps..."
stow -d . -t ~ shell/
stow -d . -t ~ apps/
print_success "Shell and apps configured."