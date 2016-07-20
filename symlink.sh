#!/bin/sh
DOT_DIRECTORY=/Users/take/github/dotfiles

for f in .??*
do
    [ "$f" = ".git" ] && continue
    ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
done
