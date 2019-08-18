#!/usr/bin/env fish

# Backup files
# Require "echoerr" function
function back_up_files
    set --local NOT_A_DIRECTORY_ERROR_CODE "$back_up_files_NOT_A_DIRECTORY_ERROR_CODE"
    set --local DEFAULT_DESTINATION "$back_up_files_DEFAULT_DESTINATIONE"
    set --local DEFAULT_COMPRESSOR "$back_up_files_DEFAULT_COMPRESSOR"
    set --local DEFAULT_SUFFIX "$back_up_files_DEFAULT_SUFFIX"

    # TODO
    argparse --name='back_up_files' --min-args=1 --exclusive='b,r' \
        'd/destination=?' 'c/compressor=?' 's/suffix=?' \
        'b/back-up' 'r/restore' 'n/remove-source' 't/timestamp' \
        'h/help' 'v/verbose' \
        -- $argv
    or return $status

    if set --query _flag_d
    and test -z "$_flag_d"
        set _flag_d "$DEFAULT_DESTINATION"
    end
    if set --query _flag_c
    and test -z "$_flag_c"
        set _flag_d "$DEFAULT_COMPRESSOR"
    end
    if set --query _flag_s
    and test -z "$_flag_s"
        set _flag_d "$DEFAULT_SUFFIX"
    end

    set --local verbose
    for v in $_flag_v
        set verbose $verbose (string replace --all -- '--verbose' '-v' "$v")
    end

    # Make sure "echoerr" function is loaded
    if not functions | grep 'echoerr' > '/dev/null'
        if test -n "$verbose"
            echo 'Info: "echoerr" function wasn\'t found' >&2
        end

        set --local function_directory (dirname (status filename))
        source "$function_directory"'/echoerr.fish'
        or return $status

        if test -n "$verbose"
            echoerr -i '"echoerr" function is loaded'
        end
    end

    # Make sure destination directory exists
    set --local backup_directory
    if test -n "$_flag_d"
        # set backup_directory (realpath "$_flag_d")
        set backup_directory "$_flag_d"
        if test -n "$verbose"
            echoerr -i -- 'Destination directory:' "$backup_directory"
        end

        if test ! -e "$backup_directory"
            if test ! -d "$backup_directory"
                echoerr -s -- '"' "$backup_directory" '"' ' is not a directory!'
                return $NOT_A_DIRECTORY_ERROR_CODE
            end

            echoerr -w -s -- 'The destination directory "' "$backup_directory" '" doesn\'t exist. It will be created'
            mkdir $verbose -p "$backup_directory"
            or return $status
            chmod $verbose 700 "$backup_directory"
            or return $status
        end
    else
        if test -n "$verbose"
            echoerr -i 'Default destination directories'
        end
    end

    set --local suffix "$_flag_s"
    if test -n "$verbose"
        if test -n "$suffix"
            echoerr -i -- 'Suffix:' "$suffix"
        else
            echoerr -i 'No suffix'
        end
    end

    if test -n "$verbose"
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
        set --local decompressor
        set --local directory_option
        if test -n "$_flag_c"
            switch (string lower "$_flag_c")
                case 'unzip' 'zip'
                    set decompressor 'unzip' $verbose
                    set directory_option '-d'
                case 'unxz' 'xz' 'tar.xz'
                    set decompressor 'tar' $verbose '-xJf'
                    set directory_option '-C'
                case 'gunzip' 'gz' 'gzip' 'tar.gz'
                    set decompressor 'tar' $verbose '-xzf'
                    set directory_option '-C'
                case 'bunzip2' 'bz2' 'bzip2' 'tar.bz2'
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

        echo 'Restoring...'
        for file in $argv
            # set file (realpath "$file")
            set --local date_time_pattern ''
            if test -n "$_flag_t"
                set date_time_pattern '_\\d{4}(-\\d{2}){2}_\\d{2}(-\\d{2}){2}'
            end
            set --local suffix_pattern "$date_time_pattern"'\\Q'"$suffix"'\\E$'

            if not string match --regex -- "$suffix_pattern" "$file" > /dev/null
            or not string match --regex -- "$suffix_pattern" (basename "$file") > /dev/null
                echoerr -s -- '"' "$file" '"' ' doesn\'t match the pattern "' "$suffix_pattern" '"!'
                continue
            end

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
                cp $verbose -i "$file" "$target"
            else if test -n "$_flag_c"
            and test -z "$_flag_n"
                $decompressor "$file" $directory_option "$backup_directory"
            else if test -z "$_flag_c"
            and test -n "$_flag_n"
                #  Prompt for confirmation before overwriting existing files
                mv $verbose -i "$file" "$target"
            else
                $decompressor "$file" $directory_option "$backup_directory"
                rm $verbose "$file"
            end
        end
    else
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

        echo 'Backing up...'
        for file in $argv
            # set file (realpath "$file")
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

            if test -d "$target"
                echoerr -s -- '"' "$target" '"' ' is a directory!'
                continue
            end

            if test -z "$_flag_c"
            and test -z "$_flag_n"
                # Write a prompt to the standard error output before copying a file that would overwrite an existing file
                cp $verbose -i "$file" "$target"
            else if test -n "$_flag_c"
            and test -z "$_flag_n"
                if test -e "$target"
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
                        rm $verbose "$target"
                    end
                end

                $compressor "$target" "$file"
            else if test -z "$_flag_c"
            and test -n "$_flag_n"
                #  Prompt for confirmation before overwriting existing files
                mv $verbose -i "$file" "$target"
            else
                if test -e "$target"
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
                        rm $verbose "$target"
                    end
                end

                $compressor "$target" "$file"
                rm $verbose "$file"
            end
        end
    end
end