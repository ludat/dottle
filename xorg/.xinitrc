#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

if [ -f ~/.Xresources ]; then
    xrdb -merge ~/.Xresources
fi

# exec gnome-session
# exec startkde
# exec startxfce4
# Turn off Touchpad
synclient TouchpadOff=1
# Start urxvt daemon
# urxvtd -q -f -o
# Start xscreensaver daemon
xscreensaver -no-splash &
# Enable numlock on startup
numlockx &
# Start pulseaudio
start-pulseaudio-x11

# Start awesome
exec awesome

# Start i3
# exec i3

# Start xmonad
# exec xmonad
# ...or the Window Manager of your choice
