#!/usr/bin/env fish

# For security
umask 077

# Set error codes
set BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 1
set SSH_IS_NOT_INSTALLED_ERROR_CODE 2
set UFW_IS_NOT_INSTALLED_ERROR_CODE 3
set NOT_ROOT_ERROR_CODE 4

set source_dir (dirname (realpath (status --current-filename)))'/Files'
set utility_dir (dirname (realpath (status --current-filename)))'/Utilities'
set local_ssh_dir "$HOME"'/.ssh'
set global_sshd_dir '/etc/ssh'

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

### For clients, add ~/.ssh/config
function _configure_ssh_client
    # Back up former ssh client user private configurations if available
    set --local get_ssh_client_side_host_configuratoins "$utility_dir"'/get_ssh_client_side_host_configuratoins.py'
    chmod u+x "$get_ssh_client_side_host_configuratoins"
    set --local delimiter '---'
    set --local lines
    if test -e "$HOME"'/.ssh/config'
        "$get_ssh_client_side_host_configuratoins" "$delimiter" | while read --local line
            set lines $lines "$line"
        end
    end

    ### Track the configuration file with "track_file" function
    set --local track_file_dir_path "$track_file_DIR_PATH"
    test -z "$track_file_dir_path"
    and set track_file_dir_path "$HOME"'/.my_private_configurations'
    set --local template_file "$track_file_dir_path"'/SSH_config'

    # Back up former template file
    if test -e "$template_file"
    or test -L "$template_file"
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$template_file"
    end

    touch "$template_file"
    # For security
    chmod 600 "$template_file"

    # Use previous ssh client user private configurations if available
    for line in $lines[2..-1]
        if test "$line" = "$delimiter"
            echo >> "$template_file"
        else
            echo "$line" >> "$template_file"
        end
    end
    echo >> "$template_file"

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
            echo 'Host '"$host" >> "$template_file"
            echo '    Hostname '"$hostname" >> "$template_file"
            echo '    User '"$user" >> "$template_file"
            test -n "$port"
            and echo '    Port '"$port" >> "$template_file"
            test -n "$identity_file"
            and echo '    IdentityFile '"$identity_file" >> "$template_file"
            echo
        end

        read --prompt-str='Host (enter empty string to end): ' host
        set host (string trim "$host")
    end

    # Back up former ssh client configurations
    set --local config_file "$local_ssh_dir"'/config'
    if test -e "$config_file"
    or test -L "$config_file"
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$config_file"
    end

    cat "$source_dir"'/config' >> "$template_file"
    and ln -si "$template_file" "$local_ssh_dir"'/config'
    and track_file --template=(basename "$template_file") --actual="$local_ssh_dir"'/config' --check
    ###
end
###

### For servers, add /etc/ssh/sshd_config
function _configure_ssh_server
    # # Back up former server sshd configurations
    # if test -e "$global_sshd_dir"'/sshd_config'
    # or test -L "$global_sshd_dir"'/sshd_config'
    #     back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$global_sshd_dir"'/sshd_config'
    # end

    # mkdir -p /etc/ssh >/dev/null 2>&1
    # cp
end
###

### Configure firewall, using "ufw"
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
set --universal AM_I_CLIENT_OR_SERVER "$client_or_server"
###

functions --erase _configure_ssh_client _configure_ssh_server _configure_firewall
