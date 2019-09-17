#!/usr/bin/env fish

# Make sure that the "fish" shell is used
test -z "$fish_pid" && echo 'Error: The shell is not "fish"!' >&2 && exit 1

# Set error codes
set --local CURL_IS_NOT_INSTALLED_ERROR_CODE 2
set --local ENCOUNTERING_ERRORS_WHEN_INSTALLING_FISHER_ERROR_CODE 3

# Load required functions
set --local package_directory (dirname (realpath (status filename)))'/Files/fish_configurations/'
source "$package_directory"'/functions/echoerr.fish'
source "$package_directory"'/functions/back_up_files.fish'


# Make sure that "curl" is installed
command -v curl > /dev/null 2>&1
or begin
    echo 'Error: "curl" is not installed! Please install the program' >&2
    exit "$CURL_IS_NOT_INSTALLED_ERROR_CODE"
end

# Install "fisher" if it hasn't been installed
if not functions fisher > /dev/null 2>&1
    curl https://git.io/fisher --create-dirs --location --output ~/.config/fish/functions/fisher.fish
    and source ~/.config/fish/functions/fisher.fish
    or begin
        echo 'Error: Encountered errors when installing "fisher"' >&2
        exit "$ENCOUNTERING_ERRORS_WHEN_INSTALLING_FISHER_ERROR_CODE"
    end
end

# Back up former fish configurations
back_up_files --back-up --timestamp --destination --compressor --suffix --parents ~/.config/fish

# Use "fisher" to add configurations and functions
fisher add "$package_directory"

# Create a symlink for this file specifically.
# If using "fisher" to add it, we'll go to the default working directory
# every time we enter "fisher" command
ln -si (dirname "$package_directory")'/set_default_working_directory.fish' ~/.config/fish/conf.d/set_default_working_directory.fish