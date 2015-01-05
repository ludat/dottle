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

# Turn off Touchpad
xinput --disable 'ETPS/2 Elantech Touchpad'
# Start urxvt daemon
urxvtd -q -f -o
# Start xscreensaver daemon
xscreensaver -no-splash &
# Enable numlock on startup
numlockx &
# Start pulseaudio
start-pulseaudio-x11
# Start easystroke
easystroke &

# Set the cursor
xsetroot -cursor_name left_ptr
# Set Spanish keyboard layout
setxkbmap -layout es
# Set wallpaper
feh --bg-fill $HOME/Images/Wallpapers/TinyGalaxy.jpg
xcompmgr &
# Start xmonad
exec xmonad

# # Start dwm
# exec dwm

# ...or the Window Manager of your choice
