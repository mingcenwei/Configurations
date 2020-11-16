#!/usr/bin/env fish

if is_platform 'homebrew'
	set --local homebrew_command_not_found_handler \
		(brew --prefix)'/Homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.fish'
	if test -f "$homebrew_command_not_found_handler"
		source "$homebrew_command_not_found_handler"
	else
		echoerr --warning 'Please run `brew tap homebrew/command-not-found`'
	end
end
