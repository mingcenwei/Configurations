#!/usr/bin/env fish

function aur-clone --description 'Git-clone AUR repos'
	check-dependencies --program --quiet='never' 'git' || return 3

	set --local packages $argv

	for package in $packages
		if not string match --regex --quiet -- \
		'^'(string escape --style 'regex' -- \
		'https://aur.archlinux.org/') "$package"
			set package 'https://aur.archlinux.org/'"$package"
		end
		if not string match --regex --quiet -- \
		(string escape --style 'regex' -- '.git')'$' "$package"
			set package "$package"'.git'
		end
		git clone -- "$package" || return 2
	end
end
