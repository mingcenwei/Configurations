#!/usr/bin/env fish

# For security
umask 077

# Set path variable
set --global PACKAGE_DIR \
    (dirname (realpath (status --current-filename)))

functions echoerr > '/dev/null' 2>&1
or source "$PACKAGE_DIR"'/Fish/Files/fish_configurations/functions/echoerr.fish'
or begin
    echo -s (set_color '--bold' 'red') \
        'Error:' (set_color 'normal') \
        ' "echoerr" function is not loaded!' >&2
    exit "$FUNCTION_NOT_LOADED_ERROR_CODE"
end

function check_function_dependencies \
    --argument-names function_list

    for func in $function_list
        functions "$func" > '/dev/null' 2>&1
        or begin
            echoerr "\"$func\""' function is not loaded!'
            exit "$FUNCTION_NOT_LOADED_ERROR_CODE"
        end
    end
end

function check_binary_dependencies \
    --argument-names binary_list

    for bin in $binary_list
        command -v "$bin" > '/dev/null' 2>&1
        or begin
            echoerr "\"$bin\""' is not installed! Please install the program'
            exit "$BINARY_NOT_FOUND_ERROR_CODE"
        end
    end
end

function read_until
    argparse 'd/default-position=' 'p/prompt=' \
        'P/prompt-on-invalid-input=' 'v/variable=' -- $argv

    set --local variable_name "$_flag_v"
    set --local prompt "$_flag_p"
    set --local prompt_on_invalid_input
    if set --query _flag_P
        set prompt_on_invalid_input "$_flag_P"
    else
        # Default prompt on invalid input
        set prompt_on_invalid_input "Please enter one of "
    end
    set --local default_position "$_flag_d"
    set --local option_str '('
    set --local position 0
    set --local lowercase_argv
    for option in $argv
        set lowercase_argv $lowercase_argv (string lower "$option")
        set position (math "$position" + 1)
        if test "$option_str" = "$default_position"
            set prompt "$option_str"(string upper "$option")'|'
        else
            set prompt "$option_str"(string lower "$option")'|'
        end
    end
    set option_str (string --regex '\\|$' ')' "$option_str")

    read --prompt-str="$prompt""$option_str" --global -- "$variable_name"
    test -z "$$variable_name"
    and set "$variable_name" "$argv["$_flag_d"]"
    set "$variable_name" (string lower "$$variable_name")

    while not contains -- "$$variable_name" $lowercase_argv
        read --prompt-str="$prompt_on_invalid_input""$option_str" \
            -- "$variable_name"
        test -z "$$variable_name"
        and set "$variable_name" "$argv["$_flag_d"]"
        set "$variable_name" (string lower "$$variable_name")
    end
end