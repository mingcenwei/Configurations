#!/usr/bin/env fish

function fish_greeting
	# Fortune - print a random, hopefully interesting, adage
	# Prerequisites: "fortune" is installed
	if not command -v fortune > '/dev/null'
	and not command -v cowfortune > '/dev/null'
		echoerr -w '"fortune"/"cowfortune" is not installed!'
	else if command -v cowfortune > '/dev/null'
		cowfortune
	else
		set_color --dim
		if is_platform 'android-termux'
			fortune
		else
			fortune -a
		end
		set_color normal
	end

	# Fish greeting
	set_color normal
	echo
	echo 'Welcome to fish, the friendly interactive shell'

	# Commands for respective package managers
	set --local package_update_commands
	set --local package_clean_commands
	if is_platform 'macos'
		set package_update_commands 'brew -v update; brew upgrade; brew cask upgrade'
		set package_clean_commands 'brew cleanup'
	else if is_platform 'android-termux'
		set package_update_commands 'apt update; apt upgrade'
		set package_clean_commands 'apt autoremove; apt autoclean'
	else if is_platform 'ubuntu'
		set package_update_commands 'sudo apt update; sudo apt upgrade'
		set package_clean_commands 'sudo apt autoremove; sudo apt autoclean'
	else if is_platform 'manjaro'
		set package_update_commands 'sudo pacman -Syu'
		set package_clean_commands 'sudo pacman -Scc'
	else if is_platform 'homebrew'
		set package_update_commands 'brew -v update; brew upgrade; brew cask upgrade'
		set package_clean_commands 'brew cleanup'
	end

	# Package updating and cleaning commands
	if test -n "$package_update_commands"
		echo -n 'Use '
		set_color --bold "$fish_color_command"
		echo -n "$package_update_commands"
		set_color normal
		echo ' to update packages'

		test -n "$package_clean_commands"
		and begin
			echo -n 'Use '
			set_color --bold "$fish_color_command"
			echo -n "$package_clean_commands"
			set_color normal
			echo ' to clean the package cache'
		end
	else
		echo -e '#\n#\n#\n#\n#' >&2
		set_color --bold "$fish_color_command"
		echoerr -w 'Unknown package manager!'
		set_color normal
		echo -e '#\n#\n#\n#\n#' >&2
	end

	# Fish completion updating command
	echo -n 'Use '
	set_color --bold "$fish_color_command"
	echo -n 'fish_update_completions'
	set_color normal
	echo ' to update man page completions'

	# Fisher updating commands
	echo -n 'Use '
	set_color --bold "$fish_color_command"
	echo -n 'fisher update'
	set_color normal
	echo ' to update fisher packages'

	# "umask" command
	echo -n 'Use '
	set_color --bold "$fish_color_command"
	echo -n 'umask -S'
	set_color normal
	echo ' to display the symbolic file creation mode mask'

	# Server log files
	set --local log_files \
		'/var/log/auth.log' \
		'/var/log/ufw.log' \
		'/var/log/shadowsocks.log'
	if test "$AM_I_CLIENT_OR_SERVER" = 'server'
	or test "$AM_I_CLIENT_OR_SERVER" = 'both'
		echo 'Log files: '
		set_color --bold "$fish_color_command"
		for file in log_files
			echo "    $file"
		end
		set_color normal
	end

	echo
end
