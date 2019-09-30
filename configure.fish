#!/usr/bin/env fish

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

set --local current_dir (dirname (realpath (status --current-filename)))
set --local my_backups "$current_dir"'/.my_backups'
set --local my_private_configurations "$current_dir"'/.my_private_configurations'

test -L "$my_backups"
or ln -si "$HOME"'/.my_backups' "$my_backups"
test -L "$my_private_configurations"
or ln -si "$HOME"'/.my_private_configurations' "$my_private_configurations"