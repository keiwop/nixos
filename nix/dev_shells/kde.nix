# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

{ pkgs ? import <nixpkgs> {} }:


pkgs.mkShell {
  packages = with pkgs; [
    kdePackages.kconfig
    dbus
  ];

  shellHook = ''
    # Storing following scripts in a unique tmp dir
    ENV_SCRIPTS_DIR="/tmp/kde-dev-scripts-$$"
    mkdir -p "$ENV_SCRIPTS_DIR"

    cat > "$ENV_SCRIPTS_DIR/kde_clean_shortcuts" <<- EOF
      #! /bin/sh
      qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.cleanUp
    EOF

    cat > "$ENV_SCRIPTS_DIR/kde_read_shortcut" <<- 'EOF'
      #! /bin/sh
      if [[ -n $1 ]]; then
          kreadconfig6 --file kglobalshortcutsrc --group kwin  --key $1
      else
          echo 'Usage: kde_read_shortcut shortcut_name'
      fi
    EOF

    cat > "$ENV_SCRIPTS_DIR/kde_log_scripts" <<- EOF
      #! /bin/sh
      journalctl -f QT_CATEGORY=js QT_CATEGORY=kwin_scripting
    EOF

    cat > "$ENV_SCRIPTS_DIR/kde_list_scripts" <<- EOF
      #! /bin/sh
      kpackagetool6 --type=KWin/Script --list
    EOF

    cat > "$ENV_SCRIPTS_DIR/kde_install_script" <<- EOF
      #! /bin/sh
      kpackagetool6 --type=KWin/Script -i $(pwd)
    EOF

    cat > "$ENV_SCRIPTS_DIR/kde_enable_script" <<- EOF
      #! /bin/sh
      kwriteconfig6 --file kwinrc --group Plugins --key $(basename $(pwd))Enabled true
      qdbus org.kde.KWin /KWin reconfigure
    EOF

    cat > "$ENV_SCRIPTS_DIR/kde_disable_script" <<- EOF
      #! /bin/sh
      kwriteconfig6 --file kwinrc --group Plugins --key $(basename $(pwd))Enabled false
      qdbus org.kde.KWin /KWin reconfigure
    EOF

    cat > "$ENV_SCRIPTS_DIR/kde_reload_script" <<- EOF
      #! /bin/sh
      kde_disable_script
      sleep 0.5
      kde_clean_shortcuts
      sleep 0.5
      kde_enable_script
    EOF

    # Make all scripts executable
    chmod +x "$ENV_SCRIPTS_DIR"/*

    # Add the scripts directory to PATH
    export PATH="$ENV_SCRIPTS_DIR:$PATH"

    echo ""
    chafa --symbols block --grid 1x1 --size 48x16 /_/etc/nixos/nix/dev_shells/img/kde_logo.png
    echo "Dev shell for $(pwd)"
    echo "   • Environment: KDE/Plasma"
    echo "   • Commands: kde_clean_shortcuts, kde_read_shortcut, kde_log_scripts, kde_list_scripts, kde_install_script, kde_enable_script, kde_disable_script, kde_reload_script"
    echo "   • Scripts created in: $ENV_SCRIPTS_DIR"
    echo "   • Target script: $(basename $(pwd))"
    echo ""
  '';
} 