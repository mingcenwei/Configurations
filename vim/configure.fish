#!/usr/bin/env fish

# For security
umask 077

check-dependencies --program --quiet='never' 'vim' || exit 3
check-dependencies --function --quiet='never' 'back-up-files' || exit 3
check-dependencies --function --quiet='never' 'read-choice' || exit 3

# Set variables
set --local vimConfigDir "$HOME"'/.vim'
set --local vimConfigFile "$vimConfigDir"'/vimrc'
set --local legacyVimConfigFile "$HOME"'/.vimrc'
set --local stowDir "$HOME"'/.say-local/stow'
set --local thisFile (realpath -- (status filename)) || exit 1
set --local thisDir (dirname -- "$thisFile") || exit 1
set --local linkDir "$thisDir"'/files/link'

### Back up previous "vim" configurations
if test -d "$stowDir"'/vim'
or test -f "$vimConfigFile" || test -L "$vimConfigFile"
	read-choice --variable removePreviousConfigurations --default 2 \
		--prompt 'Remove previous "vim" configurations? ' -- \
		'yes' 'no' || exit 2

	set --local backupCommand 'back-up-files' '--comment' 'vim-config' '--'
	test "$removePreviousConfigurations" = 'yes'
	and set backupCommand \
		'back-up-files' '--comment' 'vim-config' '--remove-source' '--'

	set --local backupConfigs
	test -d "$stowDir"'/vim' && set --append backupConfigs "$stowDir"'/vim'
	test -f "$vimConfigFile" || test -L "$vimConfigFile"
	and set --append backupConfigs "$vimConfigFile"
	test -f "$legacyVimConfigFile" || test -L "$legacyVimConfigFile"
	and set --append backupConfigs "$legacyVimConfigFile"

	if test -n "$backupConfigs"
		$backupCommand $backupConfigs || exit 1
	end
end
###

### Add "vim" configurations
for configFile in "$vimConfigFile" "$legacyVimConfigFile"
	if test -f "$configFile" || test -L "$configFile"
		rm "$configFile" || exit 1
	end
end

mkdir -m 700 -p "$stowDir"'/vim' || exit 1
rsync --recursive  "$linkDir"/ "$stowDir"'/vim' || exit 1
stow --verbose --restow --dir "$stowDir" --target "$HOME" 'vim' || exit 1
###
