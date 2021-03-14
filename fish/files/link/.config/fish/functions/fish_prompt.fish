#!/usr/bin/env fish

# See "Abbreviations for long hostnames" in the code

function fish_prompt --description 'Write out the prompt'
	set --local lastPipeStatus $pipestatus
	set --local normal (set_color normal)

	### Abbreviations for long hostnames
	set --local theHostname (prompt_hostname)
	if test "$theHostname" = 'Mingcen-Weis-MacBook'
		set theHostname '~MacBook'
	end
	###

	# Color the prompt differently when we're root
	set --local colorCwd $fish_color_cwd
	set --local prefix
	set --local suffix '>'
	if contains -- $USER root toor
		if set --query fish_color_cwd_root
			set colorCwd $fish_color_cwd_root
		end
		set suffix '#'
	end

	# If we're running via SSH, change the host color.
	set --local colorHost $fish_color_host
	if set --query SSH_TTY
		set colorHost $fish_color_host_remote
	end

	# Write pipestatus
	set --local promptStatus (__fish_print_pipestatus " [" "]" "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $lastPipeStatus)

	echo -n -s (set_color $fish_color_user) "$USER" $normal @ (set_color $colorHost) "$theHostname" $normal ' ' (set_color $colorCwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal $promptStatus $suffix " "
end
