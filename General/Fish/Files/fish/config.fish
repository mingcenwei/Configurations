#!/usr/bin/env fish

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

# For interactive shells
if status is-interactive
    # Set key bindings: Vim & Emacs
    fish_hybrid_key_bindings

    # For login shells
    if status is-login
        ### Set default working directory
        if test (uname -s) = 'Linux'
        and test (uname -o) = 'Android'
            if test ! -e "$HOME"'/Working'
                cd ~
                mkdir Working
                chmod 700 Working
                cd Working
            else
                cd ~/Working
            end
        else
            cd ~/Downloads
        end
        ###
    end
end

### Set compiler flags for C++
if test (uname -s) = 'Darwin'
    alias c++17='clang++ -std=c++17 -Wall -Wextra -pedantic-errors'
else
    alias c++17='g++ -std=c++17 -Wall -Wextra -pedantic-errors'
end
###
