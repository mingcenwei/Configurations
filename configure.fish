#!/usr/bin/env fish

# Make sure that the "fish" shell is used
test -z "$fish_pid" && echo 'Error: The shell is not "fish"!' >&2 && exit 3

# For security
umask 077

# Set variables
set --local thisFile (realpath -- (status filename)) || exit 1
set --local thisDir (dirname -- "$thisFile") || exit 1
set --local functionDir "$thisDir"'/fish/files/link/.config/fish/functions'

# Load required functions
for file in "$functionDir"/*'.fish'
	source -- "$file" || exit
end
or exit 1

# For security
for filesDir in "$thisDir"/*/'files'
	chmod -R u+rwX,go= "$filesDir" || exit 1
end
or exit 1

set --local configDirs \
	'fish' \
	'vim' \
	'gpg' \
	'git' \
	'ssh'

for configScript in "$thisDir"/*/'configure.fish'
	set --local configName (basename -- (dirname -- "$configScript"))
	test "$configName" = 'TODO' && continue

	not contains -- "$configName" $configDirs
	and echo-err --warning -- 'Please add `'"$configName"'` to $configDirs'
	or true
end
or exit 1


for configDir in $configDirs
	set --local configScript "$thisDir"/"$configDir"/'configure.fish'

	not test -f "$configScript"
	and echo-err 'Not found: '(string escape -- "$configScript")
	and continue

	echo 'Run '(string escape -- "$configScript")' ?'
	read-choice --variable runScript --default 1 -- 'yes' 'no' || exit 2
	if test "$runScript" = 'yes'
		fish -- "$configScript"
		or begin
			set --local statusCode "$status"
			echo-err 'Exit with status code: '"$statusCode"
		end
	end
end
