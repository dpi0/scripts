#!/usr/bin/env bash

msgID="9333"
time_info=$(date +"%H:%M:%S %a %d %b")
color=#24ABFFFF

dunstify "  $time_info" -t 2500 -r "$msgID" -h string:fgcolor:"$color" -h string:frcolor:"$color"
