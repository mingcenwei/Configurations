#!/usr/bin/env fish

# Import "library.fish"
source (dirname (realpath (status --current-filename)))'/library.fish'

# For security
for file in **
    if test -d "$file"
    or test (string sub -s '-5' "$file") = '.fish'
    or test (string sub -s '-3' "$file") = '.py'
        chmod -- 700 "$file"
    else
        chmod -- 600 "$file"
    end
end

set --local my_backups "$PACKAGE_DIR"'/.my_backups'
set --local my_private_configurations "$PACKAGE_DIR"'/.my_private_configurations'

test -L "$my_backups"
or ln -si "$HOME"'/.my_backups' "$my_backups"
test -L "$my_private_configurations"
or ln -si "$HOME"'/.my_private_configurations' "$my_private_configurations"

for script in "$PACKAGE_DIR"/*'/configure.fish'
    echo 'Run '"$script"'?'
    read_until --variable='yes_or_no' --default-position=1 'yes' 'no'
    if test "$yes_or_no" = 'yes'
        "$script"
    end
end

# Restore original umask
eval "$ORIGINAL_UMASK_CMD"