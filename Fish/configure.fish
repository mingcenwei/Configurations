#!/usr/bin/env fish

# Make sure that the "fish" shell is used
test -z "$fish_pid" && echo 'Error: The shell is not "fish"!' >&2 && exit 1

### Change the default login shell to "fish" if possible
set --local chsh_status 1
# For Android Termux
if is_platform 'android-termux'
    chsh -s 'fish'
    set chsh_status "$status"
else if cat "$etc_shells" 2> '/dev/null' | grep '/fish$' > '/dev/null'
    if test (cat "$etc_shells" | grep '/fish$' | wc -l) -eq 1
        chsh -s (cat "$etc_shells" | grep '/fish$')
        set chsh_status "$status"
    else
        # Ask the user which one is the "fish" shell they want
        for line in (cat "$etc_shells" | grep '/fish$')
            echo $line

            read --prompt-str='Is this shell the "fish" shell that you want to use? (YES/no): ' --local yes_or_no
            set yes_or_no (string lower "$yes_or_no")
            while not contains "$yes_or_no" 'yes' 'no'
            and test -n "$yes_or_no"
                read --prompt-str='Please enter yes/NO: ' yes_or_no
                set yes_or_no (string lower "$yes_or_no")
            end

            if test -z "$yes_or_no"
            or test "$yes_or_no" = 'yes'
                chsh -s "$line"
                set chsh_status "$status"
                break
            else
                continue
            end
        end
    end
end

# If the default login shell isn't changed to "fish" successfully
if test "$chsh_status" -ne 0
    echoerr 'The default login shell isn\'t changed. Please change it to "fish" mannualy. For example, append the line "exec <path-to-fish>" to ".bash_profile"'
end
###

# Set error codes
set --local CURL_IS_NOT_INSTALLED_ERROR_CODE 2
set --local ENCOUNTERING_ERRORS_WHEN_INSTALLING_FISHER_ERROR_CODE 3

# Load required functions
set --local package_directory (dirname (realpath (status filename)))'/Files/fish_configurations/'
source "$package_directory"'/functions/echoerr.fish'
source "$package_directory"'/functions/back_up_files.fish'
source "$package_directory"'/functions/track_my_file.fish'

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

### Configurations that are installed without "fisher"
set --local non_fisher_directory (dirname "$package_directory")'/non_fisher_fish_configurations'

# Create a symlink for this file specifically.
# If using "fisher" to add it, we'll go to the default working directory
# every time we enter "fisher" command
ln -si "$non_fisher_directory"'/set_default_working_directory.fish' ~/.config/fish/conf.d/set_default_working_directory.fish
###