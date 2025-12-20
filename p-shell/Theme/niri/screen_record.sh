#!/bin/zsh

videopath="$(xdg-user-dir VIDEOS)/Screenrecodings/\
$(date +'%Y-%m-%d_%H-%M-%S')_grim.mp4"
if [[ "$@" = "d" ]] ; then
    gpu-screen-recorder \
    -w screen \
    -f 60 \
    -a default_output \
    -encoder cpu \
    -ac aac \
    -o "$videopath"
    dunstify -I "${ThemePath}/Icons/monitor.png"  "New Recording!" 

elif [[ "$@" = "o" ]] ; then
    gpu-screen-recorder \
    -w region \
    -region $(/bin/slurp -f "%wx%h+%x+%y") \
    -f 60 \
    -a default_output \
    -encoder cpu \
    -ac aac \
    -o "$videopath"
    dunstify -I "${ThemePath}/icons/monitor.png"  "New Recording!" 
else 
    exit 1
fi


