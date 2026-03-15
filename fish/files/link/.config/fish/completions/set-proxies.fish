#!/usr/bin/env fish

complete --command 'set-proxies' \
	--no-files
complete --command 'set-proxies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s U universal' \
		'-s s show' \
	) \
	--short-option 'U' \
	--long-option 'universal' \
	--description 'Set universal env vars'
complete --command 'set-proxies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s U universal' \
		'-s s show' \
	) \
	--short-option 's' \
	--long-option 'show' \
	--description 'Show current env vars'
complete --command 'set-proxies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s s show' \
	) \
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
		"'127.0.0.1:2080' 'NekoRay default HTTP proxy'" \
		"'127.0.0.1:2081' 'NekoRay old default HTTP proxy'" \
		"'127.0.0.1:7890' 'Clash default HTTP proxy'" \
		"'127.0.0.1:9049' 'Tor custom HTTP proxy'" \
		')' \
	) \
	--keep-order
complete --command 'set-proxies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s s show' \
	) \
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
		"'127.0.0.1:2080' 'NekoRay default SOCKS proxy'" \
		"'127.0.0.1:7890' 'Clash default SOCKS proxy'" \
		"'127.0.0.1:9050' 'Tor default SOCKS proxy'" \
		"'socks5h://127.0.0.1:9050' 'Tor default SOCKS proxy for curl'" \
		')' \
	) \
	--keep-order
complete --command 'set-proxies' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s s show' \
	) \
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
		"'$(string join -- ',' \
			'localhost' \
			'127.0.0.1' \
			'127.0.0.0/8' \
			'::1' \
			'.local' \
			'.cn' \
			'10.0.0.0/8' \
			'172.16.0.0/12' \
			'192.168.0.0/16' \
			'169.254.0.0/16' \
			'fe80::/10' \
			'fc00::/7' \
		)' 'Default NO proxy'" \
		')' \
	) \
	--keep-order
