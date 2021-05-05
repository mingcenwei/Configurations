#!/usr/bin/env fish

# Filesystem safety measures
if is-platform --quiet 'linux'
	alias rm 'rm --preserve-root=all --one-file-system'
	abbr --add --global rm 'rm -I'
	abbr --add --global rmi 'rm -I'

	alias chmod 'chmod --preserve-root'
	alias chown 'chown --preserve-root'
	alias chgrp 'chgrp --preserve-root'
else
	if check-dependencies --program 'grm'
		alias grm 'grm --preserve-root=all --one-file-system'
		abbr --add --global rm 'grm -I'
		abbr --add --global rmi 'grm -I'
	else
		abbr --add --global rm 'rm -i'
		abbr --add --global rmi 'rm -i'
	end

	if check-dependencies --program 'gchmod'
		alias gchmod 'gchmod --preserve-root'
		alias chmod 'gchmod'
	end
	if check-dependencies --program 'gchown'
		alias gchown 'gchown --preserve-root'
		alias chown 'gchown'
	end
	if check-dependencies --program 'gchgrp'
		alias gchgrp 'gchgrp --preserve-root'
		alias chgrp 'gchgrp'
	end
	if check-dependencies --program 'gfind'
		alias find 'gfind'
	end
end
abbr --add --global cp 'cp -i'
abbr --add --global cpi 'cp -i'
abbr --add --global mv 'mv -i'
abbr --add --global mvi 'mv -i'
#abbr --add --global ln 'ln -i'
abbr --add --global lni 'ln -i'

# Database safety measures
if check-dependencies --program --quiet 'mysql'
	abbr --add --global mysql 'mysql -U'
end
if check-dependencies --program --quiet 'mariadb'
	abbr --add --global mariadb 'mariadb -U'
end
if check-dependencies --program --quiet 'mycli'
	abbr --add --global mycli 'mycli --warn'
end
if check-dependencies --program --quiet 'litecli'
	abbr --add --global litecli 'litecli --warn'
end
if check-dependencies --program --quiet 'pgcli'
	abbr --add --global pgcli 'pgcli --warn'
end

# Add colors: https://wiki.archlinux.org/index.php/Color_output_in_console
if check-dependencies --program 'diff'
	alias diff 'diff --color=auto'
end
alias grep 'grep --color=auto'
if check-dependencies --program --quiet 'egrep'
	alias egrep 'egrep --color=auto'
end
if check-dependencies --program --quiet 'fgrep'
	alias fgrep 'fgrep --color=auto'
end
if check-dependencies --program --quiet 'ip'
	if not is-platform --quiet 'android-termux'
		alias ip 'ip -color=auto'
	else
		function ip --wraps='ip' --description 'Colorful wrapper of "ip"'
			if isatty stdout
				command ip -color $argv
			else
				command ip $argv
			end
		end
	end
end

# Create and enter a temporary directory
abbr --add --global cdtemp 'cd (mktemp -d)'

if check-dependencies --program --quiet 'systemctl'
	abbr --add --global sc 'systemctl'
	abbr --add --global scr 'sudo systemctl'
	abbr --add --global scu 'systemctl --user'
end
if check-dependencies --program --quiet 'journalctl'
	abbr --add --global jcu 'journalctl --pager-end --catalog --unit'
end

# Add user agent and referer automatically
if check-dependencies --program 'curl'
	abbr --add --global curl2 (string escape -- \
		curl --location --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --retry 5)
end
if check-dependencies --program 'wget'
	abbr --add --global wget2 (string escape -- \
		wget --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --tries 5)
end

# For "pacman"
if is-platform --quiet 'pacman'
	if check-dependencies --program 'makepkg'
	and check-dependencies --program 'git'
		abbr --add --global makepkg2 \
			'makepkg --syncdeps --install && git clean -xd --interactive'
		abbr --add --global makepkg2-asdeps \
			'makepkg --asdeps --syncdeps --install && git clean -xd --interactive'
		abbr --add --global makepkg3 \
			'makepkg --syncdeps --rmdeps --install && git clean -xd --interactive'
		abbr --add --global makepkg3-asdeps \
			'makepkg --asdeps --syncdeps --rmdeps --install && git clean -xd --interactive'
	end

	if check-dependencies --program "pikaur"
		abbr --add --global pikaur2 'VISUAL= pikaur'
	end
end

# Start "samba"
if check-dependencies --program --quiet 'smbd'
and check-dependencies --program --quiet 'systemctl'
and check-dependencies --program 'ufw'
	abbr --add --global start-samba 'sudo systemctl start smb.service && sudo ufw allow in 445/tcp comment \'samba\''
	abbr --add --global restart-samba 'sudo systemctl restart smb.service && sudo ufw allow in 445/tcp comment \'samba\''
	abbr --add --global stop-samba 'sudo systemctl stop smb.service && sudo ufw delete allow in 445/tcp'
end

