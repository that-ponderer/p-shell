# External tools: jq gesttings (any gnome package) getopt (coreutil) 
#                 rofi swww pywal wpgtk dunst waybar swaybg imgmagick
#                 mpvpaper ffmpegthumbnailer

# Globals {{{

# Shellopts
# ----------------------
shopt -s extglob nullglob globstar
# ----------------------
# Colors
# -----------------------
c0="\e[30m"
c1='\e[31m'
c2='\e[32m'
c3='\e[33m'
c4='\e[34m'
c5='\e[35m'
c6='\e[36m'
c7='\e[37m'
cr='\e[0m'
# -----------------------
# Global Variables
# -----------------------
DEBUG=false
THEME=""
WALLPAPER_BACKEND=''
WALLPAPER=''
DISPLAY='eDP-1'

# }}}

# Filesystem {{{

readonly TP="$ThemePath"
[[ -d "$TP" ]] || fatal 'Variable {ThemePath} not found'
# --------------------------------------------
readonly DATABASE_FILE="${TP}/database.json"
readonly CONFIG_FILE="${TP}/config.json"
readonly TEMPLATES_DIR="${TP}/Templates"
readonly THEME_DIR="${TP}/Theme"
readonly TEMP_FILE="${TP}/temp"
readonly CACHE="${TP}/.cache"
# --------------------------------------------
readonly \
WALLPAPER_ROOT="${TP}/Walls"
readonly \
ROFI_WALLPAPER_SWITCHER_CONF="${TP}/Theme/rofi/config_wallpaper_switcher.rasi"
readonly \
ROFI_THEME_SWITCHER_CONF="${TP}/Theme/rofi/config_theme_switcher.rasi"
readonly \
ROFI_THEME_SWITCHER_ICON_DIR="${TP}/Theme/rofi/icons/theme_switcher"
readonly \
THUMBNAIL_DIR="${TP}/Theme/.thumbnails"
# --------------------------------------------
VS_CODE_SETTINGS_FILE=""
[[ -f "${HOME}/.config/Code - OSS/User/settings.json" ]] && \
    VS_CODE_SETTINGS_FILE="${HOME}/.config/Code - OSS/User/settings.json"
# --------------------------------------------
readonly \
VIM_AND_VIM_AIRLINE_FILE="${TP}/vim/colors"
# }}}

# Output helpers {{{

log() {
    printf "%b[switcher]\e[0m %s\n" "${c2}" "$*"
}

fail() {
    printf "%b[error]\e[0m %s\n" "${c5}" "$*" >&2
    return 1
}

fatal() {
    printf "%b[fatal]\e[0m %s\n" "${c1}" "$*" 1>&2
    exit 1
}
debug() {
    while read -r line; do
        $DEBUG && \
        printf "%b[debug]\e[0m %s\n" "${c3}" "$line" 1>&2
    done
    return 0 
}
check_pipe (){ 
    # -----------------------------
    # Usage: 
    #    Print outputs based on pipefails for the most recent pipes 
    #    or propvide a custom PIPESTATUS array
    # Inputs:
    #    str|str** command_to_run 
    #    pipe_check_start_from pipe_check_end_at custom_pipestatus_array
    # -----------------------------

    # Always grab PIPESTATUS immidiatly
    # it gets replaced with the exit
    # code of any command being ran after
    # the command with pipes in them

    local pipe_status=( "${PIPESTATUS[@]}" )
    local output_array 
    local com="${2:-fail}"
    local start="${3:-0}"
    local end="${4:-$(( start + 1 ))}"
    [[ $5 ]] && pipe_status=( "${!5}" )

    local IFS="|"
    read -ra output_array <<< "$1"
    local idx=0
    local is_fail=false
    # Note the array slice syntax
    for ps in "${pipe_status[@]:$start:$end}"; do 
        local output_text_raw
        local output_text
        output_text_raw="${output_array[idx]:-Pipe $(( start + idx ))} Failed.."
        # The only time bash does regex matching is in the '[['
        # comand with the '=~' oparator
        # Anywhere else you will use globs and ext globs
        #
        # The BASH_REMATCH array is assigned by the '=~' oparator
        # BASH_REMATCH[0] has the entire matched string
        # BASH_REMATCH[n] has the substring matched by the nth capture gruop
        # which is the stuff incased in '(..)'
        [[ $output_text_raw =~ ^[[:space:]]*(.*[^[:space:]])[[:space:]]*$ ]]
        # This regex strips out leading and trailing wp
        output_text="${BASH_REMATCH[1]}"
        # And we capture the stuff inside capture group 1
        [[ "$ps" -eq 0 ]] || { is_fail=true ; $com "${output_text}" ; }
        (( idx++ ))
    done
    $is_fail && return 1
    return 0
}
print_help() {
    local help_text
    # -d sets the delimiter. 'read' reads the file untill it encounters 
    # this character, by default its a new line character but we set it to 
    # blank here to read the whole file.
    #
    # the 'EOF' is called a 'sentinel' of the heredoc it sets the start 
    # and end of the block of text. The work does not matter but 
    # 'EOF' is commonly used.
    read -d '' -r help_text <<EOF
${c2}usage:${cr} switcheroo.sh [${c1}-h${cr}] [${c1}-d${cr}] [${c1}-l${cr}] [${c1}-t "theme"${cr}]

${c2}switcheroo${cr} -  The theme switcher of p-shell

${c2}options:${cr}
    ${c5}-h, --help${cr}          show help massage
    ${c5}-d, --debug${cr}         debug mode
    ${c5}-l, --list${cr}          list available themes
    ${c5}-t, --theme${cr}         choose one available theme
    ${c5}-c, --clean${cr}         clean cached thumbnails
EOF
    printf "%b\n"  "$help_text"
}

