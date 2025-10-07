#!/usr/bin/env bash

cliphist -preview-width=200 list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy
