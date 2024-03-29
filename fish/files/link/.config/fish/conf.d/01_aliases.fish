#!/usr/bin/env fish

# Filesystem safety measures
if is-platform --quiet 'linux'
	alias rm 'rm --preserve-root=all --one-file-system'
	abbr --add rm 'rm -I'
	abbr --add rmi 'rm -I'

	alias chmod 'chmod --preserve-root'
	alias chown 'chown --preserve-root'
	alias chgrp 'chgrp --preserve-root'
else
	if check-dependencies --program 'grm'
		alias grm 'grm --preserve-root=all --one-file-system'
		alias rm 'grm'
		abbr --add rm 'rm -I'
		abbr --add rmi 'rm -I'
	else
		abbr --add rm 'rm -i'
		abbr --add rmi 'rm -i'
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
abbr --add cp 'cp -i'
abbr --add cpi 'cp -i'
abbr --add mv 'mv -i'
abbr --add mvi 'mv -i'
#abbr --add ln 'ln -i'
abbr --add lni 'ln -i'

# Database safety measures
if check-dependencies --program --quiet 'mysql'
	abbr --add mysql 'mysql -U'
end
if check-dependencies --program --quiet 'mariadb'
	abbr --add mariadb 'mariadb -U'
end
if check-dependencies --program --quiet 'mycli'
	abbr --add mycli 'mycli --warn'
end
if check-dependencies --program --quiet 'litecli'
	abbr --add litecli 'litecli --warn'
end
if check-dependencies --program --quiet 'pgcli'
	abbr --add pgcli 'pgcli --warn all'
end

# `sudo` for docker
if check-dependencies --program --quiet 'docker'
	if is-platform --quiet 'linux'
		abbr --add docker 'sudo docker'
	end
end

# Add colors: https://wiki.archlinux.org/index.php/Color_output_in_console
if check-dependencies --program 'diff'
	if test 3 -gt (diff --version | head -n 1 | string match --regex '\\d+')
		echo-err 'Please install newer "diff" (from "GNU diffutils")'
	else
		alias diff 'diff --color=auto'
	end
	abbr --add diff-dirs 'diff --recursive --brief --no-dereference'
end
alias grep 'grep --color=auto'
if check-dependencies --program --quiet 'egrep'
	alias egrep 'grep -E --color=auto'
end
if check-dependencies --program --quiet 'fgrep'
	alias fgrep 'grep -F --color=auto'
end
abbr --add egrep 'grep -E'
abbr --add fgrep 'grep -F'
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
abbr --add cdtemp 'cd (mktemp -d) ; pwd'

if check-dependencies --program --quiet 'systemctl'
	abbr --add sc 'systemctl'
	abbr --add scr 'sudo systemctl'
	abbr --add scu 'systemctl --user'
end
if check-dependencies --program --quiet 'journalctl'
	abbr --add jcu 'journalctl --pager-end --catalog --unit'
end

# Add user agent and referer automatically
if check-dependencies --program 'curl'
	abbr --add curl2 (string escape -- \
		curl --location --compressed --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --retry 5)
end
if check-dependencies --program 'wget'
	abbr --add wget2 (string escape -- \
		wget --compression 'auto' --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --tries 5)
end
if check-dependencies --program --quiet 'youtube-dl'
	abbr --add youtube-dl2 (string escape -- \
		youtube-dl --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --retries 5)
