#!/usr/bin/env fish

# For security
umask 077

# Set error codes
set BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 1
set SSH_IS_NOT_INSTALLED_ERROR_CODE 2
set SSHD_IS_NOT_INSTALLED_ERROR_CODE 3
set UFW_IS_NOT_INSTALLED_ERROR_CODE 4
set NOT_ROOT_ERROR_CODE 5

set source_dir (dirname (realpath (status --current-filename)))'/Files'
set utility_dir (dirname (realpath (status --current-filename)))'/Utilities'
set local_ssh_config "$HOME"'/.ssh/config'
set global_sshd_config '/etc/ssh/sshd_config'

# Make sure that "back_up_files" is loaded
functions back_up_files > '/dev/null' 2>&1
or begin
    echoerr '"back_up_files" function is not loaded!'
    exit "$BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE"
end

# Make sure that "ssh" is installed
command -v ssh > '/dev/null' 2>&1
or begin
    echoerr '"ssh" is not installed! Please install the program'
    exit "$SSH_IS_NOT_INSTALLED_ERROR_CODE"
end

# Make sure that "sshd" is installed
command -v sshd > '/dev/null' 2>&1
or begin
    echoerr '"sshd" is not installed! Please install the program'
    exit "$SSHD_IS_NOT_INSTALLED_ERROR_CODE"
end

#### For clients, add ~/.ssh/config
function _configure_ssh_client
    # Back up former ssh client user private configurations if available
    set --local get_ssh_client_side_host_configuratoins "$utility_dir"'/get_ssh_client_side_host_configuratoins.py'
    chmod u+x "$get_ssh_client_side_host_configuratoins"
    set --local delimiter '---'
    set --local lines
    if test -e "$local_ssh_config"
        "$get_ssh_client_side_host_configuratoins" "$delimiter" | while read --local line
            set lines $lines "$line"
        end
    end

    ### Track the configuration file with "track_file" function
    set --local track_file_dir_path "$track_file_DIR_PATH"
    test -z "$track_file_dir_path"
    and set track_file_dir_path "$HOME"'/.my_private_configurations'
    set --local config_file "$track_file_dir_path"'/SSH_config'

    # Back up former configuration file
    if test -e "$config_file"
    or test -L "$config_file"
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$config_file"
    end

    touch "$config_file"
    # For security
    chmod 600 "$config_file"

    # Use previous ssh client user private configurations if available
    for line in $lines[2..-1]
        if test "$line" = "$delimiter"
            echo >> "$config_file"
        else
            echo "$line" >> "$config_file"
        end
    end
    echo >> "$config_file"

    # Ask the user to add new client-side host configurations
    echo 'Adding new hosts'
    read --prompt-str='Host (enter empty string to end): ' --local host
    set host (string trim "$host")
    while test -n "$host"
        read --prompt-str='Hostname: ' --local hostname
        set hostname (string trim "$hostname")
        read --prompt-str='User: ' --local user
        set user (string trim "$user")
        read --prompt-str='Port (enter empty string to use the default): ' --local port
        set port (string trim "$port")
        read --prompt-str='IdentityFile (enter empty string to use the default): ' --local identity_file
        set identity_file (string trim "$identity_file")

        if test -z "$hostname"
            echoerr '"Hostname" cannot be empty'
        else if test -z "$user"
            echoerr '"User" cannot be empty'
        else
            echo 'Host '"$host" >> "$config_file"
            echo '    Hostname '"$hostname" >> "$config_file"
            echo '    User '"$user" >> "$config_file"
            test -n "$port"
            and echo '    Port '"$port" >> "$config_file"
            test -n "$identity_file"
            and echo '    IdentityFile '"$identity_file" >> "$config_file"
            echo
        end

        read --prompt-str='Host (enter empty string to end): ' host
        set host (string trim "$host")
    end

    # Back up former ssh client configurations
    if test -e "$local_ssh_config"
    or test -L "$local_ssh_config"
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$local_ssh_config"
    end

    cat "$source_dir"'/config' >> "$config_file"
    and ln -si "$config_file" "$local_ssh_config"
    and track_file --filename=(basename "$config_file") --symlink="$local_ssh_config" --check
    ###
end
####

