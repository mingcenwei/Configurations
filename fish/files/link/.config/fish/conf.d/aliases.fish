#!/usr/bin/env fish

# Interactive mode (prompting for confirmation)
abbr --add --global rmi 'rm -i'
abbr --add --global cpi 'cp -i'
abbr --add --global mvi 'mv -i'
abbr --add --global lni 'ln -i'

# Add colors: https://wiki.archlinux.org/index.php/Color_output_in_console
alias diff 'diff --color=auto'
alias grep 'grep --color=auto'
alias ip 'ip -color=auto'

# Create and enter a temporary directory
abbr --add --global cdtemp 'cd (mktemp -d)'

if check-dependencies --program --quiet 'systemctl'
	abbr --add --global sc 'systemctl'
	abbr --add --global scr 'sudo systemctl'
	abbr --add --global scu 'systemctl --user'
end
if check-dependencies --program --quiet 'journalctl'
	abbr --add --global jcu 'journalctl --pager-end --catalog --unit'
end

# Add user agent and referer automatically
abbr --add --global curl2 (string escape -- \
	curl --location --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --retry 5)
abbr --add --global wget2 (string escape -- \
	wget --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --tries 5)

# For "pacman"
if is-platform --quiet 'pacman'
	if check-dependencies --program 'makepkg'
	and check-dependencies --program 'git'
		abbr --add --global makepkg2 \
			'makepkg --syncdeps --rmdeps --install && git clean -xd --interactive'
		abbr --add --global makepkg2-asdeps \
			'makepkg --asdeps --syncdeps --rmdeps --install && git clean -xd --interactive'
	end
end

# Auto refresh `sudo` cached credentials
if command sudo --help 2> '/dev/null' | fgrep --quiet -- '--validate'
	function sudo --wraps='sudo' --description 'sudo'
		command sudo --validate
		and command sudo $argv
	end
	if check-dependencies --program --quiet 'sudoedit'
		function sudoedit --wraps='sudoedit' --description 'sudoedit'
			command sudo --validate
			and command sudoedit $argv
		end
	end
end

# GNU Parallel for fish shell
if check-dependencies --program 'parallel'
	function parallel --wraps 'parallel' \
	--description 'GNU Parallel for fish shell'
		set --local tempHome (mktemp -d)
		and ln -s (realpath "$HOME"'/.parallel') "$tempHome"'/.parallel'
		and env HOME="$tempHome" (command --search parallel) $argv
		and rm -r "$tempHome"
	end
end

# Aliases for "vim"
if check-dependencies --program 'vim'
	alias vi 'vim'
	alias ex 'vim -e'
	check-dependencies --program --quiet 'view'
	or alias view 'vim -R'
	check-dependencies --program --quiet 'rvim'
	or alias rvim 'vim -Z'
	check-dependencies --program --quiet 'rview'
	or alias rview 'vim -Z -R'
	check-dependencies --program --quiet 'vimdiff'
	or alias vimdiff 'vim -d'
end

# Use "exa"/"lsd" instead of "ls"/"ll"/"la" or "tree"
if check-dependencies --program --quiet 'exa'
	alias ls 'exa'
	alias ll 'exa --long --binary --group --links --time-style=long-iso --git'
	alias la 'exa --all --long --binary --group --links --time-style=long-iso --git'
	alias laa 'exa --all --all --long --binary --group --links --time-style=long-iso --git'
	alias tree 'exa --tree'
else if check-dependencies --program --quiet 'lsd'
	alias ls 'lsd'
	if lsd --long --date '+%Y-%m-%d %H:%M' "$HOME" > '/dev/null' 2>&1
		alias ll 'lsd --long --date \'+%Y-%m-%d %H:%M\''
		alias la 'lsd --almost-all --long --date \'+%Y-%m-%d %H:%M\''
		alias laa 'lsd --all --long --date \'+%Y-%m-%d %H:%M\''
	else
		alias ll 'lsd --long'
		alias la 'lsd --almost-all --long'
		alias laa 'lsd --all --long'
	end
	alias tree 'lsd --tree'
else if status is-login && status is-interactive
	echo-err --warning 'Please install "exa"/"lsd"'
end

# Use pnpm instead of npm
if check-dependencies --program --quiet 'npm'
	if not check-dependencies --program --quiet 'pnpm'
	and status is-login && status is-interactive
		echo-err --warning 'Please install "pnpm" to replace "npm"'
	else
		alias plain_npm 'command npm'
		alias plain_npx 'command npx'
		function npm
			echo-err --warning 'Please use "pnpm" (or "plain_npm")'
		end
		function npx
			echo-err --warning 'Please use "pnpx" (or "plain_npx")'
		end
	end
end

# Set compiler flags for C++
if is-platform --quiet 'macos'
	if check-dependencies --program --quiet 'clang++'
		alias c++17 (string join -- ' ' \
			'clang++' \
			'-std=c++17' \
			#\
			'-Wall' \
			'-Wextra' \
			'-Wconversion' \
			'-Wsign-conversion' \
			'-pedantic-errors' \
			#\
			'-Weverything' \
			'-Wno-c++98-compat' \
			'-Wno-c++98-compat-pedantic' \
			'-Wno-covered-switch-default' \
			'-Wno-unreachable-code-break' \
			'-Wno-weak-vtables' \
			'-Wno-global-constructors' \
			'-Wno-exit-time-destructors' \
			#\
			'-DDEBUG_' \
			'-g' \
			'-fPIE' \
			'-Wl,-pie' \
			#\
			'-fsanitize=address' \
			#\
			'-fsanitize=undefined' \
			'-fsanitize=float-divide-by-zero' \
			'-fsanitize=unsigned-integer-overflow' \
			'-fsanitize=implicit-conversion' \
			'-fsanitize=nullability' \
			#\
			'-fno-omit-frame-pointer' \
			'-fno-optimize-sibling-calls' \
		)
	else if status is-login && status is-interactive
		echo-err --warning 'Please install "clang++"'
	end
else
	if check-dependencies --program --quiet 'g++'
		alias c++17 (string join -- ' ' \
			'g++' \
			'-std=c++17' \
			#\
			'-Wall' \
			'-Wextra' \
			'-Wconversion' \
			'-Wsign-conversion' \
			'-pedantic-errors' \
			# '-Werror' \
			#\
			'-DDEBUG_' \
			'-g' \
			'-fPIE' \
			'-Wl,-pie' \
		)
	else if status is-login && status is-interactive
		echo-err --warning 'Please install "g++"'
	end
end
