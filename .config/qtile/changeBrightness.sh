#! /bin/bash
if [ "$1" = "up" ] ; then
  xrandr --output eDP-1 --brightness $(awk "BEGIN {a=$(xrandr --verbose | awk '/Brightness/ { print $2; exit }') + 0.1; if(a > 1) a=1;  print a }" )
else
  if [ "$1" = "down" ] ; then
    xrandr --output eDP-1 --brightness $(awk "BEGIN {a=$(xrandr --verbose | awk '/Brightness/ { print $2; exit }') - 0.1; if(a < 0) a=0;  print a }" )
  fi
fi