#### For servers, add /etc/ssh/sshd_config
function _configure_ssh_server
    # Make sure that we're the root user
    test (whoami) = 'root'
    or begin
        echoerr 'You are not the root user! Please run "su"'
        exit "$NOT_ROOT_ERROR_CODE"
    end

    # Change the password
    passwd

    # Configure the firewall
    _configure_firewall

    # Create new users
    echo 'Creating new users'
    read --prompt-str='Username (enter empty string to end): ' --local username
    set username (string trim "$username")
    ### Find the path to fish shell
    set --local fish_shell_path (command -v fish)
    if cat "$etc_shells" 2> '/dev/null' | grep '/fish$' > '/dev/null'
        if test (cat "$etc_shells" | grep '/fish$' | wc -l) -eq 1
            set fish_shell_path (cat "$etc_shells" | grep '/fish$')
        else
            # Ask the user which one is the "fish" shell they want
            for line in (cat "$etc_shells" | grep '/fish$')
                echo $line

                read --prompt-str='Is this shell the "fish" shell that you want to use? (YES/no): ' --local yes_or_no
                set yes_or_no (string lower "$yes_or_no")
                while not contains "$yes_or_no" 'yes' 'no'
                and test -n "$yes_or_no"
                    read --prompt-str='Please enter YES/no: ' yes_or_no
                    set yes_or_no (string lower "$yes_or_no")
                end

                if test -z "$yes_or_no"
                or test "$yes_or_no" = 'yes'
                    set fish_shell_path "$line"
                    break
                else
                    continue
                end
            end
        end
    end
    ###
    while test -n "$username"
        adduser --shell "$fish_shell_path" "$username"
        # Get the ssh configuration directory of the user
        # See https://unix.stackexchange.com/questions/247576/how-to-get-home-given-user
        set --local ssh_dir_of_user (getent passwd "$username" | cut -d ':' -f 6)'/.ssh'
        set --local authorized_keys "$ssh_dir_of_user"'/authorized_keys'
        su "$username" -c 'mkdir -p -- '"$ssh_dir_of_user"
        # Ask the user whether to keep previous authorized keys
        if test -e "$authorized_keys"
            read --prompt-str='Keep previous authorized keys? (YES/no): ' --local yes_or_no
            set yes_or_no (string lower "$yes_or_no")
            while not contains "$yes_or_no" 'yes' 'no'
            and test -n "$yes_or_no"
                read --prompt-str='Please enter YES/no: ' yes_or_no
                set yes_or_no (string lower "$yes_or_no")
            end

            if test "$yes_or_no" = 'no'
                # Back up former server authorized_keys
                chown (whoami) "$authorized_keys"
                back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$authorized_keys"
            end
        else if test -L "$authorized_keys"
            # Back up former server authorized_keys
            chown (whoami) "$authorized_keys"
            back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$authorized_keys"
        end
        su "$username" -c 'touch -- '"$authorized_keys"
        su "$username" -c 'chmod -- 600 '"$authorized_keys"

        # Add new ssh pubkeys for the user
        echo 'Adding new ssh pubkeys for the user'
        read --prompt-str='Pubkey (enter empty string to end): ' --local pubkey
        set pubkey (string trim "$pubkey")
        while test -n "$pubkey"
            su "$username" -c 'echo -- '"$pubkey"' >> '"$authorized_keys"

            read --prompt-str='Pubkey (enter empty string to end): ' pubkey
            set pubkey (string trim "$pubkey")
        end

        echo
        read --prompt-str='Username (enter empty string to end): ' username
        set username (string trim "$username")
    end

    # Back up former server sshd private configuration if available
    set --local get_server_sshd_configuratoin "$utility_dir"'/get_server_sshd_configuratoin.py'
    chmod u+x "$get_server_sshd_configuratoin"
    set --local delimiter '---'
    set --local lines
    if test -e "$global_sshd_config"
        "$get_server_sshd_configuratoin" "$delimiter" | while read --local line
            set lines $lines "$line"
        end
    end

    ### Track the configuration file with "track_file" function
    set --local track_file_dir_path "$track_file_DIR_PATH"
    test -z "$track_file_dir_path"
    and set track_file_dir_path "$HOME"'/.my_private_configurations'
    set --local config_file "$track_file_dir_path"'/SSH_sshd_config'

    # Back up former configuration file
    if test -e "$config_file"
    or test -L "$config_file"
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$config_file"
    end

    cp -i "$source_dir"'/sshd_config' "$config_file"
    # For security
    chmod 600 "$config_file"

    # Use previous server sshd private configuration if available
    echo >> "$config_file"
    set --local in_match_block false
    for line in $lines
        if not "$in_match_block"
            if test "$line" = "$delimiter"
                set in_match_block true
                # Ask the user to add new ports
                echo 'Adding new ports'
                read --prompt-str='Port (enter empty string to end): ' --local port
                set port (string trim "$port")
                while test -n "$port"
                    echo 'Port' "$port" >> "$config_file"
                    read --prompt-str='Port (enter empty string to end): ' port
                    set port (string trim "$port")
                end
                echo >> "$config_file"
            else
                echo 'Port' "$line" >> "$config_file"
            end
        else
            if test "$line" = "$delimiter"
                echo >> "$config_file"
            else
                echo "$line" >> "$config_file"
            end
        end
    end
    echo >> "$config_file"

    # Ask the user to add new match block configurations
    echo
    echo 'Adding new match blocks'
    echo 'Example: Match User <username>, LocalPort <port-number>'
    read --prompt-str='Match (enter empty string to end): ' --local match
    set match (string trim "$match")
    while test -n "$match"
        read --prompt-str='AllowUsers: ' --local allow_users
        set allow_users (string trim "$allow_users")

        echo 'Match '"$match" >> "$config_file"
        test -n "$allow_users"
        and echo '    AllowUsers '"$allow_users" >> "$config_file"
        echo

        read --prompt-str='Match (enter empty string to end): ' match
        set match (string trim "$match")
    end

    # Back up former server sshd configuration
    if test -e "$global_sshd_config"
    or test -L "$global_sshd_config"
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$global_sshd_config"
    end

    ln -si "$config_file" "$global_sshd_config"
    and track_file --filename=(basename "$config_file") --symlink="$global_sshd_config" --check

    # Back up former ssh host RSA key
    set --local ssh_host_rsa_key '/etc/ssh/ssh_host_rsa_key'
    for file in "$ssh_host_rsa_key" "$ssh_host_rsa_key"'.pub'
        if test -e "$file"
        or test -L "$file"
            back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$file"
        end
    end
    # Generate new ssh host RSA key
    ssh-keygen -t 'rsa' -b '4096' -N '' -f "$ssh_host_rsa_key"
