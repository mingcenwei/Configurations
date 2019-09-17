#!/usr/bin/env fish

# Set error codes
set --local BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 1

set DIR (dirname (status --current-filename))

# Make sure that "back_up_files" is loaded
functions back_up_files > /dev/null 2>&1
or begin
    echo 'Error: "back_up_files" function is not loaded!' >&2
    exit "$BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE"
end

# For clients
function _configure_ssh_client

end

# For servers
function _configure_ssh_server
    if test -e '/etc/ssh/sshd_config'
    or test -L '/etc/ssh/sshd_config'
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source '/etc/ssh/sshd_config'
    end

    mkdir -p /etc/ssh >/dev/null 2>&1
    cp
end

echo -- 'Client or server?'
read --prompt-str='client/server: ' --local client_or_server
set client_or_server (string lower "$client_or_server")
while not contains "$client_or_server" 'client' 'server'
    read --prompt-str='Please enter either "client" or "server": ' client_or_server
    set client_or_server (string lower "$client_or_server")
end

switch "$client_or_server"
    case 'client'
        _configure_ssh_client
    case 'server'
        _configure_ssh_server
end

functions --erase _configure_ssh_client _configure_ssh_server

# # Back up former vim configurations
# for file in '.vim' '.vimrc' '.viminfo'
#     if test -e {$HOME}'/'{$file}
#     or test -L {$HOME}'/'{$file}
#         back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source {$HOME}'/'{$file}
#     end
# end

# mkdir -p {$HOME}'/.vim'
# ln -si {$DIR}'/Files/vimrc' {$HOME}'/.vim/vimrc'