#!/usr/bin/env fish

function __sayAnonymousNamespace_add-paths_help
	echo 'Usage:  add-paths [-a | -p] -v <variable-name> [--] [<paths>...]'
	echo 'Append/prepend paths to path variable'
	echo
	echo 'Options:'
	echo '        -a, --append                    Append paths (default)'
	echo '        -p, --prepend                   Prepend paths'
	echo '        -v, --variable=<variable-name>  Path variable'
	echo '        -h, --help                      Display this help message'
	echo '        --                              Only <paths>... after this'
end

function __sayAnonymousNamespace_add-paths_validatePath --argument-names path
	if status is-interactive
		if not test -e "$path"
			if test -L "$path"
				echo-err --warning 'Broken symbolic link: '(string escape -- "$path")
			else
				echo-err --warning 'Path not exist: '(string escape -- "$path")
			end
		else if not test -d "$path"
			echo-err --warning 'Not a directory: '(string escape -- "$path")
		end
	end
	return 0
end

function add-paths --description 'Append/prepend paths to path variable'
	check-dependencies --function --quiet='never' 'echo-err' || return 3

	# Parse options
	set --local  optionSpecs \
		--name 'add-paths' \
		--exclusive 'h,a,p' \
		--exclusive 'h,v' \
		(fish_opt --short 'v' --long 'variable' --required-val) \
		(fish_opt --short 'a' --long 'append') \
		(fish_opt --short 'p' --long 'prepend') \
		(fish_opt --short 'h' --long 'help')
	argparse $optionSpecs -- $argv
	or begin
		__sayAnonymousNamespace_add-paths_help
		return 2
	end
	if test -n "$_flag_h"
		__sayAnonymousNamespace_add-paths_help
		return
	end

	set --local paths $argv
	set --local variableName (string escape --style 'var' -- "$_flag_v")
	if test -z "$variableName"
		echo-err 'Variable name cannot be emtpy'
		__sayAnonymousNamespace_add-paths_help
		return 2
	end
	set --local prepend "$_flag_p"

	set --path --local tempVariable (printenv "$variableName")
	if test -z "$tempVariable"
		set --path tempVariable
	end
	if test -z "$prepend"
		for path in $paths
			__sayAnonymousNamespace_add-paths_validatePath "$path"
			and if not contains -- "$path" $tempVariable
				set --path --append tempVariable $path
			end
		end
	else
		set --local reversedPaths $paths[-1..1]
		for path in $reversedPaths
			__sayAnonymousNamespace_add-paths_validatePath "$path"
			and if not contains -- "$path" $tempVariable
				set --path --prepend tempVariable $path
			end
		end
	end
	set --path --export --global "$variableName" $tempVariable
	return 0
end

if test 0 -ne (count $argv)
	add-paths $argv
end
