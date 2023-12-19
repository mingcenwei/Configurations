#!/usr/bin/env fish

function fish_user_key_bindings
	# For "fzf"
	if check-dependencies --program 'fzf' && check-dependencies --function 'fzf_key_bindings'
		fzf_key_bindings
	end
end
