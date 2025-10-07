#!/usr/bin/env bash

swaylock --config $HOME/.dotfiles/swaylock/config.conf

# -C, --config <config_file>       Path to the config file.
# -c, --color <color>              Turn the screen into the given color instead of white.
# -d, --debug                      Enable debugging output.
# -t, --trace                      Enable tracing output.
# -e, --ignore-empty-password      When an empty password is provided, do not validate it.
# -F, --show-failed-attempts       Show current count of failed authentication attempts.
# -f, --daemonize                  Detach from the controlling terminal after locking.
# --fade-in <seconds>              Make the lock screen fade in instead of just popping in.
# --submit-on-touch                Submit password in response to a touch event.
# --grace <seconds>                Password grace period. Don't require the password for the first N seconds.
# --grace-no-mouse                 During the grace period, don't unlock on a mouse event.
# --grace-no-touch                 During the grace period, don't unlock on a touch event.
# -h, --help                       Show help message and quit.
# -i, --image [[<output>]:]<path>  Display the given image, optionally only on the given output.
# -S, --screenshots                Use a screenshots as the background image.
# -k, --show-keyboard-layout       Display the current xkb layout while typing.
# -K, --hide-keyboard-layout       Hide the current xkb layout while typing.
# -L, --disable-caps-lock-text     Disable the Caps Lock text.
# -l, --indicator-caps-lock        Show the current Caps Lock state also on the indicator.
# -s, --scaling <mode>             Image scaling mode: stretch, fill, fit, center, tile, solid_color.
# -T, --tiling                     Same as --scaling=tile.
# -u, --no-unlock-indicator        Disable the unlock indicator.
# --indicator                      Always show the indicator.
# --clock                          Show time and date.
# --timestr <format>               The format string for the time. Defaults to '%T'.
# --datestr <format>               The format string for the date. Defaults to '%a, %x'.
# -v, --version                    Show the version number and quit.
# --bs-hl-color <color>            Sets the color of backspace highlight segments.
# --caps-lock-bs-hl-color <color>  Sets the color of backspace highlight segments when Caps Lock is active.
# --caps-lock-key-hl-color <color> Sets the color of the key press highlight segments when Caps Lock is active.
# --font <font>                    Sets the font of the text.
# --font-size <size>               Sets a fixed font size for the indicator text.
# --indicator-idle-visible         Sets the indicator to show even if idle.
# --indicator-radius <radius>      Sets the indicator radius.
# --indicator-thickness <thick>    Sets the indicator thickness.
# --indicator-x-position <x>       Sets the horizontal position of the indicator.
# --indicator-y-position <y>       Sets the vertical position of the indicator.
# --indicator-image <path>         Display the given image inside of the indicator.
# --inside-color <color>           Sets the color of the inside of the indicator.
# --inside-clear-color <color>     Sets the color of the inside of the indicator when cleared.
# --inside-caps-lock-color <color> Sets the color of the inside of the indicator when Caps Lock is active.
# --inside-ver-color <color>       Sets the color of the inside of the indicator when verifying.
# --inside-wrong-color <color>     Sets the color of the inside of the indicator when invalid.
# --key-hl-color <color>           Sets the color of the key press highlight segments.
# --layout-bg-color <color>        Sets the background color of the box containing the layout text.
# --layout-border-color <color>    Sets the color of the border of the box containing the layout text.
# --layout-text-color <color>      Sets the color of the layout text.
# --line-color <color>             Sets the color of the line between the inside and ring.
# --line-clear-color <color>       Sets the color of the line between the inside and ring when cleared.
# --line-caps-lock-color <color>   Sets the color of the line between the inside and ring when Caps Lock is active.
# --line-ver-color <color>         Sets the color of the line between the inside and ring when verifying.
# --line-wrong-color <color>       Sets the color of the line between the inside and ring when invalid.
# -n, --line-uses-inside           Use the inside color for the line between the inside and ring.
# -r, --line-uses-ring             Use the ring color for the line between the inside and ring.
# --ring-color <color>             Sets the color of the ring of the indicator.
# --ring-clear-color <color>       Sets the color of the ring of the indicator when cleared.
# --ring-caps-lock-color <color>   Sets the color of the ring of the indicator when Caps Lock is active.
# --ring-ver-color <color>         Sets the color of the ring of the indicator when verifying.
# --ring-wrong-color <color>       Sets the color of the ring of the indicator when invalid.
# --separator-color <color>        Sets the color of the lines that separate highlight segments.
# --text-color <color>             Sets the color of the text.
# --text-clear-color <color>       Sets the color of the text when cleared.
# --text-caps-lock-color <color>   Sets the color of the text when Caps Lock is active.
# --text-ver-color <color>         Sets the color of the text when verifying.
# --text-wrong-color <color>       Sets the color of the text when invalid.
# --effect-blur <radius>x<times>   Blur images.
# --effect-pixelate <factor>       Pixelate images.
# --effect-scale <scale>           Scale images.
# --effect-greyscale               Make images greyscale.
# --effect-vignette <base>:<factor>Apply a vignette effect to images. Base and factor should be numbers between 0 and 1.
# --effect-custom <path>           Apply a custom effect from a shared object or C source file.
# --time-effects                   Measure the time it takes to run each effect.
