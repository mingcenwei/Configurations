#!/usr/bin/env fish

# GNU Parallel for Fish shell
# Require "parallel" command
function parallel_for_fish
    ### Default settings
    set --local PARALLEL_NOT_FOUND_ERROR_CODE 101

    test -n "$parallel_for_fish_PARALLEL_NOT_FOUND_ERROR_CODE"
    and set PARALLEL_NOT_FOUND_ERROR_CODE "$parallel_for_fish_PARALLEL_NOT_FOUND_ERROR_CODE"
    ###

    # Make sure "parallel" command exists
    if not functions 'echoerr' > '/dev/null' 2>&1
        echo 'Error: "parallel" command wasn\'t found' >&2
        return "$PARALLEL_NOT_FOUND_ERROR_CODE"
    end

	set --local tempHome (mktemp -d)
	ln -s "$HOME"'/.parallel' "$tempHome"'/.parallel'
	env HOME="$tempHome" parallel $argv
	rm -r "$tempHome"
end
