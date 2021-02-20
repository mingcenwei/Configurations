#!/usr/bin/env fish

function __sayAnonymousNamespace_is-platform_help
	echo 'Usage:  is-platform [-l | [-q] [--] <platforms>...]'
	echo 'Test whether we are on the given platform(s)'
	echo
	echo 'Options:'
	echo '        -l, --list   List all the platforms available'
	echo '        -q, --quiet  Don\'t output anything'
	echo '        -h, --help   Display this help message'
	echo '        --           Only <platforms>... after this'
end

function is-platform --description 'Test whether we are on the given platform(s)'
	check-dependencies --function 'echo-err' || return 3

	# The list of platforms
	set --local platforms \
		'linux' \
		'macos' \
		'android-termux' \
		'ubuntu' \
		'manjaro' \
		'arch' \
		'kde' \
		'homebrew' \
		'pacman' \
		'apt' \
		'apt-get' \
		'yum' \
		'snap' \
		'npm'

	# Parse options
	set --local  optionSpecs \
		--name 'is-platform' \
		--exclusive 'h,l,q' \
		(fish_opt --short 'l' --long 'list') \
		(fish_opt --short 'q' --long 'quiet') \
		(fish_opt --short 'h' --long 'help')
	argparse $optionSpecs -- $argv
	or begin
		__sayAnonymousNamespace_is-platform_help
		return 2
	end
	if test -n "$_flag_h"
		__sayAnonymousNamespace_is-platform_help
		return
	end
	if test -n "$_flag_l"
		if test (count $argv) -gt 0
			echo-err 'Expected at 0 args, got '(count $argv)
			__sayAnonymousNamespace_is-platform_help
			return 2
		end
	else if test (count $argv) -lt 1
		echo-err 'Expected at least 1 args, got '(count $argv)
		__sayAnonymousNamespace_is-platform_help
		return 2
	end

	set --local givenPlatforms $argv
	set --local list "$_flag_l"
	set --local quiet "$_flag_q"

	if test -n "$list"
		for platform in $platforms
			echo "$platform"
		end
		return
	else
		set --local statusToReturn 0
		for platform in $givenPlatforms
			set platform (string lower -- \
				(string escape --style 'url' -- "$platform"))
			set --local isUnknown 'false'
			switch "$platform"
				case 'linux' 'gnu-linux' 'linux-gnu'
					test (uname -s) = 'Linux'
				case 'macos' 'mac-os' 'mac' 'macosx' 'mac-os-x' 'osx' 'darwin'
					test (uname -s) = 'Darwin'
				case 'android-termux' 'termux-android' 'termux'
					test (uname -s) = 'Linux'
					and test (uname -o) = 'Android'
				case 'ubuntu'
					test (uname -s) = 'Linux'
					and test 'Ubuntu' = \
						(head -n 1 '/etc/issue' | cut -d ' ' -f 1)
				case 'manjaro'
					test (uname -s) = 'Linux'
					and test 'Manjaro' = \
						(head -n 1 '/etc/issue' | cut -d ' ' -f 1)
				case 'arch'
					test (uname -s) = 'Linux'
					and test 'Arch' = \
						(head -n 1 '/etc/issue' | cut -d ' ' -f 1)
				case 'kde'
					test "$XDG_CURRENT_DESKTOP" = 'KDE'
				case 'homebrew' 'brew'
					check-dependencies --program --quiet 'brew'
				case 'pacman'
					check-dependencies --program --quiet 'pacman'
				case 'apt'
					check-dependencies --program --quiet 'apt'
				case 'apt-get'
					check-dependencies --program --quiet 'apt-get'
				case 'yum'
					check-dependencies --program --quiet 'yum'
				case 'snap'
					check-dependencies --program --quiet 'snap'
				case 'npm'
					check-dependencies --program --quiet 'npm'
				case '*'
					set isUnknown 'true';
					false
			end
			or begin
				if test "$isUnknown" = 'true'
					test -z "$quiet" && echo-err 'Unknown platform: '"$platform"
					set statusToReturn 2
				else
					test -z "$quiet" && echo-err 'Not on platform: '"$platform"
					test "$statusToReturn" = 0 && set statusToReturn 1
				end
			end
		end
		return "$statusToReturn"
	end
end
