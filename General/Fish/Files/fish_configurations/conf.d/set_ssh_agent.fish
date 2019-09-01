#!/usr/bin/env fish

# Set error codes
set --local SSH_AGENT_IS_NOT_INSTALLED_ERROR_CODE 1

# Make sure that "ssh-agent" is installed
command -v ssh-agent > /dev/null 2>&1
or begin
    echoerr '"ssh-agent" is not installed! Please install the "ssh" program'
    exit "$SSH_AGENT_IS_NOT_INSTALLED_ERROR_CODE"
end

### ssh-agent is a program to hold private keys used for public key authentication
# Check whether there is an ssh-agent running. If not, create one
if test -z "$SSH_AUTH_SOCK"
    # Set the maximum lifetime of identities added to the agent to 3600 seconds
    eval (ssh-agent -c -t 3600) > /dev/null
end

# Automatically kill the agent on exit
function auto_kill_ssh_agent_by_say --on-event fish_exit
    if test -n "$SSH_AUTH_SOCK"
    and status is-login
        eval (ssh-agent -k -c) > /dev/null
    end
end
###