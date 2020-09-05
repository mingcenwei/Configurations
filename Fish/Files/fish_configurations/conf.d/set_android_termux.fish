#!/usr/bin/env fish

if is_platform 'android-termux'
    # Set "~/sdcard" directory
    if test ! -d "$HOME"'/sdcard'
        test -e "$HOME"'/sdcard'
        or test -L "$HOME"'/sdcard'
        and back_up_files --back-up --timestamp --destination --compressor \
            --suffix --parents --remove-source "$HOME"'/sdcard'

        ln -si '/sdcard' "$HOME"'/sdcard'
    end

    # Set "~/Downloads" directory
    if test ! -d "$HOME"'/Downloads'
        test -e "$HOME"'/Downloads'
        or test -L "$HOME"'/Downloads'
        and back_up_files --back-up --timestamp --destination --compressor \
            --suffix --parents --remove-source "$HOME"'/Downloads'

        mkdir -p "$HOME"'/Downloads'
    end

    # Set "~/Downloads/Download" directory
    if test ! -d "$HOME"'/Downloads/Download'
        test -e "$HOME"'/Downloads/Download'
        or test -L "$HOME"'/Downloads/Download'
        and back_up_files --back-up --timestamp --destination --compressor \
            --suffix --parents --remove-source "$HOME"'/Downloads/Download'

        ln -si '/sdcard/Download' "$HOME"'/Downloads/Download'
    end

    # Set "$PREFIX/local" directory
    if test ! -d "$PREFIX"'/local'
        test -e "$PREFIX"'/local'
        or test -L "$PREFIX"'/local'
        and back_up_files --back-up --timestamp --destination --compressor \
            --suffix --parents --remove-source "$PREFIX"'/local'

        mkdir -p "$PREFIX"'/local'
    end

    # Set "~/bin/termux-file-editor"
    if not test -e "$HOME"'/bin/termux-file-editor'
        mkdir -p "$HOME"'/bin'
        ln -si (command -v vim) "$HOME"'/bin/termux-file-editor'
    end
end
