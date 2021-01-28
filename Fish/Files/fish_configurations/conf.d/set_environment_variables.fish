#!/usr/bin/env fish

# Set error codes
set --local LENGTHS_NOT_EQUAL_ERROR_CODE 101

# To avoid duplicate paths
function __temporary_20200128_prepend_paths --argument-names var
    --local paths $argv[-1..2]

    for path in $paths
        set --local existed 'false'
        for existing_path in $$var
            if test "$existing_path" = "$path"
                set existed 'true'
            end
        end
        if test "$existed" = 'false'
            set --path --global --export "$var" "$path" $$var
        end
    end
end
function __temporary_20200128_append_paths --argument-names var
    set --local paths $argv[2..-1]

    for path in $paths
        set --local existed 'false'
        for existing_path in $$var
            if test "$existing_path" = "$path"
                set existed 'true'
            end
        end
        if test "$existed" = 'false'
            set --path --global --export "$var" $$var "$path"
        end
    end
end

### Set macOS path variables
if is_platform 'macos'
    set --local paths \
        "$HOME"'/Library/Python/3.7/bin' \
        "$HOME"'/.local/bin' \
        "$HOME"'/Library/Android/sdk/platform-tools/'

    set --local filenames \
        'Python3.7-bin' \
        'Haskell-stack-bin' \
        'Android-SDK-platform-tools'

    # Make sure previous 2 settings are correct
    if not test (count $paths) = (count $filenames)
        echoerr 'Lengths of $paths and $filenames are not equal'
        exit "$LENGTHS_NOT_EQUAL_ERROR_CODE"
    end

    # Backup and create '/etc/paths.d/'"$filenames[$iii]"
    for iii in (seq (count $paths))
        set --local filepath '/etc/paths.d/'"$filenames[$iii]"

        __temporary_20200128_append_paths PATH "$paths[$iii]"

        if not test -e "$filepath"
            or test -d "$filepath"
            if test -d "$filepath"
                or test -L "$filepath"
                back_up_files --back-up --timestamp --destination --compressor \
                    --suffix --parents --remove-source "$filepath"
                or sudo back_up_files --back-up --timestamp --destination \
                    --compressor --suffix --parents --remove-source "$filepath"
            end
            echo "$paths[$iii]" | tee "$filepath" >'/dev/null'
            or echo "$paths[$iii]" | sudo tee "$filepath" >'/dev/null'
        end
    end
end
###

### Set Android Termux environment variables
if is_platform 'android-termux'
    # Set path variables
    __temporary_20200128_append_paths PATH "$PREFIX"'/local/bin'
    __temporary_20200128_append_paths MANPATH \
        "$PREFIX"'/local/share/man' \
        "$PREFIX"'/share/man'

    # In order to use GPG
    set --global --export GPG_TTY (tty)
end
###

### Set npm prefix/bin in $PATH
if is_platform 'npm'
    __temporary_20200128_append_paths PATH "$HOME"'/.my_global_node_modules/bin'
end
###

### Set snap /snap/bin in $PATH
if is_platform 'snap'
    __temporary_20200128_append_paths PATH '/snap/bin'
end
###

### Set JAVA_HOME
if command -v java >'/dev/null' 2>&1
    if is_platform 'macos'
        set --path --universal --export JAVA_HOME ('/usr/libexec/java_home')
    end
end
###

functions --erase __temporary_20200128_prepend_paths
functions --erase __temporary_20200128_append_paths
