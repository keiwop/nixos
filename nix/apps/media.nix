# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

{ pkgs ? import <nixpkgs> {} }:

with pkgs; [
  # Multimedia packages
  # jellyfin-media-player # Removed due to webkit vulnerabilities unpatched
  jellyfin-mpv-shim
  discord
  element-desktop
  vlc
  mkvtoolnix
  subtitleedit
]
