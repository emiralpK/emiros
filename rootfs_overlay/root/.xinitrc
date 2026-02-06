#!/bin/sh
# .xinitrc - Start XFCE desktop environment

# Set background
if [ -f /usr/share/emiros/wallpaper.svg ]; then
    xsetroot -solid '#0d1117'
fi

# Start XFCE session
exec startxfce4