end
if check-dependencies --program --quiet 'yt-dlp'
	abbr --add yt-dlp2 (string escape -- \
		yt-dlp --user-agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2725.0 Safari/537.36' --referer 'https://www.google.com/' --retries 5)
else if not check-dependencies --program --quiet 'youtube-dl'
and status is-interactive
	echo-err --warning 'Please install "yt-dlp"/"youtube-dl"'
end

# For "date"
abbr --add date2 'date +\'%Y-%m-%d_%H-%M-%S\''
abbr --add date2-u 'date -u +\'%Y-%m-%d_%H-%M-%S\''

# For "pgrep"
if check-dependencies --program 'pgrep'
	abbr --add pgrep2 'pgrep -fia'
end
# For "pkill"
if check-dependencies --program 'pkill'
	abbr --add pkill2 'pkill -fi'
end

# For "git"
if check-dependencies --program 'git'
	abbr --add git-root 'git rev-parse --show-toplevel'
end

# For "rsync"
if check-dependencies --program 'rsync'
	abbr --add rsync2 'rsync -hh --info=stats1,progress2'
	abbr --add rsync2-p 'rsync -hh --info=stats1,progress2 --partial'

	if not is-platform --quiet 'android-termux'
		abbr --add rsync2-a 'rsync -hh --info=stats1,progress2 -aHSAX'
		abbr --add rsync2-pa \
			'rsync -hh --info=stats1,progress2 --partial -aHSAX'
		abbr --add rsync2-ap \
			'rsync -hh --info=stats1,progress2 --partial -aHSAX'
	else
		abbr --add rsync2-a 'rsync -hh --info=stats1,progress2 -aHS'
		abbr --add rsync2-pa \
			'rsync -hh --info=stats1,progress2 --partial -aHS'
		abbr --add rsync2-ap \
			'rsync -hh --info=stats1,progress2 --partial -aHS'
	end

	abbr --add diff-rsync-r 'rsync --dry-run -v --delete -rlD'
	abbr --add diff-rsync-rc 'rsync --dry-run -v --delete -rlD --checksum'
	abbr --add diff-rsync-cr 'rsync --dry-run -v --delete -rlD --checksum'
	abbr --add diff-rsync-a 'rsync --dry-run -v --delete -a'
	abbr --add diff-rsync-ac 'rsync --dry-run -v --delete -a --checksum'
	abbr --add diff-rsync-ca 'rsync --dry-run -v --delete -a --checksum'
	if not is-platform --quiet 'android-termux'
		abbr --add diff-rsync-A 'rsync --dry-run -v --delete -aHAX'
		abbr --add diff-rsync-Ac 'rsync --dry-run -v --delete -aHAX --checksum'
		abbr --add diff-rsync-cA 'rsync --dry-run -v --delete -aHAX --checksum'
	else
		abbr --add diff-rsync-A 'rsync --dry-run -v --delete -aH'
		abbr --add diff-rsync-Ac 'rsync --dry-run -v --delete -aH --checksum'
		abbr --add diff-rsync-cA 'rsync --dry-run -v --delete -aH --checksum'
	end
end

# For "rclone"
if check-dependencies --program 'rclone'
	abbr --add 'rclone2' 'rclone -ivP'
end

# For "pacman"
if is-platform --quiet 'pacman'
	if check-dependencies --program 'makepkg'
	and check-dependencies --program 'git'
		abbr --add makepkg2 \
			'makepkg --syncdeps --install && git clean -xd --interactive'
		abbr --add makepkg2-d \
			'makepkg --asdeps --syncdeps --install && git clean -xd --interactive'
		abbr --add makepkg2-r \
			'makepkg --syncdeps --rmdeps --install && git clean -xd --interactive'
		abbr --add makepkg2-dr \
			'makepkg --asdeps --syncdeps --rmdeps --install && git clean -xd --interactive'
		abbr --add makepkg2-rd \
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
	abbr --add brew2 'HOMEBREW_NO_AUTO_UPDATE=1 brew'
end

# Start "samba"
if check-dependencies --program --quiet 'smbd'
and check-dependencies --program --quiet 'systemctl'
and check-dependencies --program 'ufw'
	abbr --add start-samba 'sudo systemctl start smb.service && sudo ufw allow in 445/tcp comment \'samba\''
	abbr --add restart-samba 'sudo systemctl restart smb.service && sudo ufw allow in 445/tcp comment \'samba\''
	abbr --add stop-samba 'sudo systemctl stop smb.service && sudo ufw delete allow in 445/tcp'
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
	alias ll 'lsd --long --date \'+%Y-%m-%d %H:%M\''
	alias la 'lsd --almost-all --long --date \'+%Y-%m-%d %H:%M\''
	alias laa 'lsd --all --long --date \'+%Y-%m-%d %H:%M\''
	alias tree 'lsd --tree'
else if status is-interactive
	echo-err --warning 'Please install "exa"/"lsd"'
end

# List files (unsafe - not null delimited)
function __sayAnonymousNamespace_list-files_helper
	set --local args (string match --regex --groups-only -- '^(newest|oldest|first|last)\\-(\\d+)$' "$argv")
	set --local mode "$args[1]"
	set --local number "$args[2]"
	switch "$mode"
	case 'newest'
		echo -- "command ls -1 --sort='time' | head -n $number | tac"
	case 'oldest'
		echo -- "command ls -1 -r --sort='time' | head -n $number"
	case 'first'
		echo -- "command ls -1 --sort='version' | head -n $number"
	case 'last'
		echo -- "command ls -1 -r --sort='version' | head -n $number | tac"
	case '*'
		return 1
	end
end
abbr --add 'list-files' --position 'anywhere' --regex '(?:newest|oldest|first|last)\\-\\d+' --function '__sayAnonymousNamespace_list-files_helper'

# Use pnpm instead of npm
if check-dependencies --program 'npm'
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
