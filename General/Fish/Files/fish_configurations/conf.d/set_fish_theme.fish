#!/usr/bin/env fish

### Configure the theme of "fish"
set --universal fish_color_autosuggestion '969896'
set --universal fish_color_cancel 'normal'
set --universal fish_color_command 'c397d8'
set --universal fish_color_comment 'e7c547'
set --universal fish_color_cwd '-o blue'
set --universal fish_color_cwd_root '-o blue'
set --universal fish_color_end 'd7875f'
set --universal fish_color_error 'red'
set --universal fish_color_escape 'ffff00'
set --universal fish_color_history_current 'normal'
set --universal fish_color_host 'cyan'
set --universal fish_color_match 'normal'
set --universal fish_color_normal 'normal'
set --universal fish_color_operator 'ffff00'
set --universal fish_color_param '7aa6da'
set --universal fish_color_quote 'b9ca4a'
set --universal fish_color_redirection '70c0b1'
set --universal fish_color_search_match 'ffff00'
set --universal fish_color_selection 'c0c0c0'
set --universal fish_color_status 'red'
set --universal fish_color_user 'yellow'
set --universal fish_color_valid_path 'normal'
set --universal fish_pager_color_completion 'normal'
set --universal fish_pager_color_description 'B3A06D yellow'
set --universal fish_pager_color_prefix 'white --bold --underline'
set --universal fish_pager_color_progress 'brwhite --background=cyan'

# Set the greeting
# Overridden by "~/.config/fish/functions/fish_greeting.fish"
set --universal fish_greeting 'Welcome to fish, the friendly interactive shell'
# # For interactive shells
# if status is-interactive
#     # Set key bindings: Vim & Emacs
#     fish_hybrid_key_bindings
# end

# Set key bindings: Vim & Emacs
# Overridden by command "fish_hybrid_key_bindings"
set --universal fish_key_bindings 'fish_hybrid_key_bindings'
###

# # Uninstall
# # "$event_name" = 'set_fish_theme_uninstall'
# set --local event_name (basename (status filename) '.fish')'_uninstall'
# function 'set_fish_theme_uninstall' --on-event "$event_name"
#     set --erase --universal fish_color_autosuggestion
#     set --erase --universal fish_color_cancel
#     set --erase --universal fish_color_command
#     set --erase --universal fish_color_comment
#     set --erase --universal fish_color_cwd
#     set --erase --universal fish_color_cwd_root
#     set --erase --universal fish_color_end
#     set --erase --universal fish_color_error
#     set --erase --universal fish_color_escape
#     set --erase --universal fish_color_history_current
#     set --erase --universal fish_color_host
#     set --erase --universal fish_color_match
#     set --erase --universal fish_color_normal
#     set --erase --universal fish_color_operator
#     set --erase --universal fish_color_param
#     set --erase --universal fish_color_quote
#     set --erase --universal fish_color_redirection
#     set --erase --universal fish_color_search_match
#     set --erase --universal fish_color_selection
#     set --erase --universal fish_color_status
#     set --erase --universal fish_color_user
#     set --erase --universal fish_color_valid_path
#     set --erase --universal fish_pager_color_completion
#     set --erase --universal fish_pager_color_description
#     set --erase --universal fish_pager_color_prefix
#     set --erase --universal fish_pager_color_progress

#     set --erase --universal fish_greeting

#     set --erase --universal fish_key_bindings
# end
