#!/usr/bin/env bash

# The Gnome Auth Agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Audio stack ------------------------
pw-cli info || pipewire & 
pactl info || pipewire-pulse &
wpctl status || wireplumber &
# -------------------------------------

# Wallpaper -----------------------------
readonly SWITCHER_LOG="${ThemePath}/.cache"
readonly DISPLAY='eDP-1'

WALLPAPER=''
WALLPAPER_BACKEND='awww'

if jq -r '."current_wallpaper"' "$SWITCHER_LOG" ; then
    WALLPAPER="$(jq -r '."current_wallpaper"' "$SWITCHER_LOG" )"
fi
if jq -r '."wallpaper_backend"' "$SWITCHER_LOG" ; then
    WALLPAPER_BACKEND="$(jq -r '."wallpaper_backend"' "$SWITCHER_LOG" )"
fi

if [[ "$WALLPAPER_BACKEND" == "mpvpaper" ]] ; then
    mpvpaper "$DISPLAY" -o "no-audio --loop-playlist" "$WALLPAPER" &
else
    awww-daemon &
    awww restore
fi
# ----------------------------------------------

# Daemons --------------------------------------
"${ThemePath}/switcheroo.sh" -r # reload bar
mpd "${ThemePath}/Theme/mpd/mpd.conf" &
swayidle -w before-sleep "zsh -c lock" &
swaybg -i "${ThemePath}/Theme/assets/blured_wall.png" &
clipcatd -c "${ThemePath}/Theme/clipcat/clipcatd.toml" &
dunst -conf "${ThemePath}/Theme/dunstrc" &
# ----------------------------------------------

# misc _---------------------------------------
brightnessctl s "5%"
# ---------------------------------------------
