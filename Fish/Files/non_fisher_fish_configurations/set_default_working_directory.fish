#!/usr/bin/env fish

# For login and interactive shells
if status is-login
and status is-interactive
    ### Set default working directory
    if is_platform 'android-termux'
    and test ! -d "$HOME"'/Downloads'

        test -e "$HOME"'/Downloads'
        or test -L "$HOME"'/Downloads'
        and back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$HOME"'/Downloads'

        ln -si '/sdcard/Download' "$HOME"'/Downloads'
    end
    cd ~/Downloads
    ###
end