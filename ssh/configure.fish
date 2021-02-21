#!/usr/bin/env fish

# For security
umask 077

check-dependencies --function 'back-up-files' || exit 3
check-dependencies --function 'echo-err' || exit 3
check-dependencies --function 'is-platform' || exit 3
check-dependencies --function 'read-choice' || exit 3

# Set variables
set --global sshClientConfigDir "$HOME"'/.ssh'
set --global sshClientConfigFile "$sshClientConfigDir"'/config'
set --global sshServerConfigDir '/etc/ssh'
if is-platform --quiet 'android-termux'
	set sshServerConfigDir "$PREFIX"'/etc/ssh'
end
set --global sshServerConfigFile "$sshServerConfigDir"'/sshd_config'
set --global sshServerConfigHome (dirname -- "$sshServerConfigDir") || exit 1
set --global stowDir "$HOME"'/.say-local/stow'
set --global thisFile (realpath -- (status filename)) || exit 1
set --global thisDir (dirname -- "$thisFile") || exit 1
set --global clientLinkDir "$thisDir"'/files/link-client'
set --global serverLinkDir "$thisDir"'/files/link-server'

set --global formerSshClientConfigHostCount 0
function getFormerSshClientConfigHosts
	if not test -f "$sshClientConfigFile"
		return
	end

	if cat "$sshClientConfigFile" | \
	string match --regex --invert '^(Host |\\t|\\#).*$' | \
	string match --regex --invert '^\\s*$' > '/dev/null'
		echo-err --warning 'Unknown ssh client config format'
	end

	set --local lines (cat "$sshClientConfigFile") || return 1
	set --local isInWildcardHost 'false'
	for line in $lines
		set --local fieldName \
			(string lower -- \
			(string trim -- \
			(string sub --length 5 -- \
			(string trim -- "$line"))))
		if test 'host' = "$fieldName"
			set --local host \
				(string trim -- \
				(string sub --start 6 -- \
				(string trim -- "$line")))
			if test '*' = "$host"
				set isInWildcardHost 'true'
				continue
			else
				set isInWildcardHost 'false'
				set formerSshClientConfigHostCount \
					(math "$formerSshClientConfigHostCount" + 1)
				set --global \
					formerSshClientConfigHost"$formerSshClientConfigHostCount" \
					"$line"
				continue
			end
		else if test "$isInWildcardHost" = 'true'
			continue
		else if test -z (string trim -- "$line")
			continue
		else
			set --append \
				formerSshClientConfigHost"$formerSshClientConfigHostCount" \
				"$line"
			continue
		end
	end
end

set --global sshClientConfigTempFile
function addSshClientConfigHosts
	set --local tempFile (mktemp) || return 1
	set sshClientConfigTempFile "$tempFile"
	for hostNumber in (seq "$formerSshClientConfigHostCount")
		set --local host 'formerSshClientConfigHost'"$hostNumber"
		for line in $$host
			echo "$line" >> "$tempFile"
		end
		echo >> "$tempFile"
	end

	# Ask the user to add new client-side host configurations
	echo 'Adding new ssh hosts'
	read --prompt-str 'Host (enter none to end): ' --local hostHost
	and begin
		set hostHost (string trim -- "$hostHost") || true
	end
	and while test -n "$hostHost"
		read --prompt-str 'Hostname: ' --local hostHostname
		and begin
			set hostHostname (string trim -- "$hostHostname") || true
		end
		and read --prompt-str 'User: ' --local hostUser
		and begin
			set hostUser (string trim -- "$hostUser") || true
		end
		and read --prompt-str 'Port (enter none to use the default): ' \
			--hostPort hostPort
		and begin
			set hostPort (string trim -- "$hostPort") || true
		end
		and read --prompt-str 'IdentityFile (enter none to use the default): ' \
			--local hostIdentityFile
		and begin
			set hostIdentityFile (string trim -- "$hostIdentityFile") || true
		end
		and if test -z "$hostHostname"
			echo-err '"Hostname" cannot be empty'
		else if test -z "$hostUser"
			echo-err '"User" cannot be empty'
		else
			echo 'Host '"$hostHost" >> "$tempFile"
			echo \t'Hostname '"$hostHostname" >> "$tempFile"
			echo \t'User '"$hostUser" >> "$tempFile"
			test -n "$hostPort"
			and echo \t'Port '"$hostPort" >> "$tempFile"
			test -n "$hostIdentityFile"
			and echo \t'IdentityFile '"$hostIdentityFile" >> "$tempFile"
			echo >> "$tempFile"
			echo
		end

		read --prompt-str 'Host (enter none to end): ' hostHost
		and begin
			set hostHost (string trim -- "$hostHost") || true
		end
		or set --erase hostHost
	end
	return 0
