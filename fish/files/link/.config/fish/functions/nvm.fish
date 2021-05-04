#!/usr/bin/env fish

function nvm --description 'Node version manager'
	check-dependencies --function 'echo-err' || return 3
	check-dependencies --function 'bass' || return 3

	set --local nvmScript "$NVM_DIR"'/nvm.sh'

	if not test -f "$nvmScript"
		echo-err '"$NVM_DIR"/nvm.sh not found: '(string escape -- "$nvmScript")
		return 3
	end

    bass source "$nvmScript" --no-use ';' nvm $argv
end
