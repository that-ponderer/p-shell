#!/usr/bin/zsh

# My Awesome switcher

Selection=$(${ThemePath}/switcheroo.sh |\
    wofi --dmenu \
    -s ${ThemePath}/Theme/wofi.css \
    -W 300 -H 145 \
    --define hide_search=true \
    --define content_halign=center)

${ThemePath}/switcheroo.sh "${Selection}"
