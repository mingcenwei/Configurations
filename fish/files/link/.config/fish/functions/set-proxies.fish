#!/usr/bin/env fish

function set-proxies --description 'Set HTTP/SOCKS proxies'
	set --local httpProxy "$argv[1]"
	set --local socksProxy "$argv[2]"
	set --local noProxy "localhost,127.0.0.1,.cn"

	set httpProxy (string lower -- (string trim -- "$httpProxy"))
	if test -z "$httpProxy"
		echo 'Please enter HTTP proxy (or `none`/`current`)'
		read httpProxy || return 2
	end
	set httpProxy (string lower -- (string trim -- "$httpProxy"))

	set socksProxy (string lower -- (string trim -- "$socksProxy"))
	if test -z "$socksProxy"
		echo 'Please enter SOCKS proxy (or `none`/`current`)'
		read socksProxy || return 2
	end
	set socksProxy (string lower -- (string trim -- "$socksProxy"))

	switch "$httpProxy"
		case 'none'
			for proxy in http_proxy https_proxy ftp_proxy rsync_proxy
				set --erase --global "$proxy"
				set --erase --global (string upper "$proxy")
			end
		case 'current'
		case '*'
			if not string match --regex --quiet -- \
			'^[\\w\\-]+\\:\\/\\/' "$httpProxy"
				set httpProxy 'http://'"$httpProxy"
			end
			for proxy in http_proxy https_proxy ftp_proxy rsync_proxy
				set --export --global "$proxy" "$httpProxy"
				set --export --global (string upper "$proxy") "$httpProxy"
			end
	end
	switch "$socksProxy"
		case 'none'
			for proxy in all_proxy
				set --erase --global "$proxy"
				set --erase --global (string upper "$proxy")
			end
		case 'current'
		case '*'
			if not string match --regex --quiet -- \
			'^[\\w\\-]+\\:\\/\\/' "$socksProxy"
				set socksProxy 'socks5://'"$socksProxy"
			end
			for proxy in all_proxy
				set --export --global "$proxy" "$socksProxy"
				set --export --global (string upper "$proxy") "$socksProxy"
			end
	end
	for proxy in no_proxy
		set --export --global "$proxy" "$noProxy"
		set --export --global (string upper "$proxy") "$noProxy"
	end
	return 0
end
