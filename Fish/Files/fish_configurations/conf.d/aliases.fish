#!/usr/bin/env fish

# Interactive mode (prompting for confirmation)
alias rmi='rm -i'
alias cpi='cp -i'
alias mvi='mv -i'
alias lni='ln -i'

# Use "exa" instead of "ls"/"ll"/"la" or "tree"
if command -v exa > '/dev/null'
	alias ls='exa'
	alias ll='exa --long --binary --group --links --time-style=long-iso --git'
	alias la='exa --all --long --binary --group --links --time-style=long-iso --git'
	alias laa='exa --all --all --long --binary --group --links --time-style=long-iso --git'
	alias tree='exa --tree'
else
	echoerr --warning 'Please install "exa"'
end

# Create and enter a temporary directory
alias cdtemp='cd (mktemp -d)'
