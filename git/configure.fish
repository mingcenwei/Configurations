#!/usr/bin/env fish

# For security
umask 077

### Set variables
set --local gitConfigDir "$HOME"'/.config/git'
set --local stowDir "$HOME"'/.say-local/stow'
set --local thisFile (realpath (status filename)) || exit 1
set --local thisDir (dirname "$thisFile") || exit 1
set --local fixedDir "$thisDir"'/files/fixed'
###

check-dependencies --program 'git' || exit 3
check-dependencies --function 'back-up-files' || exit 3
check-dependencies --function 'echo-err' || exit 3
check-dependencies --function 'read-choice' || exit 3

# $XDG_CONFIG_HOME/git/config: Second user-specific configuration file.
# If $XDG_CONFIG_HOME is not set or empty, $HOME/.config/git/config will be used.
# Any single-valued variable set in this file will be overwritten by whatever is in ~/.gitconfig.
# It is a good idea not to create this file if you sometimes use older versions of Git, as support for this file was added fairly recently.
if test -n "$XDG_CONFIG_HOME"
	echo-err '"$XDG_CONFIG_HOME" is not empty'
	exit 2
end

# Get former git user private configurations if available
set --local privateFields 'user.name' 'user.email' 'user.signingkey'
set --local userPrivateFieldKeys
set --local userPrivateFieldValues
for field in $privateFields
	set --local pattern \
		'(?<=^'(string escape --style 'regex' -- "$field"'=')').*$'
	if set --local value \
	(string match --regex -- "$pattern" (git config --list))
		set --append userPrivateFieldKeys "$field"
		set --append userPrivateFieldValues  "$value"
	end
end

### Back up previous "git" configurations
if test -d "$stowDir"'/git'
or test -d "$gitConfigDir" || test -L "$gitConfigDir"
	read-choice --variable removePreviousConfigurations --default 2 \
		--prompt 'Remove previous "git" configurations? ' -- \
		'yes' 'no' || exit 2

	set --local backupCommand 'back-up-files' '--comment' 'git-config' '--'
	test "$removePreviousConfigurations" = 'yes'
	and set backupDirs \
		'back-up-files' '--comment' 'git-config' '--remove-source' '--'

	set --local backupConfigs
	test -d "$stowDir"'/git' && set --append backupConfigs "$stowDir"'/git'
	test -d "$gitConfigDir" || test -L "$gitConfigDir"
	and set --append backupConfigs "$gitConfigDir"

	test -n "$backupConfigs" && $backupCommand $backupConfigs || exit 1
end
###

### Add "git" configurations
mkdir -m 700 -p "$stowDir"'/git' || exit 1
rsync --archive "$fixedDir"/ "$stowDir"'/git' || exit 1
stow --verbose --restow --dir "$stowDir" --target "$HOME" 'git' || exit 1
###

### Private configurations
for field in $privateFields
	# Use previous configurations if available
	if set --local index (contains --index -- "$field" $userPrivateFieldKeys)
		git config --global "$field" "$userPrivateFieldValues[$index]"
		continue
	else if read --prompt-str "$field"' (enter none to skip): ' --local value
		set value (string trim -- "$value")
		test -n "$value" && git config --global "$field" "$value"
	end
end
###

### Platform independent configurations
# Rebase by default
git config --global 'pull.rebase' true
git config --global 'core.excludesFile' "$gitConfigDir"'/ignore'
git config --global 'gpg.program' (command -v gpg || exit 1)
###

### Platform dependent configurations
# Caching GitHub password in git
if is-platform --quiet 'macos'
	git config --global 'credential.helper' 'osxkeychain'
else if is-platform --quiet 'kde'
	check-dependencies --program 'ksshaskpass'
	and git config --global 'core.askpass' (command -v ksshaskpass)
else if is-platform --quiet 'android-termux'
	check-dependencies --program 'pass'
	and git config --global 'credential.helper' \
		'!f() { test "$1" = get && echo "url=$(pass show GitHub)"; }; f'
	and pass > '/dev/null'
end
###
