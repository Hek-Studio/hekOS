#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Configuring Shell environment and Apps..."

if ! command -v starship &> /dev/null; then
    print_info "Installing Starship prompt..."
    if retry_command bash -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y'; then
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

# Check entire configuration directories/files before stowing
backup_if_exists "$HOME/.config/kitty"
backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/yazi"
backup_if_exists "$HOME/.config/fish"
backup_if_exists "$HOME/.gitconfig"

print_info "Cleaning up old Neovim share data..."
rm -rf ~/.local/share/nvim

print_info "Applying symlinks using Stow for shell and apps..."
stow_failed=0
if ! stow -d . -t ~ shell/; then
    print_warning "Failed to stow shell/ (see conflicts above)."
    stow_failed=1
fi
if ! stow -d . -t ~ apps/; then
    print_warning "Failed to stow apps/ (see conflicts above)."
    stow_failed=1
fi

if [ "$stow_failed" -eq 1 ]; then
    print_error "Shell/apps configuration finished with errors."
    exit 1
fi
print_success "Shell and apps configured."