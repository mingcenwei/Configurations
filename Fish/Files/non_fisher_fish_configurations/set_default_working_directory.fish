#!/usr/bin/env fish

# Create ~/Downloads if it doesn't exist
if test ! -d "$HOME"'/Downloads'
    test -e "$HOME"'/Downloads'
    or test -L "$HOME"'/Downloads'
    and back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$HOME"'/Downloads'

    if is_platform 'android-termux'
        ln -si '/sdcard/Download' "$HOME"'/Downloads'
    else
        mkdir -p "$HOME"'/Downloads'
    end
end

# For login and interactive shells
if status is-login
and status is-interactive
    ### Set default working directory
    cd ~/Downloads
    ###
end