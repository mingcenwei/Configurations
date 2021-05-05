#!/usr/bin/env fish

function __sayAnonymousNamespace_check-dependencies_help
	echo 'Usage:  check-dependencies [-f | -p] [-q] [--] <dependencies>...'
	echo 'Check dependencies'
	echo
	echo 'Options:'
	echo '        -f, --function  Check fish function existence'
	echo '        -p, --program   Check program existence'
	echo '        -q, --quiet[={always|auto|never}]'
	echo '                        Whether to suppress output ("always" if omitted)'
	echo '        -h, --help      Display this help message'
	echo '        --              Only <dependencies>... after this'
end

function check-dependencies --description  'Check dependencies'
	if not functions --query 'echo-err'
		echo 'Error: "echo-err" function is not found' >&2
		return 3
	end

	# Parse options
	set --local  optionSpecs \
		--name 'check-dependencies' \
		--exclusive 'h,f,p' \
		--exclusive 'h,q' \
		(fish_opt --short 'f' --long 'function') \
		(fish_opt --short 'p' --long 'program') \
		(fish_opt --short 'q' --long 'quiet' --optional-val) \
		(fish_opt --short 'h' --long 'help')
	argparse $optionSpecs -- $argv
	or begin
		__sayAnonymousNamespace_check-dependencies_help
		return 2
	end
	if test -n "$_flag_h"
		__sayAnonymousNamespace_check-dependencies_help
		return
	end
	if not contains -- "$_flag_q" '' 'always' 'auto' 'never'
		__sayAnonymousNamespace_check-dependencies_help
		return 2
	end
	if test (count $argv) -lt 1
		echo-err 'Expected at least 1 args, got '(count $argv)
		__sayAnonymousNamespace_check-dependencies_help
		return 2
	end

	set --local  checkFunction "$_flag_f"
	set --local  checkProgram "$_flag_p"
	set --local  quiet
	if not set --query _flag_q || test "$_flag_q" = 'auto'
		if not status is-interactive
			set quiet '--quiet'
		end
	else if test "$_flag_q" = '' || test "$_flag_q" = 'always'
		set quiet '--quiet'
	end

	set --local statusToReturn 0
	if test -n "$checkFunction"
		for func in $argv
			if not functions --query "$func"
				test -z "$quiet" && echo-err \
					(string escape "$func")' function is not loaded!'
				set statusToReturn 1
			end
		end
	else if test -n "$checkProgram"
		for program in $argv
			if not command --search --quiet "$program"
				test -z "$quiet" && echo-err \
					(string escape "$program")' is not installed! Please install the program'
				set statusToReturn 1
			end
		end
	else
		for executable in $argv
			if not type --query "$executable"
				test -z "$quiet" && echo-err \
					(string escape "$executable")' is not found'
				set statusToReturn 1
			end
		end
	end
	return "$statusToReturn"
end
