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
		"'none' 'Empty HTTP proxy'" \
		"'erase' 'Erase HTTP proxy'" \
		"'127.0.0.1:8889' 'Qv2ray default HTTP proxy'" \
		"'127.0.0.1:9049' 'Tor custom HTTP proxy'" \
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
		"'none' 'Empty SOCKS proxy'" \
		"'erase' 'Erase SOCKS proxy'" \
		"'127.0.0.1:1089' 'Qv2ray default SOCKS proxy'" \
		"'127.0.0.1:9050' 'Tor default SOCKS proxy'" \
		"'socks5h://127.0.0.1:9050' 'Tor default SOCKS proxy for curl'" \
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
		"'none' 'Empty NO proxy'" \
		"'erase' 'Erase NO proxy'" \
		"'localhost,127.0.0.1,.cn' 'Default NO proxy'" \
		')' \
	) \
	--keep-order
