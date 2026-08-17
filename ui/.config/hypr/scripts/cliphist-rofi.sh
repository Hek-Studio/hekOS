#!/bin/bash
# Clipboard history picker (cliphist) via rofi, with image thumbnails for
# image entries instead of the raw "[[ binary data ... ]]" text.
# Bound to SUPER+C in binds.lua.

set -euo pipefail

cache_dir="$(mktemp -d /tmp/cliphist-preview.XXXXXX)"
trap 'rm -rf "$cache_dir"' EXIT

entries_file="$cache_dir/entries.txt"
: > "$entries_file"

while IFS= read -r line; do
    id="${line%%$'\t'*}"
    if [[ "$line" == *"binary data"* ]]; then
        img_path="$cache_dir/$id.png"
        if cliphist decode "$id" > "$img_path" 2>/dev/null && [ -s "$img_path" ]; then
            printf '%s\0icon\x1f%s\n' "$line" "$img_path" >> "$entries_file"
            continue
        fi
    fi
    printf '%s\n' "$line" >> "$entries_file"
done < <(cliphist list)

chosen="$(rofi -dmenu -i -show-icons -p 'Clipboard' -theme "$HOME/.config/rofi/style.rasi" < "$entries_file")"

[ -n "$chosen" ] && echo "$chosen" | cliphist decode | wl-copy
