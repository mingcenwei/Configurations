#!/usr/bin/env fish

# For security
umask 077

check-dependencies --program --quiet='never' 'gpg' || exit 3
check-dependencies --program --quiet='never' 'gpg-agent' || exit 3
check-dependencies --function --quiet='never' 'back-up-files' || exit 3
check-dependencies --function --quiet='never' 'echo-err' || exit 3
check-dependencies --function --quiet='never' 'read-choice' || exit 3

# Set variables
set --local gpgConfigDir "$HOME"'/.gnupg'
set --local gpgConfigFile "$gpgConfigDir"'/gpg.conf'
set --local gpgAgentConfigFile "$gpgConfigDir"'/gpg-agent.conf'
set --local stowDir "$HOME"'/.say-local/stow'
set --local thisFile (realpath -- (status filename)) || exit 1
set --local thisDir (dirname -- "$thisFile") || exit 1
set --local linkDir "$thisDir"'/files/link'

### Back up previous "gpg" configurations
if test -d "$stowDir"'/gpg'
or test -f "$gpgConfigFile" || test -L "$gpgConfigFile"
or test -f "$gpgAgentConfigFile" || test -L "$gpgAgentConfigFile"
	read-choice --variable removePreviousConfigurations --default 2 \
		--prompt 'Remove previous "gpg" configurations? ' -- \
		'yes' 'no' || exit 2

	set --local backupCommand 'back-up-files' '--comment' 'gpg-config' '--'
	test "$removePreviousConfigurations" = 'yes'
	and set backupCommand \
		'back-up-files' '--comment' 'gpg-config' '--remove-source' '--'

	set --local backupConfigs
	test -d "$stowDir"'/gpg' && set --append backupConfigs "$stowDir"'/gpg'
	test -f "$gpgConfigFile" || test -L "$gpgConfigFile"
	and set --append backupConfigs "$gpgConfigFile"
	test -f "$gpgAgentConfigFile" || test -L "$gpgAgentConfigFile"
	and set --append backupConfigs "$gpgAgentConfigFile"

	if test -n "$backupConfigs"
		$backupCommand $backupConfigs || exit 1
	end
end
###

### Add "gpg" configurations
for configFile in "$gpgConfigFile" "$gpgAgentConfigFile"
	if test -f "$configFile" || test -L "$configFile"
		rm "$configFile" || exit 1
	end
end

mkdir -m 700 -p "$stowDir"'/gpg' || exit 1
rsync --recursive  "$linkDir"/ "$stowDir"'/gpg' || exit 1
stow --verbose --restow --dir "$stowDir" --target "$HOME" 'gpg' || exit 1
###

if is-platform --quiet 'kde'
	if check-dependencies --program --quiet='never' 'pinentry-qt'
		echo 'pinentry-program '(command --search pinentry-qt) \
			>> "$gpgAgentConfigFile"
	end
end

### Generate key pairs
if test (gpg --list-secret-keys --keyid-format LONG | wc -l) -eq 0
	echo-err --warning 'No existing gpg secret keys found'
else
	echo-err --info 'Existing secret keys:'
	gpg --list-secret-keys --keyid-format LONG
end
while true
	read-choice --variable generateKeyPair \
	--prompt 'Generate a new "gpg" key pair? ' -- \
	'yes' 'no'
	and test "$generateKeyPair" = 'yes'
	or break

	gpg --full-generate-key
end
###

killall 'gpg-agent' 2> '/dev/null' || true
