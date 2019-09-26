#!/usr/bin/env fish

### Set "~/sdcard" directory
if test (uname -s) = 'Linux'
and test (uname -o) = 'Android'
and test ! -d "$HOME"'/sdcard'

    test -e "$HOME"'/sdcard'
    or test -L "$HOME"'/sdcard'
    and back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$HOME"'/sdcard'

    ln -si '/sdcard' "$HOME"'/sdcard'
end
###