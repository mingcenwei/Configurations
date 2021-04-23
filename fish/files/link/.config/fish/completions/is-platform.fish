#!/usr/bin/env fish

complete --command 'is-platform' \
	--condition (string join -- ' ' '__fish_contains_opt' \
		'-s h help' \
		'-s l list' \
	) \
	--exclusive
complete --command 'is-platform' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s l list' \
	) \
	--exclusive \
	--arguments '(is-platform --list)' \
	--description 'Platform'
complete --command 'is-platform' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s l list' \
		'-s q quiet' \
	) \
	--short-option 'l' \
	--long-option 'list' \
	--description 'List all the platforms available'
complete --command 'is-platform' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s l list' \
		'-s q quiet' \
	) \
	--short-option 'q' \
	--long-option 'quiet' \
	--description 'Don\'t output anything'
complete --command 'is-platform' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s v variable' \
		'-s a append' \
		'-s p prepend' \
	) \
	--short-option 'h' \
	--long-option 'help' \
	--description 'Display help message'
