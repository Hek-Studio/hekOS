#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Configuring Shell environment and Apps..."

print_info "Installing fish shell..."
retry_command sudo pacman -S --needed --noconfirm fish

if ! command -v starship &> /dev/null; then
    print_info "Installing Starship prompt..."
    if retry_command bash -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y'; then
        print_success "Starship installed."
    else
        print_warning "Starship installation failed. Continuing with shell setup..."
    fi
fi

if [ ! -f "$REPO_ROOT/shell/.gitconfig.local" ]; then
    read -p "Enter your Git name: " git_name
    read -p "Enter your Git email: " git_email
    echo -e "[user]\n    name = $git_name\n    email = $git_email" > "$REPO_ROOT/shell/.gitconfig.local"
    print_success "File shell/.gitconfig.local created."
else
    print_info "shell/.gitconfig.local already exists, skipping prompt."
fi

# Check entire configuration directories/files before stowing
backup_if_exists "$HOME/.config/kitty"
backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/yazi"
backup_if_exists "$HOME/.config/fish"
backup_if_exists "$HOME/.gitconfig"

print_info "Cleaning up old Neovim share data..."
marker_dir="$HOME/.config/hekOS"
marker_file="$marker_dir/02-shell.initialized"

if [ ! -f "$marker_file" ]; then
    print_info "Cleaning up old Neovim share data (first run)..."
    rm -rf "$HOME/.local/share/nvim"
    mkdir -p "$marker_dir"
    touch "$marker_file"
else
    print_info "Skipping Neovim cleanup; already performed on first run."
fi

print_info "Applying symlinks using Stow for shell and apps..."
stow_failed=0
if ! stow -d "$REPO_ROOT" -t ~ shell/; then
    print_warning "Failed to stow shell/ (see conflicts above)."
    stow_failed=1
fi
if ! stow -d "$REPO_ROOT" -t ~ apps/; then
    print_warning "Failed to stow apps/ (see conflicts above)."
    stow_failed=1
fi

if [ "$stow_failed" -eq 1 ]; then
    print_error "Shell/apps configuration finished with errors."
    exit 1
fi

fish_path="$(command -v fish)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$current_shell" != "$fish_path" ]; then
    print_info "Setting fish as the default shell for $USER..."
    if sudo usermod -s "$fish_path" "$USER"; then
        print_success "Default shell set to fish. Log out and back in for it to take effect."
    else
        print_warning "Could not set fish as the default shell. Run 'chsh -s $fish_path' manually."
    fi
else
    print_info "fish is already the default shell."
fi

print_success "Shell and apps configured."