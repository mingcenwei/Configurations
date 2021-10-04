#!/usr/bin/env fish

# Add common paths
add-paths --append --variable PATH "$HOME"'/.local/bin'

# Set path variables
if is-platform --quiet 'macos'
	set --local paths \
		"$HOME"'/.local/bin' \
		"$HOME"'/Library/Android/sdk/platform-tools'

	set --local filenames \
		'Haskell-stack-bin' \
		'Android-SDK-platform-tools'

	# Make sure previous 2 settings are correct
	if not test (count $paths) = (count $filenames)
		echo-err 'Lengths of $paths and $filenames are not equal'
	else
		# Back up and create `/etc/paths.d/"$filenames[$iii]"`
		for iii in (seq (count $paths))
			set --local path "$paths[$iii]"
			set --local filepath '/etc/paths.d/'"$filenames[$iii]"

			if test -d "$path"
				add-paths --append --variable PATH "$path"

				if not test -e "$filepath"
				or test -d "$filepath"
					if test -d "$filepath" || test -L "$filepath"
						back-up-files --remove-source -- "$filepath"
						or back-up-files --sudo --remove-source -- "$filepath"
					end
					and begin
						echo "$path" | tee "$filepath" > '/dev/null' 2>&1
						or echo "$path" | sudo tee "$filepath" > '/dev/null'
					end
				end
			end
		end
	end
else if is-platform --quiet 'android-termux'
	add-paths --append --variable PATH "$PREFIX"'/local/bin'
end

# Set man path variables
if is-platform --quiet 'android-termux'
	add-paths --append --variable MANPATH \
		"$PREFIX"'/local/share/man' \
		"$PREFIX"'/share/man'
else if is-platform --quiet 'linux'
	add-paths --append --variable MANPATH \
		'/usr/share/fish/man' \
		'/usr/share/man' \
		'/usr/local/share/man' \
		'/usr/local/man'
end

# Set snap `/snap/bin` in $PATH
if is-platform --quiet 'snap'
	add-paths --append --variable PATH '/snap/bin'
end
