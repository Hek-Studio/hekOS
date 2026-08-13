#!/bin/bash

# Colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Dynamic version from Git Tags (fallbacks to v0-dev if not tagged)
get_version() {
    local version
    version=$(git describe --tags --always 2>/dev/null)
    if [ -z "$version" ]; then
        echo "v0-dev"
    else
        echo "$version"
    fi
}

# Function for interactive Yes/No prompts with a default value
# Usage: prompt_yn "Question text" "default_value" (y or n)
prompt_yn() {
    local prompt_text="$1"
    local default_val="${2:-y}" # Default to 'y' if not specified
    local yn_suffix

    if [ "$default_val" = "y" ]; then
        yn_suffix="[Y/n]"
    else
        yn_suffix="[y/N]"
    fi

    while true; do
        read -p "$(echo -e "${YELLOW}[?]${NC} $prompt_text $yn_suffix: ")" yn
        
        # If user just hits Enter, use the default value
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

VERSION=$(get_version)

clear
echo "=================================================="
echo "       🚀 hekOS $VERSION Modular Installer        "
echo "=================================================="
echo ""

# --- SYSTEM UPDATE (Default: Yes) ---
if prompt_yn "Do you want to update the system first? (Recommended: sudo pacman -Syu)" "y"; then
    print_info "Updating system packages..."
    sudo pacman -Syu --noconfirm
    print_success "System updated successfully."
else
    print_warning "Skipping system update."
fi

echo ""

# Function to get a friendly description for each module
get_module_description() {
    case "$1" in
        "01-base-packages.sh") echo "Essential system packages (Hyprland, Waybar, Yazi, etc.)";;
        "02-shell.sh")         echo "Shell environment & Git config (Fish, Starship)";;
        "03-ui-stow.sh")       echo "UI dotfiles (Hyprland, Rofi, Waybar, SwayNC)";;
        "04-paru.sh")          echo "AUR helper (Paru)";;
        "05-awww.sh")          echo "Wallpaper daemon (Awww)";;
        "06-flatpak.sh")       echo "Flatpak & Flathub";;
        "07-sddm.sh")          echo "SDDM Display Manager & Astronaut theme";;
        *)                     echo "Additional module ($1)";;
    esac
}

# --- EXECUTE MODULES ---
INSTALL_DIR="./install"

if [ -d "$INSTALL_DIR" ]; then
    for script in "$INSTALL_DIR"/*.sh; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            
            # Skip the helper file so it's not treated as an install module
            if [ "$script_name" = "utils.sh" ]; then
                continue
            fi

            module_desc=$(get_module_description "$script_name")
            
            echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"
            if prompt_yn "Install $module_desc?" "y"; then
                bash "$script"
            else
                print_warning "Skipping $script_name."
            fi
        fi
    done
else
    echo -e "${RED}[ERROR]${NC} The 'install/' modules directory was not found."
    exit 1
fi

echo ""
echo "======================================================"
echo " 🎉 hekOS $VERSION installation process finished!           "
echo "======================================================"

# --- REBOOT PROMPT (Default: Yes) ---
if prompt_yn "Would you like to reboot your system now to apply all changes?" "y"; then
    print_info "Rebooting system..."
    sudo reboot
else
    print_info "Please remember to reboot your system later manually."
fi