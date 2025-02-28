#!/usr/bin/env bash

msgID="9333"
time_info=$(date +"%a %d %b %H:%M:%S")
color=#24ABFFFF


dunstify "  $time_info" -t 2500 -r "$msgID" -h string:fgcolor:"$color" -h string:frcolor:"$color"

# msgID="9333"
# time_info=$(date +"%a %d %b %H:%M:%S ")
#
# dunstify "  $time_info" -t 2500 -r "$msgID"
