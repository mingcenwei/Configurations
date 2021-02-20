#!/usr/bin/env fish

function __sayAnonymousNamespace_read-choice_help
	echo 'Usage:  read-choice -v <variable-name> [-d <position>]'
	echo '                    [-p <prompt>] [-P <prompt2>] [-D <delimiter>]'
	echo '                    [--] <choices>...'
	echo 'Read user choice.'
	echo
	echo 'Options:'
	echo '        -v, --variable=<variable-name>  Variable to store the choice'
	echo '        -d, --default=<position>        Default choice position (one-based)'
	echo '        -p, --prompt=<prompt>           Set the prompt (default: none)'
	echo '        -P, --prompt-invalid=<prompt2>  Set the prompt on invalid input'
	echo '                                          (default: "Please enter one of ")'
	echo '        -D, --delimiter=<delimiter>     Set the choice delimiter (default: "|")'
	echo '        -h, --help                      Display this help message'
	echo '        --                              Only <choices>... after this'
end

function read-choice --description  'Read user choice'
	check-dependencies --function 'echo-err' || return 3

	### Default settings
	set --local defaultPromptInvalid 'Please enter one of '
	isatty stdout && set defaultPromptInvalid \
		(set_color --bold 'red')"$defaultPromptInvalid"(set_color 'normal')
	set --local defaultDelimiter '|'
	###

	# Parse options
	set --local  optionSpecs \
		--name 'read-choice' \
		--exclusive 'h,v' \
		--exclusive 'h,d' \
		--exclusive 'h,p' \
		--exclusive 'h,P' \
		--exclusive 'h,D' \
		(fish_opt --short 'v' --long 'variable' --required-val) \
		(fish_opt --short 'd' --long 'default' --required-val) \
		(fish_opt --short 'p' --long 'prompt' --required-val) \
		(fish_opt --short 'P' --long 'prompt-invalid' --required-val) \
		(fish_opt --short 'D' --long 'delimiter' --required-val) \
		(fish_opt --short 'h' --long 'help')
	argparse $optionSpecs -- $argv
	or begin
		__sayAnonymousNamespace_read-choice_help
		return 2
	end
	if test -n "$_flag_h"
		__sayAnonymousNamespace_read-choice_help
		return
	end
	if test (count $argv) -lt 2
		echo-err 'Expected at least 2 args, got '(count $argv)
		__sayAnonymousNamespace_check-dependencies_help
		return 2
	end

	set --local variableName (string escape --style 'var' -- "$_flag_v")
	if test -z "$variableName"
		echo-err 'Variable name cannot be emtpy'
		__sayAnonymousNamespace_check-dependencies_help
		return 2
	end
	set --local defaultPosition
	test -n "$_flag_d" && set defaultPosition "$_flag_d"
	if test -n "$defaultPosition"
		if test "$defaultPosition" -ge 1
		and test "$defaultPosition" -le (count $argv)
		else
			echo-err 'Invalid default choice: '(string escape "$defaultPosition")
			__sayAnonymousNamespace_check-dependencies_help
			return 2
		end
	end
	set --local prompt "$_flag_p"
	set --local promptInvalid "$defaultPromptInvalid"
	set --query _flag_P && set promptInvalid "$_flag_P"
	set --local delimiter "$defaultDelimiter"
	test -n "$_flag_D" && set delimiter "$_flag_D"

	set --local choiceString '('
	set --local position 0
	set --local choices
	for choice in $argv
		set choice (string lower (string escape --style 'url' -- "$choice"))
		set --append choices "$choice"
		set position (math "$position" + 1)
		if test "$position" = "$defaultPosition"
			set choiceString "$choiceString"(string upper "$choice")"$delimiter"
		else
			set choiceString "$choiceString""$choice""$delimiter"
		end
	end

	begin
		set --local choiceStringLength (string length -- "$choiceString")
		set --local delimiterLength (string length -- "$delimiter")
		set --local newChoiceStringLength \
			(math "$choiceStringLength" - "$delimiterLength")
		set choiceString \
			(string sub --length "$newChoiceStringLength" -- "$choiceString")'): '
	end

	read --prompt-str "$prompt""$choiceString" --local -- tempVariable
	or return 2
	test -z "$tempVariable"
	and set tempVariable "$choices["$defaultPosition"]"
	set tempVariable (string lower -- (string trim -- "$tempVariable"))

	while not contains -- "$tempVariable" $choices
		read --prompt-str "$promptInvalid""$choiceString" -- tempVariable
		or return 2
		test -z "$tempVariable"
		and set tempVariable "$choices["$defaultPosition"]"
		set tempVariable (string lower (string trim -- "$tempVariable"))
	end
	set --global "$variableName" "$tempVariable"
end
