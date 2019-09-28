#!/usr/bin/env fish

# Set error codes
set --local BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE 1
set --local VIM_IS_NOT_INSTALLED_ERROR_CODE 2

set --local source_dir (dirname (realpath (status --current-filename)))'/Files'
set --local vim_dir "$HOME"'/.vim'

# Make sure that "back_up_files" is loaded
functions back_up_files > '/dev/null' 2>&1
or begin
    echoerr '"back_up_files" function is not loaded!'
    exit "$BACK_UP_FILES_IS_NOT_LOADED_ERROR_CODE"
end

# Make sure that "vim" is installed
command -v vim > '/dev/null' 2>&1
or begin
    echoerr '"vim" is not installed! Please install the program'
    exit "$VIM_IS_NOT_INSTALLED_ERROR_CODE"
end

# Back up former vim configurations
for file in '.vim' '.vimrc' '.viminfo'
    if test -e "$HOME"'/'"$file"
    or test -L "$HOME"'/'"$file"
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$HOME"'/'"$file"
    end
end

mkdir -p "$vim_dir"
ln -si "$source_dir"'/vimrc' "$vim_dir"'/vimrc'

### Create symlinks for ex/rview/rvim/vi/view/vimdiff
set vim_bin_dir (dirname (command -v vim))
for file in 'ex' 'rview' 'rvim' 'vi' 'view' 'vimdiff'
    if test -e "$vim_bin_dir"'/'"$file"
    and test -L "$vim_bin_dir"'/'"$file"
    and test (readlink "$vim_bin_dir"'/'"$file") = 'vim'
        # Skip if it's already a symlink to vim
        continue
    else if test -e "$vim_bin_dir"'/'"$file"
    or test -L "$vim_bin_dir"'/'"$file"
        # Back up former symlinks
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents "$vim_bin_dir"'/'"$file"

        rm "$vim_bin_dir"'/'"$file"
        or begin
            read --prompt-str='Sudo? (yes/NO): ' --local yes_or_no
            set yes_or_no (string lower "$yes_or_no")
            while not contains "$yes_or_no" 'yes' 'no'
            and test -n "$yes_or_no"
                read --prompt-str='Please enter yes/NO: ' yes_or_no
                set yes_or_no (string lower "$yes_or_no")
            end

            if test "$yes_or_no" = "yes"
                sudo rm "$vim_bin_dir"'/'"$file"
            else
                continue
            end
        end

        ln -si 'vim' "$vim_bin_dir"'/'"$file"
        or begin
            read --prompt-str='Sudo? (yes/NO): ' --local yes_or_no
            set yes_or_no (string lower "$yes_or_no")
            while not contains "$yes_or_no" 'yes' 'no'
            and test -n "$yes_or_no"
                read --prompt-str='Please enter yes/NO: ' yes_or_no
                set yes_or_no (string lower "$yes_or_no")
            end

            if test "$yes_or_no" = "yes"
                sudo ln -si 'vim' "$vim_bin_dir"'/'"$file"
            end
        end
    end
end
###