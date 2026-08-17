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

# Moves an existing real file/dir out of the way before stow links over it.
# Safe to call repeatedly: if a previous backup with the same name is still
# there, the new one gets a timestamp suffix instead of colliding with it.
#
# A valid symlink already pointing somewhere (presumably stow's own, from an
# earlier run) is left alone. Anything else — a real file/dir, or a broken/
# dangling symlink left over from an earlier failed or misconfigured run —
# gets moved aside, since stow would otherwise refuse it as "not owned by
# stow" without ever explaining why.
backup_if_exists() {
    local target="$1"

    if [ -L "$target" ] && [ -e "$target" ]; then
        return 0
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        local name dest
        name="$(basename "$target")"
        dest="$REPO_ROOT/backups/$name"
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            dest="$REPO_ROOT/backups/${name}-$(date +%Y%m%d-%H%M%S)"
        fi

        print_warning "Existing folder/file found at $target. Backing it up..."
        mkdir -p "$REPO_ROOT/backups"
        mv -T "$target" "$dest"
        print_success "Backed up $name to $(basename "$REPO_ROOT")/backups/$(basename "$dest")"
    fi
}

# Retries a command up to 3 times with a short pause between attempts.
# Helps with transient network blips or one-off corruption — it is not a
# substitute for fixing flaky hardware if failures keep recurring.
retry_command() {
    local attempts=3
    local delay=4
    local n=1
    until "$@"; do
        if [ "$n" -ge "$attempts" ]; then
            return 1
        fi
        print_warning "Attempt $n/$attempts failed, retrying in ${delay}s..."
        sleep "$delay"
        n=$((n + 1))
    done
}

# True if pacman package $app is installed AND all the files it owns are
# still present on disk. A package can pass `pacman -Qq` (DB says installed)
# while its files got truncated/left incomplete by an earlier interrupted
# install — this catches that case so it doesn't get silently skipped forever.
pacman_app_healthy() {
    local app="$1"
    pacman -Qq "$app" &> /dev/null && pacman -Qk --quiet "$app" &> /dev/null
}

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

# True if $app is already present and healthy via pacman/AUR, or via the
# Flatpak ID that $fallback_func (if given) maps it to — so a rerun doesn't
# reinstall through a different channel than a previous run used. If pacman
# knows about the package but its files are broken, this returns false (and
# warns) so the caller goes through the normal install path to repair it,
# instead of skipping it forever.
app_already_installed() {
    local app="$1"
    local fallback_func="${2:-}"

    if pacman -Qq "$app" &> /dev/null; then
        if pacman_app_healthy "$app"; then
            return 0
        fi
        print_warning "$app is installed but some of its files are missing or corrupted; will reinstall."
        return 1
    fi

    if [ -n "$fallback_func" ]; then
        local flatpak_id
        flatpak_id=$($fallback_func "$app")
        if [ -n "$flatpak_id" ] && flatpak info "$flatpak_id" &> /dev/null; then
            return 0
        fi
    fi

    return 1
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
        if retry_command flatpak install -y flathub "$flatpak_id"; then
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

        if app_already_installed "$app" "$fallback_func"; then
            print_success "$app is already installed, skipping."
            continue
        fi

        if ! prompt_app_yn "Do you want to install $app ($desc) via pacman?" "y"; then
            print_warning "Skipping $app."
            continue
        fi

        print_info "Installing $app..."
        # Present-but-broken packages need --needed dropped, or pacman/paru
        # would just skip them again based on version alone.
        local -a pacman_cmd=(sudo pacman -S --needed --noconfirm "$app")
        if pacman -Qq "$app" &> /dev/null; then
            pacman_cmd=(sudo pacman -S --noconfirm "$app")
        fi
        if retry_command "${pacman_cmd[@]}"; then
            print_success "$app installed via pacman."
            continue
        fi
        print_warning "Failed to install $app via pacman."

        if command -v paru &> /dev/null; then
            print_info "Trying $app via paru (AUR)..."
            local -a paru_cmd=(paru -S --needed --noconfirm "$app")
            if pacman -Qq "$app" &> /dev/null; then
                paru_cmd=(paru -S --noconfirm "$app")
            fi
            if retry_command "${paru_cmd[@]}"; then
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

        if app_already_installed "$app" "$fallback_func"; then
            print_success "$app is already installed, skipping."
            continue
        fi

        if ! prompt_app_yn "Do you want to install $app ($desc) via paru (AUR)?" "y"; then
            print_warning "Skipping $app."
            continue
        fi

        print_info "Installing $app (review PKGBUILD if prompted)..."
        local -a paru_cmd=(paru -S --needed "$app")
        if pacman -Qq "$app" &> /dev/null; then
            paru_cmd=(paru -S "$app")
        fi
        # Interactive on purpose (PKGBUILD review) — no retry_command here,
        # since a "no" to one of paru's own prompts must not be treated as a
        # transient failure worth retrying.
        if "${paru_cmd[@]}"; then
            print_success "$app installed via AUR."
            continue
        fi

        print_warning "AUR installation for $app failed. Checking for Flatpak fallback..."
        try_flatpak_fallback "$app" "$fallback_func" || true
    done
}