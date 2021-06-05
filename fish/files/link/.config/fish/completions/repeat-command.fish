#!/usr/bin/env fish
complete --command 'repeat-command' \
	--condition (string join -- ' ' 'test 1 -eq (' \
		'count (' \
		'commandline --tokenize --cut-at-cursor |' \
		'string match --regex --invert \'^(?:\\\\-e|\\\\-\\\\-eval)$\' |' \
		'string match --regex --invert \'^(?:\\\\-i|\\\\-\\\\-independent)$\' |' \
		'string match --regex --invert \'^(?:\\\\-a|\\\\-\\\\-and)$\' |' \
		'string match --regex --invert \'^(?:\\\\-o|\\\\-\\\\-or)$\'' \
		'))' \
	) \
	--exclusive \
	--arguments "(printf '%s\n' (seq 10))" \
	--keep-order
complete --command 'repeat-command' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s e eval' \
	) \
	--short-option 'e' \
	--long-option 'eval' \
	--description 'Use `eval`'
complete --command 'repeat-command' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s i independent' \
		'-s a and' \
		'-s o or' \
	) \
	--short-option 'i' \
	--long-option 'independent' \
	--description 'Run command independently'
complete --command 'repeat-command' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s i independent' \
		'-s a and' \
		'-s o or' \
	) \
	--short-option 'a' \
	--long-option 'and' \
	--description 'Stop on error'
complete --command 'repeat-command' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s i independent' \
		'-s a and' \
		'-s o or' \
	) \
	--short-option 'o' \
	--long-option 'or' \
	--description 'Stop on success'

