# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    python3
    gtk3
    gobject-introspection
    vte
    keybinder3
    libwnck
    libnotify

    (python3.withPackages (ps: with ps; [
      pygobject3
      libsass
    ]))
  ];


  shellHook = ''
    echo ""
    chafa --symbols block --grid 2x1 --size 96x16 --align vcenter /_/etc/nixos/nix/dev_shells/img/python_logo.png /_/etc/nixos/nix/dev_shells/img/gtk_logo.png
    echo "Dev shell for `pwd`"
    echo "   • Language: Python GTK3"
    echo "   • Version: $(python3 --version)"
    echo "   • Usage: python3 -m termm.termm"
    echo ""
  '';
}
