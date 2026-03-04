# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

{ pkgs ? import <nixpkgs> {} }:

with pkgs; [
  # GUI packages
  kdePackages.kate
  kdePackages.filelight
  vscodium
  gedit
  gparted
  evince
  cheese
  pulseview
  gnome-calculator
  kicad-small
  gimp3
  inkscape
  gnome-disk-utility

  # Utilities
  xsel
  wl-clipboard

  # KDE
  kdePackages.kconfig
  kdotool
  kdePackages.kde-gtk-config
  kdePackages.kaccounts-integration
  kdePackages.kaccounts-providers
  kdePackages.signond

  # Hyprland
  wofi
  waybar
  hyprpaper
  networkmanagerapplet

  # Themes
  (lib.hiPrio papirus-icon-theme)  # Icons
  papirus-folders     # Icons

  qogir-kde           # Plasma theme
  qogir-theme         # GTK theme

  bibata-cursors
]
