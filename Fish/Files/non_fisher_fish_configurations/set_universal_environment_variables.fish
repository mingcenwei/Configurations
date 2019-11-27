#!/usr/bin/env fish

### Set default text editors
# Prerequisites: Visual Studio Code is installed
if not test (command -v code)
    echoerr -w "Visual Studio Code is not installed! \$VISUAL will not be set"
else
    set --universal VISUAL (command -v code)
end

# Prerequisites: "vim" is installed
if not test (command -v vim)
    echoerr -w "\"vim\" is not installed! \$EDITOR will not be set"
else
    set --universal EDITOR (command -v vim)
end
###

### Set macOS path variables
if is_platform 'macos'
    set --universal --path JAVA_HOME ('/usr/libexec/java_home')

    # For Tomecat installed in "~/Archived/Binary Apps/"
    set --universal --path CATALINA_HOME '/Users/say/Archived/Binary Apps/apache-tomcat-9.0.20'
end
###

# # Set environment variables for function "back_up_files"
# set --universal back_up_files_NOT_A_DIRECTORY_ERROR_CODE 101
# set --universal back_up_files_DEFAULT_DESTINATION "$HOME"'/.my_backups'
# set --universal back_up_files_DEFAULT_COMPRESSOR 'xz'
# set --universal back_up_files_DEFAULT_SUFFIX '.tar.xz'

# # Uninstall
# # "$event_name" = 'set_environment_variables_uninstall'
# set --local event_name (basename (realpath (status filename)) '.fish')'_uninstall'
# function 'set_environment_variables_uninstall' --on-event "$event_name"
#     set --erase --universal VISUAL
#     set --erase --universal EDITOR

#     set --erase --universal JAVA_HOME
#     set --erase --universal CATALINA_HOME

#     # set --erase --universal back_up_files_NOT_A_DIRECTORY_ERROR_CODE
#     # set --erase --universal back_up_files_DEFAULT_DESTINATION
#     # set --erase --universal back_up_files_DEFAULT_COMPRESSOR
#     # set --erase --universal back_up_files_DEFAULT_SUFFIX
# end