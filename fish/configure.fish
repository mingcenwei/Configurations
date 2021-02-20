#!/usr/bin/env fish

# Make sure that the "fish" shell is used
test -z "$fish_pid" && echo 'Error: The shell is not "fish"!' >&2 && exit 3

# For security
umask 077

# Set variables
set --local fishConfigDir "$HOME"'/.config/fish'
set --local stowDir "$HOME"'/.say-local/stow'
set --local thisFile (realpath -- (status filename)) || exit 1
set --local thisDir (dirname -- "$thisFile") || exit 1
set --local linkDir "$thisDir"'/files/link'
set --local onceDir "$thisDir"'/files/once'
set --local functionDir "$linkDir"'/.config/fish/functions'

# Load required functions
for file in "$functionDir"/*
	source -- "$file" || exit
end
or exit 3

check-dependencies --program 'stow' || exit 3
check-dependencies --program 'rsync' || exit 3

### Change the default login shell to "fish" if possible
test "$SHELL" = (command -v fish)
or if is-platform --quiet 'android-termux'
	# For Android Termux
	chsh -s 'fish'
else
	chsh -s (command -v fish)
end
# If the default login shell isn't changed to "fish" successfully,
# e.g. when "fish" was installed by "Homebrew" to the user's local directory
or echo-err 'The default login shell isn\'t changed. Maybe you installed the fish shell with Homebrew to your local directory. Please change the default login shell to "fish" mannualy. For example, append the line "exec <path-to-fish>" to ".bash_profile"'
###

### Back up previous "fish" configurations
if test -d "$stowDir"'/fish'
or test -d "$fishConfigDir" || test -L "$fishConfigDir"
	read-choice --variable removePreviousConfigurations --default 2 \
		--prompt 'Remove previous "fish" configurations? ' -- \
		'yes' 'no' || exit 2

	set --local backupCommand 'back-up-files' '--comment' 'fish-config' '--'
	test "$removePreviousConfigurations" = 'yes'
	and set backupCommand \
		'back-up-files' '--comment' 'fish-config' '--remove-source' '--'

	set --local backupConfigs
	test -d "$stowDir"'/fish' && set --append backupConfigs "$stowDir"'/fish'
	test -d "$fishConfigDir" || test -L "$fishConfigDir"
	and set --append backupConfigs "$fishConfigDir"

	test -n "$backupConfigs" && $backupCommand $backupConfigs || exit 1
end
###

### Add "fish" configurations
mkdir -m 700 -p "$stowDir"'/fish' || exit 1
rsync --recursive "$linkDir"/ "$stowDir"'/fish' || exit 1
stow --verbose --restow --dir "$stowDir" --target "$HOME" 'fish' || exit 1
###

# Configurations that are only run once
for file in "$onceDir"/*
	source -- "$file" || exit
end
or exit 3

echo-err --info 'Run `exec fish` to use the new configurations'
