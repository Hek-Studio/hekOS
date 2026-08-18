# Changelog

## v1.0.0 - 2026-08-17

### Added
- add USB eject utility and keybind, update brightness fading logic, and improve Rofi UI aesthetics
- add music player keybinding with fallback logic for feishin and spotify
- add profile to resize window for audio-only playback
- add keybinding to navigate to mounted USB drives in yazi
- set default editor, configure mpv window behavior, and add xdg-utils to base packages
- add keybinding to navigate to trash directory in yazi
- add udisks2 and udiskie support with custom configuration and autostart integration
- add xdg-user-dirs package and initialize user directories during installation
- add libnotify to base packages list
- add script for clipboard history selection with image previews and update keybinds
- install tlp and mask conflicting power-profiles-daemon for power management
- integrate cliphist for clipboard history management with autostart and keybindings
- install and autostart hyprpolkitagent for improved authentication handling
- add user creation script
- add biometric support module
- add fish install and set as default
- add release helper script for changelog management and versioning
- add hekOS keybinds script and update keybindings for improved functionality
- add view options for oil.nvim plugin configuration
- add lazygit in base packages installation
- refactor program definitions in binds.lua for consistency
- implement conditional cleanup for old Neovim share data on first run
- modify AUR installation to remove retry mechanism for user prompts
- remove setup.sh script as part of installation process refactor
- update setup.sh file permissions to executable
- update file permissions for installation scripts to executable
- implement retry mechanism for package installations and updates
- add installation skipping for existing apps and helper for safe file backups
- enhance installation scripts with logging and Flatpak fallback support
- add installation script for Docker and Volta with user prompts
- implement interactive installation script for developer applications with Pacman and AUR support
- add interactive user applications installation script for Pacman and AUR with Flatpak fallback
- enhance AUR helper installation script with existence check for improved user experience
- update language in configuration files for improved clarity and consistency
- update package installation and enhance keybindings for improved functionality
- adjust gap and border settings for improved UI layout
- update keyboard layout configuration for improved input handling
- add editor keybinding for launching Neovim
- add media playback and opening commands for Linux in yazi.toml
- update file manager binding and reorganize keybindings for clarity
- update base package installation and add audio stack configuration
- add additional packages to base installation and cleanup Neovim share data
- add initial README.md with project overview, installation flow, and requirements
- add installation scripts for essential packages, UI configurations, and AUR helper
- migrate from vim.pack to lazy.nvim
- fix function closure and ensure XDG_DATA_DIRS is set for Flatpak
- update SDDM theme to sddm-astronaut-theme
- add hypridle configuration and brightness fade script
- update SDDM configuration for X11
- add GTK 3 and 4 configuration files for theme and appearance settings
- add configuration for SDDM
- add initial configuration neovim
- include local git configuration in main .gitconfig
- add layout and style configuration for wlogout with action buttons
- add initial hyprlock configuration for enhanced lock screen experience
- update keybindings for rofi management and add wlogout command
- add initial configuration file for Yazi with comprehensive settings
- add initial .gitconfig for user and default branch setup
- add Kitty, Fish, and Starship configuration files for enhanced terminal experience
- update autostart and launch scripts for swaync integration, add swaync configuration and styles
- add Rofi theme and configuration files, update keybindings and menu launcher
- add waybar base configuration and launch script, update autostart and keybindings
- initial configuration files for Hyprland setup

### Fixed
- remove unnecessary title comment from keybinds script
- update battery configuration for improved notifications and intervals
- improve error handling for AUR package installation
- reduce battery interval for more frequent updates and improve icon formatting

### Changed
- remove custom plugin loader and update gitignore to whitelist specific Neovim plugins
- remap Waybar restart keybind to Super+Shift+Ctrl+W and update associated execution path
- move biometrics module to scripts sections
- update installation scripts and waybar configuration for improved user experience
- change modules in waybar
- new neovim structure for plugins

### Other
- update clipboard history keybinding from SUPER+V to SUPER+C
- remove lazy-lock.json as it is no longer needed
- document new auxiliary scripts and expanded list of system dependencies in README
- remove documentation regarding manual biometrics configuration from README
- add biometrics module documentation, update setup instructions, and detail multi-user workflow
- style: update global font family to JetBrainsMono Nerd Font in SwayNC and Waybar
- Add MIT License to the project

