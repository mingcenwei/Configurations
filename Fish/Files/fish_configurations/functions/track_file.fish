#!/usr/bin/env fish

# Create a directory to track platform-dependent configuration files.
# For example, "/etc/ssh/sshd_config" has a setting "Port",
# which may have different values on different servers;
# thus it cannot be tracked with Git.
# Nevertheless, we can put this configuration file into a special directory,
# which is used specifically to track such files, and create a symlink.
# These symlinks are recorded in "~/.my_private_configurations/RECORDS"

# Track/untrack files
# Require "echoerr" and "back_up_files" function, and "sed" utility
function track_file
    # Import "library.fish"
    source (dirname (dirname (dirname (dirname (dirname \
        (realpath (status --current-filename)))))))'/library.fish'

    # Set error codes
    set --export WRONG_ARGUMENTS_ERROR_CODE 1
    set --export TRACKING_FAILED_ERROR_CODE 2
    set --export UNTRACKING_FAILED_ERROR_CODE 3
    set --export NO_SUCH_CONFIG_ERROR_CODE 4
    set --export SORTING_ERROR_CODE 5

    # Set environment variables
    set --export dir_path "$track_file_DIR_PATH"
    test -z "$dir_path"
    and set dir_path "$HOME"'/.my_private_configurations'

    set --export record_file_path "$dir_path"'/RECORDS'

    set --export delimiter "$track_file_RECORDS_DELIMITER"
    test -z "$delimiter"
    and set delimiter ' => '

    # Check dependencies
    set --local required_functions \
        'echoerr' \
        'back_up_files'
    set --local required_binary_executables \
        'sed'
    check_function_dependencies $required_functions
    and check_binary_dependencies $required_binary_executables
    or exit "$status"

    # f/filename: Basename of the configuration file
    # s/symlink: Path to the symlink
    # u/untrack: Untracking instead of the default tracking behavior
    # c/check: Check the integrity of the record file
    # l/list: List the records
    argparse --name='track_file' --max-args=0 \
        --exclusive 'h,f' --exclusive 'h,s,u' --exclusive 'h,c' \
        'f/filename=' 's/symlink=' \
        'u/untrack' 'c/check' 'l/list' \
        'h/help' 'v/verbose' \
        -- $argv
    or begin
        # Restore original umask
        eval "$ORIGINAL_UMASK_CMD"

        set --local status_returned $status
        _track_file_help
        return "$status_returned"
    end
    if test -n "$_flag_h"
        # Restore original umask
        eval "$ORIGINAL_UMASK_CMD"

        _track_file_help
        return
    end
    if not set --query _flag_f
    and not set --query _flag_s
    and not set --query _flag_u
    and not set --query _flag_c
        # Restore original umask
        eval "$ORIGINAL_UMASK_CMD"

        _track_file_help
        return
    end

    # Replace long options with short ones for compatibility
    set --local verbose
    for v in $_flag_v
        set verbose $verbose (string replace --all -- '--verbose' '-v' "$v")
    end

    ### Make sure the directory and the record file exist
    # Create the directory to track platform-dependent configuration files,
    # if not existing
    if test ! -d "$dir_path"
        if test -e "$dir_path"
        or test -L "$dir_path"
            back_up_files $verbose --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$dir_path"
        end

        mkdir -p $verbose "$dir_path"
        chmod $verbose 700 "$dir_path"
    end

    # Create the record file if not existing
    if test ! -e "$record_file_path"
        if test -L "$record_file_path"
            back_up_files $verbose --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$record_file_path"
        end

        touch "$record_file_path"
        # Verbosity
        if test -n "$verbose"
            echoerr -i -- '"'"$record_file_path"'" is created'
        end

        chmod $verbose 600 "$record_file_path"
    end
    ###

    # Check the arguments
    if test -n "$_flag_f"
    and test -z "$_flag_s"
    and test -z "$_flag_u"
        # Restore original umask
        eval "$ORIGINAL_UMASK_CMD"

        echoerr 'Wrong arguments!'
        return "$WRONG_ARGUMENTS_ERROR_CODE"
    else if test -z "$_flag_f"
    and test -n "$_flag_s"
        # Restore original umask
        eval "$ORIGINAL_UMASK_CMD"
        
        echoerr 'Wrong arguments!'
        return "$WRONG_ARGUMENTS_ERROR_CODE"
    else if test -z "$_flag_f"
    and test -n "$_flag_u"
        # Restore original umask
        eval "$ORIGINAL_UMASK_CMD"
        
        echoerr 'Wrong arguments!'
        return "$WRONG_ARGUMENTS_ERROR_CODE"
    end

    # Track
    if test -n "$_flag_s"
        set --local line "$_flag_f""$delimiter""$_flag_s"
        if echo $line >> "$record_file_path"
            # Verbosity
            test -n "$verbose"
            and echoerr -i -- 'Line "'"$line"'" added'
        else
            # Restore original umask
            eval "$ORIGINAL_UMASK_CMD"
        
            echoerr 'Tracking failed'
            return "$TRACKING_FAILED_ERROR_CODE"
        end
    # Untrack
    else if test -n "$_flag_u"
        set --local pattern "$_flag_f""$delimiter"
        if not grep -E '^\\Q'"$pattern"'\\E' "$record_file_path"
            # Restore original umask
            eval "$ORIGINAL_UMASK_CMD"
        
            echoerr 'No such configuration file'
            return "$NO_SUCH_CONFIG_ERROR_CODE"
        end

        set pattern (echo $pattern | sed -e 's/[]\\/$*.^[]/\\\\&/g')
        if sed -i'.BACKUP~' -e '/^'"$pattern"'/d' "$record_file_path"
            # Verbosity
            test -n "$verbose"
            and echoerr -i -- 'Record removed successfully'

            rm "$record_file_path"'.BACKUP~'
        else
            # Restore original umask
            eval "$ORIGINAL_UMASK_CMD"
        
            echoerr 'Untracking failed'
            return "$UNTRACKING_FAILED_ERROR_CODE"
        end
    end

    # Sort the record file and remove duplicate lines
    sort -u "$record_file_path" > "$record_file_path"'~'
    and mv "$record_file_path"'~' "$record_file_path"
    or begin
        # Restore original umask
        eval "$ORIGINAL_UMASK_CMD"
        
        echoerr 'Encountering an error when modifying the record file'
        return "$SORTING_ERROR_CODE"
    end

    # List the records
    if test -n "$_flag_l"
        cat "$record_file_path"
    end

    # Check the integrity of the record file
    if test -n "$_flag_c"
        set --local line_number 0
        set --local config_names
        while read --local line
            set line_number (math "$line_number + 1")
            set --local paths (string split "$delimiter" "$line")
            if test (count $paths) -ne 2
                echoerr -e '"'"$record_file_path"'" line '"$line_number"': syntax error\n    '"$line"
            else if test "$paths[1]" != (basename "$paths[1]")
                echoerr -e '"'"$record_file_path"'" line '"$line_number"': configuration file\'s basename should be used\n    '"$line"
            else if contains "$paths[1]" $config_names
                echoerr -e '"'"$record_file_path"'" line '"$line_number"': duplicate configuration filenames\n    '"$line"
            else
                set config_names $config_names "$paths[1]"
                if not test -e "$dir_path""/$paths[1]"
                    echoerr -e '"'"$record_file_path"'" line '"$line_number"': configuration file doesn\'t exist\n    '"$line"
                else if not test -e "$paths[2]"
                    echoerr -e '"'"$record_file_path"'" line '"$line_number"': symlink does\'t exist\n    '"$line"
                end
            end
        end < "$record_file_path"
    end

    # Restore original umask
    eval "$ORIGINAL_UMASK_CMD"
end

function _track_file_help
    echo 'Usage:  track_file [-cl] [-f {-s | -u}] [-v]'
    echo 'Track/untrack files'
    echo
    echo 'Options:'
    echo '        -c, --check                   Check the integrity of the record file'
    echo '        -l, --list                    List the records'
    echo '        -f, --filename=<config-name>  Basename of the configuration file'
    echo '        -s, --symlink=<symlink>       Path to the symlink'
    echo '        -u, --untrack                 Untracking instead of the default tracking behavior'
    echo '        -v, --verbose                 Print verbose messages'
    echo '        -h, --help                    Display this help message'
end