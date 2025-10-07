#!/usr/bin/env bash

# YDOTOOL_SOCKET="$HOME/.ydotool_socket" ydotool key 29:1 46:1 46:0 29:0

# wtype -M ctrl c -m ctrl

# only one that works
# echo key ctrl+c | dotool

# Get text from clipboard using wl-paste
clipboard_text=$(/usr/bin/wl-paste)

# Encode the text for a URL
encoded_text=$(echo "$clipboard_text" | sed 's/ /+/g')

# Open Google search in default web browser
xdg-open "http://www.google.com/search?q=$encoded_text"

hyprctl dispatch workspace 1