end

# For clients, add ~/.ssh/config
function configureSshClient
	check-dependencies --program 'ssh' || return 3

	getFormerSshClientConfigHosts
	addSshClientConfigHosts || return

	### Back up previous "ssh" client configurations
	if test -d "$stowDir"'/ssh-client'
	or test -f "$sshClientConfigFile" || test -L "$sshClientConfigFile"
		read-choice --variable removePreviousConfigurations --default 2 \
			--prompt 'Remove previous "ssh" client configurations? ' -- \
			'yes' 'no' || return 2

		set --local backupCommand \
			'back-up-files' '--comment' 'ssh_client-config' '--'
		test "$removePreviousConfigurations" = 'yes'
		and set backupCommand \
			'back-up-files' '--comment' 'ssh_client-config' '--remove-source' '--'

		set --local backupConfigs
		test -d "$stowDir"'/ssh-client'
		and set --append backupConfigs "$stowDir"'/ssh-client'
		test -f "$sshClientConfigFile" || test -L "$sshClientConfigFile"
		and set --append backupConfigs "$sshClientConfigFile"

		if test -n "$backupConfigs"
			$backupCommand $backupConfigs || return 1
		end
	end
	###

	### Add "ssh" client configurations
	for configFile in "$sshClientConfigFile"
		if test -f "$configFile" || test -L "$configFile"
			rm "$configFile" || exit 1
		end
	end

	mkdir -m 700 -p "$stowDir"'/ssh-client' || return 1
	rsync --recursive  "$clientLinkDir"/ "$stowDir"'/ssh-client' || return 1
	stow --verbose --restow --dir "$stowDir" --target "$HOME" 'ssh-client'
	or return 1
	###
	if is-platform --quiet 'macos'
		echo \t'UseKeychain yes' >> "$sshClientConfigFile"
	end

	cat "$sshClientConfigFile" >> "$sshClientConfigTempFile"
	and cat "$sshClientConfigTempFile" > "$sshClientConfigFile"
	or echo-err 'Cannot add former ssh client-side hosts'

	rm "$sshClientConfigTempFile"

	echo-err --info 'Please review and/or edit the client-side ssh config file'
	read --prompt-str 'Enter anything to continue: ' > '/dev/null'
	set --local editor 'vi'
	if test -n "$EDITOR" && check-dependencies --program --quiet "$EDITOR"
		set editor "$EDITOR"
	end
	"$editor" "$sshClientConfigFile"

	check-dependencies --program 'ssh-keygen'
	echo-err --info 'You perhaps need to run: ssh-keygen'
end

set --global formerSshServerConfigMatchCount 0
set --global formerSshServerConfigPorts
function getFormerSshServerConfigMatches
	if not test -f "$sshServerConfigDir"
		return
	end

	set --local lines (sudo cat "$sshServerConfigDir") || return 1
	set --local isInMatch 'false'
	for line in $lines
		set --local fieldNamePort \
			(string lower -- \
			(string trim -- \
			(string sub --length 5 -- \
			(string trim -- "$line"))))
		set --local fieldNameMatch \
			(string lower -- \
			(string trim -- \
			(string sub --length 6 -- \
			(string trim -- "$line"))))
		if test "$isInMatch" = 'false'
			if test 'port' = "$fieldNamePort"
				set --local ports \
					(string split -- ' ' \
					(string trim -- \
					(string sub --start 6 -- \
					(string trim -- "$line"))))
				for port in $ports
					if test -n "$port"
						set --append formerSshServerConfigPorts "$port"
					end
				end
			else if test 'match' = "$fieldNameMatch"
				set isInMatch 'true'
				set formerSshServerConfigMatchCount \
					(math "$formerSshServerConfigMatchCount" + 1)
				set --global \
					formerSshServerConfigMatch"$formerSshServerConfigMatchCount" \
					"$line"
				continue
			else
				continue
			end
		else
			if test 'match' = "$fieldNameMatch"
				set formerSshServerConfigMatchCount \
					(math "$formerSshServerConfigMatchCount" + 1)
				set --global \
					formerSshServerConfigMatch"$formerSshServerConfigMatchCount" \
					"$line"
				continue
			else if test -z (string trim -- "$line")
				continue
			else
				set --append \
					formerSshServerConfigMatch"$formerSshServerConfigMatchCount" \
					"$line"
			end
		end
	end
