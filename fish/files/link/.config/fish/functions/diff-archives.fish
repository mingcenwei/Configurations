#!/usr/bin/env fish

function diff-archives --description 'Compare archive files'
	check-dependencies --program --quiet='never' 'unar' || return 3
	check-dependencies --program --quiet='never' 'diff' || return 3

	set --local archives (path normalize -- $argv[1..2])
	for archive in $archives
		if not test -f "$archive"
			echo-err -- "Archive file not found: $archive"
			return 4
		end
	end

	set --local dir_temp (mktemp -d) || return 5
	for archive in $archives
		unar -quiet -output-directory "$dir_temp" -- "$archive" || return 5
	end

	diff --recursive --brief --no-dereference "$dir_temp"/*
	set --local statusCode "$status"
	rm -r -- "$dir_temp"
	return "$statusCode"
end

if test 0 -ne (count $argv)
	diff-archives $argv
end
