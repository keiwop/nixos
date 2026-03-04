# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2026 - keiwop <keiwop.dev@gmail.com>

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    gcc
    gdb
    gnumake
    pkg-config
    go

    gtk4
    glib
    gobject-introspection
    cairo
    pango
    gdk-pixbuf
    graphene
    vte-gtk4
  ];


  shellHook = ''
    echo ""
    chafa --symbols block --grid 2x1 --size 96x16 --align vcenter /_/etc/nixos/nix/dev_shells/img/go_logo.png /_/etc/nixos/nix/dev_shells/img/gtk_logo.png
    echo "Dev shell for `pwd`"
    echo "   • Language: Go GTK4"
    echo "   • Version: $(go version)"
    echo "   • Usage: go build"
    echo ""
  '';
}
