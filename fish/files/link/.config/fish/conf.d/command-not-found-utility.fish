#!/usr/bin/env fish

if is-platform --quiet 'homebrew'
	set --local homebrewCommandNotFoundHandler \
		(brew --prefix)'/Homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.fish'
	and if test -f "$homebrewCommandNotFoundHandler"
		source "$homebrewCommandNotFoundHandler"
	else if status is-login && status is-interactive
		echo-err --warning 'Please run `brew tap homebrew/command-not-found`'
	end
else if is-platform --quiet 'pacman'
	if not check-dependencies --program --quiet 'pkgfile'
	and status is-login && status is-interactive
		echo-err --warning \
			'Please install "pkgfile" and run `sudo pkgfile --update`'
	end
end
