#!/usr/bin/env fish

if is-platform --quiet 'homebrew'
	set --local homebrewCommandNotFoundHandler \
		(brew --prefix)'/Homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.fish'
	if test -f "$homebrewCommandNotFoundHandler"
		source "$homebrewCommandNotFoundHandler"
	else
		echo-err --warning 'Please run `brew tap homebrew/command-not-found`'
	end
else if is-platform --quiet 'pacman'
	check-dependencies --program --quiet 'pkgfile'
	or echo-err --warning 'Please install "pkgfile" and run `sudo pkgfile --update`'
end
