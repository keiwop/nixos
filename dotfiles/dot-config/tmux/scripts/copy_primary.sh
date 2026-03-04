# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

#! /bin/sh

tmux_data="$(cat)"

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    if command -v wl-copy > /dev/null 2>&1; then
        printf '%s' "$tmux_data" | wl-copy --primary --trim-newline 2> /dev/null
    fi
elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
    if command -v xclip > /dev/null 2>&1; then
        printf '%s' "$tmux_data" | xclip -selection primary -i 2> /dev/null
    elif command -v xsel > /dev/null 2>&1; then
        printf '%s' "$tmux_data" | xsel --primary --input 2> /dev/null
    fi
fi
