#!/usr/bin/env fish

# Record the path of the package
set --universal _Configurations__PATH (dirname (realpath (status --current-filename)))

# Import "library.fish"
source "$_Configurations__PATH"'/library.fish'

# For security
find "$PACKAGE_DIR" -type d '!' -path '*/.*' -print0 | xargs -0 chmod 700
find "$PACKAGE_DIR" -type f '!' -path '*/.*' -print0 | xargs -0 chmod 600
chmod -- 700 "$PACKAGE_DIR"/*.{fish,py}
chmod -- 700 "$PACKAGE_DIR"/*/configure.fish
chmod -- 700 "$PACKAGE_DIR"/*/Utilities/**.{fish,py}

set --local my_backups "$PACKAGE_DIR"'/.my_backups'
set --local my_private_configurations "$PACKAGE_DIR"'/.my_private_configurations'
set --local config_dir_list \
    'Fish' \
    'Vim' \
    'Git' \
    'SSH' \
    'GPG' \
    'macOS'

test -L "$my_backups"
or ln -si "$HOME"'/.my_backups' "$my_backups"
test -L "$my_private_configurations"
or ln -si "$HOME"'/.my_private_configurations' "$my_private_configurations"

for script in "$PACKAGE_DIR"'/'*'/configure.fish'
    not contains (basename (dirname "$script")) $config_dir_list
    and echoerr \
        'Please add "'(basename (dirname "$script"))'" to $config_dir_list'
end


for config_dir in $config_dir_list
    set --local script "$PACKAGE_DIR"'/'"$config_dir"'/configure.fish'

    not test -e "$script"
    and echoerr "$script"' isn\'t found'
    and continue

    echo 'Run '"$script"'?'
    read_until --variable='yes_or_no' --default-position=1 'yes' 'no'
    if test "$yes_or_no" = 'yes'
        eval "$script"
    end
end

# Restore original umask
eval "$ORIGINAL_UMASK_CMD"
