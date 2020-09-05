#!/usr/bin/env fish

# Set error codes
set --local LENGTHS_NOT_EQUAL_ERROR_CODE 101

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

        set --path --export PATH "$paths[$iii]"

        if not test -e "$filepath"
        or test -d "$filepath"
            if test -d "$filepath"
            or test -L "$filepath"
                back_up_files --back-up --timestamp --destination --compressor \
                    --suffix --parents --remove-source "$filepath"
                or sudo back_up_files --back-up --timestamp --destination \
                    --compressor --suffix --parents --remove-source "$filepath"
            end
            echo "$paths[$iii]" | tee "$filepath" > '/dev/null'
            or echo "$paths[$iii]" | sudo tee "$filepath" > '/dev/null'
        end
    end
end
###

### Set Android Termux environment variables
if is_platform 'android-termux'
    # Set path variables
    set --path --export PATH "$PATH" "$PREFIX"'/local/bin'
    set --path --export MANPATH "$MANPATH" "$PREFIX"'/local/share/man'

    # In order to use GPG
    set --export GPG_TTY (tty)
end
###

### Set npm prefix/bin in $PATH
if is_platform 'npm'
    set PATH $PATH "$HOME"'/.my_global_node_modules/bin'
end
###

### Set snap /snap/bin in $PATH
if is_platform 'snap'
    set PATH $PATH '/snap/bin'
end
###

### Set JAVA_HOME
if command -v java > '/dev/null' 2>&1
    if is_platform 'macos'
        set --universal --path JAVA_HOME ('/usr/libexec/java_home')
    end
end
###
