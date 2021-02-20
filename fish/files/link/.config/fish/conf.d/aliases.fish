#!/usr/bin/env fish

# Interactive mode (prompting for confirmation)
abbr --add --global rmi 'rm -i'
abbr --add --global cpi 'cp -i'
abbr --add --global mvi 'mv -i'
abbr --add --global lni 'ln -i'

# Create and enter a temporary directory
abbr --add --global cdtemp 'cd (mktemp -d)'

# Auto refresh `sudo` cached credentials
if command sudo --help 2> '/dev/null' | fgrep --quiet -- '--validate'
	function sudo --wraps='sudo' --description 'sudo'
		command sudo --validate
		and command sudo $argv
	end
end

# GNU Parallel for fish shell
if check-dependencies --program 'parallel'
	function parallel --wraps 'parallel' \
	--description 'GNU Parallel for fish shell'
		set --local tempHome (mktemp -d)
		and ln -s (realpath "$HOME"'/.parallel') "$tempHome"'/.parallel'
		and env HOME="$tempHome" (command -v parallel) $argv
		and rm -r "$tempHome"
	end
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
else
	echo-err --warning 'Please install "exa"/"lsd"'
end

# Use pnpm instead of npm
if check-dependencies --program --quiet 'npm'
	if not check-dependencies --program --quiet 'pnpm'
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
	else
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
	else
		echo-err --warning 'Please install "g++"'
	end
end
