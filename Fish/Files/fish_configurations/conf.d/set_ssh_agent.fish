#!/usr/bin/env fish

# ssh-agent is a program to hold private keys used for public key authentication
# https://github.com/danhper/fish-ssh-agent/
# https://wiki.archlinux.org/index.php/SSH_keys#SSH_agents

# Import "library.fish"
source "$_Configurations__PATH"'/library.fish'
check_binary_dependencies 'ssh-agent'

test -d "$HOME"'/.ssh'
or mkdir -p "$HOME"'/.ssh'

test -z "$_MY_SSH_AGENT_INFORMATION"
and set --global --export _MY_SSH_AGENT_INFORMATION \
    "$HOME"'/.ssh/.my_ssh_agent_information'

if test -f "$_MY_SSH_AGENT_INFORMATION"
    source "$_MY_SSH_AGENT_INFORMATION" > '/dev/null'
end

# Check whether there is an ssh-agent running. If not, create one
if test -z "$SSH_AGENT_PID"
or not pgrep -u (whoami) 'ssh-agent' | grep -q "$SSH_AGENT_PID"
    # Set the maximum lifetime of identities added to the agent to 3600 seconds
    ssh-agent -c -t 3600 | sed -e 's/^setenv/set --export/' \
        > "$_MY_SSH_AGENT_INFORMATION"
    chmod 600 "$_MY_SSH_AGENT_INFORMATION"
    source "$_MY_SSH_AGENT_INFORMATION" > '/dev/null'
end

# Restore original umask
eval "$ORIGINAL_UMASK_CMD"
