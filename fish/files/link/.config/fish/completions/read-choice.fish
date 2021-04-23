#!/usr/bin/env fish

complete --command 'read-choice' \
	--exclusive
complete --command 'read-choice' \
	--condition '__fish_contains_opt -s h help' \
	--no-files
complete --command 'read-choice' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s v variable' \
	) \
	--exclusive \
	--arguments '--variable' \
	--description 'Variable to store the choice'
complete --command 'read-choice' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s v variable' \
	) \
	--short-option 'v' \
	--long-option 'variable' \
	--exclusive \
	--description 'Variable to store the choice'
complete --command 'read-choice' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s d default' \
	) \
	--short-option 'd' \
	--long-option 'default' \
	--exclusive \
	--description 'Default choice position (one-based)'
complete --command 'read-choice' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s p prompt' \
	) \
	--short-option 'p' \
	--long-option 'prompt' \
	--exclusive \
	--description 'Set the prompt (default: none)'
complete --command 'read-choice' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s P prompt-invalid' \
	) \
	--short-option 'P' \
	--long-option 'prompt-invalid' \
	--exclusive \
	--description 'Set the prompt on invalid input'
complete --command 'read-choice' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s D delimiter' \
	) \
	--short-option 'D' \
	--long-option 'delimiter' \
	--exclusive \
	--description 'Set the choice delimiter (default: "|")'
complete --command 'read-choice' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s v variable' \
		'-s d default' \
		'-s p prompt' \
		'-s P prompt-invalid' \
		'-s D delimiter' \
	) \
	--short-option 'h' \
	--long-option 'help' \
	--description 'Display help message'
