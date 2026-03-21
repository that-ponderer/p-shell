#!/usr/bin/env bash

# extension and mimetype
FORMAT=("mp4" "text/uri-list" )

mkdir -p "$(xdg-user-dir VIDEOS)/Screenrecordings"
videopath="$(xdg-user-dir VIDEOS)/Screenrecordings/\
$(date +'%Y-%m-%d_%H-%M-%S')_grim.${FORMAT[0]}"

if [[ "$1" = "d" ]] ; then
    # Gpu encoder does not work for me
    gpu-screen-recorder \
    -w screen \
    -f 60 \
    -a default_output \
    -encoder cpu \
    -ac aac \
    -o "$videopath"
elif [[ "$1" = "o" ]] ; then
    gpu-screen-recorder \
    -w region \
    -region "$(slurp -f "%wx%h+%x+%y")" \
    -f 60 \
    -a default_output \
    -encoder cpu \
    -ac aac \
    -o "$videopath"
else 
    exit 1
fi

notify-send -i "${ThemePath}/Theme/icons/monitor.png"  "Screen Cliped!" 
# freedesktop standerd file transfer mimetype
# uses urls, used in drag and droping
wl-copy --type "${FORMAT[1]}" "file://${videopath}"
