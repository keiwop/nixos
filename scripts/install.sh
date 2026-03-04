#! /bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>


USER_NAME=keiwop
HOST_NAME=nix-test

NIXOS_PATH=/_/etc/nixos
NIX_DIR=$NIXOS_PATH/nix
DOT_DIR=$NIXOS_PATH/dotfiles

GIT_DOWNLOAD="https://github.com/keiwop/nixos.git"
SSH_DOWNLOAD="nibbler:/_/etc/nixos"

FLAG_DOWNLOAD=false
FLAG_BKP=false
FLAG_SECRETS=false


show_help(){
    cat << EOF
install.sh - Install custom NixOS configuration

USAGE:
    ./install.sh [options]

    This script will download a custom NixOS configuration and install it
    Get more information at https://github.com/keiwop/nixos.git

OPTIONS:
    --download, -d  Downloads the NixOS configuration then exits
    --help, -h      Show this help
    --secrets, -s   Generate secrets (passwords, ssh keys, etc...) then exits

EOF
}


download_configuration(){
    if [ ! -e $NIXOS_PATH ]; then
        mkdir -p $NIXOS_PATH
        echo "Fetching NixOS configuration from git repository"
        nix-shell -p git --run "git clone $GIT_DOWNLOAD $NIXOS_PATH"
        if [ "$FLAG_DOWNLOAD" = true ]; then 
            exit 0
        fi
    elif [ -d $NIXOS_PATH ]; then
        if [ -z "$(ls -A $NIXOS_PATH)" ]; then
            # If directory exists and is empty, download from machine over ssh
            echo "Downloading NixOS configuration over ssh"
            scp -r $SSH_DOWNLOAD $NIXOS_PATH
            if [ "$FLAG_DOWNLOAD" = true ]; then 
                exit 0
            fi
        else
            echo "System already has a NixOS configuration. Skipping download"
        fi
    fi
}


generate_secrets(){
    echo "Generating passwords"

    local SECRETS="$NIX_DIR/machines/$HOST_NAME/secrets.nix"
    if [ -f "$SECRETS" ]; then
        echo "$SECRETS already exists. Skipping password generation"
    else
        mkdir -p $NIX_DIR/machines/$HOST_NAME
        echo "{" > "$SECRETS"
        echo "Enter user password:"
        echo "  user_password = \"$(mkpasswd -m bcrypt)\";" >> "$SECRETS"
        echo "Enter root password:"
        echo "  root_password = \"$(mkpasswd -m bcrypt)\";" >> "$SECRETS"
        echo "Enter syncthing WebUI password:"
        echo "  syncthing_password = \"$(mkpasswd -m bcrypt)\";" >> "$SECRETS"
        echo "}" >> "$SECRETS"
    fi


    echo "Generating SSH keys"

    local SSH_PRV="$NIX_DIR/machines/$HOST_NAME/ssh/id_ed25519"
    local SSH_PUB="$NIX_DIR/machines/$HOST_NAME/ssh/id_ed25519.pub"
    if [ -f "$SSH_PRV" ] || [ -f "$SSH_PUB" ]; then
        echo "Key found in $(dirname $SSH_PRV). Skipping SSH keys generation"
    else
        mkdir -p $(dirname $SSH_PRV)
        ssh-keygen -t ed25519 -N "" -C "$USER_NAME@$HOST_NAME" -f $SSH_PRV
    fi


    echo "Generating Syncthing certificates"

    local SYNC="$NIX_DIR/machines/$HOST_NAME/syncthing"
    if [ -n "$(ls -A $SYNC/*.pem 2>/dev/null)" ]; then
        echo "Syncthing certificate found in $SYNC. Skipping certificate generation"
    else
        mkdir -p $SYNC
        nix-shell -p syncthing --run "syncthing generate --home $SYNC"
        rm $SYNC/.syncthing.tmp.* $SYNC/config.xml
    fi

    if [ "$FLAG_SECRETS" = true ]; then
        exit 0
    fi
}


generate_local_configuration(){
    echo "Generating $NIX_DIR/local_config.nix"

    cat >$NIX_DIR/local_config.nix <<EOF
{
  host_name = "$HOST_NAME";
}
EOF
    # TODO Option to copy config from another machine directory
    local CONFIG="$NIX_DIR/machines/$HOST_NAME"
    local EXAMPLE="$NIX_DIR/machines/example"
    if [ ! -f $CONFIG/$HOST_NAME.nix ]; then
        echo "Copying example machine configuration"
        cp -v $EXAMPLE/example.nix $CONFIG/$HOST_NAME.nix
    fi

    if [ ! -f $CONFIG/syncthing/syncthing.nix ]; then
        echo "Copying example syncthing configuration"
        cp -v $EXAMPLE/syncthing/syncthing.nix $CONFIG/syncthing/syncthing.nix
    fi

}


link_nix_configuration(){
    if [ -f /etc/nixos/configuration.nix ]; then
        echo "Backing-up original NixOS configuration"
        sudo mv -v /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bkp
        FLAG_BKP=true
    fi

    echo -n "Linking NixOS configuration"
    nix-shell -p stow --run "sudo stow --restow --no-folding --dir=\"$NIX_DIR\" --target=/etc/nixos/ ."

    if [ $? -ne 0 ]; then
        echo " ❌ Configuration linking failed"
        if [ "$FLAG_BKP" = true ]; then
            echo "Restoring original NixOS configuration"
            sudo cp /etc/nixos/configuration.nix.bkp /etc/nixos/configuration.nix
        fi
        exit 1
    fi
}


link_dotfiles(){
    if [ -d $DOT_DIR ] && [ -n "$(ls -A $DOT_DIR)" ]; then
        echo "Linking dotfiles"
        nix-shell -p stow --run "sudo -u \"$USER_NAME\" stow --restow --no-folding --dotfiles --dir=\"$DOT_DIR\" --target=/home/\"$USER_NAME\"/ ."
    else
        echo "No dotfiles found. Skipping linking"
    fi
}



# Handle args
case "$1" in
    --download|-d)
        FLAG_DOWNLOAD=true
        ;;
    --help|-h)
        show_help
        exit 0
        ;;
    --secrets|-s)
        FLAG_SECRETS=true
        ;;
esac


download_configuration
generate_secrets
generate_local_configuration
link_nix_configuration
link_dotfiles


echo "Installation done!"
echo "Don't forget to modify $HOST_NAME.nix from $NIX_DIR/machines/"
echo "If you're using syncthing, add the IDs to $HOST_NAME/secrets.nix and configure $HOST_NAME/syncthing/syncthing.nix"
echo "Then run sudo nixos-rebuild switch"
