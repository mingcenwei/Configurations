#!/usr/bin/env fish

# Echo error messages
function echoerr
    set --local status_returned $status

    # S/status: Change the status code returned (default: last code returned)
    # p/prompt: Set the prompt of the error message (default: "Error: ")
    # f/format: Use a custom format function. First literal "--" separate options and arguments
    # w/warning: Set the prompt of the error message to "Warning: "
    # i/info: Set the prompt of the error message to "Info: "
    # n, s, E, e: Options for "echo" command
    argparse --name='echoerr' --exclusive 'p,f,w,i' \
        'S/status=' 'p/prompt=' 'f/format=' \
        'w/warning' 'i/info' \
        'h/help' 'v/verbose' \
        'n' 's' 'E' 'e' \
        -- $argv
    or return $status

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
        "$_flag_f" $_flag_n $_flag_s $_flag_E $_flag_e -- $argv
    else
        echo -n "$prompt" >&2
        echo $_flag_n $_flag_s $_flag_E $_flag_e -- $argv >&2
    end

    return "$status_returned"
end