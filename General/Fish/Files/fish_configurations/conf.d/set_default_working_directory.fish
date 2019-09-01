#!/usr/bin/env fish

# For login and interactive shells
if status is-login
and status is-interactive
    ### Set default working directory
    if test (uname -s) = 'Linux'
    and test (uname -o) = 'Android'
    and test ! -e "$HOME"'/Downloads'
        cd ~
        ln -s '/sdcard/Downloads' 'Downloads'
    end
    cd ~/Downloads
    ###
end