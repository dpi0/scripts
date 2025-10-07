#!/usr/bin/env bash

waylock -ignore-empty-password -init-color "0x000000" -input-color "0x281D4E" -input-alt-color "0x252535" -fail-color "0xE82424"

# -h                         Print this help message and exit.
# -version                   Print the version number and exit.
# -log-level <level>         Set the log level to error, warning, info, or debug.
#
# -fork-on-lock              Fork to the background after locking.
# -ready-fd <fd>             Write a newline to fd after locking.
# -ignore-empty-password     Do not validate an empty password.
#
# -init-color 0xRRGGBB       Set the initial color.
# -input-color 0xRRGGBB      Set the color used after input.
# -input-alt-color 0xRRGGBB  Set the alternate color used after input.
# -fail-color 0xRRGGBB       Set the color used on authentication failure.
