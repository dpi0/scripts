#!/bin/bash

current_mode=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ $current_mode == "'prefer-dark'" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi
