#!/usr/bin/env bash

# run `sudo efibootmgr` to get the `0001` ID for windows.

pkexec /usr/bin/efibootmgr --bootnext 0001 && /usr/bin/reboot
