#!/usr/bin/env fish

function fish_greeting
    # Fortune - print a random, hopefully interesting, adage
    # Prerequisites: "fortune" is installed
    if test ! (command -v fortune)
        echoerr -w '"fortune" is not installed!'
    else
        set_color --dim
        if is_platform 'android-termux'
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
    if is_platform 'macos'
        set package_update_commands 'brew -v update; brew upgrade; brew cleanup'
    else if is_platform 'android-termux'
        set package_update_commands \
            'apt update; apt upgrade; apt autoremove; apt autoclean'
    else if is_platform 'ubuntu'
        set package_update_commands \
            'apt update; apt upgrade; apt autoremove; apt autoclean'
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

    # "umask" command
    echo -n 'Use '
    set_color --bold "$fish_color_command"
    echo -n 'umask -S'
    set_color normal
    echo ' to display the symbolic file creation mode mask'

    # Server log files
    set --local log_files \
        '/var/log/auth.log' \
        '/var/log/ufw.log' \
        '/var/log/shadowsocks.log'
    if test "$AM_I_CLIENT_OR_SERVER" = 'server'
    or test "$AM_I_CLIENT_OR_SERVER" = 'both'
        echo 'Log files: '
        set_color --bold "$fish_color_command"
        for file in log_files
            echo "    $file"
        end
        set_color normal
    end

    echo
end
