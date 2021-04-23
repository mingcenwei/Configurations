#!/usr/bin/env fish

complete --command 'check-dependencies' \
	--exclusive
complete --command 'check-dependencies' \
	--condition '__fish_contains_opt -s h help' \
	--no-files
complete --command 'check-dependencies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s f function' \
		'-s p program' \
	) \
	--arguments (string join -- ' ' \
		'(' \
		"printf '%s\t%s\n'" \
		"'--function' 'Check fish function existence'" \
		"'--program' 'Check program existence'" \
		')' \
	)
complete --command 'check-dependencies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s f function' \
		'-s p program' \
	) \
	--short-option 'f' \
	--long-option 'function' \
	--description 'Check fish function existence'
complete --command 'check-dependencies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s f function' \
		'-s p program' \
	) \
	--short-option 'p' \
	--long-option 'program' \
	--description 'Check program existence'
complete --command 'check-dependencies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s q quiet' \
	) \
	--short-option 'q' \
	--long-option 'quiet' \
	--description 'Don\'t output anything'
complete --command 'check-dependencies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s f function' \
		'-s p program' \
		'-s q quiet' \
	) \
	--short-option 'h' \
	--long-option 'help' \
	--description 'Display help message'
