#!/usr/bin/env bash

clipboard_text=$(/usr/bin/wl-paste)
xdg-open "http://www.google.com/search?q=$clipboard_text"
hyprctl dispatch workspace 1