# }}}

# Helpers {{{

# ----------------------
# Apply themes
# ----------------------
# DEPRICATED (I dont use slop-ditor anymore)
# ============================================
apply_vscode_theme() {
    local settings_file="$1"
    local theme_name="$2"
    local temp_file="$3"

    log "Applying vs-code theme.."
    [[ -n "$settings_file" ]] || \
        { fail "vs-code config not found: skipping.." ; return 1 ; }
    jq --arg theme_name "$theme_name" \
        '."workbench.colorTheme" = $theme_name' "${settings_file}" \
        2>&1 | tee "$temp_file" | debug
    check_pipe "Failed to install vs-code theme: skiping..| \
        Failed to write to Temp_file: skipping.." "fail" 0 2 || \
        return 1
    mv "$temp_file" "$settings_file" 2>&1 | debug
    check_pipe "Failed to override vs-code config: skipping.."
}
# ============================================
apply_gtk_theme() {
    local gtk_theme_name="$1"
    local icon_theme_name="$2"
    local font_name="$3"
    local font_size="${4:-12}"

    log "Applying gtk theme.."
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme_name" 2>&1 \
        | debug
    check_pipe "Failed to install gtk-theme: skipping"
    if ! [[ -z "$icon_theme_name" ]] ; then
        gsettings set org.gnome.desktop.interface icon-theme \
            "$icon_theme_name" 2>&1 | debug
        check_pipe "Failed to install icon-theme: skipping.."
    fi
    if ! [[ -z "$font_name" || -z "$font_size" ]] ; then
        gsettings set org.gnome.desktop.interface font-name \
            "$font_name $font_size" 2>&1 | debug
        check_pipe "Failed to install font-theme: skipping.."
    fi
}
apply_gtk_theme_flatpak() {
    local gtk_theme_name="$1"
    local icon_theme_name="$2"
    local font_name="$3"
    local font_size="${4:-12}"

    log "Applying flagtk gtk theme.."
    command -v flatpak &> >(debug) || fail "flatpak not installed: skipping.."
    flatpak override --user --env=GTK_THEME="$gtk_theme_name" 2>&1 \
        | debug
    check_pipe "Failed to install flatpak gtk-theme: skipping"
    if ! [[ -z "$icon_theme_name" ]] ; then
        flatpak override --user --env=ICON_THEME="$icon_theme_name" \
              2>&1 | debug
        check_pipe "Failed to install icon-theme: skipping.."
    fi
    if ! [[ -z "$font_name" || -z "$font_size" ]] ; then
        flatpak override --user --env=GTK_FONT_NAME="${font_name} ${font_size}" \
            2>&1 | debug
        check_pipe "Failed to install font-theme: skipping.."
    fi
}
apply_vim_theme(){
    local _vim_theme="$1"
    local _temp_file="$2"
    
    log "Appying vim theme.."
    [[ -f "$VIM_AND_VIM_AIRLINE_FILE" ]] || \
        { fail "Failed to apply vim-colorscheme" ; return 1 ; }

    local _output=''
    while IFS= read -r line ; do
        [[ "$line" =~ ^[[:space:]]*colorscheme.* ]] && \
            line="colorscheme $_vim_theme"
        _output+="$line\n"
    done < "$VIM_AND_VIM_AIRLINE_FILE"

    printf "%b" "$_output" > "$_temp_file"
    
    mv "$_temp_file" "$VIM_AND_VIM_AIRLINE_FILE" &> >(debug) ||
        fatal "Internal error.."
}
apply_vim_airline_theme(){
    local _vim_airline_theme="$1"
    local _temp_file="$2"
    
    log "Appying vim airline theme.."
    [[ -f "$VIM_AND_VIM_AIRLINE_FILE" ]] || \
        { fail "Failed to apply vim-airline-colorscheme" ; return 1 ; }

    local _output=''
    while IFS= read -r line ; do
        [[ "$line" =~ ^[[:space:]]*let[[:space:]]*g:airline_theme.* ]] && \
            line="let g:airline_theme = \"$_vim_airline_theme\""
        _output+="$line\n"
    done < "$VIM_AND_VIM_AIRLINE_FILE"

    printf "%b" "$_output" > "$_temp_file"
    
    mv "$_temp_file" "$VIM_AND_VIM_AIRLINE_FILE" &> >(debug) ||
        fatal "Internal error.."
}
# ----------------------
# Json
# ----------------------
placeholders_objs_to_A_array() {
    # Usage:
    #
    #   Takes a theme name that has a json obj containing 
    #   values for the placeholders,
    #   the name of an array and the path to the file
    #   returns a str that can be evaluated {eval} to generate said 
    #   associative array
    #
    # Input:
    # 
    # {
    #   "Theme": {
    #       "placeholders": {
    #           "A": "value1",
    #           "B": "value2"
    #           }
    #       }
    #  }
    #
    # Output:
    #
    #   arr=( ["A"]="value1" ["B"]="value2" )
    #
    [[ "$#" -ge 3 ]] || return 1
    local theme_name="$1"
    local arr_name="$2"
    local file="$3"
    
    local arr
    arr=$(
        jq \
        --arg _theme_name "$theme_name" \
        --arg _arr_name "$arr_name" \
        -r \
        '.[$_theme_name].["placeholders"] | to_entries[] |
        "\($_arr_name)[\(.key | @sh)]=\(.value | @sh)"' \
        "$file" 2> >(debug) \
        || fatal "Failed to parse the placeholders: exiting.."
        )
     printf "%s" "$arr"
}
config_objs_to_A_array(){
    # Usage:
    #
    #   Takes the the name of the array path of the config file and
    #   returns an associative array expression with the same name
    # 
    # Input:
    #   
    #   {
    #       "module1":["attr1","attr2","attr3"]
    #       "module2":["attr1","attr2","attr3"]
    #   }
    #   
    # Output:
    #   
    #   arr=( 
    #       ["module1"]="attr1 attr2 attr3" # The values can easily be 
    #       ["module2"]="attr1 attr2 attr3" # made into arrays 
    #       )
    #
    [[ "$#" -ge 2 ]] || return 1
    local arr_name="$1"
    local config_file="$2"

    local arr
    arr=$(
        jq -r --arg _arr_name "$arr_name" '. | to_entries[] | 
            "\($_arr_name)[\(.key | @sh )]+=\(" \(.value[])" | @sh)"' \
            "$config_file" 2> >(debug) \
            || fatal "Failed to parse the config: exiting.."
        )
    printf "%s" "$arr"
}
fetch_gtk_theme(){
    local _theme_name="$1"
    local _database_file="$2"
    local gtk_theme
    gtk_theme="$(jq -r --arg __theme_name "$_theme_name" \
        '.[$__theme_name].["gtk-theme"]' "$_database_file" \
        2> >(debug) || fail "Failed to parse gtk-theme: skipping")"
    if [[ "$gtk_theme" == "null" ]] ; then
        printf ""
    else 
        printf "%s" "$gtk_theme"
    fi
}
fetch_gtk_icon_theme(){
    local _theme_name="$1"
    local _database_file="$2"
    local _gtk_icon_theme
    _gtk_icon_theme="$(jq -r --arg __theme_name "$_theme_name" \
        '.[$__theme_name].["gtk-icon-theme"]' "$_database_file"\
        2> >(debug) || fail "Failed to parse gtk-icon-theme: skipping")"
    if [[ "$_gtk_icon_theme" == "null" ]] ; then
        printf ""
    else 
        printf "%s" "$_gtk_icon_theme"
    fi
}
fetch_gtk_font(){
    local _theme_name="$1"
    local _database_file="$2"
    _gtk_font="$(jq -r --arg __theme_name "$_theme_name" \
        '.[$__theme_name].["gtk-font"]' "$_database_file"\
        2> >(debug) || fail "Failed to parse gtk-font: skipping")"
    if [[ "$_gtk_font" == "null" ]] ; then
        printf ""
    else 
        printf "%s" "$_gtk_font"
    fi
}
fetch_gtk_font_size(){
    local _theme_name="$1"
    local _database_file="$2"
    local _gtk_font_size
    _gtk_font_size="$(jq -r --arg __theme_name "$_theme_name" \
        '.[$__theme_name].["gtk-font-size"]' "$_database_file"\
        2> >(debug) || fail "Failed to parse gtk-font-size: skipping")"
    if [[ "$_gtk_font_size" == "null" ]] ; then
        printf ""
    else 
        printf "%s" "$_gtk_font_size"
    fi
}
fetch_vim_colorscheme(){
    local _theme_name="$1"
    local _database_file="$2"
    local _vim_colorscheme
    _vim_colorscheme="$(jq -r --arg __theme_name "$_theme_name" \
        '.[$__theme_name].["vim-colorscheme"]' "$_database_file"\
        2> >(debug) || fail "Failed to parse vim-colorscheme: skipping")"
    if [[ "$_vim_colorscheme" == "null" ]] ; then
        printf ""
    else 
        printf "%s" "$_vim_colorscheme"
    fi
}
fetch_vim_airline_colorscheme(){
    local _theme_name="$1"
    local _database_file="$2"
    local _vim_airline_colorscheme
    _vim_airline_colorscheme="$(jq -r --arg __theme_name "$_theme_name" \
        '.[$__theme_name].["vim-airline-colorscheme"]' "$_database_file"\
        2> >(debug) || fail "Failed to parse vim-airline-colorscheme: skipping")"
    if [[ "$_vim_airline_colorscheme" == "null" ]] ; then
        printf ""
    else 
        printf "%s" "$_vim_airline_colorscheme"
    fi
}
write_cache(){
    local _current_theme="$1"
    local _current_wallpaper="$2"
    local _wallpaper_backend="$3"

    local data=''
    data="$( jq -n \
       --arg theme "$_current_theme" \
       --arg wallpaper "$_current_wallpaper" \
       --arg wallpaper_backend "$_wallpaper_backend" \
       '{
        "current_theme":"\($theme)",
        "current_wallpaper":"\($wallpaper)",
        "wallpaper_backend":"\($wallpaper_backend)"
        }' \
       2> >(debug) || fail "failed to write cache..")"
   printf "%b" "$data" > "$CACHE"
}
fetch_current_theme(){
    local _theme
    _theme="$(jq -r \
        '."current_theme"' "$CACHE" \
        2> >(debug) || fail "Failed to parse cache..")"
    if [[ "$_theme" == "null" ]] ; then
        printf ""
    else 
        printf "%s" "$_theme"
    fi
}
fetch_current_wallpaper(){
    local _wallpaper
    _wallpaper="$(jq -r \
        '."current_wallpaper"' "$CACHE" \
        2> >(debug) || fail "Failed to parse cache..")"
    if [[ "$_wallpaper" == "null" ]] ; then
        printf ""
    else 
        printf "%s" "$_wallpaper"
    fi
}
# ----------------------
# Colors
# ----------------------
hex_to_rgb() {
    local hex_value="$1"

    local rgb_value
    rgb_value=$(pastel -m off format rgb "$hex_value" 2> >(debug))
    [[ -n "$rgb_value" ]] || \
    fatal "Failed to do color conversion: exiting.."
    printf "%s" "$rgb_value"
}
hex_to_rgb_A_array(){ # require: hex_to_rgb()
    local -n input_arr="$1"
    local arr_name="$2"
    
    declare -A output_arr
    for key in "${!input_arr[@]}"; do
        output_arr["$key"]="$( hex_to_rgb "${input_arr[$key]}" )" 
    done
    for key in "${!output_arr[@]}" ; do
        # Note the new line. You need that otherwise the whole thing is 
        # going to look like one single command
        printf "%s['%s']='%s\n'" "$arr_name" "$key" "${output_arr["$key"]}"
    done
}
parse_pywal_color(){
    # Generate array from pywal

    local arr_name="$1"
    local PYWAL_FILE="$HOME/.cache/wal/colors.json"

    output="$( jq -r --arg _arr_name "$arr_name" \
        '."colors" | to_entries[] | "\($_arr_name)+=(\(.value | @sh))"' \
        "$PYWAL_FILE" 2> >(debug) )"
    [[ -z "$output" ]] && fali "Failed to parse pywal: Skipping.."
    printf "%s" "$output"
}
# ----------------------
# Transformations
# ----------------------

