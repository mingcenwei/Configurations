#!/usr/bin/env fish

# Set error codes
set --local NOT_MAS_OS_ERROR_CODE 1
set --local BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 2

# Exit if the operating system is not macOS
is_platform 'macos'
or echo 'Error: The operating system is not macOS' >&2
and exit "$NOT_MAS_OS_ERROR_CODE"

set --local source_dir (dirname (realpath (status --current-filename)))'/Files'
set --local utility_dir (dirname (realpath (status --current-filename)))'/Utilities'
set --local workflow_dir "$HOME"'/Library/Services/'
set --local launchd_dir "$HOME"'/Library/LaunchAgents/'

# Make sure that "back_up_files" is loaded
functions back_up_files > /dev/null 2>&1
or begin
    echo 'Error: "back_up_files" function is not loaded!' >&2
    exit "$BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE"
end

### Workflows
for file in "$source_dir"'/Workflows/'*
    if test -e "$workflow_dir"'/'(basename "$file")
    or test -L "$workflow_dir"'/'(basename "$file")
        # Back up former workflows with the same name if existing
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$workflow_dir"'/'(basename "$file")
    end

    ln -si "$file" "$workflow_dir"'/'(basename "$file")
end
###

### Launchd
for file in "$source_dir"'/Launchd/'*
    if test -e "$launchd_dir"'/'(basename "$file")
    or test -L "$launchd_dir"'/'(basename "$file")
        # Back up former launchd agents with the same name if existing
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$launchd_dir"'/'(basename "$file")
    end

    ln -si "$file" "$launchd_dir"'/'(basename "$file")

    # Load an agent if its "ProgramArguments" have all been installed
    set --local parse_launchd_plists "$utility_dir"'/parse_launchd_plists.py'
    chmod u+x "$parse_launchd_plists"
    set --local plist_will_be_loaded "true"
    "$parse_launchd_plists" "$file" | while read --local program_path
        if not test -e "$program_path"
            set plist_will_be_loaded "false"
            break
        end
    end
    if test "$plist_will_be_loaded" = "true"
        launchctl load "$launchd_dir"'/'(basename "$file")
    end
end
###