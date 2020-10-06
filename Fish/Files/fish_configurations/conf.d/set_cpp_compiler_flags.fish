#!/usr/bin/env fish

# Set error codes
set --local CLANGPP_IS_NOT_INSTALLED_ERROR_CODE 1
set --local GPP_IS_NOT_INSTALLED_ERROR_CODE 2

#### Set compiler flags for C++
# Prerequisites: clang++/g++ is installed
if is_platform 'macos'
    ### Make sure that "clang++" is installed
    command -v clang++ > '/dev/null' 2>&1
    or begin
        echoerr '"clang++" is not installed! Please install the program'
        exit "$CLANGPP_IS_NOT_INSTALLED_ERROR_CODE"
    end
    ###
    alias c++17=(string join -- ' ' \
        'clang++' \
        '-std=c++17' \
        \
        '-Wall' \
        '-Wextra' \
        '-Wconversion' \
        '-Wsign-conversion' \
        '-pedantic-errors' \
        \
        '-Weverything' \
        '-Wno-c++98-compat' \
        '-Wno-c++98-compat-pedantic' \
        '-Wno-covered-switch-default' \
        '-Wno-unreachable-code-break' \
        '-Wno-weak-vtables' \
        '-Wno-global-constructors' \
        '-Wno-exit-time-destructors' \
        \
        '-DDEBUG_' \
        '-g' \
        '-fPIE' \
        '-Wl,-pie' \
        \
        '-fsanitize=address' \
        \
        '-fsanitize=undefined' \
        '-fsanitize=float-divide-by-zero' \
        '-fsanitize=unsigned-integer-overflow' \
        '-fsanitize=implicit-conversion' \
        '-fsanitize=nullability' \
        \
        '-fno-omit-frame-pointer' \
        '-fno-optimize-sibling-calls' \
        \
    )
else
    ### Make sure that "g++" is installed
    command -v g++ > '/dev/null' 2>&1
    or begin
        echoerr '"g++" is not installed! Please install the program'
        exit "$GPP_IS_NOT_INSTALLED_ERROR_CODE"
    end
    ###
    alias c++17=(string join -- ' ' \
        'g++' \
        '-std=c++17' \
        '-Wall' \
        '-Wextra' \
        '-pedantic-errors' \
        '-Wconversion' \
        '-Wsign-conversion' \
        # '-Werror' \
    )
end
####