end

function changePassword
	read-choice --variable changePassword --default 1 \
		--prompt 'Change user and root password? ' -- 'yes' 'no' || return 2
	if test "$changePassword" = 'yes'
		echo-err --info 'Change current user\'s password'
		passwd
		if test (id -u) -ne 0
			echo-err --info 'Change root password'
			sudo passwd
		end
	end
	true
end

function addAuthorizedKeys --argument-names username authorizedKeysFile
	set username (string trim -- "$username")
	set authorizedKeysFile (string trim -- "$authorizedKeysFile")
	test -z "$username" && return 2
	if test -z "$authorizedKeysFile"
		# See https://unix.stackexchange.com/questions/247576/how-to-get-home-given-user
		#set --local userHome (getent passwd "$username" | cut -d ':' -f 6)
		set --local userHome \
			(sudo su -s (command -v fish) -l "$username" -c 'echo "$HOME"')
		or return 2
		set --local sshDir "$userHome"'/.ssh'
		set authorizedKeysFile "$sshDir"'/authorized_keys'
	end
	set --local sshDir (dirname -- "$authorizedKeysFile") || return 2

	# Ask the user whether to keep previous authorized keys
	set --local backupCommand \
		'sudo' 'back-up-files' '--comment' 'ssh-authorized_keys' \
		'--backup-dir' "$HOME"'/.say-local/backups'
	if test -e "$authorizedKeysFile"
		read-choice --variable keepPreviousAuthorizedKeys --default 1 \
			--prompt 'Keep previous authorized keys? ' -- \
			'yes' 'no' || return 2
		if test "$keepPreviousAuthorizedKeys" = 'no'
			set --append backupCommand '--remove-source'
		end
		$backupCommand -- "$authorizedKeysFile" || return 1
	else if test -L "$authorizedKeysFile"
		set --append backupCommand '--remove-source'
		$backupCommand -- "$authorizedKeysFile" || return 1
	end

	sudo su -s (command -v fish) -l "$username" -c \
		'mkdir -m 700 -p -- '(string escape -- "$sshDir")
	sudo su -s (command -v fish) -l "$username" -c \
		'touch -- '(string escape -- "$authorizedKeysFile")
	sudo su -s (command -v fish) -l "$username" -c \
		'chmod -- 600 '(string escape -- "$authorizedKeysFile")

	# Add new ssh pubkeys for the user
	echo 'Adding new ssh pubkeys for user: '"$username"
	read --prompt-str 'Pubkey (enter none to end): ' --local pubkey
	and begin
		set pubkey (string trim -- "$pubkey") || true
	end
	and while test -n "$pubkey"
		set --local command \
			'printf -- '(string escape -- \
				"$pubkey")'\'\\n\' >> '(string escape -- "$authorizedKeysFile")
		sudo su -s (command -v fish) -l "$username" -c "$command"
		and read --prompt-str 'Pubkey (enter none to end): ' pubkey
		and begin
			set pubkey (string trim -- "$pubkey") || true
		end
		or break
	end
end

set --global newUsers
function createNewUsers-linuxServer
	# Create new users
	echo 'Creating new users'
	read --prompt-str 'Username (enter none to end): ' --local username
	and begin
		set username (string trim -- "$username") || true
	end
	or return 2
	while test -n "$username"
		if check-dependencies --program --quiet 'adduser'
			sudo adduser --shell (command -v fish) -- "$username"
		else
			sudo useradd --shell (command -v fish) --create-home -- "$username"
			and sudo passwd -- "$username"
		end
		and set --append newUsers "$username"

		addAuthorizedKeys "$username"

		echo
		read --prompt-str 'Username (enter none to end): ' username
		and begin
			set username (string trim --"$username") || true
		end
		or return 2
	end
end

