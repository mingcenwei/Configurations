#!/usr/bin/env fish

function sc-show-description --description 'Show systemd unit descriptions' \
--wraps 'systemctl show'
	check-dependencies --program 'systemctl' || return 3

	# Set the color of the message
	set --local normal ''
	set --local nameColor ''
	if isatty stdout
		set normal (set_color 'normal')
		set nameColor (set_color --bold --underline 'blue')
	end

	# Parse options
	set --local  optionSpecs \
		--name 'sc-show-description' \
		(fish_opt --short 'u' --long 'user')
	argparse $optionSpecs -- $argv || return 2
	set --local userOpt
	if test -n "$_flag_u"
		set userOpt '--user'
	end
	set --local units $argv

	for unit in $units
		set --local description \
			(systemctl $userOpt show --property 'Description' "$unit" | \
				string replace --regex '^Description\\=' '')
		or continue
		
		printf '%s\t%s\n' "$nameColor""$unit""$normal" "$description"
	end
end
