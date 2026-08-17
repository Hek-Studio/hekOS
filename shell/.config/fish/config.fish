if status is-interactive
    # Set up your interactive shell environment here
    set -g fish_greeting
end

set -gx EDITOR nvim
set -gx VISUAL nvim

starship init fish | source
zoxide init fish | source

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	command rm -f -- "$tmp"
end

function hekOS --description "hekOS helper commands"
	switch "$argv[1]"
		case keybinds '' --help -h
			~/.config/hypr/scripts/hekos-keybinds.sh
		case '*'
			echo "Unknown hekOS subcommand: $argv[1]"
			echo "Usage: hekOS keybinds"
			return 1
	end
end

if test -d $HOME/.local/share/flatpak/exports/share
    set -gx XDG_DATA_DIRS $HOME/.local/share/flatpak/exports/share /var/lib/flatpak/exports/share $XDG_DATA_DIRS
end
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
