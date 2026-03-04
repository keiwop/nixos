# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

{ pkgs ? import <nixpkgs> {} }:

let
  customCrossSystem = {
    config = "riscv32-none-elf";
    libc = "newlib-nano";
    gcc = {
      arch = "rv32ec";
      abi = "ilp32e";
    };
  };
  crossPkgs = import <nixpkgs> { crossSystem = customCrossSystem; };
in

pkgs.mkShell {
  nativeBuildInputs = [
    crossPkgs.buildPackages.gcc
    crossPkgs.buildPackages.binutils
    pkgs.gnumake
  ];


  shellHook = ''
    echo ""
    chafa --symbols block --grid 2x1 --size 96x16 --align vcenter /_/etc/nixos/nix/dev_shells/img/c_logo.png /_/etc/nixos/nix/dev_shells/img/riscv_logo.png
    echo "Dev shell for `pwd`"
    echo "   • Language: C RISCV"
    echo "   • Version: $(riscv32-none-elf-gcc --version | head -n 1)"
    echo "   • Usage: riscv32-none-elf-gcc -march=rv32ec -mabi=ilp32e main.c"
    echo ""
  '';
}
