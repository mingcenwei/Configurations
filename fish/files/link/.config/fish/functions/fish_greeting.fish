#!/usr/bin/env fish

function fish_greeting
	set --local commandColor (set_color --bold $fish_color_command)
	set --local dimColor (set_color --dim)
	set --local normalColor (set_color 'normal')

	# Fortune - print a random, hopefully interesting, adage
	if not check-dependencies --program --quiet 'fortune'
	and not check-dependencies --program --quiet 'cowfortune'
		echo-err --warning '"fortune"/"cowfortune" is not installed!'
	else if check-dependencies --program --quiet 'cowfortune'
		cowfortune
	else
		set --local fortuneQuote
		if is-platform --quiet 'android-termux'
			set fortuneQuote (fortune)
		else
			set fortuneQuote (fortune -a)
		end
		printf '%s%s%s\n' "$dimColor" "$fortuneQuote" "$normalColor"
	end

	# Fish greeting
	printf '\nWelcome to fish, the friendly interactive shell\n'

	# Crontab command
	printf 'Use %s%s%s to schedule commands\n' "$commandColor" 'crontab -e' "$normalColor"

	# Commands for respective package managers
	set --local packageUpdateCommands
	set --local packageCleanCommands
	if is-platform --quiet 'android-termux'
		set packageUpdateCommands 'apt update && apt upgrade'
		set packageCleanCommands 'apt autoremove; apt autoclean'
	else if is-platform --quiet 'homebrew'
		set packageUpdateCommands 'brew -v update && brew upgrade'
		set packageCleanCommands 'brew cleanup'
	else if is-platform --quiet 'apt'
		set packageUpdateCommands 'sudo apt update && sudo apt upgrade'
		set packageCleanCommands 'sudo apt autoremove; sudo apt autoclean'
	else if is-platform --quiet 'pacman'
		set packageUpdateCommands 'sudo pacman -Syu'
		set packageCleanCommands 'sudo pacman -Scc'
	end

	# Package updating and cleaning commands
	if test -n "$packageUpdateCommands"
		printf 'Use %s%s%s to update packages\n' "$commandColor" "$packageUpdateCommands" "$normalColor"

		if test -n "$packageCleanCommands"
			printf 'Use %s%s%s to clean the package cache\n' "$commandColor" "$packageCleanCommands" "$normalColor"
		end
	else
		echo-err --warning 'Unknown package manager!'
	end

	# Fish completion updating command
	printf 'Use %s%s%s to update fish completions\n' "$commandColor" 'fish_update_completions' "$normalColor"

	# "umask" command
	printf 'Use %s%s%s to display the symbolic umask\n' "$commandColor" 'umask -S' "$normalColor"

	printf '\n'
end
