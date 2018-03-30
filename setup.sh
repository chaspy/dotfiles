#!/bin/bash

CURRENTDIR=$( dirname $( readlink -f $0 ) )

for file in .??*
do
  [[ "$file" == ".git" ]] && continue
  [[ "$file" == ".DS_Store" ]] && continue

  ln -fs $CURRENTDIR/$file $HOME/$file
done
