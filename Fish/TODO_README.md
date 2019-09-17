fish
curl
Visual Studio Code
vim
ssh
fortune
TODO pipupgrade -> greeting
cleanup -> greeting
# Fish

- Unix: `./.vim` <-> `~/.vim`
- Windows: `./vimfiles` <-> `$HOME/vimfiles`

## Description

A file that contains initialization commands is called a "vimrc" file.
Each line in a vimrc file is executed as an Ex command line. It is
sometimes also referred to as "exrc" file. They are the same type of
file, but "exrc" is what Vi always used, "vimrc" is a Vim specific
name. Also see |vimrc-intro|.

        Places for your personal initializations:
                Unix            $HOME/.vimrc or $HOME/.vim/vimrc
                OS/2            $HOME/.vimrc, $HOME/vimfiles/vimrc
                                or $VIM/.vimrc (or _vimrc)
                MS-Windows      $HOME/_vimrc, $HOME/vimfiles/vimrc
                                or $VIM/_vimrc
                Amiga           s:.vimrc, home:.vimrc, home:vimfiles:vimrc
                                or $VIM/.vimrc

        The files are searched in the order specified above and only the first
        one that is found is read.

        RECOMMENDATION: Put all your Vim configuration stuff in the
        $HOME/.vim/ directory ($HOME/vimfiles/ for MS-Windows). That makes it
        easy to copy it to another system.
