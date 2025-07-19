#!/bin/sh
export GOPATH=/Users/chaspy/go
DOT_DIRECTORY=/Users/chaspy/go/src/github.com/chaspy/dotfiles

for f in .??*; do
	[ "$f" = ".git" ] || [ "$f" = ".toml" ] && continue
	ln -snfv "${DOT_DIRECTORY}/${f}" "${HOME}/${f}"
done

# for system gitignore
mkdir -p "${HOME}"/.config/git/
ln -snfv "${DOT_DIRECTORY}"/ignore "${HOME}"/.config/git/ignore

# for vim plugin
mkdir -p ~/.vim/rc
ln -snfv "${DOT_DIRECTORY}"/dein.toml ~/.vim/rc/dein.toml
ln -snfv "${DOT_DIRECTORY}"/dein_lazy.toml ~/.vim/rc/dein_lazy.toml

# for aqua
ln -snfv "${DOT_DIRECTORY}"/aqua.yaml ~/.config/aquaproj-aqua/aqua.yaml

# cvs code
ln -snfv "${DOT_DIRECTORY}"/settings.json ~/Library/Application\ Support/Code/User/settings.json

# for claude
mkdir -p ~/.claude
ln -snfv "${DOT_DIRECTORY}"/.claude/settings.json ~/.claude/settings.json
ln -snfv "${DOT_DIRECTORY}"/.claude/commands ~/.claude/commands

