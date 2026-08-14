# utils.sh

# Absolute path to the repo root, regardless of the caller's cwd or clone location
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

# Tries a Flatpak fallback for $app via $fallback_func, if one is configured.
try_flatpak_fallback() {
    local app="$1"
    local fallback_func="$2"
    local flatpak_id
    flatpak_id=$($fallback_func "$app")

    if [ -z "$flatpak_id" ]; then
        print_warning "No Flatpak fallback configured for $app."
        return 1
    fi

    if prompt_app_yn "Do you want to install $app using Flatpak instead?" "y"; then
        print_info "Installing $app via Flatpak ($flatpak_id)..."
        if flatpak install -y flathub "$flatpak_id"; then
            print_success "$app installed successfully via Flatpak fallback."
            return 0
        else
            print_warning "Flatpak installation for $app also failed."
            return 1
        fi
    else
        print_warning "Flatpak fallback skipped for $app."
        return 1
    fi
}

# Installs apps via pacman, falling back to AUR (paru) and then Flatpak if given.
# Usage: install_pacman_apps <array_name> [flatpak_fallback_func]
install_pacman_apps() {
    local -n apps_ref=$1
    local fallback_func="${2:-}"

    for item in "${apps_ref[@]}"; do
        local app="${item%%:*}"
        local desc="${item#*:}"

        if ! prompt_app_yn "Do you want to install $app ($desc) via pacman?" "y"; then
            print_warning "Skipping $app."
            continue
        fi

        print_info "Installing $app..."
        if sudo pacman -S --needed --noconfirm "$app"; then
            print_success "$app installed via pacman."
            continue
        fi
        print_warning "Failed to install $app via pacman."

        if command -v paru &> /dev/null; then
            print_info "Trying $app via paru (AUR)..."
            if paru -S --needed --noconfirm "$app"; then
                print_success "$app installed via AUR."
                continue
            fi
            print_warning "AUR installation for $app also failed."
        else
            print_warning "Paru is not installed, skipping AUR fallback for $app."
        fi

        if [ -n "$fallback_func" ]; then
            try_flatpak_fallback "$app" "$fallback_func" || true
        fi
    done
}

# Installs apps via AUR (paru), falling back to Flatpak if given.
# Usage: install_aur_apps <array_name> <flatpak_fallback_func>
install_aur_apps() {
    local -n apps_ref=$1
    local fallback_func=$2

    for item in "${apps_ref[@]}"; do
        local app="${item%%:*}"
        local desc="${item#*:}"

        if ! prompt_app_yn "Do you want to install $app ($desc) via paru (AUR)?" "y"; then
            print_warning "Skipping $app."
            continue
        fi

        print_info "Installing $app (review PKGBUILD if prompted)..."
        if paru -S --needed "$app"; then
            print_success "$app installed via AUR."
            continue
        fi

        print_warning "AUR installation for $app failed. Checking for Flatpak fallback..."
        try_flatpak_fallback "$app" "$fallback_func" || true
    done
}