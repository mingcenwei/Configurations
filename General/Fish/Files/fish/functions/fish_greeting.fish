#!/usr/bin/env fish

function fish_greeting
    set_color --dim
    fortune -a

    set_color normal
    echo
    echo "Welcome to fish, the friendly interactive shell"

    echo -n "Use "
    set_color --bold "$fish_color_command"
    echo -n "brew update; brew upgrade"
    set_color normal
    echo " to upgrade packages"

    echo -n "Use "
    set_color --bold "$fish_color_command"
    echo -n "fish_update_completions"
    set_color normal
    echo " to update man page completions"

    echo
end
