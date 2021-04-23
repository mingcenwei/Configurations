#!/usr/bin/env fish

complete --command 'set-proxies' \
	--exclusive
complete --command 'set-proxies' \
	--condition 'test 1 -eq (count (commandline --tokenize --cut-at-cursor))' \
	--exclusive \
	--arguments (string join -- ' ' \
		'(' \
		"printf '%s\t%s\n'" \
		"'current' 'Keep current HTTP proxy'" \
		"'none' 'Remove HTTP proxy'" \
		"'https://127.0.0.1:8889' 'Qv2ray Default HTTP proxy'" \
		')' \
	) \
	--keep-order
complete --command 'set-proxies' \
	--condition 'test 2 -eq (count (commandline --tokenize --cut-at-cursor))' \
	--exclusive \
	--arguments (string join -- ' ' \
		'(' \
		"printf '%s\t%s\n'" \
		"'current' 'Keep current SOCKS proxy'" \
		"'none' 'Remove SOCKS proxy'" \
		"'socks5://127.0.0.1:1089' 'Qv2ray Default SOCKS proxy'" \
		')' \
	) \
	--keep-order
