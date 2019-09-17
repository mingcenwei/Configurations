#!/usr/bin/env fish

# Create a directory to track platform-dependent configuration files.
# For example, "/etc/ssh/sshd_config" has a setting "Port",
# which may have different values on different servers;
# thus it cannot be tracked with Git.
# Nevertheless, we have a template file for such a configuration file.
# The link between these two files is recorded
# in "~/.my_untracked_files/links"

# Create the directory "~/.my_untracked_files" if not exist
if test ! -d ~/.my_untracked_files
    if test -e ~/.my_untracked_files
    or test -L ~/.my_untracked_files
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source ~/.my_untracked_files
    end

    mkdir ~/.my_untracked_files
    chmod 700 ~/.my_untracked_files
end

# Create the file "~/.my_untracked_files/links" if not exist
if test ! -e ~/.my_untracked_files/links
    if test -L ~/.my_untracked_files/links
        back_up_files --back-up --timestamp --destination --compressor --suffix --parents --remove-source ~/.my_untracked_files
    end

    touch ~/.my_untracked_files/links
    chmod 600 ~/.my_untracked_files/links
end

# Check the integrity of the file "~/.my_untracked_files/links"
