#!/usr/bin/env fish

complete --command 'is-platform' \
	--condition (string join -- ' ' '__fish_contains_opt' \
		'-s h help' \
		'-s l list' \
	) \
	--no-files
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
	--arguments (string join -- ' ' \
		'(' \
		"printf '%s\t%s\n'" \
		"'always' 'Always suppress output'" \
		"'auto' 'Suppress output when non-interactive'" \
		"'never' 'Never suppress output'" \
		')' \
	) \
	--keep-order \
	--description 'Whether to suppress output'
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
