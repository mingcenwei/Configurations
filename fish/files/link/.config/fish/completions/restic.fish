#!/usr/bin/env fish

begin
	set --local completionFile (mktemp)
	restic generate --fish-completion "$completionFile"
	source "$completionFile"
end
