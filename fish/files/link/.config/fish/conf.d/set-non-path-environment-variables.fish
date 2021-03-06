#!/usr/bin/env fish

# Set XDG variables
set --export --global XDG_CACHE_HOME "$HOME"'/.cache'
set --export --global XDG_CONFIG_HOME "$HOME"'/.config'
set --export --global XDG_DATA_HOME "$HOME"'/.local/share'

# For "less"
set --export --global PAGER 'less'
set --export --global LESS  \
	'--ignore-case' '--status-column' '--LONG-PROMPT' '--RAW-CONTROL-CHARS' \
	'--HILITE-UNREAD' '--tabs=4' '--window=-3'
set --export --global LESS_TERMCAP_mb (set_color --bold 'brmagenta')
set --export --global LESS_TERMCAP_md (set_color --bold 'brred')
set --export --global LESS_TERMCAP_me (set_color 'normal')
set --export --global LESS_TERMCAP_so (set_color --bold --background 'cyan' 'white')
set --export --global LESS_TERMCAP_se (set_color 'normal')
set --export --global LESS_TERMCAP_us (set_color --underline --bold 'brblue')
set --export --global LESS_TERMCAP_ue (set_color 'normal')

### Set default text editors
if not check-dependencies --program --quiet 'vim'
	if status is-interactive
		echo-err --warning '"vim" is not installed! $EDITOR will not be set'
	end
else
	set --export --universal EDITOR (command --search vim)
	set --export --universal SUDO_EDITOR (command --search vim)
end

if not check-dependencies --program --quiet 'code'
	if status is-interactive
		echo-err --warning '"Visual Studio Code" is not installed! $VISUAL will not be set'
	end
else
	set --export --universal VISUAL (command --search code)
end
###

# In order to use GPG
set --export --global GPG_TTY (tty)

# For Homebrew
if is-platform --quiet 'homebrew'
	# Discouraged, see https://github.com/Homebrew/brew/issues/1670#issuecomment-267847105
	#set --export --global HOMEBREW_NO_AUTO_UPDATE 1

	set --export --global HOMEBREW_AUTO_UPDATE_SECS (math 3600 '*' 24)
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

# For ruby
if check-dependencies --program --quiet 'ruby'
	set --export --global GEM_HOME (ruby -e 'puts Gem.user_dir')
	add-paths --append --variable PATH "$GEM_HOME"'/bin'
end
