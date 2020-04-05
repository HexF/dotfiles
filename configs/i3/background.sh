#!/bin/sh
RANDNUM=$RANDOM$RANDOM
IMGPATH=$HOME/Pictures/Wal/bgr$RANDNUM.jpg
rm -rf  $HOME/Pictures/Wal/bgr*.jpg

splash --collection $1 --save $IMGPATH

wal -i $IMGPATH -n
xrdb ~/.config/X11/xresources
feh --no-fehbg --bg-fill "$IMGPATH"
