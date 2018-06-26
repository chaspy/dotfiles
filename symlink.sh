#!/bin/sh
DOT_DIRECTORY=~/github.com/chaspy/dotfiles

for f in .??*
do
    [ "$f" = ".git" ] && continue
    ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
done
