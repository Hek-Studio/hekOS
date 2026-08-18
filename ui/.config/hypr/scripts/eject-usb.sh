#!/bin/bash
# Safely unmount/eject a removable device (USB drive, SD card) via rofi.
# Companion to udiskie's auto-mount — bound to SUPER+U in binds.lua.

set -euo pipefail

mounts_dir="/run/media/$USER"

if [ ! -d "$mounts_dir" ] || [ -z "$(ls -A "$mounts_dir" 2>/dev/null)" ]; then
    notify-send "Eject" "No mounted removable devices found."
    exit 0
fi

chosen="$(ls "$mounts_dir" | rofi -dmenu -i -p 'Eject USB drive' -theme "$HOME/.config/rofi/style.rasi")"
[ -z "$chosen" ] && exit 0

if udiskie-umount --detach "$mounts_dir/$chosen"; then
    notify-send "Eject" "$chosen safely ejected — you can remove it now."
else
    notify-send -u critical "Eject" "Failed to eject $chosen — it may still be in use."
fi
