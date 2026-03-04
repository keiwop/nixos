# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

#! /bin/sh

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    if command -v wl-paste > /dev/null 2>&1; then
        wl-paste --primary 2> /dev/null || printf ""
    fi
elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
    if command -v xclip > /dev/null 2>&1; then
        xclip -selection primary -o 2> /dev/null || printf ""
    elif command -v xsel > /dev/null 2>&1; then
        xsel --primary --output 2> /dev/null || printf ""
    fi
fi
