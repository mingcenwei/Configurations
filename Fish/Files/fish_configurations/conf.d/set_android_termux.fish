#!/usr/bin/env fish

if is_platform 'android-termux'
    ### Make common directories
    function __temporary_20200203_try_mkdir --argument-names path
        if not test -d "$path"
            test -e "$path"
            or test -L "$path"
            and back_up_files --back-up --timestamp --destination --compressor \
                --suffix --parents --remove-source "$path"

            mkdir -p "$path"
        end
    end

    __temporary_20200203_try_mkdir "$HOME"'/Workspace'
    __temporary_20200203_try_mkdir "$HOME"'/UnderlyingFileSystem'
    __temporary_20200203_try_mkdir "$PREFIX"'/local'

    functions --erase __temporary_20200203_try_mkdir
    ###

    ### Link common directories
    function __temporary_20200203_try_link --argument-names from to
        if not test -d "$HOME"/"$to"
            test -e "$HOME"/"$to"
            or test -L "$HOME"/"$to"
            and back_up_files --back-up --timestamp --destination --compressor \
                --suffix --parents --remove-source "$HOME"/"$to"

            ln -si "$from" "$HOME"/"$to"
        end

        set --local from_realpath (realpath "$from")
        set --local sdcard_realpath \
            (string replace --regex '\\/*$' '' (realpath '/sdcard'))
        set --local pattern '^'(string escape --style=regex "$sdcard_realpath")
        if string match --quiet --regex "$pattern" "$from_realpath"
            set --local prefix "$HOME"'/UnderlyingFileSystem'
            if not test -L "$prefix"/"$to"
                test -e "$prefix"/"$to"
                and back_up_files --back-up --timestamp --destination --compressor \
                    --suffix --parents --remove-source "$prefix"/"$to"

                set --local underlying '/data/media/0'
                set --local from_underlying \
                    (string replace --regex "$pattern" "$underlying" "$from_realpath")
                ln -si "$from_underlying" "$prefix"/"$to"
            end
        end
    end

    __temporary_20200203_try_link '/sdcard' 'sdcard'
    __temporary_20200203_try_link '/sdcard/Download' 'Download'
    __temporary_20200203_try_link '/sdcard/DCIM' 'DCIM'
    __temporary_20200203_try_link '/sdcard/Pictures' 'Pictures'
    __temporary_20200203_try_link '/sdcard/Telegram' 'Telegram'
    __temporary_20200203_try_link '/sdcard/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv' 'QQ'
    __temporary_20200203_try_link '/sdcard/Android/data/com.tencent.mm/MicroMsg/Download' 'WeChat'

    functions --erase __temporary_20200203_try_link
    ###

    # Set "~/bin/termux-file-editor"
    if not test -e "$HOME"'/bin/termux-file-editor'
        mkdir -p "$HOME"'/bin'
        ln -si (command -v vim) "$HOME"'/bin/termux-file-editor'
    end
end
