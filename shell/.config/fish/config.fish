if status is-interactive
    # Set up your interactive shell environment here
    set -g fish_greeting
end

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

if test -d $HOME/.local/share/flatpak/exports/share
    set -gx XDG_DATA_DIRS $HOME/.local/share/flatpak/exports/share /var/lib/flatpak/exports/share $XDG_DATA_DIRS
end