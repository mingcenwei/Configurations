#!/usr/bin/env fish

set DIR (dirname (status --current-filename))

if test ! -e {$HOME}'/.say_backups'
    cd ~
    mkdir '.say_backups'
    chmod 700 '.say_backups'
end

if test -e {$HOME}'/.vim'
    cd ~
    mv '.vim' '.say_backups'
end

cd ~
ln -s {$DIR}/'.vim' '.vim'