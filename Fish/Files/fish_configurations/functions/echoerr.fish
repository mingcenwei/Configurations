#!/usr/bin/env fish

# Echo error messages
function echoerr
    set --local status_returned $status

    # S/status: Change the status code returned (default: last status returned)
    # p/prompt: Set the prompt of the error message (default: "Error: ")
    # f/format: Use a custom format function. First literal "--" separate options and arguments
    # w/warning: Set the prompt of the error message to "Warning: "
    # i/info: Set the prompt of the error message to "Info: "
    # n, s, E, e: Options for "echo" command
    argparse --name='echoerr' --exclusive 'h,p,f,w,i' \
        --exclusive 'h,S' --exclusive 'h,E,e' \
        --exclusive 'h,n' --exclusive 'h,s' \
        'S/status=' 'p/prompt=' 'f/format=' \
        'w/warning' 'i/info' \
        'h/help' 'v/verbose' \
        'n' 's' 'E' 'e' \
        -- $argv
    or begin
        set status_returned $status
        _echoerr_help
        return "$status_returned"
    end
    if test -n "$_flag_h"
        _echoerr_help
        return
    end

    if set --query _flag_S
        set status_returned "$_flag_S"
    end

    set --local prompt 'Error: '
    if set --query _flag_p
        set prompt "$_flag_p"
    else if set --query _flag_w
        set prompt 'Warning: '
    else if set --query _flag_i
        set prompt 'Info: '
    end

    if set --query _flag_f
        "$_flag_f" $_flag_n $_flag_s $_flag_E $_flag_e $_flag_v -- $argv
    else
        echo -n "$prompt" >&2
        echo $_flag_n $_flag_s $_flag_E $_flag_e -- $argv >&2
    end

    return "$status_returned"
end

function _echoerr_help
    echo 'Usage:  echoerr [-w | -i | -p <prompt> | -f <format-function>]'
    echo '                [-S <status-code>] [-ns] [-E | -e]'
    echo '                [--] [<messages>...]'
    echo 'Echo error messages "Error: <message1> <message2>...".'
    echo
    echo 'Options:'
    echo '        -w, --warning                   Use "Warning: " as prompt'
    echo '        -i, --info                      Use "Info: " as prompt'
    echo '        -p, --prompt=<prompt>           Use a custom prompt'
    echo '        -f, --format=<format-function>  Use a format function to display message'
    echo '        -S, --status=<status-code>      Return this status code (default: last status returned)'
    echo '        -n                              Do not output the trailing newline'
    echo '        -s                              Do not separate arguments with spaces'
    echo '        -E                              Disable interpretation of backslash escapes (default)'
    echo '        -e                              Enable interpretation of backslash escapes'
    echo '        -h, --help                      Display this help message'
    echo '        --                              Only <messages>... after this'
end