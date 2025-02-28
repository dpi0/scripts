#!/usr/bin/env bash

msgID="2345"
notification_timeout=800
show_music_in_volume_indicator="true"
show_album_art="true"
download_album_art="true"
color=#13dd0c

# Function to get volume using pamixer
function get_volume {
    pamixer --get-volume
}

# Function to get mute status using pamixer
function get_mute {
    if pamixer --get-mute; then
        echo "yes"
    else
        echo "no"
    fi
}

# Function to get volume icon based on volume and mute status
function get_volume_icon {
    volume=$(get_volume)
    mute=$(get_mute)
    if [ "$volume" -eq 0 ] || [ "$mute" == "yes" ] ; then
        volume_icon="󰖁"
    elif [ "$volume" -lt 50 ]; then
        volume_icon=""
    else
        volume_icon=""
    fi
}

# Function to get album art
function get_album_art {
    url=$(playerctl -f "{{mpris:artUrl}}" metadata)
    if [[ $url == "file://"* ]]; then
        album_art="${url/file:\/\//}"
    elif [[ $url == "http://"* ]] && [[ $download_album_art == "true" ]]; then
        filename="$(echo $url | sed "s/.*\///")"
        if [ ! -f "/tmp/$filename" ]; then
            wget -O "/tmp/$filename" "$url"
        fi
        album_art="/tmp/$filename"
    elif [[ $url == "https://"* ]] && [[ $download_album_art == "true" ]]; then
        filename="$(echo $url | sed "s/.*\///")"
        if [ ! -f "/tmp/$filename" ]; then
            wget -O "/tmp/$filename" "$url"
        fi
        album_art="/tmp/$filename"
    else
        album_art=""
    fi
}

# Function to show volume notification
function show_volume_notif {
    volume=$(get_volume)
    mute=$(get_mute)
    get_volume_icon

    if [[ $show_music_in_volume_indicator == "true" ]]; then
        current_song=$(playerctl -f "{{title}} - {{artist}}" metadata)

        if [[ $show_album_art == "true" ]]; then
            get_album_art
        fi

        notify-send -t $notification_timeout -h string:x-dunst-stack-tag:volume_notif -h int:value:$volume -h string:frcolor:"$color" -h string:fgcolor:"$color" -h string:hlcolor:"$color" -i "$album_art" "$volume_icon Volume: $volume%" "$current_song"
    else
        notify-send -t $notification_timeout -h string:x-dunst-stack-tag:volume_notif -h int:value:$volume -h string:frcolor:"$color" -h string:hlcolor:"$color" -h string:fgcolor:"$color" "$volume_icon Volume: $volume%"
    fi
}

# Main script logic
volume=$(get_volume)
muted=$(get_mute)

# Check if audio is muted and show notification
if [ "$muted" == "yes" ]; then
    dunstify -t $notification_timeout -r "$msgID" -h string:fgcolor:"$color" -h string:frcolor:"$color" -h string:hlcolor:"$color" "󰖁 Muted"
else
    show_volume_notif
fi

canberra-gtk-play -i audio-volume-change -d "changeVolume"
