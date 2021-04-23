#!/usr/bin/env fish

complete --command 'echo-err' \
	--condition '__fish_contains_opt -s h help' \
	--exclusive
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s w warning' \
		'-s i info' \
		'-s p prompt' \
		'-s f format' \
	) \
	--short-option 'w' \
	--long-option 'warning' \
	--description 'Use "Warning:" as prompt'
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s w warning' \
		'-s i info' \
		'-s p prompt' \
		'-s f format' \
	) \
	--short-option 'i' \
	--long-option 'info' \
	--description 'Use "Info:" as prompt'
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s w warning' \
		'-s i info' \
		'-s p prompt' \
		'-s f format' \
	) \
	--short-option 'p' \
	--long-option 'prompt' \
	--exclusive \
	--description 'Use a custom prompt'
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s w warning' \
		'-s i info' \
		'-s p prompt' \
		'-s f format' \
	) \
	--short-option 'f' \
	--long-option 'format' \
	--require-parameter \
	--description 'Use a format function to display message'
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s S status' \
	) \
	--short-option 's' \
	--long-option 'status' \
	--exclusive \
	--description 'Return this status code'
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s x no-space' \
	) \
	--short-option 'x' \
	--long-option 'no-space' \
	--description 'Do not add a space after the prompt'
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s n' \
	) \
	--short-option 'n' \
	--description 'Do not output the trailing newline'
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s s' \
	) \
	--short-option 's' \
	--description 'Do not separate arguments with spaces'
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s E' \
		'-s e' \
	) \
	--short-option 'E' \
	--description 'Disable interpretation of backslash escapes (default)'
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s E' \
		'-s e' \
	) \
	--short-option 'e' \
	--description 'Enable interpretation of backslash escapes'
complete --command 'echo-err' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s w warning' \
		'-s i info' \
		'-s p prompt' \
		'-s f format' \
		'-s S status' \
		'-s x no-space' \
		'-s n' \
		'-s s' \
		'-s E' \
		'-s e' \
	) \
	--short-option 'h' \
	--long-option 'help' \
	--description 'Display help message'
