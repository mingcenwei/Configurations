#!/usr/bin/env fish

### Source scripts and load functions needed
set --local function_directory (dirname (status filename))'/Files/fish/functions/'
source "$function_directory"'/echoerr.fish'
source "$function_directory"'/back_up_files.fish'

source (dirname (status filename))'/Files/fish/config.fish'
###

#### Set universal variables
### Configure the theme
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
###

# Set the greeting
# Overridden by "~/.config/fish/functions/fish_greeting.fish"
set --universal fish_greeting 'Welcome to fish, the friendly interactive shell'

# Set key bindings: Vim & Emacs
# Overridden by command "fish_hybrid_key_bindings"
set --universal fish_key_bindings 'fish_hybrid_key_bindings'

### Set default text editors
# Prerequisites: Visual Studio Code is installed
if test ! (which code)
    echoerr -w "Visual Studio Code is not installed! \$VISUAL is not set"
else
    set --universal VISUAL (which code)
end

# Prerequisites: Vim is installed
if test ! (which vim)
    echoerr -w "Vim is not installed! \$EDITOR is not set"
else
    set --universal EDITOR (which vim)
end
###

### Set macOS path variables
if test (uname -s) = 'Darwin'
    set --universal --path PATH '/usr/local/bin' '/usr/bin' '/bin' '/usr/sbin' '/sbin'
    # For MacGPG2, Wireshark
    set PATH $PATH '/usr/local/MacGPG2/bin' '/Applications/Wireshark.app/Contents/MacOS'

    set --universal --path JAVA_HOME ('/usr/libexec/java_home')

    # For Tomecat installed in "~/Archived/Binary Apps/"
    set --universal --path CATALINA_HOME '/Users/say/Archived/Binary Apps/apache-tomcat-9.0.20'
end

# Set environment variables for function "back_up_files"
set --universal back_up_files_NOT_A_DIRECTORY_ERROR_CODE 101
set --universal back_up_files_DEFAULT_DESTINATIONE "$HOME"'/.my_backups'
set --universal back_up_files_DEFAULT_COMPRESSOR 'xz'
set --universal back_up_files_DEFAULT_SUFFIX '.tar.xz'
####

### Link configuration files
###