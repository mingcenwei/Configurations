#!/usr/bin/env fish

# Set error codes
set --local BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 1

set DIR (dirname (status --current-filename))

# Make sure that "back_up_files" is loaded
functions back_up_files > /dev/null 2>&1
or begin
    echo 'Error: "back_up_files" function is not loaded!' >&2
    exit "$BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE"
end

# Back up former vim configurations
for file in '.vim' '.vimrc' '.viminfo'
    if test -e {$HOME}'/'{$file}
    or test -L {$HOME}'/'{$file}
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source {$HOME}'/'{$file}
    end
end

mkdir -p {$HOME}'/.vim'
ln -si {$DIR}'/Files/vimrc' {$HOME}'/.vim/vimrc'