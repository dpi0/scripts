#!/usr/bin/env bash

rofi -show calc -modi calc -no-show-match -no-sort -calc-command "printf '%s' '{result}' | wl-copy" 2>/dev/null
