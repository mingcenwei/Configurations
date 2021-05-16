#!/usr/bin/env fish

complete --command 'set-proxies' \
	--no-files
complete --command 'set-proxies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s U universal' \
	) \
	--short-option 'U' \
	--long-option 'universal' \
	--description 'Set universal env vars'
complete --command 'set-proxies' \
	--condition (string join -- ' ' 'test 1 -eq (' \
		'count (' \
		'commandline --tokenize --cut-at-cursor |' \
		'string match --regex --invert \'^(?:\\\\-U|\\\\-\\\\-universal)$\'' \
		'))' \
	) \
	--exclusive \
	--arguments (string join -- ' ' \
		'(' \
		"printf '%s\t%s\n'" \
		"'current' 'Keep current HTTP proxy'" \
		"'none' 'Remove HTTP proxy'" \
		"'127.0.0.1:8889' 'Qv2ray Default HTTP proxy'" \
		')' \
	) \
	--keep-order
complete --command 'set-proxies' \
	--condition (string join -- ' ' 'test 2 -eq (' \
		'count (' \
		'commandline --tokenize --cut-at-cursor |' \
		'string match --regex --invert \'^(?:\\\\-U|\\\\-\\\\-universal)$\'' \
		'))' \
	) \
	--exclusive \
	--arguments (string join -- ' ' \
		'(' \
		"printf '%s\t%s\n'" \
		"'current' 'Keep current SOCKS proxy'" \
		"'none' 'Remove SOCKS proxy'" \
		"'127.0.0.1:1089' 'Qv2ray Default SOCKS proxy'" \
		')' \
	) \
	--keep-order
complete --command 'set-proxies' \
	--condition (string join -- ' ' 'test 3 -eq (' \
		'count (' \
		'commandline --tokenize --cut-at-cursor |' \
		'string match --regex --invert \'^(?:\\\\-U|\\\\-\\\\-universal)$\'' \
		'))' \
	) \
	--no-files \
	--arguments (string join -- ' ' \
		'(' \
		"printf '%s\t%s\n'" \
		"'current' 'Keep current NO proxy'" \
		"'none' 'Remove NO proxy'" \
		')' \
	) \
	--keep-order
