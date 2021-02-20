#!/usr/bin/env fish

# For login and interactive shells
if status is-login
and status is-interactive
and test (pwd) = "$HOME"
	### Set default working directory
	cd "$HOME"'/Workspace' > '/dev/null' 2>&1
	or cd "$HOME"'/Downloads' > '/dev/null' 2>&1
	or echo-err --warning 'No default working directory found'
	###
end
