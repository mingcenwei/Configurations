#!/usr/bin/env fish

function fish_user_key_bindings
	# For "fzf"
	if check-dependencies --program 'fzf'
		fzf_key_bindings
	end
end
