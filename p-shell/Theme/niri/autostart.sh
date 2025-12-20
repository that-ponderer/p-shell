#!/usr/bin/zsh

# The Gnome Auth Agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

## Some Apps 
swww-daemon &
GTK_THEME=Adwaita waybar -c "${ThemePath}/Theme/waybar/config-niri.jsonc" \
-s "${ThemePath}/Theme/waybar/style-niri.css" &
dunst -conf "${ThemePath}/Theme/dunstrc" & 
mpd "${ThemePath}/Theme/mpd/mpd.conf" &
nm-applet &
swayidle -w before-sleep "${ThemePath}/Theme/niri/swaylock.sh" &
waypaper --restore 
swaybg -i "${ThemePath}/Theme/assets/blured_wall.png" &
clipcatd -c "${ThemePath}/Theme/clipcat/clipcatd.toml" &
eval "$(ssh-agent -s)"

