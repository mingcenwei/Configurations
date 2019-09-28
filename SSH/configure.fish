#!/usr/bin/env fish

# Set error codes
set --local BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 1
set --local SSH_IS_NOT_INSTALLED_ERROR_CODE 2
set --local UFW_IS_NOT_INSTALLED_ERROR_CODE 3
set --local NOT_ROOT_ERROR_CODE 4

set --local source_dir (dirname (realpath (status --current-filename)))'/Files'
set --local local_ssh_dir "$HOME"'/.ssh'
set --local global_sshd_dir '/etc/ssh'

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

### For clients
function _configure_ssh_client

end
###

### For servers
function _configure_ssh_server
    if test -e '/etc/ssh/sshd_config'
    or test -L '/etc/ssh/sshd_config'
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source '/etc/ssh/sshd_config'
    end

    mkdir -p /etc/ssh >/dev/null 2>&1
    cp
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