# Configure firewall, using "ufw"
# Parameters: ssh ports
function configureFirewall
	check-dependencies --program 'systemctl' || return 3
	check-dependencies --program 'ufw' || return 3
	set --local sshPorts $argv
	for sshPort in $sshPorts
		test 1 -gt "$sshPort" && return 2
	end

	echo 'Configuring firewall, using "ufw"'
	read-choice --variable resetUfw --prompt 'Reset ufw configurations? ' -- \
		'yes' 'no' || return 2
	read-choice --variable enableHttpPort --prompt 'Enable HTTP port 80? ' \
		--default 1 -- 'yes' 'no' || return 2
	read-choice --variable enableHttpsPort --prompt 'Enable HTTPS port 443? ' \
		--default 1 -- 'yes' 'no' || return 2
	read --prompt-str 'Please enter the proxy ports (space delimited): ' \
		--local --array proxyPorts || return 2

	sudo systemctl disable --now firewalld.service > '/dev/null' 2>&1
	sudo systemctl enable --now ufw.service || return 1

	if test "$resetUfw" = 'yes'
		sudo ufw reset
	end
	sudo ufw default deny incoming
	sudo ufw default allow outgoing
	sudo ufw default deny routed
	if test "$enableHttpPort" = 'yes'
		sudo ufw allow in 'http/tcp' comment "http"
	end
	if test "$enableHttpsPort" = 'yes'
		sudo ufw allow in 'https/tcp' comment "https"
	end
	for sshPort in $sshPorts
		sudo ufw limit in "$sshPort"/'tcp' comment "ssh"
	end
	for port in $proxyPorts
		test 1 -le "$port"
		and sudo ufw allow in "$port" comment "proxy"
	end
	sudo ufw logging medium
	sudo ufw enable
	sudo ufw status numbered
end

