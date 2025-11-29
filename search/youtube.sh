#!/usr/bin/env bash

clipboard_text=$(/usr/bin/wl-paste)
xdg-open "https://www.youtube.com/results?search_query=$clipboard_text"
hyprctl dispatch workspace 1
