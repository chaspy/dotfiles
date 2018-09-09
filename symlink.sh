#!/bin/sh
DOT_DIRECTORY=$GOPATH/src/github.com/chaspy/dotfiles

for f in .??*
do
    [ "$f" = ".git" ] && continue
    ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
done

# for system gitignore
mkdir -p $HOME/.config/git/
ln -snfv ${DOT_DIRECTORY}/ignore $HOME/.config/git/ignore
