#!/usr/bin/env bash

# only one that works
# echo key ctrl+c | dotool

# Get text from clipboard using wl-paste
clipboard_text=$(wl-paste)

# Encode the text for a URL
encoded_text=$(echo "$clipboard_text" | sed 's/ /+/g')

# Open Google search in default web browser
xdg-open "https://www.youtube.com/results?search_query=$encoded_text"

hyprctl dispatch workspace 1
