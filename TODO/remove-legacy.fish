#!/usr/bin/env fish

back-up-files --remove-source -- "$HOME"/.ssh/.my_ssh_agent_information
back-up-files --remove-source -- "$HOME"/.my_backups
back-up-files --remove-source -- "$HOME"/.my_private_configurations
