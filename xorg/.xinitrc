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
# Start easystroke
easystroke &

# # Start awesome
# xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu > $HOME/.config/awesome/localdata/menus.lua
# exec awesome

# set the cursor
xsetroot -cursor_name left_ptr
# set German keyboard layout
setxkbmap -layout es
# set wallpaper
feh --bg-fill $HOME/Images/Wallpapers/tinyGalaxy.jpg
# start xcompmgr for transparency
xcompmgr &
# start xmonad
exec xmonad

# # Start dwm
# exec dwm

# ...or the Window Manager of your choice
