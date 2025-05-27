#!/usr/bin/env bash

REPLACE=false

# Option
# -r Replace file if exists.
while getopts "r" opt; do
    case "$opt" in
        r) REPLACE=true ;;
        *) 
            echo "Invalid flag" >&2
            exit 1
            ;;
    esac
done

# Shift processed options from the positional parameters
shift $((OPTIND - 1))

# Default dotfiles
dotfiles=(".vimrc" ".tmux.conf")

if [[ $# -gt 0 ]]; then
    dotfiles=()
    for file in "$@"
    do
        dotfiles+=("$file")
    done
    echo "Installing dotfiles: ${dotfiles[*]}"
else
    echo "Installing default dotfiles: ${dotfiles[*]}"
fi

installed=()
skipped=()

for file in "${dotfiles[@]}"
do
    homefile="$HOME/$file" 
    if [[ -e "$file" ]]; then
        if [[ -L "$homefile" && "$REPLACE" = true ]]; then
            rm "$homefile"
	    ln -s "$(realpath $file)" "$homefile"
            installed+=("$file")
        elif [[ ! -L  $homefile ]]; then
	    ln -s "$(realpath $file)" "$homefile"
            installed+=("$file")
        else
            skipped+=("$file")
        fi
    else
        echo "File \"$file\" not exist"
        exit 1
    fi
done

if [[ ${#installed[@]} -gt 0 ]]; then
    echo -e "Installed: \033[0;32m${installed[*]}\033[0m"
fi

if [[ ${#skipped[@]} -gt 0 ]]; then
    echo -e "Skipped (already exist): \033[0;33m${skipped[*]}\033[0m"
fi

