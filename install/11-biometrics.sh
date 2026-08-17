#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Biometrics setup (fingerprint reader / IR face unlock)..."
print_warning "Skip either of these if your machine doesn't have that hardware."

# 1. Fingerprint reader (fprintd)
if prompt_app_yn "Install fingerprint support (fprintd)?" "n"; then
    if retry_command sudo pacman -S --needed --noconfirm fprintd; then
        print_success "fprintd installed."
        print_info "Next steps (manual on purpose — see note below):"
        echo "  1. Check your reader is detected:  fprintd-list \$USER"
        echo "  2. Enroll a fingerprint:           fprintd-enroll"
        echo "  3. Test it standalone:             fprintd-verify"
        echo "  4. To use it for login/sudo, add a line to the relevant PAM file"
        echo "     yourself, e.g. in /etc/pam.d/sudo:"
        echo "       auth sufficient pam_fprintd.so"
        echo "     See: https://wiki.archlinux.org/title/Fprint"
    else
        print_warning "Failed to install fprintd."
    fi
else
    print_warning "Skipping fingerprint setup."
fi

# 2. IR camera face unlock (Howdy, AUR)
if prompt_app_yn "Install IR face-unlock support (Howdy, from AUR)?" "n"; then
    if command -v paru &> /dev/null; then
        if retry_command paru -S --needed --noconfirm howdy; then
            print_success "howdy installed."
            print_info "Next steps (manual on purpose — see note below):"
            echo "  1. Find your IR camera device:  ls /dev/video*"
            echo "  2. Point Howdy at it:           sudo nano /etc/howdy/config.ini"
            echo "  3. Enroll your face:            sudo howdy add"
            echo "  4. Test it standalone:          howdy test"
            echo "  5. To use it for login/sudo, add howdy to the relevant PAM file,"
            echo "     e.g. in /etc/pam.d/sudo:"
            echo "       auth sufficient pam_python.so /lib/security/howdy/pam.py"
            echo "     Note: Howdy is software-based face matching, generally considered"
            echo "     less secure than a fingerprint or password."
            echo "     See: https://github.com/boltgolt/howdy"
        else
            print_warning "Failed to install howdy."
        fi
    else
        print_warning "Paru is not installed, cannot install howdy from AUR. Skipping."
    fi
else
    print_warning "Skipping IR face-unlock setup."
fi

print_warning "hekOS does not touch PAM automatically. A bad PAM edit can lock you out"
print_warning "of sudo or login — keep a root shell open while you test any change there,"
print_warning "so you can revert it if something goes wrong."

print_success "Biometrics setup finished."
