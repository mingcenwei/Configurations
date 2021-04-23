#!/usr/bin/env fish

if check-dependencies --program --quiet 'exa'
	complete --command 'ls' \
		--short-option 'T' \
		--erase
	complete --command 'll' \
		--short-option 'T' \
		--erase
	complete --command 'la' \
		--short-option 'T' \
		--erase
end
