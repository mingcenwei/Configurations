#!/usr/bin/env fish

# Set error codes
set --local BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 1

set --local source_dir (dirname (realpath (status --current-filename)))'/Files'
set --local workflow_dir "$HOME"'/Library/Services/'

# Make sure that "back_up_files" is loaded
functions back_up_files > /dev/null 2>&1
or begin
    echo 'Error: "back_up_files" function is not loaded!' >&2
    exit "$BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE"
end

# Back up former workflows with the same name if existing
for file in "$source_dir"'/Workflows/'*
    if test -e "$workflow_dir"'/'(basename "$file")
    or test -L "$workflow_dir"'/'(basename "$file")
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$workflow_dir"'/'(basename "$file")
    end

    ln -si "$file" "$workflow_dir"'/'(basename "$file")
end