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
	and set hostHost (string trim -- "$hostHost")
	and while test -n "$hostHost"
		read --prompt-str 'Hostname: ' --local hostHostname
		and set hostHostname (string trim -- "$hostHostname")
		and read --prompt-str 'User: ' --local hostUser
		and set hostUser (string trim -- "$hostUser")
		and read --prompt-str 'Port (enter none to use the default): ' \
			--hostPort hostPort
		and set hostPort (string trim -- "$hostPort")
		and read --prompt-str 'IdentityFile (enter none to use the default): ' \
			--local hostIdentityFile
		and set hostIdentityFile (string trim -- "$hostIdentityFile")
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
		and set hostHost (string trim -- "$hostHost")
		or set --erase hostHost
	end
	return 0
end

# For clients, add ~/.ssh/config
function configureSshClient
	getFormerSshClientConfigHosts
	addSshClientConfigHosts || return

	### Back up previous "ssh client" configurations
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

		test -n "$backupConfigs" && $backupCommand $backupConfigs || return 1
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

# Configure firewall, using "ufw"
function configureFirewall --argument-names sshPort
	check-dependencies --program 'ufw' || return 3

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
	sudo ufw limit in "$sshPort"/'tcp' comment "ssh"
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
	changePassword || return

#	# Configure the firewall
#	configureFirewall

#	# Create new users
#	echo 'Creating new users'
#	read --prompt-str 'Username (enter none to end): ' --local username
#	set username (string trim "$username")
#	### Find the path to fish shell
#	set --local fish_shell_path (command -v fish)
#	if cat "$etc_shells" 2> '/dev/null' | grep '/fish$' > '/dev/null'
#		if test (cat "$etc_shells" | grep '/fish$' | wc -l) -eq 1
#			set fish_shell_path (cat "$etc_shells" | grep '/fish$')
#		else
#			# Ask the user which one is the "fish" shell they want
#			for line in (cat "$etc_shells" | grep '/fish$')
#				echo $line

#				read --prompt-str 'Is this shell the "fish" shell that you want to use? (YES/no): ' --local yes_or_no
#				set yes_or_no (string lower "$yes_or_no")
#				while not contains "$yes_or_no" 'yes' 'no'
#				and test -n "$yes_or_no"
#					read --prompt-str 'Please enter YES/no: ' yes_or_no
#					set yes_or_no (string lower "$yes_or_no")
#				end

#				if test -z "$yes_or_no"
#				or test "$yes_or_no" = 'yes'
#					set fish_shell_path "$line"
#					break
#				else
#					continue
#				end
#			end
#		end
#	end
#	###
#	while test -n "$username"
#		adduser --shell "$fish_shell_path" "$username"
#		# Get the ssh configuration directory of the user
#		# See https://unix.stackexchange.com/questions/247576/how-to-get-home-given-user
#		set --local ssh_dir_of_user (getent passwd "$username" | cut -d ':' -f 6)'/.ssh'
#		set --local authorized_keys "$ssh_dir_of_user"'/authorized_keys'
#		su -l "$username" -c 'mkdir -p -- '"$ssh_dir_of_user"
#		# Ask the user whether to keep previous authorized keys
#		if test -e "$authorized_keys"
#			read --prompt-str 'Keep previous authorized keys? (YES/no): ' --local yes_or_no
#			set yes_or_no (string lower "$yes_or_no")
#			while not contains "$yes_or_no" 'yes' 'no'
#			and test -n "$yes_or_no"
#				read --prompt-str 'Please enter YES/no: ' yes_or_no
#				set yes_or_no (string lower "$yes_or_no")
#			end

#			if test "$yes_or_no" = 'no'
#				# Back up former server authorized_keys
#				chown (whoami) "$authorized_keys"
#				back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$authorized_keys"
#			end
#		else if test -L "$authorized_keys"
#			# Back up former server authorized_keys
#			chown (whoami) "$authorized_keys"
#			back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$authorized_keys"
#		end
#		su -l "$username" -c 'touch -- '"$authorized_keys"
#		su -l "$username" -c 'chmod -- 600 '"$authorized_keys"

