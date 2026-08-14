#!/bin/bash
set -euo pipefail

# Import utility functions and colors
source "$(dirname "$0")/utils.sh"

print_info "Starting Docker and Volta installation..."

# 1. Docker Installation & Configuration
if prompt_app_yn "Do you want to install Docker and Docker Compose?" "y"; then
    print_info "Installing Docker..."
    if sudo pacman -S --needed --noconfirm docker docker-compose; then
        print_success "Docker packages installed via pacman."
        
        print_info "Enabling and starting Docker service..."
        sudo systemctl enable --now docker.service

        if ! groups | grep -q docker; then
            print_info "Adding current user ($USER) to the docker group..."
            sudo usermod -aG docker "$USER"
            print_success "User added to docker group. (Note: You may need to log out and log back in for this to take effect)."
        else
            print_success "User is already in the docker group."
        fi
    else
        print_warning "Failed to install Docker via pacman."
    fi
else
    print_warning "Skipping Docker installation."
fi

# 2. Volta Installation (JavaScript Tool Manager)
if prompt_app_yn "Do you want to install Volta (Node.js toolchain manager)?" "y"; then
    print_info "Checking Volta installation..."
    if command -v volta &>/dev/null; then
        print_success "Volta is already installed."
    else
        print_info "Installing Volta via official script..."
        if curl https://get.volta.sh | bash; then
            print_success "Volta installed successfully."
        else
            print_warning "Failed to install Volta."
        fi
    fi
else
    print_warning "Skipping Volta installation."
fi

print_success "Docker and Volta setup completed."