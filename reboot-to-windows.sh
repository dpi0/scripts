#!/usr/bin/env bash

# run `sudo efibootmgr` to get the `0002` ID for windows.

pkexec /usr/bin/efibootmgr --bootnext 0002 && /usr/bin/reboot
