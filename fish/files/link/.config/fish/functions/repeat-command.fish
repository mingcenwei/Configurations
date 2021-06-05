#!/usr/bin/env fish

function repeat-command --description 'Repeatedly run command'
	# Parse options
	set --local  optionSpecs \
		--name 'repeat-command' \
		--exclusive 'i,a,o' \
		(fish_opt --short 'e' --long 'eval') \
		(fish_opt --short 'i' --long 'independent') \
		(fish_opt --short 'a' --long 'and') \
		(fish_opt --short 'o' --long 'or')
	argparse $optionSpecs -- $argv || return 2

	set --local policy 'independent'
	if test -n "$_flag_a"
		set policy 'and'
	else if test -n "$_flag_o"
		set policy 'or'
	end

	set --local maybeEval
	if test -n "$_flag_e"
		set maybeEval 'eval'
	end

	set --local times "$argv[1]"
	set --local command $maybeEval $argv[2..]

	switch "$policy"
		case 'and'
			set --local returnStatus 0
			for index in (seq "$times")
				$command
				or begin
					set returnStatus "$status"
					break
				end
			end
			return "$returnStatus"
		case 'or'
			for index in (seq "$times")
				$command && break
			end
		case '*'
			for index in (seq "$times")
				$command
			end
	end
end
