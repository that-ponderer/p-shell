#!/usr/bin/env bash

GTK_THEME=Adwaita \
waybar -c "${ThemePath}/Theme/waybar/config-niri.jsonc" -s \
"${ThemePath}/Theme/waybar/style-niri.css"