# Auto refresh `sudo` cached credentials
if check-dependencies --program --quiet 'sudo'
and command sudo --help 2> '/dev/null' | fgrep --quiet -- '--validate'
	function sudo --wraps='sudo' --description 'sudo'
		command sudo --validate
		and command sudo $argv
	end
	if check-dependencies --program --quiet 'sudoedit'
		function sudoedit --wraps='sudoedit' --description 'sudoedit'
			command sudo --validate
			and command sudoedit $argv
		end
	end
end

# GNU Parallel for fish shell
if check-dependencies --program 'parallel'
	function parallel --wraps 'parallel' \
	--description 'GNU Parallel for fish shell'
		set --local parallel (command --search parallel)
		and set --local tempHome (mktemp -d)
		and begin
			if test -d "$HOME"'/.parallel'
				ln -s "$HOME"'/.parallel/.' "$tempHome"'/.parallel'
			end
			and env HOME="$tempHome" XDG_CONFIG_HOME= "$parallel" $argv
			and rm -r "$tempHome"
			or begin
				set --local statusToReturn "$status"
				echo-err --warning 'Residual temporary HOME directory: '"$tempHome"
				return "$statusToReturn"
			end
		end
	end
end

# Aliases for "vim"
if check-dependencies --program 'vim'
	alias vi 'vim'
	alias ex 'vim -e'
	check-dependencies --program --quiet 'view'
	or alias view 'vim -R'
	check-dependencies --program --quiet 'rvim'
	or alias rvim 'vim -Z'
	check-dependencies --program --quiet 'rview'
	or alias rview 'vim -Z -R'
	check-dependencies --program --quiet 'vimdiff'
	or alias vimdiff 'vim -d'
end

# Use "exa"/"lsd" instead of "ls"/"ll"/"la" or "tree"
if check-dependencies --program --quiet 'exa'
	alias ls 'exa'
	alias ll 'exa --long --binary --group --links --time-style=long-iso --git'
	alias la 'exa --all --long --binary --group --links --time-style=long-iso --git'
	alias laa 'exa --all --all --long --binary --group --links --time-style=long-iso --git'
	alias tree 'exa --tree'
else if check-dependencies --program --quiet 'lsd'
	alias ls 'lsd'
	# TODO: remove legacy workarounds
	if lsd --long --date '+%Y-%m-%d %H:%M' "$HOME" > '/dev/null' 2>&1
		alias ll 'lsd --long --date \'+%Y-%m-%d %H:%M\''
		alias la 'lsd --almost-all --long --date \'+%Y-%m-%d %H:%M\''
		alias laa 'lsd --all --long --date \'+%Y-%m-%d %H:%M\''
	else
		alias ll 'lsd --long'
		alias la 'lsd --almost-all --long'
		alias laa 'lsd --all --long'
	end
	alias tree 'lsd --tree'
else if status is-interactive
	echo-err --warning 'Please install "exa"/"lsd"'
end

# Use pnpm instead of npm
if check-dependencies --program --quiet 'npm'
	if not check-dependencies --program --quiet 'pnpm'
		if status is-interactive
			echo-err --warning 'Please install "pnpm" to replace "npm"'
		end
	else
		alias plain_npm 'command npm'
		alias plain_npx 'command npx'
		function npm
			echo-err --warning 'Please use "pnpm" (or "plain_npm")'
		end
		function npx
			echo-err --warning 'Please use "pnpx" (or "plain_npx")'
		end
		function pnpm --wraps 'npm' --description 'npm replacement'
			command pnpm $argv
		end
	end
end

# Set compiler flags for C++
if is-platform --quiet 'macos'
	if check-dependencies --program 'clang++'
		alias c++17 (string join -- ' ' \
			'clang++' \
			'-std=c++17' \
			#\
			'-Wall' \
			'-Wextra' \
			'-Wconversion' \
			'-Wsign-conversion' \
			'-pedantic-errors' \
			#\
			'-Weverything' \
			'-Wno-c++98-compat' \
			'-Wno-c++98-compat-pedantic' \
			'-Wno-covered-switch-default' \
			'-Wno-unreachable-code-break' \
			'-Wno-weak-vtables' \
			'-Wno-global-constructors' \
			'-Wno-exit-time-destructors' \
			#\
			'-DDEBUG_' \
			'-g' \
			'-fPIE' \
			'-Wl,-pie' \
			#\
			'-fsanitize=address' \
			#\
			'-fsanitize=undefined' \
			'-fsanitize=float-divide-by-zero' \
			'-fsanitize=unsigned-integer-overflow' \
			'-fsanitize=implicit-conversion' \
			'-fsanitize=nullability' \
			#\
			'-fno-omit-frame-pointer' \
			'-fno-optimize-sibling-calls' \
		)
	end
else
	if check-dependencies --program 'g++'
		alias c++17 (string join -- ' ' \
			'g++' \
			'-std=c++17' \
			#\
			'-Wall' \
			'-Wextra' \
			'-Wconversion' \
			'-Wsign-conversion' \
			'-pedantic-errors' \
			# '-Werror' \
			#\
			'-DDEBUG_' \
			'-g' \
			'-fPIE' \
			'-Wl,-pie' \
		)
	end
end
