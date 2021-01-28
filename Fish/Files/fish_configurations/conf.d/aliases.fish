#!/usr/bin/env fish

# Interactive mode (prompting for confirmation)
alias rmi='rm -i'
alias cpi='cp -i'
alias mvi='mv -i'
alias lni='ln -i'

# Create and enter a temporary directory
alias cdtemp='cd (mktemp -d)'

# Use "exa"/"lsd" instead of "ls"/"ll"/"la" or "tree"
if command -v exa > '/dev/null'
	alias ls='exa'
	alias ll='exa --long --binary --group --links --time-style=long-iso --git'
	alias la='exa --all --long --binary --group --links --time-style=long-iso --git'
	alias laa='exa --all --all --long --binary --group --links --time-style=long-iso --git'
	alias tree='exa --tree'
else if command -v lsd > '/dev/null'
	alias ls='lsd'
	if lsd --long --date '+%Y-%m-%d %H:%M' "$HOME" > '/dev/null' 2>&1
		alias ll='lsd --long --date \'+%Y-%m-%d %H:%M\''
		alias la='lsd --almost-all --long --date \'+%Y-%m-%d %H:%M\''
		alias laa='lsd --all --long --date \'+%Y-%m-%d %H:%M\''
	else
		alias ll='lsd --long'
		alias la='lsd --almost-all --long'
		alias laa='lsd --all --long'
	end
	alias tree='lsd --tree'
else
	echoerr --warning 'Please install "exa" or "lsd"'
end

# Set compiler flags for C++
if is_platform 'macos'
	if command -v clang++ > '/dev/null'
		alias c++17=(string join -- ' ' \
			'clang++' \
			'-std=c++17' \
			\
			'-Wall' \
			'-Wextra' \
			'-Wconversion' \
			'-Wsign-conversion' \
			'-pedantic-errors' \
			\
			'-Weverything' \
			'-Wno-c++98-compat' \
			'-Wno-c++98-compat-pedantic' \
			'-Wno-covered-switch-default' \
			'-Wno-unreachable-code-break' \
			'-Wno-weak-vtables' \
			'-Wno-global-constructors' \
			'-Wno-exit-time-destructors' \
			\
			'-DDEBUG_' \
			'-g' \
			'-fPIE' \
			'-Wl,-pie' \
			\
			'-fsanitize=address' \
			\
			'-fsanitize=undefined' \
			'-fsanitize=float-divide-by-zero' \
			'-fsanitize=unsigned-integer-overflow' \
			'-fsanitize=implicit-conversion' \
			'-fsanitize=nullability' \
			\
			'-fno-omit-frame-pointer' \
			'-fno-optimize-sibling-calls' \
			\
		)
	else
		echoerr --warning 'Please install "clang++"'
	end
else
	if command -v g++ > '/dev/null'
		alias c++17=(string join -- ' ' \
			'g++' \
			'-std=c++17' \
			'-Wall' \
			'-Wextra' \
			'-pedantic-errors' \
			'-Wconversion' \
			'-Wsign-conversion' \
			# '-Werror' \
		)
	else
		echoerr --warning 'Please install "g++"'
	end
end