check_parent(){
    local file="$1"
    [[ -z "$file" ]] && fatal "func check_parent() needs an argument: exiting.."

    local file_dir="${file%/*}"
    [[ -d "$file_dir" ]] \
        || { log "$file does not have a parent directory: creating.." ; \
        mkdir -p "$file_dir" || fatal "Failed to create dir: $file_dir exiting.."\
        ; }
}
replace_placeholder_and_move(){ #require: fatal() debug() log()
    [[ "$#" -ge 4 ]] || fatal "Not enough Arguments: exiting.."
    local template="$1"
    # The -n makes the NAME point to another variable of name VALUE
    local -n array="$2"
    local output="$3"
    local temp_file="$4"
    
    # Reading
    local input_data
    [[ -f "$template" ]] || \
        fatal "Failed to parse template:- $template :exiting.."
    input_data=$(< "$template")
    
    # Substitution 
    local output_data="$input_data"
    # NOTE: The '!' does not represent indirect expantion here 
    # I dont think it evan works with arrays, It is just for looping through 
    # the keys. The indirect expantion has already been handled by 'local -n'
    for key in "${!array[@]}" ; do 
        local placeholder="{$key}"
        local value="${array[$key]}"
        output_data="${output_data//"$placeholder"/"$value"}" 
    done

    # Writing
    check_parent "$temp_file"
    printf "%s" "$output_data" 1> "$temp_file" 2> >(debug) || \
        fatal "Failed to write to file while replacing placeholders: exiting.."
    
    # Moving
    check_parent "$output"
    mv "$temp_file" "$output" 1> >(debug) 2>&1 || \
        fatal "Failed to move temp_file: exiting.."
    log "Template ${1##*/} done.." 
}
update_pywal_colors() {
    local _database_file="$1"
    local _temp_file="$2"

    declare -a _arr_pywal
    log "Parsing pywal colors.."
    eval "$( parse_pywal_color "_arr_pywal" )"

    local _database_data
    _database_data="$(jq -r '.' "$_database_file" 2> >(debug) \
        || fail "Failed to parse $_database_file : Skipping..")"
    
    for idx in {0..15} ; do
        _database_data="$( jq -r --arg _idx "$idx" \
            --arg _col "${_arr_pywal[$idx]}"\
            '."Dynamic"."placeholders".[$_idx] = $_col' \
            <<< "$_database_data" 2> >(debug) \
            || fail "Failed to generate pywal colors: Skipping..")"
    done

    check_parent "$_temp_file"
    printf "%s" "$_database_data" > "$_temp_file"  2> >(debug) || \
        fatal "Internal error: exiting.."
    check_parent "$_database_file" 
    mv "$_temp_file" "$_database_file" 2> >(debug) || \
        fail "Failed to update $_database_file : Skipping.."
}
fetch_themes(){
    local _database_file="$1"
    printf "%s" "$( jq -r '. | to_entries[] | "\(.key)"' "$_database_file" \
        2> >(debug) || fatal "Failed to parse available themes: exiting..")"
}
# ------------------------
# Dynamic 
# ------------------------
pywal (){
    [[ -z "$WALLPAPER" ]] && return 1
    
    wal -c -n -q -s -t -e -i "$WALLPAPER" &> >(debug) \
        || fatal "Failed to launch pywal: exiting.."
}
wpgtk () {
    wpg -n --noterminal --noreload -a "${WALLPAPER}" &> >(debug) \
    || fatal "Failed to launch wpg: exiting.."
    wpg -n --noterminal --noreload -s "${WALLPAPER##*/}" &> >(debug) \
    || fatal "Failed to launch wpg: exiting.."
    wpg -n --noterminal --noreload -d "${WALLPAPER##*/}" &> >(debug) \
    || fatal "Failed to launch wpg: exiting.."
}
generate_blurred_wallpaper() {
    local _resolution="1980x1080"
    local _blur="0x35"
    local _output="${TP}/Theme/assets/blured_wall.png"
    magick "${WALLPAPER}[0]" -resize  "$_resolution" -blur "$_blur" "$_output" \
        2> >(debug) || fatal "Failed to generate blurred wallpaper: exiting.."
}
# ------------------------
# modules
# ------------------------
reload_modules() {
    # non fatal 
    killall -INT dunst waybar &> >(debug) || true
    dunst -conf "${TP}/Theme/dunstrc" &> >(debug) &
    GTK_THEME=Adwaita waybar \
        -c "${TP}/Theme/waybar/config-niri.jsonc" \
        -s "${TP}/Theme/waybar/style-niri.css" \
        1> /dev/null 2> >(debug) &

    
    "${TP}/Theme/gowall/gowall.sh" > >(debug) 2>&1 || \
        fail "Failed to generate fastfetch icons: skipping.."

    dunstify -I "${TP}/Theme/icons/icon.png" "$THEME" &> >(debug)

    # Generating blured_wall takes the most amount of time in this script
    # Keep it at last..
    # ------------------------------------------------------------------
    generate_blurred_wallpaper
    swaybg -i "${TP}/Theme/assets/blured_wall.png" \
        1> /dev/null 2> >(debug) &
    # ------------------------------------------------------------------   
} 
# -------------------------------
# Thumbnails
# -------------------------------

