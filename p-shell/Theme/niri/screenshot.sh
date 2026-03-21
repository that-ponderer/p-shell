#!/usr/bin/env bash

mkdir -p "$(xdg-user-dir PICTURES)/Screenshots"
shotpath="$(xdg-user-dir PICTURES)/Screenshots/\
$(date +'%Y-%m-%d_%H-%M-%S')_grim.png" 

if [[ "$1" = "d" ]] ; then
    grim -l 0 \
    -g "0,0 1920x1080" \
    "$shotpath"
elif [[ "$1" = "o" ]] ; then
    grim -l 0 \
    -g "$(slurp -o)" \
    "$shotpath" 
else 
    exit 1
fi

wl-copy < "$shotpath"
notify-send -i "$shotpath" "Screen Grabbed"
