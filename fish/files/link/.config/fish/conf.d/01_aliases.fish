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
		alias rm 'grm'
		abbr --add --global rm 'rm -I'
		abbr --add --global rmi 'rm -I'
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
	abbr --add --global pgcli 'pgcli --warn all'
end

# Add colors: https://wiki.archlinux.org/index.php/Color_output_in_console
if check-dependencies --program 'diff'
	if test 3 -gt (diff --version | head -n 1 | string match --regex '\\d+')
		echo-err 'Please install newer "diff" (from "GNU diffutils")'
	else
		alias diff 'diff --color=auto'
	end
end
alias grep 'grep --color=auto'
if check-dependencies --program --quiet 'egrep'
	alias egrep 'grep -E --color=auto'
end
if check-dependencies --program --quiet 'fgrep'
	alias fgrep 'grep -F --color=auto'
end
abbr --add --global egrep 'grep -E'
abbr --add --global fgrep 'grep -F'
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
		curl --location --compressed --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --retry 5)
end
if check-dependencies --program 'wget'
	abbr --add --global wget2 (string escape -- \
		wget --compression 'auto' --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --tries 5)
end
if check-dependencies --program 'youtube-dl'
	abbr --add --global youtube-dl2 (string escape -- \
		youtube-dl --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --retries 5)
end

# For "date"
abbr --add --global date2 'date +\'%Y-%m-%d_%H-%M-%S\''
abbr --add --global date2-u 'date -u +\'%Y-%m-%d_%H-%M-%S\''

# For "pgrep"
if check-dependencies --program 'pgrep'
	abbr --add --global pgrep2 'pgrep -fia'
end
# For "pkill"
if check-dependencies --program 'pkill'
	abbr --add --global pkill2 'pkill -fi'
end

# For "fzf"
if check-dependencies --program 'fzf'
	fzf_key_bindings
end

# For "git"
if check-dependencies --program 'git'
	abbr --add --global git-root 'git rev-parse --show-toplevel'
end

# For "rsync"
if check-dependencies --program 'rsync'
	abbr --add --global rsync2 'rsync -hh --info=stats1,progress2'
	abbr --add --global rsync2-p 'rsync -hh --info=stats1,progress2 --partial'

	if not is-platform --quiet 'android-termux'
		abbr --add --global rsync2-a 'rsync -hh --info=stats1,progress2 -aHSAX'
		abbr --add --global rsync2-pa \
			'rsync -hh --info=stats1,progress2 --partial -aHSAX'
		abbr --add --global rsync2-ap \
			'rsync -hh --info=stats1,progress2 --partial -aHSAX'
	else
		abbr --add --global rsync2-a 'rsync -hh --info=stats1,progress2 -aHS'
		abbr --add --global rsync2-pa \
			'rsync -hh --info=stats1,progress2 --partial -aHS'
		abbr --add --global rsync2-ap \
			'rsync -hh --info=stats1,progress2 --partial -aHS'
	end
end

# For "rclone"
if check-dependencies --program 'rclone'
	abbr --add --global 'rclone2' 'rclone -ivP'

	if check-dependencies --program 'pass'
		function rclone --wraps='rclone' --description 'rclone'
			pass ls > '/dev/null'; true
			command rclone --password-command='pass show rclone_config' --ask-password=false $argv
		end
	else
		function rclone --wraps='rclone' --description 'rclone'
			if test -z "$RCLONE_CONFIG_PASS"
				echo 'Enter configuration password: '
				read --global --silent --prompt-str='password: ' RCLONE_CONFIG_PASS
			end
			RCLONE_CONFIG_PASS="$RCLONE_CONFIG_PASS" command rclone --ask-password=false $argv
		end
	end
end

# For "pacman"
if is-platform --quiet 'pacman'
	if check-dependencies --program 'makepkg'
	and check-dependencies --program 'git'
		abbr --add --global makepkg2 \
			'makepkg --syncdeps --install && git clean -xd --interactive'
		abbr --add --global makepkg2-d \
			'makepkg --asdeps --syncdeps --install && git clean -xd --interactive'
		abbr --add --global makepkg2-r \
			'makepkg --syncdeps --rmdeps --install && git clean -xd --interactive'
		abbr --add --global makepkg2-dr \
			'makepkg --asdeps --syncdeps --rmdeps --install && git clean -xd --interactive'
		abbr --add --global makepkg2-rd \
			'makepkg --asdeps --syncdeps --rmdeps --install && git clean -xd --interactive'
	end

	if check-dependencies --program "pikaur"
		function pikaur --wraps='pikaur' --description 'pikaur'
			env --unset='VISUAL' pikaur $argv
		end
	end
end

# For "moreutils"
if check-dependencies --program "vidir"
	function vidir --wraps='vidir' --description 'vidir'
		env --unset='VISUAL' vidir $argv
	end
end
if check-dependencies --program "vipe"
	function vipe --wraps='vipe' --description 'vipe'
		env --unset='VISUAL' vipe $argv
	end
end

# For Homebrew
if is-platform --quiet 'homebrew'
	abbr --add --global brew2 'HOMEBREW_NO_AUTO_UPDATE=1 brew'
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
and command sudo --help 2> '/dev/null' | grep -F --quiet -- '--validate'
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
