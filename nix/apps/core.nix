# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

{ pkgs ? import <nixpkgs> {} }:

with pkgs; [
  # Core packages
  zsh-completions
  syncthing
  stow
  vim
  wget
  git
  tree
  screen
  tmux
  picocom
  nmap
  inetutils # traceroute + telnet
  dnsutils # dig
  hexedit
  fzf
  tldr
  cryfs
  killall
  usbutils # lsusb
  pciutils # lspci
  ripgrep
  ripgrep-all
  helix
  chafa

  # System monitoring
  pv
  iotop
  iftop
  iproute2  # ifstat
  htop
  btop
  lm_sensors
  dysk
  wavemon
  ntfy-sh
  nix-output-monitor
  powertop
]
