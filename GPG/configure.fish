#!/usr/bin/env fish

# For security
umask 077

# Set error codes
set --local BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 1
set --local GPG_IS_NOT_INSTALLED_ERROR_CODE 2

set --local source_dir (dirname (realpath (status --current-filename)))'/Files'
set --local gpg_dir "$HOME"'/.gnupg'
set --local gpg_conf "$gpg_dir"'/gpg.conf'

# Make sure that "back_up_files" is loaded
functions back_up_files > '/dev/null' 2>&1
or begin
    echoerr '"back_up_files" function is not loaded!'
    exit "$BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE"
end

# Make sure that "gpg" is installed
command -v gpg > '/dev/null' 2>&1
or begin
    echoerr '"gpg" is not installed! Please install the program'
    exit "$GPG_IS_NOT_INSTALLED_ERROR_CODE"
end

# Back up former gpg.conf
if test -e "$gpg_conf"
or test -L "$gpg_conf"
    back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$gpg_conf"
end

mkdir -p -- "$gpg_dir"
ln -si "$source_dir"'/gpg.conf' "$gpg_conf"