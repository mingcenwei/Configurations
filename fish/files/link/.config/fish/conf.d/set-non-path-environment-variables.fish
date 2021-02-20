#!/usr/bin/env fish

### Set default text editors
if not check-dependencies --program --quiet 'vim'
	echo-err --warning '"vim" is not installed! $EDITOR will not be set'
else
	set --export --universal EDITOR (command -v vim)
end

if not check-dependencies --program --quiet 'code'
	echo-err --warning '"Visual Studio Code" is not installed! $VISUAL will not be set'
else
	set --export --universal VISUAL (command -v code)
end
###

# In order to use GPG
set --export --global GPG_TTY (tty)

# Set JAVA_HOME
if check-dependencies --program --quiet 'java'
	if is-platform --quiet 'macos'
		set --export --global JAVA_HOME ('/usr/libexec/java_home')
	end
end
