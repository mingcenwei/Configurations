#!/usr/bin/env fish

function set-proxies --description 'Set HTTP/SOCKS proxies'
	# Parse options
	set --local  optionSpecs \
		--name 'set-proxies' \
		--exclusive 's,U' \
		(fish_opt --short 'U' --long 'universal') \
		(fish_opt --short 's' --long 'show')
	argparse $optionSpecs -- $argv || return 2

	if test -n "$_flag_s"
		set --show HTTP_PROXY ALL_PROXY NO_PROXY
		echo
		for proxy in HTTP_PROXY ALL_PROXY NO_PROXY
			printf '%10s: %s\\n' "$proxy" (printenv "$proxy")
		end

		if test (count $argv) -eq 0
			return 0
		else
			return 2
		end
	end

	set --local scope '--global'
	if test -n "$_flag_U"
		set scope '--universal'
	end

	set --local httpProxy "$argv[1]"
	set --local socksProxy "$argv[2]"
	set --local noProxy "$argv[3]"

	set httpProxy (string lower -- (string trim -- "$httpProxy"))
	if string match --quiet --regex -- '^\s*$' "$httpProxy"
		echo 'Please enter HTTP proxy (or `none`/`current`/`erase`)'
		read httpProxy || return 2
	end
	set httpProxy (string lower -- (string trim -- "$httpProxy"))

	set socksProxy (string lower -- (string trim -- "$socksProxy"))
	if string match --quiet --regex -- '^\s*$' "$socksProxy"
		echo 'Please enter SOCKS proxy (or `none`/`current`/`erase`)'
		read socksProxy || return 2
	end
	set socksProxy (string lower -- (string trim -- "$socksProxy"))

	set noProxy (string lower -- (string trim -- "$noProxy"))
	if string match --quiet --regex -- '^\s*$' "$noProxy"
		#set noProxy (string join -- ',' \
		#	'localhost' \
		#	'127.0.0.1' \
		#	'.local' \
		#	'.cn' \
		#	'10.0.0.0/8' \
		#	'172.16.0.0/12' \
		#	'192.168.0.0/16' \
		#	'127.0.0.0/8' \
		#)
		set noProxy (string join -- ',' \
			'localhost' \
			'127.0.0.1' \
			'.local' \
			'.cn' \
			'10.0.0.0/8' \
			'172.16.0.0/12' \
			'192.168.0.0/16' \
			'127.0.0.0/8' \
			'0.0.0.0/8' \
			'169.254.0.0/16' \
			'192.0.2.0/24' \
			'192.88.99.0/24' \
			'198.18.0.0/15' \
			'224.0.0.0/4' \
			'240.0.0.0/4' \
		)
	end

	switch "$httpProxy"
		case 'current'
		case 'none'
			for proxy in 'http_proxy' 'https_proxy' 'ftp_proxy' 'rsync_proxy'
				set --export "$scope" "$proxy" ''
				set --export "$scope" (string upper -- "$proxy") ''
			end
		case 'erase'
			for proxy in 'http_proxy' 'https_proxy' 'ftp_proxy' 'rsync_proxy'
				set --erase "$scope" "$proxy"
				set --erase "$scope" (string upper -- "$proxy")
			end
		case '*'
			if not string match --regex --quiet -- \
			'^[\\w\\-]+\\:\\/\\/' "$httpProxy"
				set httpProxy 'http://'"$httpProxy"
			end
			for proxy in 'http_proxy' 'https_proxy' 'ftp_proxy' 'rsync_proxy'
				set --export "$scope" "$proxy" "$httpProxy"
				set --export "$scope" (string upper -- "$proxy") "$httpProxy"
			end
	end
	switch "$socksProxy"
		case 'current'
		case 'none'
			for proxy in 'all_proxy'
				set --export "$scope" "$proxy" ''
				set --export "$scope" (string upper -- "$proxy") ''
			end
		case 'erase'
			for proxy in 'all_proxy'
				set --erase "$scope" "$proxy"
				set --erase "$scope" (string upper -- "$proxy")
			end
		case '*'
			if not string match --regex --quiet -- \
			'^[\\w\\-]+\\:\\/\\/' "$socksProxy"
				set socksProxy 'socks5://'"$socksProxy"
			end
			for proxy in 'all_proxy'
				set --export "$scope" "$proxy" "$socksProxy"
				set --export "$scope" (string upper -- "$proxy") "$socksProxy"
			end
	end
	switch "$noProxy"
		case 'current'
		case 'none'
			for proxy in 'no_proxy'
				set --export "$scope" "$proxy" ''
				set --export "$scope" (string upper -- "$proxy") ''
			end
		case 'erase'
			for proxy in 'no_proxy'
				set --erase "$scope" "$proxy"
				set --erase "$scope" (string upper -- "$proxy")
			end
		case '*'
			for proxy in 'no_proxy'
				set --export "$scope" "$proxy" "$noProxy"
				set --export "$scope" (string upper -- "$proxy") "$noProxy"
			end
	end
	return 0
end
