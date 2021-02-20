#!/usr/bin/env fish

function fish_greeting
	# Fortune - print a random, hopefully interesting, adage
	if not check-dependencies --program --quiet 'fortune'
	and not check-dependencies --program --quiet 'cowfortune'
		echo-err --warning '"fortune"/"cowfortune" is not installed!'
	else if check-dependencies --program --quiet 'cowfortune'
		cowfortune
	else
		set_color --dim
		if is-platform --quiet 'android-termux'
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

	# Crontab command
	echo -n 'Use '
	set_color --bold "$fish_color_command"
	echo -n 'crontab -e'
	set_color normal
	echo ' to schedule commands'


	# Commands for respective package managers
	set --local packageUpdateCommands
	set --local packageCleanCommands
	if is-platform 'macos'
		set packageUpdateCommands 'brew -v update; brew upgrade; brew cask upgrade'
		set packageCleanCommands 'brew cleanup'
	else if is-platform 'android-termux'
		set packageUpdateCommands 'apt update; apt upgrade'
		set packageCleanCommands 'apt autoremove; apt autoclean'
	else if is-platform 'ubuntu'
		set packageUpdateCommands 'sudo apt update; sudo apt upgrade'
		set packageCleanCommands 'sudo apt autoremove; sudo apt autoclean'
	else if is-platform 'manjaro'
		set packageUpdateCommands 'sudo pacman -Syu'
		set packageCleanCommands 'sudo pacman -Scc'
	else if is-platform 'arch'
		set packageUpdateCommands 'sudo pacman -Syu'
		set packageCleanCommands 'sudo pacman -Scc'
	else if is-platform 'homebrew'
		set packageUpdateCommands 'brew -v update; brew upgrade; brew cask upgrade'
		set packageCleanCommands 'brew cleanup'
	end

	# Package updating and cleaning commands
	if test -n "$packageUpdateCommands"
		echo -n 'Use '
		set_color --bold "$fish_color_command"
		echo -n "$packageUpdateCommands"
		set_color normal
		echo ' to update packages'

		test -n "$packageCleanCommands"
		and begin
			echo -n 'Use '
			set_color --bold "$fish_color_command"
			echo -n "$packageCleanCommands"
			set_color normal
			echo ' to clean the package cache'
		end
	else
		echo -e '#\n#\n#\n#\n#' >&2
		set_color --bold "$fish_color_command"
		echo-err --warning 'Unknown package manager!'
		set_color normal
		echo -e '#\n#\n#\n#\n#' >&2
	end

	# Fish completion updating command
	echo -n 'Use '
	set_color --bold "$fish_color_command"
	echo -n 'fish_update_completions'
	set_color normal
	echo ' to update man page completions'

	## Fisher updating commands
	#echo -n 'Use '
	#set_color --bold "$fish_color_command"
	#echo -n 'fisher update'
	#set_color normal
	#echo ' to update fisher packages'

	# "umask" command
	echo -n 'Use '
	set_color --bold "$fish_color_command"
	echo -n 'umask -S'
	set_color normal
	echo ' to display the symbolic file creation mode mask'

	## Server log files
	#set --local log_files \
	#	'/var/log/auth.log' \
	#	'/var/log/ufw.log' \
	#	'/var/log/shadowsocks.log'
	#if test "$AM_I_CLIENT_OR_SERVER" = 'server'
	#or test "$AM_I_CLIENT_OR_SERVER" = 'both'
	#	echo 'Log files: '
	#	set_color --bold "$fish_color_command"
	#	for file in log_files
	#		echo "    $file"
	#	end
	#	set_color normal
	#end

	echo
end