NEXT_THUMBNAIL=''

generate_thumbnail() {
    local _file="$1"

    local _file_extension=''
    local _output=''
    local _thumbnail_name="${_file//"/"/"."}"
    local _thumbnail_file="${THUMBNAIL_DIR}/[Thumbnail]${_thumbnail_name}.jpg"

    _file_extension="${_file##*.}"

    check_parent "${THUMBNAIL_DIR}/testfile"

    if [[ "$_file_extension" == *(mp4|mkv) ]]; then
        if ! [[ -f "$_thumbnail_file" ]] ; then
            if ffmpegthumbnailer -i "$_file" -s 256 \
                -o "$_thumbnail_file" \
                &> >(debug) ; then
                _output="$_thumbnail_file"
            else
                fail "Failed to generate thumbnail: Skipping.."
                _output=""
            fi
        else 
            _output="$_thumbnail_file"
        fi
    else
        if ! [[ -f "$_thumbnail_file" ]] ; then 
            if ffmpegthumbnailer -i "$_file" \
                -s 265 -o "$_thumbnail_file" \
                &> >(debug) ; then

                _output="$_thumbnail_file"
            else
                fail "Failed to generate thumbnail: Skipping.."
                _output=""
            fi
        else
            _output="$_thumbnail_file"
        fi
    fi
    NEXT_THUMBNAIL="$_output"
}
# }}}

