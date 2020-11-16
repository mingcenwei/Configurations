#!/usr/bin/env fish

# For security
umask 077

# Set error codes
set --local NOT_MAS_OS_ERROR_CODE 1
set --local BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 2

# Exit if the operating system is not macOS
is_platform 'macos'
or begin
	echoerr 'The operating system is not macOS'
	and exit "$NOT_MAS_OS_ERROR_CODE"
end

set --local source_dir (dirname (realpath (status --current-filename)))'/Files'
set --local utility_dir (dirname (realpath (status --current-filename)))'/Utilities'
set --local workflow_dir "$HOME"'/Library/Services/'
set --local launchd_dir "$HOME"'/Library/LaunchAgents/'
set --local karabiner_dir "$HOME"'/.config/karabiner'

# Make sure that "back_up_files" is loaded
functions back_up_files > '/dev/null' 2>&1
or begin
	echoerr '"back_up_files" function is not loaded!'
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
		# Unload and back up former launchd agents with the same name if existing
		launchctl bootout 'gui/'(id -u) "$launchd_dir"'/'(basename "$file")
		back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$launchd_dir"'/'(basename "$file")
	end

	ln -si "$file" "$launchd_dir"'/'(basename "$file")

	# Load an agent if its "ProgramArguments" have all been installed;
	# otherwise give an warning
	set --local parse_launchd_plists "$utility_dir"'/parse_launchd_plists.py'
	chmod u+x "$parse_launchd_plists"
	set --local plist_will_be_loaded "true"
	"$parse_launchd_plists" "$file" | while read --local program_path
		if not test -e "$program_path"
			echoerr -w '"'"$program_path"'" isn\'t installed. Please install the program'
			set plist_will_be_loaded "false"
		end
	end
	if test "$plist_will_be_loaded" = "true"
		launchctl bootstrap 'gui/'(id -u) "$launchd_dir"'/'(basename "$file")
	end
end
###

### Karabiner-Elements
if test -e "$karabiner_dir"
or test -L "$karabiner_dir"
	# Back up former Karabiner-Elements configurations if existing
	back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$karabiner_dir"
end

# Do not make a symlink to karabiner.json.
# Karabiner-Elements does not reload the configuration file properly if you make a symlink to json file directly.
ln -si "$source_dir"'/Karabiner-Elements' "$karabiner_dir"

# Tell the user to install Karabiner-Elements if it's not installed
if not ls '/Applications' | grep 'Karabiner-Elements.app' > '/dev/null'
	echoerr -w 'Karabiner-Elements isn\'t installed. Please install the program'
end

# You have to restart karabiner_console_user_server process by the following command after you made a symlink in ordre to tell Karabiner-Elements that the parent directory is changed.
launchctl kickstart -k 'gui/'(id -u)'/org.pqrs.karabiner.karabiner_console_user_server'
###
