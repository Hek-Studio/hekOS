# hekOS

A modular Arch Linux / CachyOS setup for a clean, fast, and elegant Hyprland desktop.

The idea behind hekOS is simple: keep the system configuration close to the repo, make installation repeatable, and give the desktop a polished feel without the usual friction of manual setup.

This project is inspired by the clarity and structure of modern Linux dotfile repos, with a focus on a Wayland-first workflow and an easy-to-follow install process.

## Overview

hekOS is a curated desktop environment based around:

- Hyprland
- Waybar
- Rofi
- SwayNC
- wlogout
- Starship
- SDDM
- a modular package installation flow

It is designed for users who want a consistent Arch-based machine setup that can be version-controlled and reinstalled without rebuilding everything from scratch.

## Status

Currently tested on:

- Arch Linux
- CachyOS

## Why this project exists

Many Linux setups are either too fragmented or too manual. hekOS tries to solve that by organizing everything into clear sections:

- system packages
- shell configuration
- apps configuration
- UI dotfiles
- display manager setup

Everything is kept in a single repo and applied with `stow`, which makes the setup easy to maintain and update.

## Project structure

```text
hekOS/
├── setup.sh
├── LICENSE
├── notes.txt
├── install/
│   ├── 01-base-packages.sh
│   ├── 02-shell.sh
│   ├── 03-ui-stow.sh
│   ├── 04-paru.sh
│   ├── 05-awww.sh
│   ├── 06-flatpak.sh
│   ├── 07-sddm.sh
│   └── utils.sh
├── shell/
│   └── .config/
│       └── ...
├── apps/
│   └── .config/
│       └── ...
├── ui/
│   └── .config/
│       └── ...
├── system/
│   └── sddm/
│       └── hekOS.conf
└── README.md
```

## Requirements

Before running the installer, make sure you have:

- a fresh Arch Linux or CachyOS installation
- `sudo` configured for your user
- an active internet connection
- a GitHub-ready terminal environment

## Quick start

Clone the repository and run the setup script:

```bash
git clone https://github.com/Hek-Studio/hekOS.git
cd hekOS
chmod +x setup.sh
./setup.sh
```

The installer will guide you through the setup interactively and ask whether you want to:

- update the system first
- install each module
- reboot when the process is complete

## Installation flow

The project is divided into modular scripts inside the `install` directory:

- `01-base-packages.sh` - installs the core packages for a Hyprland-based setup
- `02-shell.sh` - installs Starship and configures the shell and app dotfiles
- `03-ui-stow.sh` - applies the UI configuration with `stow`
- `04-paru.sh` - installs the AUR helper `paru`
- `05-awww.sh` - installs the wallpaper daemon and applies the default background
- `06-flatpak.sh` - enables Flatpak and Flathub
- `07-sddm.sh` - installs SDDM and links the system config

This modular design makes the installation easier to understand and safer to customize.

## Manual usage

If you want to apply the configuration manually, you can use `stow` directly:

```bash
stow -d . -t ~ shell/
stow -d . -t ~ apps/
stow -d . -t ~ ui/
```

This links the repo files into your `$HOME` so your desktop configuration stays centralized and easy to manage.

## Desktop packages and tools

The base install includes several components that are important for a polished Wayland desktop experience, including:

- `hyprland`
- `waybar`
- `rofi`
- `swaync`
- `wlogout`
- `hypridle`
- `hyprlock`
- `brightnessctl`
- `yazi`
- `xdg-desktop-portal-hyprland`
- `nwg-look`
- `gnome-themes-extra`

## Wallpaper setup

The project includes support for the `awww` wallpaper daemon. Once installed, you can set a wallpaper with:

```bash
awww img ~/.config/hypr/wallpapers/wallpaper-001.png
```

## SDDM

This repo also includes a system configuration for SDDM with a Hyprland-friendly setup:

```bash
sudo systemctl enable sddm.service
```

The config is linked from the repo to `/etc/sddm.conf.d/` during setup.

## Reboot

After the installation finishes, a reboot is recommended so all desktop components, display settings, and environment changes are applied correctly:

```bash
sudo reboot
```

## Notes

- This project is optimized for Arch and CachyOS.
- It is intentionally opinionated and built around a specific desktop workflow.
- The installation is meant to be easy to modify and extend as your setup evolves.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for more details.
