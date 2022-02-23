#!/usr/bin/env fish

# Set XDG variables
begin
	set --export --global XDG_CACHE_HOME "$HOME"'/.cache'
	set --export --global XDG_CONFIG_HOME "$HOME"'/.config'
	set --export --global XDG_DATA_HOME "$HOME"'/.local/share'
end

# Appended to "$PATH"
begin
	# Append "$HOME/.local/bin" to "$PATH"
	fish_add_path --global --append --path "$HOME"'/.local/bin'

	# For Termux
	if is-platform --quiet 'android-termux'
		fish_add_path --global --append --path "$HOME"'/bin' "$PREFIX"'/local/bin'
	end

	# For Cargo
	if check-dependencies --program --quiet 'cargo'
		fish_add_path --global --append --path "$HOME"'/.cargo/bin'
	end

	# For ruby
	if check-dependencies --program --quiet 'ruby'
		set --export --global GEM_HOME (ruby -e 'puts Gem.user_dir')
		fish_add_path --global --append --path "$GEM_HOME"'/bin'
	end
end

# Prepended to "$PATH"
begin
	# For snap
	fish_add_path --global '/snap/bin'

	# For pyenv
	begin
		set --export --global PYENV_ROOT "$HOME"'/.pyenv'
		fish_add_path --global "$PYENV_ROOT"'/bin'
		if check-dependencies --program --quiet 'pyenv'
			status is-login && pyenv init --path | source
			status is-interactive && pyenv init - | source
		end
	end
end

# Set "$MANPATH"
if is-platform --quiet 'android-termux'
	add-paths --append --variable MANPATH "$PREFIX"'/share/man' "$PREFIX"'/local/share/man'
else if is-platform --quiet 'linux'
	add-paths --append --variable MANPATH '/usr/share/fish/man' '/usr/share/man' '/usr/local/share/man' '/usr/local/man'
end

# Set default text editors
begin
	if not check-dependencies --program --quiet 'vim'
		if status is-interactive
			echo-err --warning '"vim" is not installed! $EDITOR will not be set'
		end
	else
		set --export --global EDITOR (command --search vim)
		set --export --global SUDO_EDITOR (command --search vim)
	end

	if not check-dependencies --program --quiet 'code'
		if status is-interactive
			echo-err --warning '"Visual Studio Code" is not installed! $VISUAL will not be set'
		end
	else
		set --export --global VISUAL (command --search code)
	end
end

# Set default browser
begin
	if check-dependencies --program --quiet 'firefox-developer-edition'
		set --export --global BROWSER (command --search firefox-developer-edition)
	end
end

# For "less"
begin
	set --export --global PAGER 'less'
	set --export --global LESS  '--ignore-case' '--status-column' '--LONG-PROMPT' '--RAW-CONTROL-CHARS' '--HILITE-UNREAD' '--tabs=4' '--window=-3'
	set --export --global LESS_TERMCAP_mb (set_color --bold 'brmagenta')
	set --export --global LESS_TERMCAP_md (set_color --bold 'brred')
	set --export --global LESS_TERMCAP_me (set_color 'normal')
	set --export --global LESS_TERMCAP_so (set_color --bold --background 'cyan' 'white')
	set --export --global LESS_TERMCAP_se (set_color 'normal')
	set --export --global LESS_TERMCAP_us (set_color --underline --bold 'brblue')
	set --export --global LESS_TERMCAP_ue (set_color 'normal')
end

# Fore GPG
set --export --global GPG_TTY (tty)

# For Homebrew
begin
	# Discouraged, see https://github.com/Homebrew/brew/issues/1670#issuecomment-267847105
	#set --export --global HOMEBREW_NO_AUTO_UPDATE 1

	set --export --global HOMEBREW_AUTO_UPDATE_SECS (math '3600 * 24')
end

# For ssh agent
if is-platform --quiet 'kde'
	if check-dependencies --program 'ksshaskpass'
		set --export --global SSH_ASKPASS (command --search ksshaskpass)
	end
end

# Set JAVA_HOME
if is-platform --quiet 'macos'
	if set --local javaHome ('/usr/libexec/java_home' 2> '/dev/null')
		set --export --global JAVA_HOME "$javaHome"
	end
end

# For nvm
set --export --global NVM_DIR "$HOME"'/.nvm'
