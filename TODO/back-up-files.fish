#!/usr/bin/env fish

function __sayAnonymousNamespace_back-up-files_help
	echo 'Usage:  back-up-files [back-up | restore] [-xf] [-c [<command>]]'
	echo '                      [-d [<directory>]] [-s [<suffix>]]'
	echo '                      [-v] [--] <files>...'
	echo 'Back up/restore files'
	echo
	echo 'Subcommands:'
	echo '        back-up                        Back up files (default)'
	echo '        restore                        Restore backups'
	echo
	echo 'Options:'
	echo '        -n, --remove-source            Remove original files'
	echo '        -p, --parents                  Create intermediate directories as required without prompt'
	echo '        -c, --compressor=<command>     (De)compression command (zero argument to use the default)'
	echo '                                         (shortcuts: zip/xz/gz/bz2)'
	echo '        -d, --destination=<directory>  Specify destination directory (zero argument: use the default)'
	echo '                                         (no -d option: use source directories as destinations)'
	echo '        -v, --verbose                  Print verbose messages'
	echo '        -h, --help                     Display this help message'
	echo '        --                             Only <files>... after this'
end

# Back up files
# Required functions: echo-err
function back-up-files --description  'Back up files'
	# Make sure "echo-err" function is loaded
	if not functions 'echo-err' > '/dev/null' 2>&1
		echo 'Error: "echo-err" function wasn\'t found' >&2
		return 1
	end

	### Default settings
	set --local defaultBackupDir "$HOME"'/.say_local/backups'
	set --local defaultCompressor 'xz'
	###

	# back-up: Back up files (default)
	# restore: Restore backups
	set --local subcommand 'back-up'
	switch "$argv[1]"
		case 'back-up' 'restore'
			set subcommand  "$argv[1]"
			set --erase  argv[1]
		case  '*'
	end

	# d/backup-dir: Backup directory (default: "$HOME"/.say_local/backups)
	# c/compressor: (De)compress using the compressor (zero argument: use the default)
	# n/remove-source: Remove original files
	# f/force: Use force as required without prompt
	set --local  optionSpecs \
		--name 'back-up-files' \
		(fish_opt --short 'd' --long 'backup-dir' --required-val) \
		(fish_opt --short 'c' --long 'compressor' --optional-val) \
		(fish_opt --short 'x' --long 'remove-source')  \
		(fish_opt --short 'f' --long 'force')  \
		(fish_opt --short 'h' --long 'help')  \
		(fish_opt --short 'v' --long 'verbose')  \
		--min-args 1 \
		--exclusive 'h,d' \
		--exclusive 'h,c' \
		--exclusive 'h,x' \
		--exclusive 'h,f'
	argparse $optionSpecs -- $argv
	or begin
		set --local status_returned $status
		__sayAnonymousNamespace_back-up-files_help
		return "$status_returned"
	end
	if test -n "$_flag_h"
		__sayAnonymousNamespace_back-up-files_help
		return
	end

	# Zero argument, use default settings
	set --local backupDir (realpath "$defaultBackupDir") || return
	set --local compressor
	set --local removeSource 'false'
	set --local force
	set --local verbose
	if set -n "$_flag_d"
		set backupDir (realpath "$_flag_d") || return
	end
	if set --query _flag_c
		if  test -n "$_flag_c"
			set compressor "$_flag_c"
		else
			set compressor "$defaultCompressor"
		end
	end
	if set -n "$_flag_x"
		set removeSource 'true'
	end
	if set -n "$_flag_f"
		set force '-f'
	end
	# Replace long options with short ones for compatibility
	for v in $_flag_v
		set --append verbose (string replace --all -- '--verbose' '-v' "$v")
	end

	if test -n "$verbose"
		echo-err -i -- 'Backup directory:' (string escape "$backupDir")
	end
	### Create the backup directory if it does not exist
	if not test -e "$backupDir" && not test -L "$backupDir"
		if test -z "$force"
			echo-err -w -- 'The backup directory "'(string escape "$backupDir")'" doesn\'t exist'

			echo -- 'Create the directory?'

			read --prompt-str='YES/no: ' --local yes_or_no
			set yes_or_no (string lower "$yes_or_no")
			while not contains "$yes_or_no" 'yes' 'no'
			and test -n "$yes_or_no"
				read --prompt-str='Please enter yes/NO: ' yes_or_no
				set yes_or_no (string lower "$yes_or_no")
			end

			if test "$yes_or_no" = no
				return
			end
		else
			echo-err -w -s -- 'The destination directory "' "$backupDir" '" doesn\'t exist. It will be created'
		end

		mkdir $verbose -p "$backupDir"
		or return $status
		chmod $verbose 700 "$backupDir"
		or return $status
	else if not test -d "$backupDir"
		echo-err -s -- '"' "$backupDir" '"' ' is not a directory!'
		return $NOT_A_DIRECTORY_ERROR_CODE
	end
	###

	# Verbosity
	if test -n "$verbose"
		if test -n "$suffix"
			echo-err -i -- 'Suffix:' "$suffix"
		else
			echo-err -i 'No suffix'
		end

		if test -n "$_flag_t"
			echo-err -i 'Using timestamp'
		else
			echo-err -i 'No timestamp'
		end

		if test -n "$_flag_n"
			echo-err -i 'Source files will be removed'
		else
			echo-err -i 'Source files will be kept'
		end
	end

	if test -n "$_flag_r"
		### Set the decompression command
		# Shortcuts: unzip/zip/.zip, unxz/xz/.xz/tar.xz/tar xz/.tar.xz, gunzip/gz/.gz/gzip/tar.gz/tar gz/.tar.gz, bunzip2/bz2/.bz2/bzip2/tar.bz2/tar bz2/.tar.bz2
		set --local decompressor
		set --local directory_option
		if test -n "$_flag_c"
			switch (string lower "$_flag_c")
				case 'unzip' 'zip' '.zip'
					set decompressor 'unzip' $verbose
					set directory_option '-d'
				case 'unxz' 'xz' '.xz' 'tar.xz' 'tar xz' '.tar.xz'
					set decompressor 'tar' $verbose '-xJf'
					set directory_option '-C'
				case 'gunzip' 'gz' '.gz' 'gzip' 'tar.gz' 'tar gz' '.tar.gz'
					set decompressor 'tar' $verbose '-xzf'
					set directory_option '-C'
				case 'bunzip2' 'bz2' '.bz2' 'bzip2' 'tar.bz2' 'tar bz2' '.tar.bz2'
					set decompressor 'tar' $verbose '-xjf'
					set directory_option '-C'
				case '*'
					set decompressor 'eval' "$_flag_c"
					echo-err -w 'Unknown decompressor. This command may be HARMFUL!'
					echo -s -- 'Use the provided command "' "$_flag_c" ' SOURCE $directory_option DESTINATION" to decompress files? (Can be DANGEROUS!)'

					read --prompt-str='yes/NO: ' --local yes_or_no
					set yes_or_no (string lower "$yes_or_no")
					while not contains "$yes_or_no" 'yes' 'no'
					and test -n "$yes_or_no"
						read --prompt-str='Please enter yes/NO: ' yes_or_no
						set yes_or_no (string lower "$yes_or_no")
					end

					if test "$yes_or_no" != yes
						return
					else
						read --prompt-str='Enter "directory_option": ' directory_option
					end
			end
		end
		if test -n "$verbose"
			if test -n "$decompressor"
				echo-err -i -- 'Decompression command:' "$decompressor" 'SOURCE' "$directory_option" 'DESTINATION'
			else
				echo-err -i 'No decompression'
			end
		end
		###

		echo 'Restoring...'
		for file in $argv
			# set file (realpath "$file")

			### Set the suffix pattern for removing the suffix
			set --local date_time_pattern ''
			if test -n "$_flag_t"
				set date_time_pattern '_\\d{4}(-\\d{2}){2}_\\d{2}(-\\d{2}){2}'
			end
			set --local suffix_pattern "$date_time_pattern"'\\Q'"$suffix"'\\E$'
			###

			# Check whether the pattern matches the suffix
			if not string match --regex -- "$suffix_pattern" "$file" > /dev/null
			or not string match --regex -- "$suffix_pattern" (basename "$file") > /dev/null
				echo-err -s -- '"' "$file" '"' ' doesn\'t match the pattern "' "$suffix_pattern" '"!'
				continue
			end

			# Remove the suffix
			set --local target
			if test -z "$_flag_c"
				if test -z "$_flag_d"
					set target (string replace --regex -- "$suffix_pattern" '' "$file")
				else
					set target "$backupDir"'/'(string replace --regex -- "$suffix_pattern" '' (basename "$file"))
				end
			end

			if test -d "$target"
				echo-err -s -- '"' "$target" '"' ' is a directory!'
				continue
			end

			if test -z "$_flag_c"
			and test -z "$_flag_n"
				# Write a prompt to the standard error output before copying a file that would overwrite an existing file
				cp $verbose -R -i "$file" "$target"
			else if test -n "$_flag_c"
			and test -z "$_flag_n"
				$decompressor "$file" $directory_option "$backupDir"
			else if test -z "$_flag_c"
			and test -n "$_flag_n"
				#  Prompt for confirmation before overwriting existing files
				mv $verbose -i "$file" "$target"
			else
				$decompressor "$file" $directory_option "$backupDir"
				rm -r $verbose -- "$file"
			end
		end
		echo 'Restoring finished'
	else
		### Set the compression command
		# Shortcuts: unzip/zip/.zip, unxz/xz/.xz/tar.xz/tar xz/.tar.xz, gunzip/gz/.gz/gzip/tar.gz/tar gz/.tar.gz, bunzip2/bz2/.bz2/bzip2/tar.bz2/tar bz2/.tar.bz2
		set --local compressor
		if test -n "$_flag_c"
			switch (string lower "$_flag_c")
				case 'unzip' 'zip'
					set compressor 'zip' $verbose '-r'
				case 'unxz' 'xz' 'tar.xz'
					set compressor 'tar' $verbose '-cJf'
				case 'gunzip' 'gz' 'gzip' 'tar.gz'
					set compressor 'tar' $verbose '-czf'
				case 'bunzip2' 'bz2' 'bzip2' 'tar.bz2'
					set compressor 'tar' $verbose '-cjf'
				case '*'
					set compressor 'eval' "$_flag_c"
					echo-err -w 'Unknown compressor. This command may be HARMFUL!'
					echo -s -- 'Use the provided command "' "$_flag_c" ' TARGET SOURCE" to compress files? (Can be DANGEROUS!)'

					read --prompt-str='yes/NO: ' --local yes_or_no
					set yes_or_no (string lower "$yes_or_no")
					while not contains "$yes_or_no" 'yes' 'no'
					and test -n "$yes_or_no"
						read --prompt-str='Please enter yes/NO: ' yes_or_no
						set yes_or_no (string lower "$yes_or_no")
					end

					if test "$yes_or_no" != yes
						return
					end
			end
		end
		if test -n "$verbose"
			if test -n "$compressor"
				echo-err -i -- 'Compression command:' "$compressor" 'TARGET SOURCE'
			else
				echo-err -i 'No compression'
			end
		end
		###

		# For security
		set --local ORIGINAL_UMASK_CMD (umask -p)
		umask 077
		echo 'Backing up...'

		for file in $argv
			# set file (realpath "$file")

			### Set the suffix
			set --local date_time ''
			if test -n "$_flag_t"
				set date_time (string replace --all ':' '-' (date +'_%F_%T'))
			end
			set --local full_suffix "$date_time""$suffix"
			set --local target
			if test -z "$_flag_d"
				set target "$file""$full_suffix"
			else
				set target "$backupDir"'/'(basename "$file")"$full_suffix"
			end
			###

			if test -d "$target"
				echo-err -s -- '"' "$target" '"' ' is a directory!'
				continue
			end

			if test -z "$_flag_c"
			and test -z "$_flag_n"
				# Write a prompt to the standard error output before copying a file that would overwrite an existing file
				cp $verbose -R -i "$file" "$target"
			else if test -n "$_flag_c"
			and test -z "$_flag_n"
				if test -e "$target"
				or test -L "$target"
					echo -s -- 'File "' "$target" ' exists. Overwrite?'

					read --prompt-str='yes/NO: ' --local yes_or_no
					set yes_or_no (string lower "$yes_or_no")
					while not contains "$yes_or_no" 'yes' 'no'
					and test -n "$yes_or_no"
						read --prompt-str='Please enter yes/NO: ' yes_or_no
						set yes_or_no (string lower "$yes_or_no")
					end

					if test "$yes_or_no" != yes
						continue
					else
						rm $verbose -- "$target"
					end
				end

				$compressor "$target" "$file"
			else if test -z "$_flag_c"
			and test -n "$_flag_n"
				#  Prompt for confirmation before overwriting existing files
				mv $verbose -i "$file" "$target"
			else
				if test -e "$target"
				or test -L "$target"
					echo -s -- 'File "' "$target" ' exists. Overwrite?'

					read --prompt-str='yes/NO: ' --local yes_or_no
					set yes_or_no (string lower "$yes_or_no")
					while not contains "$yes_or_no" 'yes' 'no'
					and test -n "$yes_or_no"
						read --prompt-str='Please enter yes/NO: ' yes_or_no
						set yes_or_no (string lower "$yes_or_no")
					end

					if test "$yes_or_no" != yes
						continue
					else
						rm -r $verbose -- "$target"
					end
				end

				$compressor "$target" "$file"
				rm -r $verbose -- "$file"
			end
		end
		echo 'Backing up finished'

		# Restore original umask
		eval "$ORIGINAL_UMASK_CMD"
	end
end
