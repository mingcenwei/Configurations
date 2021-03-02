#!/usr/bin/env fish

set --erase --universal track_file_DIR_PATH
set --erase --universal _Configurations__PATH
set --erase --universal JAVA_HOME

set --local fisherUniversalVariables \
	(set --names --universal | grep '_fisher_')
for var in $fisherUniversalVariables
	set --erase --universal "$var"
end

set --local filesToRemove
for file in "$HOME"/.ssh/.my_ssh_agent_information \
"$HOME"/.my_backups \
"$HOME"/.my_private_configurations \
"$HOME"/.say-local/.ssh-agent-info
	test -e "$file"
	and set --append filesToRemove "$file"
end
back-up-files --remove-source -- $filesToRemove
