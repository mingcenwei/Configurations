#!/usr/bin/env fish

# Add common paths
add-paths --append --variable PATH "$HOME"'/.local/bin'

# Set macOS path variables
if is-platform --quiet 'macos'
	set --local paths \
		"$HOME"'/.local/bin' \
		"$HOME"'/Library/Python/3.7/bin' \
		"$HOME"'/Library/Android/sdk/platform-tools'

	set --local filenames \
		'Haskell-stack-bin' \
		'Python3.7-bin' \
		'Android-SDK-platform-tools'

	# Make sure previous 2 settings are correct
	if not test (count $paths) = (count $filenames)
		echo-err 'Lengths of $paths and $filenames are not equal'
	else
		# Back up and create `/etc/paths.d/"$filenames[$iii]"`
		for iii in (seq (count $paths))
			set --local filepath '/etc/paths.d/'"$filenames[$iii]"

			add-paths --append --variable PATH "$paths[$iii]"

			if not test -e "$filepath"
			or test -d "$filepath"
				if test -d "$filepath" || test -L "$filepath"
					back-up-files --remove-source -- "$filepath"
					or sudo back-up-files --remove-source -- "$filepath"
				end
				and echo "$paths[$iii]" | tee "$filepath" > '/dev/null'
				or echo "$paths[$iii]" | sudo tee "$filepath" > '/dev/null'
			end
		end
	end
end

# Set Android Termux path variables
if is-platform --quiet 'android-termux'
	add-paths --append --variable PATH "$PREFIX"'/local/bin'
	add-paths --append --variable MANPATH \
		"$PREFIX"'/local/share/man' \
		"$PREFIX"'/share/man'
end

# Set snap `/snap/bin` in $PATH
if is-platform --quiet 'snap'
	add-paths --append --variable PATH '/snap/bin'
end