# Misc {{{
# This cant be at the top as it needs the fetch_themes() func
print_list() {
    fetch_themes "$DATABASE_FILE"
}
# }}}

# GUI Helpers {{{

theme_switcher(){
   log "Launching theme switcher.." 
    local -a _themes
    # Tip: The IFS variable sets word splitting and tralling and leading 
    # char stripping but does not set the delimiter, read still stops reading
    # after a newline for that use read -d ; Here we use IFS= to unset the IFS
    # variables so that read does not strip any spaces, just a safe thing...
    while IFS= read -r _line ; do _themes+=("$_line") ; done \
        <<< "$( fetch_themes "$DATABASE_FILE" )"
    local rofi_menu=''

    for theme in "${_themes[@]}" ; do
        local _icon_prefix="${ROFI_THEME_SWITCHER_ICON_DIR}/${theme}"
        # I have to treat this as a array cause shellcheck thinks it 
        # can expand into multiple files which it wont cause of @() 
        # ext glob syntax, so this is just to shut up shellcheck
        local _icon=( "${_icon_prefix}".@(png|jpeg|jpg) )

        [[ -z "${_icon[0]}" ]] && fail "No icon found for theme: $theme"

        rofi_menu+="${theme}\0icon\x1f${_icon[0]}\n"
    done
    
    local _current_wallpaper=''
    local _current_theme=''
    
    _current_theme="$( fetch_current_theme )"
    _current_wallpaper="$( fetch_current_wallpaper )"

    THEME=$(printf  "%b" "$rofi_menu" | rofi -dmenu \
        -p "[${_current_theme}] ${_current_wallpaper##*/} " \
        -config "$ROFI_THEME_SWITCHER_CONF" 2> >(debug) \
        || fatal "Failed to select theme: exiting..")

}
wallpaper_switcher (){
    log "Launching wallpaper switcher.."
    # This is a wallpaper selector script made with rofi
    # Some of the stuff dont do anything and just here for future use
    # Like the surrent wallpaper part, My rofi menu has text disabled so
    # It makes Zero diff in the layout 

    local _theme="$1"

    local _wallpaper_files=''
    local _rofi_menu=''
    local _selected_wallpaper=''
    local _selected_wallpaper_name=''
    local _selected_wallpaper_extension=''
    local _icon=''

    _wallpaper_files="$( printf "%s\n" \
        "$WALLPAPER_ROOT"/**/*(*.png|*.jpg|*.jpeg|*.gif|*.mp4|*.mkv) )"
    if [[ -n "$_theme" && "$_theme" != "Dynamic" ]] ; then 
        _wallpaper_files="$( printf "%s\n" \
            "$WALLPAPER_ROOT/$_theme"/**/*(*.png|*.jpg|*.jpeg|*.gif|*.mp4|*.mkv))"
    fi
    
    WALLPAPER="$(fetch_current_wallpaper)"

    while IFS= read -r _wallpaper_path; do
        local _wallpaper_name=''

        _wallpaper_name="${_wallpaper_path#"${WALLPAPER_ROOT}/"}"
        
        generate_thumbnail "$_wallpaper_path"

        if [[ "$_wallpaper_path" == "$WALLPAPER" ]]; then
          _rofi_menu+="${_wallpaper_name} (current)\0icon\x1f${NEXT_THUMBNAIL}\n"
        else
          _rofi_menu+="${_wallpaper_name}\0icon\x1f${NEXT_THUMBNAIL}\n"
        fi
    done <<<"$_wallpaper_files"

    _selected_wallpaper=$(printf "%b" "$_rofi_menu" | rofi -dmenu \
        -config "$ROFI_WALLPAPER_SWITCHER_CONF" 2> >(debug) \
        || fatal "Failed to select wallpaper: exiting..")

    _selected_wallpaper_name=${_selected_wallpaper//" (current)"/""}

    _selected_wallpaper_extension=${_selected_wallpaper_name##*.}

    if [[ -n "$_selected_wallpaper_name" ]]; then
        pidof mpvpaper &> >(debug) && \
            killall -INT mpvpaper &> >(debug)
        # ---------------------------
        if [[ "$_selected_wallpaper_extension" == *(mp4|mkv) ]] ; then
            # -------------------------------
            if pidof swww-daemon &> >(debug) ; then
                killall -INT swww-daemon
            fi
            mpvpaper "$DISPLAY" \
            -o "no-audio --loop-playlist" \
            "$WALLPAPER_ROOT/$_selected_wallpaper_name" &> >(debug) \
            || fail "Failed to launch mpvpaper: skipping.." &
            WALLPAPER_BACKEND="mpvpaper"
            # -------------------------------
        else
            # -------------------------------
            if ! pidof swww-daemon &> >(debug) ; then
                swww-daemon &> >(debug) || \
                    fatal "Failed to launch swww daemon: exiting.." & 
            fi
            swww img "$WALLPAPER_ROOT/$_selected_wallpaper_name" \
                --transition-type wipe \
                --transition-angle 315  \
                --transition-step 90 \
                --transition-duration 1 \
                --transition-fps 60 \
                || fatal "Failed to launch swww: exiting.."
            WALLPAPER_BACKEND="swww"
            # -------------------------------
        fi
        # ---------------------------

        WALLPAPER="$WALLPAPER_ROOT/$_selected_wallpaper_name"
    else
        exit 0
    fi
}
# }}}

# Parsing Args {{{

PARSED_OPTS=$( getopt -o hdlt:c \
    --long "help,debug,list,theme,clean" \
    -n 'switcheroo.sh' \
    -- "$@" ) \
    || fatal "Failed to parse options" 

eval set -- "$PARSED_OPTS"

while true; do
    case "$1" in
        -h | --help) print_help ; exit 0 ;;
        -d | --debug) DEBUG=true ; shift ;;
        -l | --list) print_list ; exit 0 ;;
        -t | --theme) THEME="$2" ; shift 2 ;;
        -c | --clean) rm -r "$THUMBNAIL_DIR" &> >(debug) ; \
            log "Cleaned the thumbnail cache..." ; exit 0 ;;
        --) shift ; break ;;
        *) fatal "Internal error" ;;
    esac
