#!/usr/bin/zsh

# --------------------------------------------------
# Wofi theme switcher frontend for p-shell
# --------------------------------------------------

THEME="$*"
SCRIPT_NAME="$(basename "$0")"
CURRENT_PID="$$"

THEME_PATH="${ThemePath}"
WALLPAPER_ROOT="${THEME_PATH}/Walls"

LAST_SWWW_OUTPUT=""


# --------------------------------------------------
# Helpers
# --------------------------------------------------

die() {
    notify-send "Theme switcher error" "$1"
    exit 1
}


apply_wallpaper() {
    local wall_dir="$1"

    [[ -d "$wall_dir" ]] || die "Theme folder not found: $wall_dir"

    waypaper --backend swww --folder "$wall_dir" \
        || true
}


wait_for_swww_update() {
    local last="$1"
    local current=""

    while true; do
        current="$(swww query 2>/dev/null)" || continue
        [[ "$last" != "$current" ]] && break
        sleep 1
    done
}


# --------------------------------------------------
# Kill other running instances
# --------------------------------------------------

for pid in $(pgrep -f "$SCRIPT_NAME" 2>/dev/null); do
    [[ "$pid" != "$CURRENT_PID" ]] && kill -9 "$pid" 2>/dev/null
done


# --------------------------------------------------
# Main logic
# --------------------------------------------------

if [[ -n "$THEME" ]]; then
    LAST_SWWW_OUTPUT="$(swww query 2>/dev/null)" \
        || die "Unable to query swww"

    killall -INT wofi 2>/dev/null || true

    if [[ "$THEME" == "WAL" ]]; then
        apply_wallpaper "$WALLPAPER_ROOT"
    else
        apply_wallpaper "${WALLPAPER_ROOT}/${THEME}"
    fi

    wait_for_swww_update "$LAST_SWWW_OUTPUT"

    python "${THEME_PATH}/switcheroo.py" -t "$THEME" \
        || die "Theme application failed"

    # Reload UI components (non-fatal)
    killall -INT dunst waybar 2>/dev/null || true

    dunst -conf "${THEME_PATH}/Theme/dunstrc" &

    niri msg outputs 2>/dev/null || true

    GTK_THEME=Adwaita waybar \
        -c "${THEME_PATH}/Theme/waybar/config-niri.jsonc" \
        -s "${THEME_PATH}/Theme/waybar/style-niri.css" \
        >/dev/null 2>&1 &

    swaybg -i "${THEME_PATH}/Theme/assets/blured_wall.png" \
        >/dev/null 2>&1 &
    
    "${THEME_PATH}/Theme/gowall/gowall.sh" >/dev/null 2>&1 || true

    sleep 1.5

    dunstify -I "${THEME_PATH}/Theme/icons/icon.png" "$THEME" || true

fi

#---------------------------------------
# For Wofi (Must Always Run)
#---------------------------------------

python "${THEME_PATH}/switcheroo.py" --themes \
    || die "Theme application failed"

# ----

