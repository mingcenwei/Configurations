#!/usr/bin/env fish

function __sayAnonymousNamespace_echo-err_help
	echo 'Usage:  echo-err [-w | -i | -p <prompt> | -f <format-function>]'
	echo '                 [-S <status-code>] [-xns] [-E | -e]'
	echo '                 [--] [<messages>...]'
	echo 'Echo error messages "Error: <message1> <message2>...".'
	echo
	echo 'Options:'
	echo '        -w, --warning                   Use "Warning:" as prompt'
	echo '        -i, --info                      Use "Info:" as prompt'
	echo '        -p, --prompt=<prompt>           Use a custom prompt'
	echo '        -f, --format=<format-function>  Use a format function to display message'
	echo '        -S, --status=<status-code>      Return this status code (default: last status returned)'
	echo '        -x, --no-space                  Do not add a space after the prompt'
	echo '        -n                              Do not output the trailing newline'
	echo '        -s                              Do not separate arguments with spaces'
	echo '        -E                              Disable interpretation of backslash escapes (default)'
	echo '        -e                              Enable interpretation of backslash escapes'
	echo '        -h, --help                      Display this help message'
	echo '        --                              Only <messages>... after this'
end

function echo-err --description  'Echo error messages'
	set --local previousStatus $status

	# Set the color of the message
	set --local normal ''
	set --local promptColor ''
	set --local messageColor ''
	if isatty stderr
		set normal (set_color 'normal')
		set promptColor (set_color --bold --background 'yellow' 'brred')
		set messageColor (set_color --bold 'brmagenta')
	end

	# Parse options
	set --local  optionSpecs \
		--name 'echo-err' \
		--exclusive 'h,p,f,w,i' \
		--exclusive 'h,S' \
		--exclusive 'h,E,e' \
		--exclusive 'h,n' \
		--exclusive 'h,s' \
		--exclusive 'h,x' \
		(fish_opt --short 'S' --long 'status' --required-val) \
		(fish_opt --short 'p' --long 'prompt' --required-val) \
		(fish_opt --short 'f' --long 'format' --required-val) \
		(fish_opt --short 'w' --long 'warning') \
		(fish_opt --short 'i' --long 'info') \
		(fish_opt --short 'x' --long 'no-space') \
		(fish_opt --short 'h' --long 'help') \
		(fish_opt --short 'v' --long 'version') \
		(fish_opt --short 'n') \
		(fish_opt --short 's') \
		(fish_opt --short 'E') \
		(fish_opt --short 'e')
	argparse $optionSpecs -- $argv
	or begin
		__sayAnonymousNamespace_echo-err_help
		return 2
	end
	if test -n "$_flag_h"
		__sayAnonymousNamespace_echo-err_help
		return
	end

	if set --query _flag_S
		set previousStatus "$_flag_S"
	end

	set --local prompt 'Error:'
	if set --query _flag_p
		set prompt "$_flag_p"
	else if set --query _flag_w
		set prompt 'Warning:'
	else if set --query _flag_i
		set prompt 'Info:'
	end

	set --local maybe_space ' '
	test -n "$_flag_x" && set maybe_space ''

	if set --query _flag_f
		"$_flag_f" $_flag_n $_flag_s $_flag_E $_flag_e $_flag_v -- $argv
	else
		# set_color outputs escape codes to change the foreground
		# and/or background color of the terminal.
		# These escape codes may be captured in command substitutions
		echo -n "$promptColor""$prompt""$normal""$maybe_space" >&2
		echo $_flag_n $_flag_s $_flag_E $_flag_e -- \
			"$messageColor"$argv"$normal" >&2
	end

	return "$previousStatus"
end
