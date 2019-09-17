#!/usr/bin/env fish

function fish_greeting
    # Fortune - print a random, hopefully interesting, adage
    # Prerequisites: "fortune" is installed
    if test ! (command -v fortune)
        echoerr -w '"fortune" is not installed!'
    else
        set_color --dim
        if test (uname -s) = 'Linux'
        and test (uname -o) = 'Android'
            fortune
        else
            fortune -a
        end
    end

    # Fish greeting
    set_color normal
    echo
    echo 'Welcome to fish, the friendly interactive shell'

    # Commands for respective package managers
    set --local package_update_commands
    if test (uname -s) = 'Darwin'
        set package_update_commands 'brew -v update; brew upgrade'
    else if test (uname -s) = 'Linux'
    and test (uname -o) = 'Android'
        set package_update_commands 'pkg upgrade'
    end

    # Package updating commands
    if test -n "$package_update_commands"
        echo -n 'Use '
        set_color --bold "$fish_color_command"
        echo -n "$package_update_commands"
        set_color normal
        echo ' to update packages'
    else
        echo -e '#\n#\n#\n#\n#' >&2
        set_color --bold "$fish_color_command"
        echoerr -w 'Unknown package manager!'
        set_color normal
        echo -e '#\n#\n#\n#\n#' >&2
    end

    # Fish completion updating command
    echo -n 'Use '
    set_color --bold "$fish_color_command"
    echo -n 'fish_update_completions'
    set_color normal
    echo ' to update man page completions'

    # Fisher updating commands
    echo -n 'Use '
    set_color --bold "$fish_color_command"
    echo -n 'fisher self-update; fisher'
    set_color normal
    echo ' to update fisher packages'

    echo
end
