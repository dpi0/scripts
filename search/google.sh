#!/usr/bin/env bash

clipboard_text=$(/usr/bin/wl-paste)
xdg-open "https://www.google.com/search?udm=14&q=$clipboard_text&num=50"
hyprctl dispatch workspace 1