#		# Add new ssh pubkeys for the user
#		echo 'Adding new ssh pubkeys for the user'
#		read --prompt-str 'Pubkey (enter none to end): ' --local pubkey
#		set pubkey (string trim "$pubkey")
#		while test -n "$pubkey"
#			su -l "$username" -c 'echo -- '"$pubkey"' >> '"$authorized_keys"

#			read --prompt-str 'Pubkey (enter none to end): ' pubkey
#			set pubkey (string trim "$pubkey")
#		end

#		echo
#		read --prompt-str 'Username (enter none to end): ' username
#		set username (string trim "$username")
#	end

#	# Back up former server sshd private configuration if available
#	set --local get_server_sshd_configuratoin "$utility_dir"'/get_server_sshd_configuratoin.py'
#	chmod u+x "$get_server_sshd_configuratoin"
#	set --local delimiter '---'
#	set --local lines
#	if test -e "$global_sshd_config"
#		"$get_server_sshd_configuratoin" "$delimiter" | while read --local line
#			set lines $lines "$line"
#		end
#	end

#	### Track the configuration file with "track_file" function
#	set --local track_file_dir_path "$track_file_DIR_PATH"
#	test -z "$track_file_dir_path"
#	and set track_file_dir_path "$HOME"'/.my_private_configurations'
#	set --local config_file "$track_file_dir_path"'/SSH_sshd_config'

#	# Back up former configuration file
#	if test -e "$config_file"
#	or test -L "$config_file"
#		back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$config_file"
#	end

#	cp -i "$source_dir"'/sshd_config' "$config_file"
#	# For security
#	chmod 600 "$config_file"

#	echo
#	echo 'Configuring ssh'
#	# Ask the user to add new ports
#	echo >> "$config_file"
#	echo 'Adding new ssh ports'
#	read --prompt-str 'Port (enter none to end): ' --local port
#	set port (string trim "$port")
#	while test -n "$port"
#		echo 'Port' "$port" >> "$config_file"
#		read --prompt-str 'Port (enter none to end): ' port
#		set port (string trim "$port")
#	end

#	# Use previous server sshd private configuration if available
#	set --local in_match_block false
#	for line in $lines
#		if not "$in_match_block"
#			if test "$line" = "$delimiter"
#				set in_match_block true
#				echo >> "$config_file"
#			else
#				echo 'Port' "$line" >> "$config_file"
#			end
#		else
#			if test "$line" = "$delimiter"
#				echo >> "$config_file"
#			else
#				echo "$line" >> "$config_file"
#			end
#		end
#	end
#	echo >> "$config_file"

#	# Ask the user to add new match block configurations
#	echo
#	echo 'Adding new match blocks'
#	echo 'Example: Match User <username>, LocalPort <port-number>'
#	read --prompt-str 'Match (enter none to end): ' --local match
#	set match (string trim "$match")
#	while test -n "$match"
#		read --prompt-str 'AllowUsers: ' --local allow_users
#		set allow_users (string trim "$allow_users")

#		echo 'Match '"$match" >> "$config_file"
#		test -n "$allow_users"
#		and echo '    AllowUsers '"$allow_users" >> "$config_file"
#		echo >> "$config_file"
#		echo

#		read --prompt-str 'Match (enter none to end): ' match
#		set match (string trim "$match")
#	end

#	# Back up former server sshd configuration
#	if test -e "$global_sshd_config"
#	or test -L "$global_sshd_config"
#		back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$global_sshd_config"
#	end

#	ln -si "$config_file" "$global_sshd_config"
#	and track_file --filename=(basename "$config_file") --symlink="$global_sshd_config" --check

#	# Back up former ssh host RSA key
#	set --local ssh_host_rsa_key '/etc/ssh/ssh_host_rsa_key'
#	for file in "$ssh_host_rsa_key" "$ssh_host_rsa_key"'.pub'
#		if test -e "$file"
#		or test -L "$file"
#			back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$file"
#		end
#	end
#	# Generate new ssh host RSA key
#	ssh-keygen -t 'rsa' -b '4096' -N '' -f "$ssh_host_rsa_key"

#	# Reload sshd
#	systemctl restart sshd
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
