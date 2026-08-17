#!/bin/bash
# Prints hekOS's main Hyprland keybinds.
# Used by `hekOS keybinds` (fish, see shell/.config/fish/config.fish) and by
# the SUPER+I rofi popup (see ui/.config/hypr/modules/binds.lua).

KEYBINDS="Apps
  SUPER + T             Terminal (kitty)
  SUPER + E             Editor (nvim)
  SUPER + F             File manager (yazi)
  SUPER + B             Browser (zen-browser, falls back to chromium)
  ALT + SPACE           App launcher (rofi)
  SUPER+SHIFT+CTRL + W  Restart Waybar
  SUPER+SHIFT + Q       Logout menu (wlogout)
  SUPER+SHIFT+CTRL + L  Lock screen (hyprlock)
  SUPER+SHIFT+CTRL + Q  Exit Hyprland

Windows
  SUPER + Q             Close focused window
  SUPER + V             Toggle floating
  SUPER+SHIFT + F       Toggle fullscreen
  SUPER+SHIFT + M       Toggle maximize
  SUPER+SHIFT + S       Toggle split layout (dwindle)
  SUPER + H/L/K/J       Focus left/right/up/down
  SUPER+SHIFT + H/L/K/J Move window left/right/up/down
  SUPER + drag LMB      Move window
  SUPER + drag RMB      Resize window

Workspaces
  SUPER + 0-9           Go to workspace
  SUPER+SHIFT + 0-9     Move window to workspace
  SUPER + scroll        Next/previous workspace
  SUPER + S             Toggle scratchpad
  SUPER+SHIFT+CTRL + S  Move window to scratchpad

Screenshots
  SUPER + P             Area screenshot to clipboard
  SUPER+SHIFT + P       Full screen screenshot to clipboard

Clipboard
  SUPER + C             Clipboard history (cliphist)
  
Media keys (hardware)
  Volume / Mic mute     Standard multimedia keys
  Brightness up/down    Standard multimedia keys
  Play/Pause/Next/Prev  Standard multimedia keys (playerctl)

Help
  SUPER + I             Show this list"

if [ "$1" = "--rofi" ]; then
    echo "$KEYBINDS" | rofi -dmenu -i -p "hekOS keybinds" -theme "$HOME/.config/rofi/style.rasi"
else
    echo "$KEYBINDS"
fi
