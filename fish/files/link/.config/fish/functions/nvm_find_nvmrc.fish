#!/usr/bin/env fish

function nvm_find_nvmrc --description 'Find .nvmrc file for nvm'
	check-dependencies --function --quiet='never' 'echo-err' || return 3
	check-dependencies --function --quiet='never' 'bass' || return 3

	set --local nvmScript "$NVM_DIR"'/nvm.sh'

	if not test -f "$nvmScript"
		echo-err '"$NVM_DIR"/nvm.sh not found: '(string escape -- "$nvmScript")
		return 3
	end

    bass source "$nvmScript" --no-use ';' nvm_find_nvmrc
end
