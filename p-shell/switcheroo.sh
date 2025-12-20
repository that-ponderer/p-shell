#!/usr/bin/bash

# this is script solely made for wofi to give the user a clean interface
# when choosing the theme . 
# wofi runs this script first time without any args , 
# and splits up and diplayes whatever got echoed that first time 
# to choose one of those options . 
# then it runs this script with that option . 


THEME="$@"
LAST_OUTPUT=""
NEW_OUTPUT=""
Update_Keeper_Format="p-shell-update-"
Update_Keeper=""
Current_Update_Num=0
Wallpaper_Path="${ThemePath}/Walls"
SCRIPT_NAME=$(basename "$0")
CURRENT_PID=$$

# Kill all other instances of this script
for pid in $(pgrep -f "$SCRIPT_NAME"); do
    if [ "$pid" -ne "$CURRENT_PID" ]; then
        kill -9 "$pid" 2>/dev/null
    fi
done

Apply_Wall() {
    if [[ -d "$1" ]]; then
        waypaper --backend swww --folder "$1"
        Num=${Update_Keeper##*-}
        Current_Update_Num=$((Num + 1))
        rm "$Update_Keeper"
        touch "${XDG_CACHE_HOME}/${Update_Keeper_Format}${Current_Update_Num}"
    else
        notify-send "Theme folder not found: $1"
        exit
    fi

}

if [[ -n "$THEME" ]] ; then

    LAST_OUTPUT=$(swww query)
    killall -INT wofi 2>/dev/null
    
    # Creating a Cheeky Counter to see how many times did it get applied.
    for updater in ${XDG_CACHE_HOME}/${Update_Keeper_Format}* ; do
       Update_Keeper="$updater"
    done
    if ! [[ -e "${Update_Keeper}" ]] ; then
        New_Update_Keeper="${XDG_CACHE_HOME}/${Update_Keeper_Format}${Current_Update_Num}"
        touch "${New_Update_Keeper}" 
        Update_Keeper="${New_Update_Keeper}"
    fi
           
    #open up waypaper according that theme , 
    #note : the folder with wallpapers in it has to be named the same 

    if ! [[ "$THEME" = "WAL" ]] ; then 

        WALL_PATH="${Wallpaper_Path}/$THEME"
        Apply_Wall "${WALL_PATH}"

    #choose the entire wall collection for pywal 
    #as it is fully dependent on the wallpaper 
    else 

        WALL_PATH="${Wallpaper_Path}"
        Apply_Wall "${WALL_PATH}"
    fi
    #Query for the update in the "swww query" command and then apply that theme
    #this allows swww to cache for as long as it wants
    while true ; do
        NEW_OUTPUT=$(swww query)
        if ! [[ "$LAST_OUTPUT" = "$NEW_OUTPUT" ]] ; then
            break
        fi
        sleep 1
     done

     python ${ThemePath}/switcheroo.py -t $THEME 
     #reloading some apps
     killall -INT dunst waybar  

     dunst -conf ${ThemePath}/Theme/dunstrc &

     niri msg outputs && \
     GTK_THEME=Adwaita waybar -c  ${ThemePath}/Theme/waybar/config-niri.jsonc \
     -s ${ThemePath}/Theme/waybar/style-niri.css >/dev/null 2>&1 & \
     swaybg -i ${ThemePath}/Theme/assets/blured_wall.png >/dev/null 2>&1 &
     
     sleep 1.5
     dunstify -I ${ThemePath}/icons/icon.png "$THEME"

     ${ThemePath}/Theme/gowall/gowall.sh >/dev/null 2>&1

fi

#This generates the required options for wofi to choose from ,
#it must run every time otherwise no options would show up
python ${ThemePath}/switcheroo.py --themes && echo WAL