end
####

#### Configure firewall, using "ufw"
function _configure_firewall
    # Make sure that "ufw" is installed
    command -v ufw > '/dev/null' 2>&1
    or begin
        echoerr '"ufw" is not installed! Please install the program'
        exit "$UFW_IS_NOT_INSTALLED_ERROR_CODE"
    end

    # Make sure that we're the root user
    test (whoami) = 'root'
    or begin
        echoerr 'You are not the root user! Please run "su"'
        exit "$NOT_ROOT_ERROR_CODE"
    end

    ufw reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw default deny routed

    # Limit/allow tcp ports for incoming traffic from "ssh" and "shadowsocks"
    read --prompt-str='Please enter the ssh port' --local ports
    for port in $ports
        ufw limit in "$port"'/tcp'
    end
    read --prompt-str='Please enter the shadowsocks ports' --local ports
    for port in $ports
        ufw allow in "$port"'/tcp'
    end

    ufw logging medium
    ufw enable
    ufw status verbose
end
###

### Ask whether it's a client or a server
echo -- 'Client or server or both?'
read --prompt-str='client/server/both: ' --local client_or_server
set client_or_server (string lower "$client_or_server")
while not contains "$client_or_server" 'client' 'server' 'both'
# and test -n "$client_or_server"
    read --prompt-str='Please enter "client" or "server" or "both": ' client_or_server
    set client_or_server (string lower "$client_or_server")
end

switch "$client_or_server"
    case 'client'
        _configure_ssh_client
    case 'server'
        _configure_ssh_server
    case 'both'
        _configure_ssh_server
        _configure_ssh_client
end
####

functions --erase _configure_ssh_client _configure_ssh_server _configure_firewall
