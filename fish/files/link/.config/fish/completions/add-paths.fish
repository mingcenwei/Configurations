#!/usr/bin/env fish

complete --command 'add-paths' \
	--condition '__fish_contains_opt -s h help' \
	--exclusive
complete --command 'add-paths' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s v variable' \
	) \
	--exclusive \
	--arguments '-v' \
	--description 'Path variable'
complete --command 'add-paths' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s a append' \
		'-s p prepend' \
	) \
	--short-option 'a' \
	--long-option 'append' \
	--description 'Append paths (default)'
complete --command 'add-paths' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s a append' \
		'-s p prepend' \
	) \
	--short-option 'p' \
	--long-option 'prepend' \
	--description 'Prepend paths'
complete --command 'add-paths' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s v variable' \
	) \
	--short-option 'v' \
	--long-option 'variable' \
	--exclusive \
	--description 'Path variable'
complete --command 'add-paths' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s v variable' \
		'-s a append' \
		'-s p prepend' \
	) \
	--short-option 'h' \
	--long-option 'help' \
	--description 'Display help message'
