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
dotfiles=(
    ".vimrc"
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
    echo "Installing dotfiles: ${dotfiles[*]}"
else
    echo "Installing default dotfiles: ${dotfiles[*]}"
fi

installed=()
skipped=()

for file in "${dotfiles[@]}"
do
    homefile="$HOME/$file" 

    if [[ ! -e "$file" ]]; then
        echo "File \"$file\" not exist"
        exit 1
    fi

    if [[ "$file" == ".gitconfig" ]]; then
        default_email="$(grep 'email' .gitconfig | sed -E 's/\s*email\s*=\s*//')"
        echo -n ".gitconfig user.email: ($default_email) "
        read -r email

        if [[ -z $email ]]; then
            email=$default_email
        fi

        sed -E "s/email\s*=.*/email = $email/" .gitconfig > .gitconfig.tmp
        diff "$homefile" .gitconfig.tmp > /dev/null

        # Only copy file when file does not exist or file content is different.
        if [[ ! -e "$homefile" || $? -gt 0 ]]; then
            mv .gitconfig.tmp "$homefile"
            installed+=("$file")
        else
            rm .gitconfig.tmp
            skipped+=("$file")
        fi

        continue
    fi

    if [[ "$file" == ".gitconfig_global" ]]; then
        diff "$homefile" .gitconfig_global > /dev/null

        if [[ ! -e "$homefile" || $? -gt 0 ]]; then
            cp .gitconfig_global "$homefile"
            installed+=("$file")
        else
            skipped+=("$file")
        fi

        continue
    fi

    if [[ -L "$homefile" && "$REPLACE" = true ]]; then
        rm "$homefile"
        ln -s "$(realpath "$file")" "$homefile"
        installed+=("$file")
    elif [[ ! -L  "$homefile" ]]; then
        ln -s "$(realpath "$file")" "$homefile"
        installed+=("$file")
    else
        skipped+=("$file")
    fi
done

if [[ ${#installed[@]} -gt 0 ]]; then
    echo -e "Installed: \033[0;32m${installed[*]}\033[0m"
fi

if [[ ${#skipped[@]} -gt 0 ]]; then
    echo -e "Skipped: \033[0;33m${skipped[*]}\033[0m"
fi

