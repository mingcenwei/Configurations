#!/usr/bin/env fish

# Set error codes
set --local LENGTHS_NOT_EQUAL_ERROR_CODE 101

### Set macOS path variables
if is_platform 'macos'
    set --local paths \
        "$HOME"'/Library/Python/3.7/bin' \
        "$HOME"'/.local/bin'

    set --local filenames \
        'Python3.7-bin' \
        'Haskell-stack-bin'

    # Make sure previous 2 settings are correct
    if not test (count $paths) = (count $filenames)
        echoerr 'Lengths of $paths and $filenames are not equal'
        exit "$LENGTHS_NOT_EQUAL_ERROR_CODE"
    end

    # Backup and create '/etc/paths.d/'"$filenames[$iii]"
    for iii in (seq (count $paths))
        set --local filepath '/etc/paths.d/'"$filenames[$iii]"

        set --path PATH $PATH "$paths[$iii]"

        if not test -e "$filepath"
        or test -d "$filepath"
            if test -d "$filepath"
            or test -L "$filepath"
                back_up_files --back-up --timestamp --destination --compressor \
                    --suffix --parents --remove-source "$filepath"
                or sudo back_up_files --back-up --timestamp --destination \
                    --compressor --suffix --parents --remove-source "$filepath"
            end

            echo "$paths[$iii]" > "$filepath"
            or echo "$paths[$iii]" | sudo tee "$filepath" > '/dev/null'
        end
    end
end
###

### Set npm prefix/bin in $PATH
if is_platform 'npm'
    set PATH $PATH "$HOME"'/.my_global_node_modules/bin'
end
###
