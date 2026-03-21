#!/usr/bin/env bash

# The Gnome Auth Agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# --------------------------------------------
# Wallpaper 
# --------------------------------------------
readonly SWITCHER_LOG="${ThemePath}/.cache"
readonly DISPLAY='eDP-1'

WALLPAPER=''
WALLPAPER_BACKEND='swww'

if jq -r '."current_wallpaper"' "$SWITCHER_LOG" ; then
    WALLPAPER="$(jq -r '."current_wallpaper"' "$SWITCHER_LOG" )"
fi
if jq -r '."wallpaper_backend"' "$SWITCHER_LOG" ; then
    WALLPAPER_BACKEND="$(jq -r '."wallpaper_backend"' "$SWITCHER_LOG" )"
fi

if [[ "$WALLPAPER_BACKEND" == "mpvpaper" ]] ; then
    mpvpaper "$DISPLAY" -o "no-audio --loop-playlist" "$WALLPAPER" &
else
    swww-daemon &
    swww restore
fi
# ----------------------------------------------
## Some other Apps 
GTK_THEME=Adwaita waybar -c "${ThemePath}/Theme/waybar/config-niri.jsonc" \
-s "${ThemePath}/Theme/waybar/style-niri.css" &
dunst -conf "${ThemePath}/Theme/dunstrc" & 
mpd "${ThemePath}/Theme/mpd/mpd.conf" &
nm-applet &
swayidle -w before-sleep "${ThemePath}/Theme/niri/swaylock.sh" &
swaybg -i "${ThemePath}/Theme/assets/blured_wall.png" &
clipcatd -c "${ThemePath}/Theme/clipcat/clipcatd.toml" &

