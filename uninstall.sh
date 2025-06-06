#!/usr/bin/env bash

# Default dotfiles
dotfiles=(
    "nvim"
    ".tmux.conf"
    ".gitconfig"
    ".gitconfig_global"
    ".aliases"
)

if [[ $# -gt 0 ]]; then
    dotfiles=()
    for file in "$@"
    do
        dotfiles+=("$file")
    done
    echo "Deleting dotfiles: ${dotfiles[*]}"
else
    echo "Deleting default dotfiles: ${dotfiles[*]}"
fi

deleted=()
failed=()

for file in "${dotfiles[@]}"
do
	installed_path="$HOME/$file"

	if [[ "$file" == "nvim" ]]; then
		installed_path="$HOME/.config/nvim"
	fi

    # Check if file deleted successfully.
    if rm "$installed_path" 2> /dev/null; then
        deleted+=("$file")
    else
        failed+=("$file")
    fi
done

if [[ ${#deleted[@]} -gt 0 ]]; then
    echo -e "Deleted: \033[0;32m${deleted[*]}\033[0m"
fi

if [[ ${#failed[@]} -gt 0 ]]; then
    echo -e "Not exist: \033[0;33m${failed[*]}\033[0m"
fi

