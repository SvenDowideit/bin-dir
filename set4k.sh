#!/bin/bash

#is this the yoga260 with onelink+ dock?
dockDP=$(xrandr | grep "DP-2-1 connected")
echo "found: $dockDP"
if [ "$dockDP" != "" ]; then
	# try https://bugzilla.redhat.com/show_bug.cgi?id=1179924
	xset dpms force off
	xrandr --output DP-2-1 --mode "3840x2160" --above eDP-1
	i3-msg move workspace to output up
	exit
fi



exit
# this is the yoga tablet using HDMI
xrandr --newmode "3840x2160"  262.75  3840 3888 3920 4000  2160 2163 2168 2191 +hsync -vsync
xrandr --addmode HDMI-1 3840x2160

xrandr --newmode "3840x2160x30" 297.00  3840 4016 4104 4400  2160 2168 2178 2250 +hsync -vsync
xrandr --addmode HDMI-1 3840x2160x30

xrandr --output HDMI-1 --mode 3840x2160x30 --above eDP-1
xrandr --output eDP-1 --mode 2160x1440
xrandr --output eDP-1 --brightness 0.6
