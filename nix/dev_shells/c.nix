# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    gcc
    gdb
    gnumake
    pkg-config
    udev
    libusb1
  ];


  shellHook = ''
    echo ""
    chafa --grid 1x1 --size 48x16 --symbols block /_/etc/nixos/nix/dev_shells/img/c_logo.png
    echo "Dev shell for `pwd`"
    echo "   • Language: C"
    echo "   • Version: $(gcc --version | head -n 1)"
    echo "   • Usage: gcc main.c"
    echo ""
  '';
}
