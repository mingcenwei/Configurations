#!/usr/bin/env fish

function aur-clone --description 'Git-clone AUR repos'
	check-dependencies --program 'git' || return 3

	set --local packages $argv

	for package in $packages
		git clone -- 'https://aur.archlinux.org/'"$package"'.git' || return 2
	end
end
