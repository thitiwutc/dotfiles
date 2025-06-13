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
    "helix"
    ".tmux.conf"
    ".gitconfig"
    ".gitignore_global"
    ".aliases"
    ".zshrc"
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
failed=()
skipped=()

for file in "${dotfiles[@]}"
do
    installed_path="$HOME/$file"

    if [[ ! -e "$file" ]]; then
        echo "File \"$file\" not exist"
        exit 1
    fi

    if [[ "$file" == "helix" ]]; then
        installed_path="$HOME/.config/helix"

        if [[ -e "$installed_path" && "$REPLACE" = true ]]; then
            rm -rf "$installed_path"
            ln -s "$(realpath "$file")" "$installed_path"
            installed+=("$file")
        elif [[ ! -e  "$installed_path" ]]; then
            ln -s "$(realpath "$file")" "$installed_path"
            installed+=("$file")
        else
            skipped+=("$file")
        fi

        continue
    fi

    if [[ "$file" == ".gitconfig" ]]; then
        default_email="$(grep 'email' .gitconfig | sed -E 's/\s*email\s*=\s*//')"
        echo -n ".gitconfig user.email: ($default_email) "
        read -r email

        if [[ -z $email ]]; then
            email=$default_email
        fi

        sed -E "s/email\s*=.*/email = $email/" .gitconfig > .gitconfig.tmp
        diff "$installed_path" .gitconfig.tmp > /dev/null

        # Only copy file when file does not exist or file content is different.
        if [[ ! -e "$installed_path" || $? -gt 0 ]]; then
            mv .gitconfig.tmp "$installed_path"
            installed+=("$file")
        else
            rm .gitconfig.tmp
            skipped+=("$file")
        fi

        continue
    fi

    if [[ -e "$installed_path" && "$REPLACE" = true ]]; then
        # Skip when file content is indifferent.
        if diff -rq "$file" "$installed_path" > /dev/null; then
            skipped+=("$file")
            continue
        fi

        rm "$installed_path"
        ln -s "$(realpath "$file")" "$installed_path"
        installed+=("$file")
    elif [[ ! -e  "$installed_path" ]]; then
        if ln -s "$(realpath "$file")" "$installed_path"; then
            installed+=("$file")
        else
            failed+=("$file")
        fi
    else
        skipped+=("$file")
    fi
done

if [[ ${#installed[@]} -gt 0 ]]; then
    echo -e "Installed: \033[0;32m${installed[*]}\033[0m"
fi

if [[ ${#failed[@]} -gt 0 ]]; then
    echo -e "Failed: \033[0;31m${failed[*]}\033[0m"
fi

if [[ ${#skipped[@]} -gt 0 ]]; then
    echo -e "Skipped: \033[0;33m${skipped[*]}\033[0m"
fi
