#!/usr/bin/env fish

# Echo error messages
function echoerr
	set --local status_returned $status

	# Set the color of the message
	set --local prompt_color '--bold' '--background=yellow' 'brred'
	set --local message_color '--bold'  'brmagenta'

	# S/status: Change the status code returned (default: last status returned)
	# p/prompt: Set the prompt of the error message (default: "Error:")
	# f/format: Use a custom format function. First literal "--" separate options and arguments
	# w/warning: Set the prompt of the error message to "Warning:"
	# i/info: Set the prompt of the error message to "Info:"
	# x/no-space: Do not add a space after the prompt
	# n, s, E, e: Options for "echo" command
	argparse --name='echoerr' --exclusive 'h,p,f,w,i' \
		--exclusive 'h,S' --exclusive 'h,E,e' \
		--exclusive 'h,n' --exclusive 'h,s' \
		--exclusive 'h,x' \
		'S/status=' 'p/prompt=' 'f/format=' \
		'w/warning' 'i/info' 'x/no-space' \
		'h/help' 'v/verbose' \
		'n' 's' 'E' 'e' \
		-- $argv
	or begin
		set status_returned $status
		_echoerr_help
		return "$status_returned"
	end
	if test -n "$_flag_h"
		_echoerr_help
		return
	end

	if set --query _flag_S
		set status_returned "$_flag_S"
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
	test -n "$_flag_x"
	and set maybe_space ''

	if set --query _flag_f
		"$_flag_f" $_flag_n $_flag_s $_flag_E $_flag_e $_flag_v -- $argv
	else
		# set_color outputs escape codes to change the foreground
		# and/or background color of the terminal.
		# These escape codes may be captured in command substitutions
		echo -n (set_color $prompt_color)"$prompt"(set_color normal)"$maybe_space" >&2
		echo $_flag_n $_flag_s $_flag_E $_flag_e -- (set_color $message_color)$argv(set_color normal) >&2
	end

	return "$status_returned"
end

function _echoerr_help
	echo 'Usage:  echoerr [-w | -i | -p <prompt> | -f <format-function>]'
	echo '                [-S <status-code>] [-xns] [-E | -e]'
	echo '                [--] [<messages>...]'
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
