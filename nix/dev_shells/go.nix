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
  ];


  shellHook = ''
    echo ""
    chafa --symbols block --grid 1x1 --size 48x16 /_/etc/nixos/nix/dev_shells/img/go_logo.png
    echo "Dev shell for `pwd`"
    echo "   • Language: Go"
    echo "   • Version: $(go version)"
    echo "   • Usage: go build"
    echo ""
  '';
}
