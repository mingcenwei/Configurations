#!/usr/bin/env fish

### Set default text editors
if not check-dependencies --program --quiet 'vim'
and status is-login && status is-interactive
	echo-err --warning '"vim" is not installed! $EDITOR will not be set'
else
	set --export --universal EDITOR (command --search vim)
end

if not check-dependencies --program --quiet 'code'
and status is-login && status is-interactive
	echo-err --warning '"Visual Studio Code" is not installed! $VISUAL will not be set'
else
	set --export --universal VISUAL (command --search code)
end
###

# In order to use GPG
set --export --global GPG_TTY (tty)

# For ssh agent
if is-platform --quiet 'kde'
	if check-dependencies --program 'ksshaskpass'
		set --export --global SSH_ASKPASS (command --search ksshaskpass)
	end
end

# Set JAVA_HOME
if check-dependencies --program --quiet 'java'
	if is-platform --quiet 'macos'
		set --export --global JAVA_HOME ('/usr/libexec/java_home')
	end
end
