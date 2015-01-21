#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
        for f in /etc/X11/xinit/xinitrc.d/*; do
                [ -x "$f" ] && . "$f"
        done
        unset f
fi


if [ $(xrandr | grep DP2 | cut -d' ' -f 2) = "connected" ]; then
    xrandr --output eDP1 --off
    xrandr --output DP2 --primary --auto --output DP1 --auto --left-of DP2
fi

xset m 4 3
xset r on
xset b off
xset s off
xset -dpms

xrdb -merge ~/.Xresources         # update x resources db
xscreensaver -no-splash &         # starts screensaver daemon 
xsetroot -cursor_name left_ptr &  # sets the cursor icon
#sh ~/.fehbg &                     # sets the background imaue

#if [ -f $HOME/.Xmodmap ]; then
xmodmap $HOME/.Xmodmap
#fi


exec /usr/bin/awesome
