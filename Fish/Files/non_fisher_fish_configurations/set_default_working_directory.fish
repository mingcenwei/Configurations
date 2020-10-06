#!/usr/bin/env fish

# For login and interactive shells
if status is-login
and status is-interactive
    ### Set default working directory
    test -d ~/Downloads
    and cd ~/Downloads
    ###
end