#!/usr/bin/env fish

# Create a directory to track platform-dependent configuration files.
# For example, "/etc/ssh/sshd_config" has a setting "Port",
# which may have different values on different servers;
# thus it cannot be tracked with Git.
# Nevertheless, we have a template file for such a configuration file.
# The link between these two files is recorded
# in "~/.my_untracked_files/records"

# Track/untrack files
# Require "echoerr" and "back_up_files" function, and "sed" utility
function track_file
    ### Default settings
    set --local ECHOERR_NOT_FOUND_ERROR_CODE "$track_file_ECHOERR_NOT_FOUND_ERROR_CODE"
    test -z "$ECHOERR_NOT_FOUND_ERROR_CODE"
    and set ECHOERR_NOT_FOUND_ERROR_CODE 101

    set --local BACK_UP_FILES_NOT_FOUND_ERROR_CODE "$track_file_BACK_UP_FILES_NOT_FOUND_ERROR_CODE"
    test -z "$BACK_UP_FILES_NOT_FOUND_ERROR_CODE"
    and set BACK_UP_FILES_NOT_FOUND_ERROR_CODE 102

    set --local SED_NOT_FOUND_ERROR_CODE "$track_file_SED_NOT_FOUND_ERROR_CODE"
    test -z "$SED_NOT_FOUND_ERROR_CODE"
    and set SED_NOT_FOUND_ERROR_CODE 103

    set --local WRONG_ARGUMENTS_ERROR_CODE "$track_file_WRONG_ARGUMENTS_ERROR_CODE"
    test -z "$WRONG_ARGUMENTS_ERROR_CODE"
    and set WRONG_ARGUMENTS_ERROR_CODE 104

    set --local TRACKING_FAILED_ERROR_CODE "$track_file_TRACKING_FAILED_ERROR_CODE"
    test -z "$TRACKING_FAILED_ERROR_CODE"
    and set TRACKING_FAILED_ERROR_CODE 105

    set --local UNTRACKING_FAILED_ERROR_CODE "$track_file_UNTRACKING_FAILED_ERROR_CODE"
    test -z "$UNTRACKING_FAILED_ERROR_CODE"
    and set UNTRACKING_FAILED_ERROR_CODE 106

    set --local NO_SUCH_TEMPLATE_ERROR_CODE "$track_file_NO_SUCH_TEMPLATE_ERROR_CODE"
    test -z "$NO_SUCH_TEMPLATE_ERROR_CODE"
    and set NO_SUCH_TEMPLATE_ERROR_CODE 107

    set --local dir_path "$track_file_DIR_PATH"
    test -z "$dir_path"
    and set dir_path "$HOME"'/.my_untracked_files'

    set --local record_file_path "$dir_path"'/records'

    set --local delimiter "$track_file_RECORDS_DELIMITER"
    test -z "$delimiter"
    and set delimiter ' => '
    ###

    # t/template: Basename of the template file
    # a/actual: Path of the actual file
    # u/untrack: Untracking instead of the default tracking behavior
    # c/check: Check the integrity of the record file
    # l/list: List the records
    argparse --name='track_file' --max-args=0 \
        --exclusive 'h,t' --exclusive 'h,a,u' --exclusive 'h,c' \
        't/template=' 'a/actual=' \
        'u/untrack' 'c/check' 'l/list' \
        'h/help' 'v/verbose' \
        -- $argv
    or begin
        set --local status_returned $status
        _track_file_help
        return "$status_returned"
    end
    if test -n "$_flag_h"
        _track_file_help
        return
    end
    if not set --query _flag_t
    and not set --query _flag_a
    and not set --query _flag_u
    and not set --query _flag_c
        _track_file_help
        return
    end

    # Replace long options with short ones for compatibility
    set --local verbose
    for v in $_flag_v
        set verbose $verbose (string replace --all -- '--verbose' '-v' "$v")
    end

    # Make sure "echoerr" function is loaded
    if not functions 'echoerr' > '/dev/null' 2>&1
        echo 'Error: "echoerr" function wasn\'t found' >&2
        return "$ECHOERR_NOT_FOUND_ERROR_CODE"
    end
    # Make sure "back_up_files" function is loaded
    if not functions 'back_up_files' > '/dev/null' 2>&1
        echo 'Error: "back_up_files" function wasn\'t found' >&2
        return "$BACK_UP_FILES_NOT_FOUND_ERROR_CODE"
    end
    # Make sure that "sed" is installed
    command -v sed > /dev/null 2>&1
    or begin
        echo 'Error: "curl" is not installed! Please install the program' >&2
        return "$SED_NOT_FOUND_ERROR_CODE"
    end

    ### Make sure the directory and the record file exist
    # Create the directory to track platform-dependent configuration files,
    # if not existing
    if test ! -d "$dir_path"
        if test -e "$dir_path"
        or test -L "$dir_path"
            back_up_files $verbose --back-up --timestamp --destination --compressor --suffix --parents --remove-source "$dir_path"
        end

        mkdir $verbose "$dir_path"
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
    if test -n "$_flag_t"
    and test -z "$_flag_a"
    and test -z "$_flag_u"
        echoerr 'Wrong arguments!'
        return "$WRONG_ARGUMENTS_ERROR_CODE"
    else if test -z "$_flag_t"
    and test -n "$_flag_a"
        echoerr 'Wrong arguments!'
        return "$WRONG_ARGUMENTS_ERROR_CODE"
    else if test -z "$_flag_t"
    and test -n "$_flag_u"
        echoerr 'Wrong arguments!'
        return "$WRONG_ARGUMENTS_ERROR_CODE"
    end

    # Track
    if test -n "$_flag_a"
        set --local line "$_flag_t""$delimiter""$_flag_a"
        if echo $line >> "$record_file_path"
            # Verbosity
            test -n "$verbose"
            and echoerr -i -- 'Line "'"$line"'" added'
        else
            echoerr 'Tracking failed'
            return "$TRACKING_FAILED_ERROR_CODE"
        end
    # Untrack
    else if test -n "$_flag_u"
        set --local pattern "$_flag_t""$delimiter"
        if not grep -E '^\\Q'"$pattern"'\\E' "$record_file_path"
            echoerr 'No such template'
            return "$NO_SUCH_TEMPLATE_ERROR_CODE"
        end

        set pattern (echo $pattern | sed -e 's/[]\\/$*.^[]/\\\\&/g')
        if sed -i'.BACKUP~' -e '/^'"$pattern"'/d' "$record_file_path"
            # Verbosity
            test -n "$verbose"
            and echoerr -i -- 'Record removed successfully'

            rm "$record_file_path"'.BACKUP~'
        else
            echoerr 'Untracking failed'
            return "$UNTRACKING_FAILED_ERROR_CODE"
        end
    end

    # Sort the record file and remove duplicate lines
    sort -u "$record_file_path" > "$record_file_path"'~'
    mv "$record_file_path"'~' "$record_file_path"

    # List the records
    if test -n "$_flag_l"
        cat "$record_file_path"
    end

    # Check the integrity of the record file
    if test -n "$_flag_c"
        set --local line_number 0
        set --local template_names
        while read --local line
            set line_number (math "$line_number + 1")
            set --local paths (string split "$delimiter" "$line")
            if test (count $paths) -ne 2
                echoerr -e '"'"$record_file_path"'" line '"$line_number"': syntax error\n    '"$line"
            else if test "$paths[1]" != (basename "$paths[1]")
                echoerr -e '"'"$record_file_path"'" line '"$line_number"': template file\'s basename should be used\n    '"$line"
            else if contains "$paths[1]" $template_names
                echoerr -e '"'"$record_file_path"'" line '"$line_number"': duplicate template filename\n    '"$line"
            else
                set template_names $template_names "$paths[1]"
                if not test -e "$dir_path""/$paths[1]"
                    echoerr -e '"'"$record_file_path"'" line '"$line_number"': template file doesn\'t exist\n    '"$line"
                else if not test -e "$paths[2]"
                    echoerr -e '"'"$record_file_path"'" line '"$line_number"': actual file does\'t exist\n    '"$line"
                end
            end
        end < "$record_file_path"
    end
end

function _track_file_help
    echo 'Usage:  track_file [-cl] [-t {-a | -u}] [-v]'
    echo 'Track/untrack files'
    echo
    echo 'Options:'
    echo '        -c, --check                     Check the integrity of the record file'
    echo '        -l, --list                      List the records'
    echo '        -t, --template=<template-name>  Basename of the template file'
    echo '        -a, --actual=<actual-file>      Path of the actual file'
    echo '        -u, --untrack                   Untracking instead of the default tracking behavior'
    echo '        -v, --verbose                   Print verbose messages'
    echo '        -h, --help                      Display this help message'
end