#!/usr/bin/env fish

# Set error codes
set --local BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 1

set --local source_dir (dirname (realpath (status --current-filename)))'/Files'

# Make sure that "back_up_files" is loaded
functions back_up_files > '/dev/null' 2>&1
or begin
    echo 'Error: "back_up_files" function is not loaded!' >&2
    exit "$BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE"
end

# $XDG_CONFIG_HOME/git/config: Second user-specific configuration file.
# If $XDG_CONFIG_HOME is not set or empty, $HOME/.config/git/config will be used.
# Any single-valued variable set in this file will be overwritten by whatever is in ~/.gitconfig.
# It is a good idea not to create this file if you sometimes use older versions of Git, as support for this file was added fairly recently.
set --local git_home "$XDG_CONFIG_HOME"
if test -z "$git_home"
    set git_home "$HOME"'/.config/git'
end

# Back up former git user private configurations if available
set --local private_keys 'user.name' 'user.email' 'user.signingkey'
set --local user_private_confs_values
set --local user_private_confs_keys
for key in $private_keys
    set --local pattern (string replace --all '.' '\\.' '^'"$key"'=')
    if set --local value (git config --list | grep "$pattern")
        set user_private_confs_values $user_private_confs_values (string match --regex '(?<==).*$' "$value")
        set user_private_confs_keys $user_private_confs_keys "$key"
    end
end

# Back up former git configurations if existing
back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$git_home"
for file in '.gitconfig' '.gitignore' '.config/git'
    if test -e "$HOME"'/'"$file"
    or test -L "$HOME"'/'"$file"
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$HOME"'/'"$file"
    end
end

mkdir -p "$git_home"
for file in 'attributes' 'ignore'
    ln -si "$source_dir"'/'"$file" "$git_home"'/'"$file"
end

# Track these files with "track_file" function
set --local track_file_dir_path "$track_file_DIR_PATH"
test -z "$track_file_dir_path"
and set track_file_dir_path "$HOME"'/.my_private_configurations'
for file in 'config'
    set --local template_file "$track_file_dir_path"'/GIT_'"$file"
    cp -i "$source_dir"'/'"$file" "$template_file"
    ln -si "$template_file" "$git_home"'/'"$file"
    track_file --template='GIT_'"$file" --actual="$git_home"'/'"$file" --check
end

### Private configurations
for key in $private_keys
    # Use previous configurations if available
    if set --local index (contains --index -- "$key" $user_private_confs_keys)
        git config --global "$key" "$user_private_confs_values[$index]"
        continue
    else
        read --prompt-str="$key"': ' --local value
        git config --global "$key" "$value"
        continue
    end
end
###

### Platform dependent configurations
git config --global 'core.excludesFile' "$git_home"'/ignore'
if is_platform 'macos'
    # Caching GitHub password in git
    git config --global credential.helper 'osxkeychain'
end
###