#!/usr/bin/env fish

# For security
umask 077

check-dependencies --function 'back-up-files' || exit 3
check-dependencies --function 'echo-err' || exit 3
check-dependencies --function 'is-platform' || exit 3
check-dependencies --function 'read-choice' || exit 3

# Exit if the operating system is not macOS
if not is-platform 'macos'
	exit 3
end

# Tell the user to install Karabiner-Elements if it's not installed
if not test -e '/Applications/Karabiner-Elements.app'
	check-dependencies --program 'Karabiner-Elements' || exit 3
end

### Set variables
set --local servicesConfigDir "$HOME"'/Library/Services'
set --local launchAgentsConfigDir "$HOME"'/Library/LaunchAgents'
set --local karabinerElementsConfigDir "$HOME"'/.config/karabiner'
set --local stowDir "$HOME"'/.say-local/stow'
set --local thisFile (realpath -- (status filename)) || exit 1
set --local thisDir (dirname -- "$thisFile") || exit 1
set --local linkDir "$thisDir"'/files/link'
###

### Back up previous "Services" configurations
if test -d "$stowDir"'/mac-os/Library/Services'
or test -d "$servicesConfigDir" || test -L "$servicesConfigDir"
	read-choice --variable removePreviousConfigurations --default 2 \
		--prompt 'Remove all previous "macOS Services" configurations? ' -- \
		'yes' 'no' || exit 2

	set --local backupCommand \
		'back-up-files' '--comment' 'mac_os-services-config' '--'
	test "$removePreviousConfigurations" = 'yes'
	and set backupCommand \
		'back-up-files' '--comment' 'mac_os-services-config' '--remove-source' '--'

	set --local backupConfigs
	test -d "$stowDir"'/mac-os/Library/Services'
	and set --append backupConfigs "$stowDir"'/mac-os/Library/Services'
	test -d "$servicesConfigDir" || test -L "$servicesConfigDir"
	and set --append backupConfigs "$servicesConfigDir"

	test -n "$backupConfigs" && $backupCommand $backupConfigs || exit 1
end
###

### Back up previous "LaunchAgents" configurations
begin
	set --local launchAgentsToBackUp
	for file in "$linkDir"'/Library/Services'/*
		set --local launchAgent "$launchAgentsConfigDir"/(basename -- "$file")
		if test -f "$launchAgent"
		or test -L "$launchAgent"
			# Unload and back up former agents with the same name if existing
			launchctl bootout 'gui'/(id -u) "$launchAgent"
			set --append launchAgentsToBackUp "$launchAgent"
		end

		set --local stowLaunchAgent \
			"$stowDir"'/mac-os/Library/LaunchAgents'/(basename -- "$file")
		if test -f "$stowLaunchAgent"
		or test -L "$stowLaunchAgent"
			set --append launchAgentsToBackUp "$stowLaunchAgent"
		end
	end
	test -n "$launchAgentsToBackUp"
	and back-up-files --comment 'mac_os-launch_agents-config' \
		--remove-source -- $launchAgentsToBackUp || exit 1
end
###

### Back up previous "Karabiner-Elements" configurations
if test -d "$stowDir"'/mac-os/.config/karabiner'
or test -d "$karabinerElementsConfigDir" || test -L "$karabinerElementsConfigDir"
	# Do not make a symlink to karabiner.json.
	# Karabiner-Elements does not reload the configuration file properly if you make a symlink to json file directly.
	set --local backupCommand \
		'back-up-files' '--comment' 'mac_os-karabiner_elements-config' '--remove-source' '--'

	set --local backupConfigs
	test -d "$stowDir"'/mac-os/.config/karabiner'
	and set --append backupConfigs "$stowDir"'/mac-os/.config/karabiner'
	test -d "$karabinerElementsConfigDir" || test -L "$karabinerElementsConfigDir"
	and set --append backupConfigs "$karabinerElementsConfigDir"

	test -n "$backupConfigs" && $backupCommand $backupConfigs || exit 1
end
###

### Add "macOS" configurations
for file in "$linkDir"'/Library/Services'/*
	set --local baseFilename (basename "$file")
	set --local configFile "$servicesConfigDir"/"$baseFilename"
	if test -f "$configFile" || test -L "$configFile"
		rm "$configFile" || exit 1
	end
end

mkdir -m 700 -p "$stowDir"'/mac-os' || exit 1
rsync --recursive  "$linkDir"/ "$stowDir"'/mac-os' || exit 1
stow --verbose --restow --dir "$stowDir" --target "$HOME" 'mac-os' || exit 1
###

### Reload LaunchAgents
for file in "$linkDir"'/Library/Services'/*
	set --local launchAgent "$launchAgentsConfigDir"/(basename -- "$file")
	launchctl bootstrap 'gui'/(id -u) "$launchAgent"
	or echo-err 'Failed bootstraping: '(string escape -- "$launchAgent")
end
###

### Reload Karabiner-Elements
# You have to restart karabiner_console_user_server process by the following command after you made a symlink in order to tell Karabiner-Elements that the parent directory is changed.
launchctl kickstart -k \
	'gui'/(id -u)/'org.pqrs.karabiner.karabiner_console_user_server'
or echo-err 'Failed kickstarting: org.pqrs.karabiner.karabiner_console_user_server'
###
