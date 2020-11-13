#!/usr/bin/env fish

# Import "library.fish"
source (dirname (dirname \
    (realpath (status --current-filename))))'/library.fish'

# Set environment variables
set --export source_dir \
    (dirname (realpath (status --current-filename)))'/Files'

# Check dependencies
set --local required_functions \
    'back_up_files'
set --local required_binary_executables \
    'git'
check_function_dependencies $required_functions
check_binary_dependencies $required_binary_executables

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
    set --local config_file "$track_file_dir_path"'/GIT_'"$file"
    cp -i "$source_dir"'/'"$file" "$config_file"
    # For security
    chmod 600 "$config_file"
    ln -si "$config_file" "$git_home"'/'"$file"
    and track_file --filename='GIT_'"$file" --symlink="$git_home"'/'"$file" --check
end

### Private configurations
for key in $private_keys
    # Use previous configurations if available
    if set --local index (contains --index -- "$key" $user_private_confs_keys)
        git config --global "$key" "$user_private_confs_values[$index]"
        continue
    else
        read --prompt-str="$key"' (enter empty string to skip): ' --local value
        test -n "$value"
        and git config --global "$key" "$value"
        continue
    end
end
###

### Platform dependent configurations
git config --global 'core.excludesFile' "$git_home"'/ignore'
# Caching GitHub password in git
if is_platform 'macos'
    git config --global credential.helper 'osxkeychain'
else if is_platform 'kde'
    # Make sure that "ksshaskpass" is installed
    check_binary_dependencies 'ksshaskpass'
    and git config --global core.askpass (command -v ksshaskpass)
else if is_platform 'android-termux'
    # Make sure that "pass" is installed and intialized
    check_binary_dependencies 'pass'
    and git config --global credential.helper '!f() { test "$1" = get && echo "url=$(pass show GitHub)"; }; f'
    and pass > '/dev/null'
end
git config --global gpg.program (command -v gpg)
###

# Restore original umask
eval "$ORIGINAL_UMASK_CMD"
