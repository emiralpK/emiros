# .bash_profile - Auto-start X on login

# If we're on tty1 and X is not running, start it
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
