#! /bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - keiwop <keiwop.dev@gmail.com>


SHELLS_PATH="/_/etc/nixos/nix/dev_shells"
TARGET_NIX_FILE="shell.nix"


show_help(){
    cat << EOF
create_direnv - Setup direnv with nix development shells

USAGE:
    create_direnv <fuzzy> <shell>
    create_direnv <path/to/shell.nix>

    This script will find the specified nix shell file, then perform the following actions:
    - Create a ".envrc"
    - Copy the found nix shell to "./shell.nix"
    - Run 'direnv allow'

OPTIONS:
    --list, -l    Show available shell files
    --delete, -d  Delete the direnv of current directory
    --help, -h    Show this help

EXAMPLES:
    create_direnv python                # Use python*.nix, checks python.nix first
    create_direnv py                    # Use py*.nix
    create_direnv c riscv               # Use c*riscv*.nix, checks c[-_]riscv.nix first
    create_direnv /path/to/shell.nix    # Use specific file

EOF
}


# Handle args
case "$1" in
    --list|-l)
        echo "Available shells in $SHELLS_PATH:"
        find "$SHELLS_PATH" -type f -name "*.nix" | sed "s:$SHELLS_PATH/::" | sort
        exit 0
        ;;
    --help|-h)
        show_help
        exit 0
        ;;
    --delete|-d)
        echo "Deleting direnv from `pwd`"
        direnv deny
        rm -fr .direnv .envrc shell.nix
        exit 0
        ;;
    "")
        echo "Error: No shell name/path specified" >&2
        show_help
        exit 1
        ;;
esac


echo "Searching for a nix shell"
nix_file=""

if [ -f "$1" ]; then
    # Found direct name match
    nix_file="$1"
else
    search_args="$@"

    # Looking for close to direct match (only - or _ between words)
    nix_file_hyphen="$SHELLS_PATH/$(echo "$search_args" | tr ' ' '-').nix"
    nix_file_underscore="$SHELLS_PATH/$(echo "$search_args" | tr ' ' '_').nix"

    if [ -f "$nix_file_hyphen" ]; then
        nix_file="$nix_file_hyphen"
    elif [ -f "$nix_file_underscore" ]; then
        nix_file="$nix_file_underscore"
    else
        # Switching to fuzzy search
        glob_pattern="$(echo "$search_args" | tr ' ' '*')*.nix"

        found_files=$(find "$SHELLS_PATH" -type f -name "$glob_pattern" 2>/dev/null)

        if [ -n "$found_files" ]; then
            nix_file=$(echo "$found_files" | head -n 1)
        fi
    fi
fi


if [ -z "$nix_file" ] || ! [ -f "$nix_file" ]; then
    echo "❌ Error: No nix shell found for '$@'" >&2
    exit 1
fi


echo -e "\nFound shell: $nix_file"

echo "   • Creating .envrc file"
echo "use nix" > .envrc

echo "   • Copying $nix_file to ./$TARGET_NIX_FILE"
cp "$nix_file" "./$TARGET_NIX_FILE"

echo '   • Running "direnv allow"'
direnv allow

echo -e "\nDevelopment shell successfully created!"
echo -e "\n--------------------------------------------------------------------------------\n"
