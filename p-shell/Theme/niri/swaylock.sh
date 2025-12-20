#!/usr/bin/bash

InsideCol=cba6f7ff
InsideClearCol=a6e3a1ff
InsideVerifyCol=89b4faff
InsideWrongCol=f38ba8ff

RingCol=cba6f7ff
RingClearCol=a6e3a1ff
RingVerifyCol=89b4faff
RingWrongCol=f38ba8ff

KeyHighLightCol=fab387ff
BackSpaceHighLightSegCol=f38ba8ff

swaylock -i ${ThemePath}/Theme/assets/blured_wall.png \
        --font "JetBrainsMono Nerd Font Propo" --indicator-radius 70 \
        --inside-color $InsideCol \
        --inside-clear-color $InsideClearCol \
        --inside-ver-color $InsideVerifyCol \
        --inside-wrong-color $InsideWrongCol \
        --ring-color $RingCol \
        --ring-clear-color $RingClearCol \
        --ring-ver-color $RingVerifyCol \
        --ring-wrong-color $RingWrongCol \
        --bs-hl-color $BackSpaceHighLightSegCol \
        --key-hl-color $KeyHighLightCol
