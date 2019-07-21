#!/bin/sh
DOT_DIRECTORY=$GOPATH/src/github.com/chaspy/dotfiles

for f in .??*
do
    [ "$f" = ".git" -o "$f" = ".toml" ] && continue
    ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
done

# for system gitignore
mkdir -p $HOME/.config/git/
ln -snfv ${DOT_DIRECTORY}/ignore $HOME/.config/git/ignore

# for vim plugin
ln -snfv ${DOT_DIRECTORY}/dein.toml ~/.vim/rc/dein.toml
ln -snfv ${DOT_DIRECTORY}/dein_lazy.toml ~/.vim/rc/dein_lazy.toml
