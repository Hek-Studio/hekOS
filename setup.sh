#!/bin/bash
set -euo pipefail

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

# Resolve the repo root from this script's own location, not the caller's cwd
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$LOG_DIR"

# Mirror all output (stdout+stderr) to a log file as well as the terminal
exec > >(tee -a "$LOG_FILE") 2>&1

clear
echo "=================================================="
echo "       🚀 hekOS $VERSION Modular Installer        "
echo "=================================================="
echo ""

# --- SYSTEM UPDATE (Default: Yes) ---
if prompt_yn "Do you want to update the system first? (Recommended: sudo pacman -Syu)" "y"; then
    print_info "Updating system packages..."
    if sudo pacman -Syu --noconfirm; then
        print_success "System updated successfully."
    else
        print_warning "System update failed. Continuing anyway — you may want to resolve this manually."
    fi
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
        "08-user-apps.sh")     echo "User Applications (Pacman, AUR and Flatpak interactive)";;
        "09-dev-apps.sh")      echo "Developer Applications (Pacman, AUR and Flatpak interactive)";;
        "10-dev-tools.sh")     echo "Developer Tools (Docker, Volta)";;
        *)                     echo "Additional module ($1)";;
    esac
}

# --- EXECUTE MODULES ---
declare -a SUMMARY_OK=()
declare -a SUMMARY_FAILED=()
declare -a SUMMARY_SKIPPED=()

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
                if bash "$script"; then
                    SUMMARY_OK+=("$script_name — $module_desc")
                else
                    print_warning "$script_name failed. Continuing with the next module..."
                    SUMMARY_FAILED+=("$script_name — $module_desc")
                fi
            else
                print_warning "Skipping $script_name."
                SUMMARY_SKIPPED+=("$script_name — $module_desc")
            fi
        fi
    done
else
    echo -e "${RED}[ERROR]${NC} The 'install/' modules directory was not found."
    exit 1
fi

echo ""
echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"
echo "Installation summary:"
for m in "${SUMMARY_OK[@]}"; do echo -e "  ${GREEN}[OK]${NC}      $m"; done
for m in "${SUMMARY_FAILED[@]}"; do echo -e "  ${RED}[FAILED]${NC}  $m"; done
for m in "${SUMMARY_SKIPPED[@]}"; do echo -e "  ${YELLOW}[SKIPPED]${NC} $m"; done
echo ""
print_info "Full log saved to: $LOG_FILE"

if [ "${#SUMMARY_FAILED[@]}" -gt 0 ]; then
    echo ""
    print_warning "Some modules failed. Check the log above (or $LOG_FILE), fix the underlying issue, and re-run ./setup.sh — modules that already completed are safe to skip and won't be repeated."
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