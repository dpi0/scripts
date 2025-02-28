#!/usr/bin/env bash

urls=(
        "https://youtu.be/Xgu7wttFOSQ"
        "https://youtu.be/UpsPZ0nHkQI"
        "https://youtu.be/R_jI2DR5mpI"
        "https://youtu.be/8JP5v6q-6yc"
        "https://youtu.be/7UQBfmP10eM"
        "https://youtu.be/uy0G1vDn_ls"
        "https://youtu.be/kqh9SmmhOZQ"
        "https://youtu.be/q5iCwB8Bmvo"
        "https://youtu.be/U7-jQSzXr6k"
        "https://youtu.be/5-EDchieZZc"
        "https://youtu.be/-_jkXJtNS_g"
        "https://youtu.be/xMzLyT8XDhY"
        "https://youtu.be/-En9U3hnW_s"
        "https://youtu.be/X-Xf0RGhlyE"
        "https://youtu.be/jZAAHLvDx24"
        "https://youtu.be/jZAAHLvDx24"
        "https://youtu.be/6qzWiFPNybU"
        "https://youtu.be/YdUZko10qs4"
        "https://youtu.be/1PshxrZagCc"
        "https://youtu.be/sxvZe9y-_-k"
        "https://youtu.be/KVl5kMXz1vA"
        "https://youtu.be/V-j1uKrN-aU"
        "https://youtu.be/Lj-Bxx-T0GM"
        "https://youtu.be/x-X2AkE3qmA"
        "https://youtu.be/onY62jGRsLY"
        "https://youtu.be/MYNyZnBBfIM"
        "https://youtu.be/g2Yi0YXOFk4"
        "https://youtu.be/0zUNXKvncgY"
        "https://youtu.be/ohgfesvNRkg"
)

if ! command -v yt-dlp &> /dev/null
then
    echo "yt-dlp could not be found. Please install it first."
    exit 1
fi

counter=1

# Output file
output_file="yt-video-title"
# Clear the output file if it exists
> "$output_file"

for url in "${urls[@]}"; do
    title=$(yt-dlp --simulate --print "%(title)s" "$url")
    echo "## $title" >> "$output_file"
    echo "**<$url>**" >> "$output_file"
    echo "$counter  $title - $url"
    ((counter++))
done

echo "Video titles have been saved to $output_file."