# For servers, add /etc/ssh/sshd_config
function configureSshServer
	if is-platform --quiet 'macos'
		echo-err 'Not implemented for macOS'
		return 3
	else if not is-platform --quiet 'android-termux'
	and not check-dependencies --program 'systemctl'
		return 3
	end

	check-dependencies --program 'sshd' || return 3
	check-dependencies --program 'ssh-keygen' || return 3

	getFormerSshServerConfigMatches
	changePassword || return
	if not is-platform --quiet 'android-termux'
		createNewUsers-linuxServer
	end

	echo-err --info \
		'You perhaps need to add authorized keys to: '(string escape -- \
		"$HOME"'/.ssh/authorized_keys')

	# Add new sshd config match blocks
	set --local matchUsernames
	set --local matchPorts
	echo 'Adding ssh server-side user/port pairs'
	read --prompt-str 'Username (enter none to end): ' --local matchUsername
	and begin
		set matchUsername (string trim -- "$matchUsername") || true
	end
	and read --prompt-str 'Port: ' --local matchPort
	and begin
		set matchPort (string trim -- "$matchPort") || true
	end
	and test 1 -le "$matchPort"
	and set --append matchUsernames "$matchUsername"
	and set --append matchPorts "$matchPort"
	or return 2
	and while test -n "$matchUsername"
		echo
		read --prompt-str 'Username (enter none to end): ' matchUsername
		and begin
			set matchUsername (string trim -- "$matchUsername") || true
		end
		and read --prompt-str 'Port: ' matchPort
		and begin
			set matchPort (string trim -- "$matchPort") || true
		end
		and test 1 -le "$matchPort"
		and set --append matchUsernames "$matchUsername"
		and set --append matchPorts "$matchPort"
		or return 2
	end

	set --local allSshPorts (for port in $formerSshServerConfigPorts $matchPorts
			test 1 -le "$port" && echo "$port"
		end | sort | uniq
	) || exit 2

	if not is-platform --quiet 'android-termux'
		configureFirewall $allSshPorts
	end

	### Back up previous "ssh" server configurations
	set --local sshHostRsaSecretKey "$sshServerConfigDir"'/ssh_host_rsa_key'
	set --local sshHostRsaPublicKey "$sshHostRsaSecretKey"'.pub'
	if test -d "$stowDir"'/ssh-server'
	or test -f "$sshServerConfigFile" || test -L "$sshServerConfigFile"
	or test -f "$sshHostRsaSecretKey" || test -L "$sshHostRsaSecretKey"
	or test -f "$sshHostRsaPublicKey" || test -L "$sshHostRsaPublicKey"
		read-choice --variable removePreviousConfigurations --default 2 \
			--prompt 'Remove previous "ssh" server configurations? ' -- \
			'yes' 'no' || return 2

		set --local backupCommand \
			'back-up-files' '--comment' 'ssh_server-config' '--'
		test "$removePreviousConfigurations" = 'yes'
		and set backupCommand \
			'back-up-files' '--comment' 'ssh_server-config' '--remove-source' '--'

		set --local backupConfigs
		test -d "$stowDir"'/ssh-server'
		and set --append backupConfigs "$stowDir"'/ssh-server'
		test -f "$sshServerConfigFile" || test -L "$sshServerConfigFile"
		and set --append backupConfigs "$sshServerConfigFile"
		test -f "$sshHostRsaSecretKey" || test -L "$sshHostRsaSecretKey"
		and set --append backupConfigs "$sshHostRsaSecretKey"
		test -f "$sshHostRsaPublicKey" || test -L "$sshHostRsaPublicKey"
		and set --append backupConfigs "$sshHostRsaPublicKey"

		if test -n "$backupConfigs"
			sudo $backupCommand $backupConfigs || return 1
		end
	end
	###

	### Add "ssh" server configurations
	for configFile in "$sshServerConfigFile" "$sshHostRsaSecretKey" "$sshHostRsaPublicKey"
		if test -f "$configFile" || test -L "$configFile"
			sudo rm "$configFile" || exit 1
		end
	end

	mkdir -m 700 -p "$stowDir"'/ssh-server' || return 1
	rsync --recursive  "$serverLinkDir"/ "$stowDir"'/ssh-server' || return 1
	sudo stow --verbose --restow --dir "$stowDir" \
		--target "$sshServerConfigHome" 'ssh-server' || return 1
	###

	echo | sudo tee -a "$sshServerConfigHome" > '/dev/null' || return 1
	for sshPort in $allSshPorts
		echo 'Port '"$sshPort" | \
			sudo tee -a "$sshServerConfigHome" > '/dev/null' || return 1
	end

	for matchNumber in (seq "$formerSshServerConfigMatchCount")
		echo | sudo tee -a "$sshServerConfigHome" > '/dev/null' || return 1
		set --local match 'formerSshServerConfigMatch'"$matchNumber"
		for line in $$match
			echo "$line" | sudo tee -a "$sshServerConfigHome" > '/dev/null'
			or return 1
		end
	end

	for iii in (seq (count $matchPorts))
		echo | sudo tee -a "$sshServerConfigHome" > '/dev/null' || return 1
		set --local matchUsername "$matchUsernames[$iii]"
		set --local matchPort "$matchPorts[$iii]"
		echo 'Match User '"$matchUsername"', LocalPort '"$matchPort" | \
			sudo tee -a "$sshServerConfigHome" > '/dev/null' || return 1
		echo \t'AllowUsers '"$matchUsername" | \
			sudo tee -a "$sshServerConfigHome" > '/dev/null' || return 1
	end

	echo-err --info 'Please review and/or edit the server-side ssh config file'
	read --prompt-str 'Enter anything to continue: ' > '/dev/null'
	set --local editor 'vi'
	if test -n "$EDITOR" && check-dependencies --program --quiet "$EDITOR"
		set editor "$EDITOR"
	end
	sudo "$editor" "$sshServerConfigHome"

	# Generate new ssh host RSA key
	sudo ssh-keygen -t 'rsa' -b '4096' -N '' -f "$sshHostRsaSecretKey"
	or return 1

	if is-platform --quiet 'android-termux'
		sudo chown (id -un):(id -un) "$sshServerConfigHome"
		sudo chown (id -un):(id -un) "$sshHostRsaSecretKey"
		sudo chown (id -un):(id -un) "$sshHostRsaPublicKey"
	end

	# Reload sshd
	if not is-platform --quiet 'android-termux'
		sudo systemctl enable --now sshd.service
		sudo systemctl reload sshd.service
	end
end

read-choice --variable clientOrServer \
	--prompt 'Are you an ssh client or server or both? ' -- \
	'client' 'server' 'both' || exit 2
switch "$clientOrServer"
	case 'client'
		configureSshClient
	case 'server'
		configureSshServer
	case 'both'
		configureSshServer
		and configureSshClient
end
