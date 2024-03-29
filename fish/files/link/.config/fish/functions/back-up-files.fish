#!/usr/bin/env fish

function __sayAnonymousNamespace_back-up-files_help
	echo 'Usage:  back-up-files [-s] [-x] [-HAX | -a] [-c <comment>]'
	echo '                      [-d <directory>] [--] <files>...'
	echo 'Back up files'
	echo
	echo 'Options:'
	echo '        -s, --sudo                    Use `sudo`'
	echo '        -x, --remove-source           Remove original files'
	echo '        -d, --backup-dir=<directory>  Specify backup directory'
	echo '                                        (default: "$HOME"/.say-local/backups/)'
	echo '        -c, --comment=<comment>       Add comment to backup name'
	echo '        -H, --hard-links              Preserve hard links'
	echo '        -A, --acls                    Preserve ACLs'
	echo '        -X, --xattrs                  Preserve extended attributes'
	echo '        -a, --preserve-all            Equal to `-HAX`'
	echo '        -h, --help                    Display this help message'
	echo '        --                            Only <files>... after this'
end

function back-up-files --description 'Back up files'
	check-dependencies --program --quiet='never' 'find' || return 3
	check-dependencies --program --quiet='never' 'realpath' || return 3
	check-dependencies --program --quiet='never' 'rsync' || return 3

	### Default settings
	set --local defaultBackupDir "$HOME"'/.say-local/backups'
	###

	# Parse options
	set --local optionSpecs \
		--name 'back-up-files' \
		--exclusive 'h,d' \
		--exclusive 'h,c' \
		--exclusive 'h,s' \
		--exclusive 'h,x' \
		--exclusive 'h,H' \
		--exclusive 'h,A' \
		--exclusive 'h,X' \
		--exclusive 'h,a' \
		(fish_opt --short 'd' --long 'backup-dir' --required-val) \
		(fish_opt --short 'c' --long 'comment' --required-val) \
		(fish_opt --short 's' --long 'sudo') \
		(fish_opt --short 'x' --long 'remove-source') \
		(fish_opt --short 'H' --long 'hard-links') \
		(fish_opt --short 'A' --long 'acls') \
		(fish_opt --short 'X' --long 'xattrs') \
		(fish_opt --short 'a' --long 'preserve-all') \
		(fish_opt --short 'h' --long 'help')
	argparse $optionSpecs -- $argv
	or begin
		__sayAnonymousNamespace_back-up-files_help
		return 2
	end
	if test -n "$_flag_h"
		__sayAnonymousNamespace_back-up-files_help
		return
	end
	if test (count $argv) -lt 1
		echo-err 'Expected at least 1 args, got '(count $argv)
		__sayAnonymousNamespace_back-up-files_help
		return 2
	end

	set --local files $argv
	set --local backupDir "$defaultBackupDir"
	test -n "$_flag_d" && set backupDir "$_flag_d"
	set --local comment \
		(string escape --style 'url' -- (string trim -- "$_flag_c"))
	test -n "$comment" && set comment '.'"$comment"
	set --local useSudo "$_flag_s"
	set --local removeSource "$_flag_x"

	set --local preserve
	if test -n "$_flag_H"
		set --append preserve '--hard-links'
	end
	if test -n "$_flag_A"
		set --append preserve '--acls'
	end
	if test -n "$_flag_X"
		set --append preserve '--xattrs'
	end
	if test -n "$_flag_a"
		set preserve '--hard-links' '--acls' '--xattrs'
	end

	set --local cRealpath 'realpath'
	set --local cTest 'test'
	set --local cMkdir 'mkdir'
	set --local cMktemp 'mktemp'
	set --local cRsync 'rsync'
	set --local cFind 'find'

	set --local hasGfind 'true'
	if is-platform --quiet 'macos'
		if check-dependencies --program --quiet='never' 'gfind'
			set cFind 'gfind'
		else
			set hasGfind 'false'
		end
	end
	if test -n "$useSudo"
		for var in cRealpath cTest cMkdir cMktemp cRsync cFind
			set --prepend "$var" 'sudo'
		end
	end

	set --local filesFullPaths
	for file in $files
		set --append filesFullPaths ($cRealpath --no-symlinks -- "$file")
		or return 1
	end
	set --local timestamp (date +"%Y-%m-%d_%H-%M-%S")
	$cTest -d "$backupDir" || $cMkdir -m 700 -p -- "$backupDir" || return 1
	set backupDir ($cRealpath -- "$backupDir") || return 1
	set --local backupRoot \
		($cMktemp -d "$backupDir"/"$timestamp""$comment"'.XXXXXXXXXX')
	or return 1

	if test -z "$removeSource"
		$cRsync --archive --sparse $preserve --relative -- \
			$filesFullPaths "$backupRoot" || return 1
	else
		$cRsync --archive --sparse $preserve --relative \
			--remove-source-files -- $filesFullPaths "$backupRoot" || return 1
		set --local returnStatus 0
		for filesFullPath in $filesFullPaths
			if $cTest -d "$filesFullPath"
				if test "$hasGfind" = 'true'
					$cFind "$filesFullPath" -type d -empty -delete
				else
					$cFind "$filesFullPath" -depth -type d -empty -execdir \
						rmdir -- '{}' ';'
				end || set returnStatus 1
			end
		end
		return "$returnStatus"
	end
end

if test 0 -ne (count $argv)
	back-up-files $argv
end
