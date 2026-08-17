#!/bin/bash
# scripts/create-user.sh — creates a new Linux user set up to run the hekOS
# Hyprland desktop (correct groups for a working Wayland session, fish as
# the default shell if it's installed).
#
# Not part of setup.sh's install/ flow — this is a standalone maintenance
# tool for multi-user machines. Run it manually, as root, whenever you want
# to add another account.
#
# Usage: sudo scripts/create-user.sh

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this with sudo: sudo $0"
    exit 1
fi

read -rp "Username for the new account: " username
if [ -z "$username" ]; then
    echo "Username can't be empty."
    exit 1
fi
if id "$username" &> /dev/null; then
    echo "User '$username' already exists."
    exit 1
fi

read -rp "Full name / description (optional, press Enter to skip): " fullname
read -rp "Give this user sudo access (wheel group)? [y/N]: " give_sudo

shell_path="/usr/bin/fish"
if ! command -v fish &> /dev/null; then
    echo "fish isn't installed system-wide yet — this account will get bash for now."
    echo "(hekOS's own setup.sh installs fish; run it as this user to switch later"
    echo " with: chsh -s /usr/bin/fish)"
    shell_path="/bin/bash"
fi

# Groups needed for a working Wayland/Hyprland session (GPU, audio, input,
# removable media, network, wifi/bt toggle, printing) — independent of sudo.
# Only added if they actually exist on this system, so a missing one never
# breaks account creation.
wanted_groups=(video render audio input storage network rfkill lp users)
groups_to_add=()
for g in "${wanted_groups[@]}"; do
    getent group "$g" &> /dev/null && groups_to_add+=("$g")
done
[[ "$give_sudo" =~ ^[Yy] ]] && groups_to_add+=("wheel")

groups_csv=$(IFS=,; echo "${groups_to_add[*]}")

useradd -m -G "$groups_csv" -s "$shell_path" -c "$fullname" "$username"

echo ""
echo "User '$username' created (groups: $groups_csv)."
echo "Set a password now — you'll be asked to type it twice to confirm:"
if ! passwd "$username"; then
    echo "Password not set (mismatch or cancelled). Run 'sudo passwd $username' later to set one."
fi

echo ""
echo "Done. Next steps for '$username':"
echo "  1. Log into that account."
echo "  2. Clone hekOS into its own \$HOME and run ./setup.sh from there to"
echo "     apply dotfiles — packages already installed system-wide are"
echo "     detected and skipped automatically."
