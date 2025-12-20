#!/usr/bin/zsh

shotpath="$(xdg-user-dir PICTURES)/Screenshots/\
$(date +'%Y-%m-%d_%H-%M-%S')_grim.png" 

if [[ "$@" = "d" ]] ; then
    grim -l 0 \
    -g "0,0 1920x1080" \
    "$shotpath"
elif [[ "$@" = "o" ]] ; then
    grim -l 0 \
    -g "$(slurp -o)" \
    "$shotpath" 
else 
    exit 1
fi

wl-copy < "$shotpath"
