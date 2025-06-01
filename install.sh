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
    echo "Installing dotfiles: ${dotfiles[*]}"
else
    echo "Installing default dotfiles: ${dotfiles[*]}"
fi

installed=()
skipped=()

for file in "${dotfiles[@]}"
do
    installed_path="$HOME/$file"

    if [[ ! -e "$file" ]]; then
        echo "File \"$file\" not exist"
        exit 1
    fi

    if [[ "$file" == "nvim" ]]; then
        installed_path="$HOME/.config/nvim"
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


    if [[ -L "$installed_path" && "$REPLACE" = true ]]; then
	diff -rq "$file" "$installed_path" > /dev/null

	# Skip when file content is indifferent.
	if [[ $? -gt 0 ]]; then
		continue
	fi

        rm "$installed_path"
        ln -s "$(realpath "$file")" "$installed_path"
        installed+=("$file")
    elif [[ ! -L  "$installed_path" ]]; then
	echo "HERE $installed_path $file"
        ln -s "$(realpath "$file")" "$installed_path"
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

