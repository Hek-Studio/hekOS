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
├── install/
│   ├── 01-base-packages.sh
│   ├── 02-shell.sh
│   ├── 03-ui-stow.sh
│   ├── 04-paru.sh
│   ├── 05-awww.sh
│   ├── 06-flatpak.sh
│   ├── 07-sddm.sh
│   ├── 08-user-apps.sh
│   ├── 09-dev-apps.sh
│   ├── 10-dev-tools.sh
│   └── utils.sh
├── scripts/
│   ├── 11-biometrics.sh
│   ├── create-user.sh
│   └── release.sh
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

Running `setup.sh` also creates two local, git-ignored directories the first time you need them:

- `backups/` - existing configs found in `~/.config` are moved here before a module symlinks its own dotfiles over them.
- `logs/` - a timestamped log of every install run, for troubleshooting a failed or partial installation.

## Requirements

Before running the installer, make sure you have:

- a fresh Arch Linux or CachyOS installation
- `sudo` configured for your user
- an active internet connection
- a GitHub-ready terminal environment

## Quick start

If you plan to make hekOS your own (recommended, unless you're just trying it out), **fork it** or use GitHub's **"Use this template"** first, so you have a repo of your own to customize and push changes to — cloning `Hek-Studio/hekOS` directly leaves you with nowhere of your own to push to. Forking keeps a link back to this repo so you can pull future updates; "Use this template" gives you a clean, independent copy with no upstream link.

Then clone your own copy and run the setup script:

```bash
git clone https://github.com/<your-username>/hekOS.git
cd hekOS
chmod +x setup.sh
./setup.sh
```

The installer will guide you through the setup interactively and ask whether you want to:

- update the system first
- install each module
- reboot when the process is complete


If you forked hekOS and later sync updates from upstream (`git fetch upstream` + merge/rebase), expect an occasional merge conflict in `CHANGELOG.md` if both sides have added entries — `release.sh` always inserts at the top of the file, which is the most conflict-prone spot possible. That's normal and harmless (unlike git tags, which never collide across repos since each repo's tags are independent); just resolve it like any other merge conflict, keeping the entries you want.

## Installation flow

The project is divided into modular scripts inside the `install` directory:

- `01-base-packages.sh` - installs the core packages for a Hyprland-based setup
- `02-shell.sh` - installs Starship and configures the shell and app dotfiles
- `03-ui-stow.sh` - applies the UI configuration with `stow`
- `04-paru.sh` - installs the AUR helper `paru`
- `05-awww.sh` - installs the wallpaper daemon and applies the default background
- `06-flatpak.sh` - enables Flatpak and Flathub
- `07-sddm.sh` - installs SDDM and links the system config
- `08-user-apps.sh` - interactive install of everyday apps (browsers, Bitwarden, Spotify, etc.)
- `09-dev-apps.sh` - interactive install of developer apps (VS Code, DBeaver, Postman, etc.)
- `10-dev-tools.sh` - optional Docker and Volta (Node.js toolchain manager) setup

Modules 08-10 are interactive per-app installers: each app is tried via `pacman` first, then falls back to the AUR (`paru`), then to Flatpak if neither is available — you're prompted before each attempt.

This modular design makes the installation easier to understand and safer to customize.

`scripts/11-biometrics.sh` (fingerprint and IR face unlock support, via `fprintd`/`howdy`) lives outside `install/` for now, staged for testing on real hardware before it joins the main flow — run it manually with `bash scripts/11-biometrics.sh` if you want to try it. It only installs the packages and prints the manual steps to enroll and enable them — it does not touch PAM (`/etc/pam.d/...`) automatically, since a bad PAM edit can lock you out of your session.

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
- `chromium`, `bluetui`, `pavucontrol` - browser and quick-access tools wired into Waybar's clock, network, and bluetooth modules
- `lazygit` - terminal UI for git, available anywhere from the shell
- `hyprpolkitagent` - lets GUI apps show a password prompt when they need elevated privileges (nothing does this by default on a minimal Hyprland setup)
- `cliphist` - clipboard history, browse it with `SUPER + C`
- `tlp` - power management, enabled as a system service for better laptop battery life
- `xdg-user-dirs` - creates `~/Downloads`, `~/Documents`, `~/Pictures`, etc. so apps have somewhere standard to save files
- `udisks2`, `udiskie` - auto-mounts USB drives/SD cards with a notification to open them in yazi; `SUPER + U` safely ejects one
- `xdg-utils` - provides `xdg-open`, yazi's fallback for file types without a specific opener rule (PDFs, etc.)

## Wallpaper setup

The project uses the `awww` wallpaper daemon. Hyprland's autostart config starts `awww-daemon` and applies the default wallpaper automatically every time you log in — no manual step needed. To change it yourself at any point:

```bash
awww img ~/.config/hypr/wallpapers/wallpaper-001.png
```

## Keybinds

The full list of Hyprland keybinds is available two ways once the shell and UI dotfiles are applied:

```bash
hekOS keybinds
```

or press `SUPER + I` for the same list as a Rofi popup, styled with your Rofi theme.

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

## Troubleshooting

If a module fails during the initial install, `setup.sh` prints it as `FAILED` in the summary at the end and keeps going with the rest — it won't leave you stuck mid-install. Most failures come down to a flaky network connection or a stale package cache/mirror during a big install session, not a real problem with the script.

If that happens:

1. Check the log for that run under `logs/install-<timestamp>.log` for the actual error.
2. **Reboot, then re-run `./setup.sh`.** This is the single most effective fix for connection- or cache-related failures, and it's safe: every module is idempotent, so anything that already installed correctly is skipped, and only what actually failed gets retried.
3. If it keeps failing on the same step after a reboot, that's when it's worth reading the log closely — it's more likely a real issue at that point (a wrong package name, a broken mirror, etc.) than a transient one.

## Notes

- This project is optimized for Arch and CachyOS.
- It is intentionally opinionated and built around a specific desktop workflow.
- The installation is meant to be easy to modify and extend as your setup evolves.

## Multiple users

hekOS applies cleanly to more than one account on the same machine: system packages only need installing once, and each user just needs their own dotfiles applied. To add another account set up for a working Hyprland session:

```bash
sudo scripts/create-user.sh
```

It asks for a username, an optional full name, and whether to grant sudo (`wheel`) — nothing is assumed. The new account gets the groups a Wayland session actually needs (GPU, audio, input, network, etc.) and `fish` as its shell if it's already installed. From there, log into the new account, clone hekOS into its own `$HOME`, and run `./setup.sh` — already-installed system packages are skipped automatically, so only that user's dotfiles get applied.

This script isn't part of the `install/` flow — it's a standalone tool, run manually whenever you want it.

## Releasing (maintainers)

`scripts/release.sh` reads the Conventional Commits (`feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, ...) since the last tag, suggests the next semver version, and writes a `CHANGELOG.md` entry:

```bash
./scripts/release.sh
```

It shows the suggested version and the categorized commit list first, lets you accept it or type a different one, then writes the changelog entry so you can review/edit it before anything is committed. From there it separately asks — one confirmation at a time — whether to commit + tag, push, and create a GitHub Release (via `gh`, if installed). Nothing gets pushed or tagged without an explicit yes at each step.

Since it groups commits by their raw prefix, treat the generated changelog as a draft — trim or reword entries before publishing, especially on a repo with a long history.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for more details.
