#!/usr/bin/env fish

# Backup files
# Require "echoerr" function
function back_up_files
    # For security
    umask 077

    ### Default settings
    set --local ECHOERR_NOT_FOUND_ERROR_CODE 101
    set --local NOT_A_DIRECTORY_ERROR_CODE 102
    set --local DEFAULT_DESTINATION "$HOME"'/.my_backups'
    set --local DEFAULT_COMPRESSOR 'xz'
    set --local DEFAULT_SUFFIX '.tar.xz'

    test -n "$back_up_files_ECHOERR_NOT_FOUND_ERROR_CODE"
    and set ECHOERR_NOT_FOUND_ERROR_CODE "$back_up_files_ECHOERR_NOT_FOUND_ERROR_CODE"
    test -n "$back_up_files_NOT_A_DIRECTORY_ERROR_CODE"
    and set NOT_A_DIRECTORY_ERROR_CODE "$back_up_files_NOT_A_DIRECTORY_ERROR_CODE"
    test -n "$back_up_files_DEFAULT_DESTINATION"
    and set DEFAULT_DESTINATION "$back_up_files_DEFAULT_DESTINATION"
    test -n "$back_up_files_DEFAULT_COMPRESSOR"
    and set DEFAULT_COMPRESSOR "$back_up_files_DEFAULT_COMPRESSOR"
    test -n "$back_up_files_DEFAULT_SUFFIX"
    and set DEFAULT_SUFFIX "$back_up_files_DEFAULT_SUFFIX"
    ###

    # d/destination: Destination directory (zero argument: use the default) (no -d option: use source directories as destination directories)
    # c/compressor: (De)compression command (zero argument: use the default)
    # s/suffix: Add/remove the suffix to/from files (zero argument: use the default)
    # b/back-up: Back up files (default)
    # r/restore: Restore backups
    # n/remove-source: Remove original files
    # t/timestamp: Add/remove timestamp to/from files
    # p/parents: Create intermediate directories as required without prompt
    argparse --name='back_up_files' --min-args=1 --exclusive='h,b,r' \
        --exclusive 'h,d' --exclusive 'h,c' \
        --exclusive 'h,s' --exclusive 'h,n' \
        --exclusive 'h,t' --exclusive 'h,p' \
        'd/destination=?' 'c/compressor=?' 's/suffix=?' \
        'b/back-up' 'r/restore' 'n/remove-source' 't/timestamp' \
        'p/parents' 'h/help' 'v/verbose' \
        -- $argv
    or begin
        set --local status_returned $status
        _back_up_files_help
        return "$status_returned"
    end
    if test -n "$_flag_h"
        _back_up_files_help
        return
    end

    # Zero argument, use default settings
    if set --query _flag_d
    and test -z "$_flag_d"
        set _flag_d "$DEFAULT_DESTINATION"
    end
    if set --query _flag_c
    and test -z "$_flag_c"
        set _flag_c "$DEFAULT_COMPRESSOR"
    end
    if set --query _flag_s
    and test -z "$_flag_s"
        set _flag_s "$DEFAULT_SUFFIX"
    end

    # Replace long options with short ones for compatibility
    set --local verbose
    for v in $_flag_v
        set verbose $verbose (string replace --all -- '--verbose' '-v' "$v")
    end

    # Make sure "echoerr" function is loaded
    if not functions 'echoerr' > '/dev/null' 2>&1
        echo 'Error: "echoerr" function wasn\'t found' >&2
        return "$ECHOERR_NOT_FOUND_ERROR_CODE"
    end

    # Make sure destination directory exists
    set --local backup_directory
    if set --query _flag_d
        # set backup_directory (realpath "$_flag_d")
        set backup_directory "$_flag_d"
        if test -n "$verbose"
            echoerr -i -- 'Destination directory:' "$backup_directory"
        end

        ### Create the destination directory if it does not exist
        if test ! -e "$backup_directory"
        and test ! -L "$backup_directory"
            if test -z "$_flag_p"
                echoerr -w -s -- 'The destination directory "' "$backup_directory" '" doesn\'t exist'

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
                echoerr -w -s -- 'The destination directory "' "$backup_directory" '" doesn\'t exist. It will be created'
            end

            mkdir $verbose -p "$backup_directory"
            or return $status
            chmod $verbose 700 "$backup_directory"
            or return $status
        else if test ! -d "$backup_directory"
            echoerr -s -- '"' "$backup_directory" '"' ' is not a directory!'
            return $NOT_A_DIRECTORY_ERROR_CODE
        end
        ###
    else
        if test -n "$verbose"
            echoerr -i 'Using source directories as destination directories'
        end
    end

    set --local suffix "$_flag_s"

    # Verbosity
    if test -n "$verbose"
        if test -n "$suffix"
            echoerr -i -- 'Suffix:' "$suffix"
        else
            echoerr -i 'No suffix'
        end

        if test -n "$_flag_t"
            echoerr -i 'Using timestamp'
        else
            echoerr -i 'No timestamp'
        end

        if test -n "$_flag_n"
            echoerr -i 'Source files will be removed'
        else
            echoerr -i 'Source files will be kept'
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
                    echoerr -w 'Unknown decompressor. This command may be HARMFUL!'
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
                echoerr -i -- 'Decompression command:' "$decompressor" 'SOURCE' "$directory_option" 'DESTINATION'
            else
                echoerr -i 'No decompression'
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
                echoerr -s -- '"' "$file" '"' ' doesn\'t match the pattern "' "$suffix_pattern" '"!'
                continue
            end

            # Remove the suffix
            set --local target
            if test -z "$_flag_c"
                if test -z "$_flag_d"
                    set target (string replace --regex -- "$suffix_pattern" '' "$file")
                else
                    set target "$backup_directory"'/'(string replace --regex -- "$suffix_pattern" '' (basename "$file"))
                end
            end

            if test -d "$target"
                echoerr -s -- '"' "$target" '"' ' is a directory!'
                continue
            end

            if test -z "$_flag_c"
            and test -z "$_flag_n"
                # Write a prompt to the standard error output before copying a file that would overwrite an existing file
                cp $verbose -R -i "$file" "$target"
            else if test -n "$_flag_c"
            and test -z "$_flag_n"
                $decompressor "$file" $directory_option "$backup_directory"
            else if test -z "$_flag_c"
            and test -n "$_flag_n"
                #  Prompt for confirmation before overwriting existing files
                mv $verbose -i "$file" "$target"
            else
                $decompressor "$file" $directory_option "$backup_directory"
                rm -rf $verbose -- "$file"
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
                    echoerr -w 'Unknown compressor. This command may be HARMFUL!'
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
                echoerr -i -- 'Compression command:' "$compressor" 'TARGET SOURCE'
            else
                echoerr -i 'No compression'
            end
        end
        ###

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
                set target "$backup_directory"'/'(basename "$file")"$full_suffix"
            end
            ###

            if test -d "$target"
                echoerr -s -- '"' "$target" '"' ' is a directory!'
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
                        rm -rf $verbose -- "$target"
                    end
                end

                $compressor "$target" "$file"
                rm -rf $verbose -- "$file"
            end
        end
        echo 'Backing up finished'
    end
end

function _back_up_files_help
    echo 'Usage:  back_up_files [-b | -r] [-ntp] [-c [<command>]]'
    echo '                      [-d [<directory>]] [-s [<suffix>]]'
    echo '                      [-v] [--] <files>...'
    echo 'Back up/restore files'
    echo
    echo 'Options:'
    echo '        -b, --back-up                  Back up files (default)'
    echo '        -r, --restore                  Restore backups'
    echo '        -n, --remove-source            Remove original files'
    echo '        -t, --timestamp                Add/remove timestamp to/from files'
    echo '        -p, --parents                  Create intermediate directories as required without prompt'
    echo '        -c, --compressor=<command>     (De)compression command (zero argument to use the default)'
    echo '                                         (shortcuts: zip/xz/gz/bz2)'
    echo '        -d, --destination=<directory>  Specify destination directory (zero argument: use the default)'
    echo '                                         (no -d option: use source directories as destinations)'
    echo '        -s, --suffix=<suffix>          Add/remove suffix to/from files (zero argument: use the default)'
    echo '        -v, --verbose                  Print verbose messages'
    echo '        -h, --help                     Display this help message'
    echo '        --                             Only <files>... after this'
end