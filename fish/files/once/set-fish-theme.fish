#!/usr/bin/env fish

### Configure the theme of "fish"
set --universal fish_color_autosuggestion '555555' 'brblack'
set --universal fish_color_cancel '--reverse'
set --universal fish_color_command 'c397d8' 'magenta'
set --universal fish_color_comment '--italics' '--dim' '809030' 'yellow'
set --universal fish_color_cwd '--bold' 'blue'
set --universal fish_color_cwd_root '--bold' 'green'
set --universal fish_color_end '--italics' '00a6b2' 'green'
set --universal fish_color_error 'ff0000' 'red'
set --universal fish_color_escape 'ffff00' 'bryellow'
set --universal fish_color_history_current '--bold'
set --universal fish_color_host 'cyan'
set --universal fish_color_host_remote 'bryellow'
set --universal fish_color_keyword '--italics' 'brgreen'
set --universal fish_color_match '--background=brblue'
set --universal fish_color_normal 'normal'
set --universal fish_color_operator '--bold' 'cyan'
set --universal fish_color_param '7aa6da' 'brblue'
set --universal fish_color_quote 'b9ca4a' 'bryellow'
set --universal fish_color_redirection '--italics' '70c0b1' 'brcyan'
set --universal fish_color_search_match '--background=brblack' 'ffff00' 'bryellow'
set --universal fish_color_selection '--bold' '--background=brblack' 'white'
set --universal fish_color_status 'red'
set --universal fish_color_user 'yellow'
set --universal fish_color_valid_path '--underline' '7aa6da' 'brblue'

set --universal fish_pager_color_progress '--background=cyan' 'brwhite'

#set --universal fish_pager_color_background 'normal'
set --universal fish_pager_color_completion 'normal'
set --universal fish_pager_color_description 'b3a06d' 'yellow'
set --universal fish_pager_color_prefix '--bold' '--underline' 'white'

#set --universal fish_pager_color_selected_background 'normal'
#set --universal fish_pager_color_selected_completion 'normal'
#set --universal fish_pager_color_selected_description 'normal'
#set --universal fish_pager_color_selected_prefix 'normal'

#set --universal fish_pager_color_secondary_background 'normal'
#set --universal fish_pager_color_secondary_completion 'normal'
#set --universal fish_pager_color_secondary_description 'normal'
#set --universal fish_pager_color_secondary_prefix 'normal'

# Set the greeting
# Overridden by "~/.config/fish/functions/fish_greeting.fish"
set --universal fish_greeting 'Welcome to fish, the friendly interactive shell'

# Set key bindings: Vim & Emacs
# Overridden by command "fish_hybrid_key_bindings"
set --universal fish_key_bindings 'fish_hybrid_key_bindings'
###
