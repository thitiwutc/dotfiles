#!/usr/bin/env bash

dotfiles=(".vimrc" ".tmux.conf")

for file in "${dotfiles[@]}"
do
    rm "$HOME/$file"
done

