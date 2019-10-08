#!/usr/bin/env fish

# Test whether we are on the given platform(s)
function is_platform
    # l/list: List all the platforms available
    argparse --name='is_platform' \
        --exclusive 'h,l' \
        'l/list' \
        'h/help' \
        -- $argv
    or begin
        set status_returned $status
        _is_platform_help
        return "$status_returned"
    end
    if test -n "$_flag_h"
        _is_platform_help
        return
    else if test -z "$_flag_l"
    and test -z "$argv"
        _is_platform_help
        return 2
    end

    # The list of platforms
    set --local platforms \
        'android-termux' \
        'macos' \
        'ubuntu' \
        'manjaro' \
        'kde' \
        'homebrew'

    if test -n "$_flag_l"
        for platform in $platforms
            echo "$platform"
        end
    end

    if test -n $argv
        for platform in $argv
            set platform (string lower "$platform")
            switch "$platform"
                case 'android-termux' 'termux'
                    test (uname -s) = 'Linux'
                    and test (uname -o) = 'Android'
                    or return 1
                case 'macos' 'macosx'
                    test (uname -s) = 'Darwin'
                    or return 1
                case 'ubuntu'
                    test (uname -s) = 'Linux'
                    and test (head -n 1 '/etc/issue' | cut -d ' ' -f 1) \
                        = 'Ubuntu'
                case 'manjaro'
                    test (uname -s) = 'Linux'
                    and test (head -n 1 '/etc/issue' | cut -d ' ' -f 1) \
                        = 'Manjaro'
                case 'kde'
                    test "$XDG_CURRENT_DESKTOP" = KDE
                case 'homebrew' 'brew'
                    command -v 'brew' > '/dev/null'
                case '*'
                    echoerr 'Unknown platform:' "$platform"
                    return 1
            end
        end
        return
    end
end

function _is_platform_help
    echo 'Usage:  is_platform [-l] [<platforms>...]'
    echo 'Test whether we are on the given platform(s)'
    echo
    echo 'Options:'
    echo '        -l, --list  List all the platforms available'
    echo '        -h, --help  Display this help message'
end