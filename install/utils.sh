# utils.sh

# Colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

prompt_app_yn() {
    local prompt_text="$1"
    local default_val="${2:-y}"
    local yn_suffix="[Y/n]"
    local yn

    while true; do
        read -p "$(echo -e "${YELLOW}[?]${NC} $prompt_text $yn_suffix: ")" yn </dev/tty
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

install_pacman_apps() {
    local -n apps_ref=$1
    for item in "${apps_ref[@]}"; do
        local app="${item%%:*}"
        local desc="${item#*:}"

        if prompt_app_yn "Do you want to install $app ($desc) via pacman?" "y"; then
            print_info "Installing $app..."
            if sudo pacman -S --needed --noconfirm "$app"; then
                print_success "$app installed."
            else
                print_warning "Failed to install $app via pacman."
            fi
        else
            print_warning "Skipping $app."
        fi
    done
}

install_aur_apps() {
    local -n apps_ref=$1
    local fallback_func=$2

    for item in "${apps_ref[@]}"; do
        local app="${item%%:*}"
        local desc="${item#*:}"

        if prompt_app_yn "Do you want to install $app ($desc) via paru (AUR)?" "y"; then
            print_info "Installing $app (review PKGBUILD if prompted)..."
            
            if paru -S --needed "$app"; then
                print_success "$app installed via AUR."
            else
                print_warning "AUR installation for $app failed. Checking for Flatpak fallback..."
                
                local flatpak_id=$($fallback_func "$app")
                if [ -n "$flatpak_id" ]; then
                    if prompt_app_yn "AUR failed. Do you want to install $app using Flatpak instead?" "y"; then
                        print_info "Installing $app via Flatpak ($flatpak_id)..."
                        flatpak install -y flathub "$flatpak_id"
                        print_success "$app installed successfully via Flatpak fallback."
                    else
                        print_warning "Flatpak fallback skipped for $app."
                    fi
                else
                    print_warning "No Flatpak fallback configured for $app."
                fi
            fi
        else
            print_warning "Skipping $app."
        fi
    done
}