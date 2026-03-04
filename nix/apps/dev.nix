# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

{ pkgs ? import <nixpkgs> {} }:

with pkgs; [
  # Development packages (more in dev_shells)
  direnv
  nix-prefetch-git
  gnumake
  android-tools     # adb, fastboot
  flashrom
  vbindiff
  python3
  go
  openssl
  # iptables-legacy
]