done

if [[ -n "$*" ]] ; then # check for unwanted remaining non-option args after {--}
    fatal "Arguments not supported: $*"
fi


# }}}

# Main {{{

apply_theme(){
    
    # A wrapper for applying every part of the theme 
    # Heavily depends on a lot of function so not portable :(
    
    # Parameters:
    # --------------------
    local _theme_name="$1"
    local _database_file="$2"
    local _config_file="$3"
    local _templates_dir="$4"
    local _theme_dir="$5"
    local _temp_file="$6"
    [[ "$#" -lt 6 ]] && fatal "Not enough Arguments: exiting.. "
    # --------------------

    # Parsing files
    # --------------------
    declare -A _templates_conf_arr
    declare -A _placeholders_arr_hex
    
    log "Parsing config.."
    eval "$( \
        config_objs_to_A_array \
        _templates_conf_arr "$_config_file" \
        )"
    log "Parsing placeholders.."
    eval "$( \
        placeholders_objs_to_A_array \
        "$_theme_name" \
        _placeholders_arr_hex \
        "$_database_file" \
        )"
    [[ "${#_templates_conf_arr[@]}" -eq 0 ]] \
        && fatal "Internal error: exiting.."
    [[ "${#_placeholders_arr_hex[@]}" -eq 0 ]] \
        && fatal "$_theme_name needs atleast one placeholder: exiting.."
    # --------------------

    # Generating files
    # --------------------
    for _template in "${!_templates_conf_arr[@]}" ; do 
        local -A _placeholders_arr_hex_local 
        for key in "${!_placeholders_arr_hex[@]}" ; do
            _placeholders_arr_hex_local[$key]="${_placeholders_arr_hex[$key]}"
        done

        local _config
        read -ra _config <<< "${_templates_conf_arr[$_template]}"
        local _dest="${_config[0]}"
        local _color_format="${_config[1]}"
        # Pound -> # 
        local _keep_pound="${_config[2]}"
       
        # Color Format specific helpers
        # Bash cant copy arrays so had to do this shit :.)
        # ----------------
        replacer_and_mover() {
            replace_placeholder_and_move "${_templates_dir}/${_template}" \
                 "$1" "${_theme_dir}/${_dest}" "$_temp_file"
        }
        replace_placeholder_and_move_hex(){
            replacer_and_mover _placeholders_arr_hex_local
        }
        replace_placeholder_and_move_rgb(){
            declare -A _placeholders_arr_rgb_local
            eval "$( hex_to_rgb_A_array _placeholders_arr_hex_local \
                _placeholders_arr_rgb_local )"

            replacer_and_mover _placeholders_arr_rgb_local
        }
        # Misc
        # ----------------
        strip_pound() {
            for key in "${!_placeholders_arr_hex_local[@]}" ; do
                local value="${_placeholders_arr_hex_local["$key"]#'#'}"
                _placeholders_arr_hex_local["$key"]="$value"
            done
        }
        # Pound check 
        # ----------------
        case "$_keep_pound" in
            "true") true ;;
            "false") strip_pound ;;
        esac
        # Color format check
        # ----------------
        case "$_color_format" in
            "hex") replace_placeholder_and_move_hex ;;
            "rgb") replace_placeholder_and_move_rgb ;;
        esac
    done
    # --------------------
    
    # GTK
    # --------------------
    log "Parsing gtk-theme.."
    local _gtk_theme
    local _gtk_icon_
    local _font_name
    local _font_size
    _gtk_theme="$( fetch_gtk_theme "$_theme_name" "$_database_file" )"
    _gtk_icon_theme="$( fetch_gtk_icon_theme "$_theme_name" "$_database_file" )"
    _font_name="$( fetch_gtk_font "$_theme_name" "$_database_file" )"
    _font_size="$( fetch_gtk_font_size "$_theme_name" "$_database_file" )"
   
    apply_gtk_theme "$_gtk_theme" "$_gtk_icon_theme" "$_font_name" "$_font_size"
    apply_gtk_theme_flatpak "$_gtk_theme" "$_gtk_icon_theme" \
        "$_font_name" "$_font_size"

    # Vim and Vim airline
    # ----------------------------
    log "Parsing vim theme.."
    local _vim_theme
    _vim_theme="$( fetch_vim_colorscheme "$_theme_name" "$_database_file" )"
    log "Parsing vim airline theme.."
    local _vim_airline_theme
    _vim_airline_theme="$( fetch_vim_airline_colorscheme \
        "$_theme_name" "$_database_file" )"

    apply_vim_theme "$_vim_theme" "$TEMP_FILE"
    apply_vim_airline_theme "$_vim_airline_theme" "$TEMP_FILE"
}

main(){
    [[ -z "$THEME" ]] && \
        theme_switcher
    if [[ -n "$THEME" ]] ; then
        wallpaper_switcher "$THEME"
        write_cache "$THEME" "$WALLPAPER" "$WALLPAPER_BACKEND"
        pywal
        wpgtk
        update_pywal_colors "$DATABASE_FILE" "$TEMP_FILE" 
        apply_theme "$THEME" "$DATABASE_FILE" "$CONFIG_FILE" \
        "$TEMPLATES_DIR" "$THEME_DIR" "$TEMP_FILE"
        reload_modules
    fi
}
main
# }}}
