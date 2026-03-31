#!/usr/bin/env bash

shopt -s extglob nullglob

# Global vars ---------------------------------------------------------
if [[ -d $XDG_CACHE_HOME ]] ; then  cache_dir="$XDG_CACHE_HOME/p-shell"
else cache_dir="$HOME/.cache/p-shell" ; fi
current_dir="$(pwd)"
total_deps=()

# Arch vars -----
aur_helper=""

# package db  {{{
declare -A deps_arch=(
    ["hard"]="
    python-pywal,
    imagemagick, 
    wpgtk, 
    swww, 
    glib2, 
    zsh, 
    bash, 
    dunst, 
    libnotify,
    bibata-cursor-theme, 
    polkit-gnome,
    gtk-engine-murrine, 
    jq,
    mpvpaper,
    ffmpegthumbnailer,
    "
    ["soft"]="
    cava: Colorful real-time audio visualizer,
    clipcat: Lightweight clipboard manager with history support,
    gowall: Generates color schemes from images for theming,
    kitty: GPU accelerated terminal with image and graphics protocol support,
    mpd: Minimal flexible music player daemon,
    niri: Scrollable tiling Wayland compositor window manager,
    xwayland-satellite: Standalone Xwayland bridge used by Niri,
    xdg-desktop-portal-gnome: GNOME backend for XDG portals for screenshare and file pickers,
    xdg-desktop-portal-gtk: GTK based fallback XDG portal implementation,
    rmpc: Elegant TUI client for MPD,
    qutebrowser: Keyboard driven minimal browser with Vim like bindings,
    rofi: Application launcher and dmenu replacement with scripting support,
    swaylock: Secure screen locker for Wayland compositors,
    waybar: Highly customizable Wayland status bar,
    yazi: Fast TUI file manager with async operations and plugins,
    fastfetch: System information tool alternative to neofetch,
    swaybg: Simple wallpaper setter for Wayland used for static backgrounds,
    swayidle: Idle management daemon for Wayland triggers lock and sleep,
    gpu-screen-recorder: Lightweight GPU accelerated screen recorder,
    rofimoji: Emoji picker using rofi,
    grim: Screenshot tool for Wayland compositors,
    slurp: Interactive screen region selector used with grim,
    wl-clipboard: Wayland clipboard utilities wl copy and wl paste,
    bat: Cat clone with syntax highlighting and Git integration,
    fzf: Fuzzy finder for files commands and more,
    zoxide: Smarter cd command with frequency based navigation,
    zsh-autosuggestions: Fish like command suggestions for Zsh,
    zsh-syntax-highlighting: Syntax highlighting for Zsh command line,
    gvim: GUI version of Vim,
    nodejs: JavaScript runtime built on V8,
    npm: Node package manager,
    bluez: Official Linux Bluetooth protocol stack,
    bluez-utils: Command line tools for managing Bluetooth devices,
    overskride: Minimal Wayland friendly Bluetooth device manager,
    fd: Simple fast alternative to find,
    glow: Markdown renderer for the terminal,
    less: Terminal pager for viewing text files,
    flatpak: Sandbox based application distribution system,
    tesseract-data-eng: Tesseract language data for the english,
    tesseract: Command-line OCR (Optical Character Recognition) engine,
    numr: A text calculator for natural language expressions with a vim-style TUI,
    mediainfo: View tags for images and videos, 
    "
    ["installer"]="
    unzip, 
    git, 
    "
    )

# }}}

# Helpers {{{

# Colors --
c1='\e[31m'
c2='\e[32m'
c3='\e[33m'
c4='\e[34m'
c5='\e[35m'
c6='\e[36m'
c7='\e[37m'

trim() {
    local var="$1"
    trimmed="${var#"${var%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
}
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
is_command() {
    command -v "$@" &> /dev/null || \
        { log "$* not installed, Skipping resource creation.."
          return 1
        }
}
yn_choice() {
    printf "${c2}[choice] %s [y/n]:\e[0m" "$*"
    read -r choice
    [[ "$choice" == +(*n*|*N*) ]] && return 1
    return 0
}
print_welcome (){
    welcome_logo=(
        "██████╗       ███████╗██╗  ██╗███████╗██╗     ██╗"
        "██╔══██╗      ██╔════╝██║  ██║██╔════╝██║     ██║"
        "██████╔╝█████╗███████╗███████║█████╗  ██║     ██║"
        "██╔═══╝ ╚════╝╚════██║██╔══██║██╔══╝  ██║     ██║"
        "██║           ███████║██║  ██║███████╗███████╗███████╗"
        "╚═╝           ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝"
        )
    welcome_bar="$(printf "=%.0s" {1..54})"
    printf "${c6}%b\e[0m\n" "$welcome_bar"
    printf "${c4}%b\e[0m\n" "${welcome_logo[@]}"
    printf "${c6}%b\e[0m\n" "$welcome_bar"
    printf " %.0s" {1..18} 
    printf "${c2}%b\e[0m\n" "A Ponderer's Shell"
    printf "${c6}%b\e[0m\n" "$welcome_bar"
    for gfx in "█████╗" "╚════╝"; do
        for idx in {1..7}; do
            local _col="c${idx}"
            printf "%b%s  " "${!_col}" "$gfx"
        done
        printf "\n"
    done
    printf "%b# Welcome to p-shell....\e[0m\n" "${c7}"
    yn_choice "continue?" || exit 0
}
setup_cache() {
    if [[ -d "$cache_dir" ]]; then
        log "Removing old cache: $cache_dir"
        rm -rf "$cache_dir" || return 1
    fi
    mkdir -p "$cache_dir" || return 1
}
# }}} 

# Arch {{{
detect_or_install_aur_helper() {
    for helper in yay paru; do
        if command -v "$helper" &>/dev/null; then
            aur_helper="$helper"
            log "Using AUR helper: $aur_helper"
            return 0
        fi
    done
    log "No AUR helper found."
    select choice in yay paru; do
        [[ -z "$choice" ]] && continue
        aur_helper="$choice"
        sudo pacman -S --needed git base-devel || return 1
        git clone --depth 1 "https://aur.archlinux.org/$choice.git" \
            "$cache_dir/$choice" || return 1
        cd "$cache_dir/$choice" || return 1
        makepkg -si --noconfirm || return 1
        cd "$current_dir" || return 1
        break
    done
}

resolve_soft_deps() {
    printf "${c6}%b\e[0m\n" "$welcome_bar"
    log "Optional dependencies:"
    printf "${c6}%b\e[0m\n" "$welcome_bar"

    declare -a soft_deps
    declare -a soft_deps_docs
    declare -a hard_deps
    while IFS= read -d ',' -r pak ; do 
        trim "$pak"
        while IFS=':' read  -r _pak docs ; do 
            soft_deps+=( "$_pak" )
            soft_deps_docs+=( "$docs" )
        done <<< "$trimmed"
    done  <<< "${deps_arch[soft]}"
    while IFS= read -d ',' -r pak ; do 
        trim "$pak"
        hard_deps+=( "$trimmed" )
    done  <<< "${deps_arch[hard]}"
    while IFS= read -d ',' -r pak ; do 
        trim "$pak"
        hard_deps+=( "$trimmed" )
    done  <<< "${deps_arch[installer]}"

    for i in "${!soft_deps[@]}"; do
        printf "%b" "[$i] \
${soft_deps[i]}\
$( for ((j=0; j < 27 - (${#soft_deps[i]}+2+${#i}) ;j++)) ; do printf " " ; done  )\
${c2}${soft_deps_docs[i]}\e[0m\n"
    done
    printf "${c6}%b\e[0m\n" "$welcome_bar"
    log "Enter numbers to EXCLUDE (space-separated):"
    read -r -a exclude
    total_deps=("${hard_deps[@]}")
    for i in "${!soft_deps[@]}"; do
        skip=false
        for j in "${exclude[@]}"; do
            [[ "$i" == "$j" ]] && skip=true
        done
        ! $skip && total_deps+=("${soft_deps[i]}")
    done
}

install_packages() {
    [[ -z "$aur_helper" ]] && { fail "Could not find aur helper.." ; exit 1 ; }
    log "Installing packages..."
    "$aur_helper" -Suy --needed --noconfirm "${total_deps[@]}" || \
        { fail "Package install failed" ; exit 1 ; }
}

# }}}

# Installers {{{
install_wpgtk_templates() {
    is_command wpg || return 1
    log "Installing wpgtk templates..."
    mkdir -p "$HOME/.config/wpg/templates"
    /usr/bin/wpg-install.sh -Gi || log "Skipped wpgtk templates..."
}
install_vim_config() {
    is_command vim || return 1
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || \
    { fail "vim-plug could not be installed.." ; return 1 ; }

}
install_gtk_themes() {
    local themes=(
    "https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme.git"
    "https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git"
        )
    for idx in "${!themes[@]}" ; do
        git clone --depth=1  "${themes[$idx]}" "$cache_dir/gtk_theme_$idx" || \
            { fail "Failed to install gtk theme [${themes[$idx]}]: skipping.." \
                ; continue ; }
        cd "$cache_dir/gtk_theme_$idx/themes" \
            || { fail "failed to change directory.." ; continue  ; } 

        ./install.sh -c "dark" --tweaks "float" --tweaks "macos" \
            || { fail "Failed to install gtk theme: skipping.." ; continue  ; } 
        cd "$current_dir" || \
            { fatal "Failed to change directory.." ; }
    done
    
    # Nordic
    git clone --depth=1 "https://github.com/EliverLara/Nordic.git" \
        "$cache_dir/Nordic" || \
        { fail "Failed to install gtk theme [Nordic]: skipping.." ; }
    [[ -d "$HOME/.themes/Nordic" ]] && rm -rf "$HOME/.themes/Nordic"
    mv -f "$cache_dir/Nordic" "$HOME/.themes" || \
        { fail "Failed to move GTK theme [Nordic]: skipping.." ; }

}
install_flatpak(){
    log "Applying flatpak overrides.."
    is_command flatpak || { fail "flatpak not installed: skipping.." ; return 1 ; }
    flatpak override --user --filesystem="$HOME/.themes" &> /dev/null
    flatpak override --user --filesystem="$HOME/.icons" &> /dev/null
    flatpak override --user --filesystem="$HOME/.local/share/themes" &> /dev/null
    flatpak override --user --filesystem="$HOME/.local/share/icons" &> /dev/null
    flatpak override --user --filesystem="$HOME/.local/share/fonts" &> /dev/null
}
# }}}

# File Operations {{{
backup_and_copy() {
    local src="$1"
    local dest="$2"
    
    # This is so that we dont end up backing up the whole 
    # .config directory
    local src_dirname=${src##*/}
    local org_dir="${dest}/${src_dirname}"

    if [[ -d "$org_dir" ]]; then
        log "Backing up $org_dir → ${org_dir}_bak"
        rm -rf "${org_dir}_bak"
        mv "$org_dir" "${org_dir}_bak" || return 1
    fi
    mkdir -p "$dest"
    cp -r "$src" "$dest" || mv "${org_dir}_bak" "${dest}"
}
backup_and_copy_file() {
    local src="$1"
    local dest="$2"

    if [[ -f "$dest" ]]; then
        log "Backing up $dest → ${dest}.bak"
        rm -f "${dest}.bak" 
        mv "$dest" "${dest}.bak" || return 1
    fi
    mkdir -p "${dest%/*}"
    cp "$src" "$dest" || mv "${dest}.bak" "${dest}"
}
move_project_files() {
    mkdir -p "$HOME/Theme"
    backup_and_copy "p-shell" "$HOME/Theme"
}
move_wpg_config() {
    is_command wpg || return 1
    backup_and_copy "config-overrides/wpg" "$HOME/.config"
}
move_fonts() {
    log "Installing fonts"
    cp -rn fonts "$HOME/.local/share/fonts"
}
# }}}

# Zsh {{{
change_shell() {
    yn_choice "Change default shell to zsh?" || return 1
    log "Changing default shell to zsh"
    chsh -s /usr/bin/zsh
}

install_zshenv() {
    yn_choice "Install .zshenv?" || { log "Skipping .zshenv..." ; return 1 ; }
    backup_and_copy_file zshenv "$HOME/.zshenv"
}
# }}}

# Manual Interventions {{{
setup_dirs() {
    mkdir -p p-shell/Theme/{clipcat,mpd/playlists}
}
setup_clipcat() { 
    is_command clipcatd || return 1
    local dir="p-shell/Theme/clipcat"
    mkdir -p "$dir" || return 1
    clipcatd default-config     > "$dir/clipcatd.toml" || return 1 
    clipcatctl default-config   > "$dir/clipcatctl.toml" || return 1
    clipcat-menu default-config > "$dir/clipcat-menu.toml" || return 1
    local data
    data="$(< "$dir/clipcat-menu.toml")"
    [[ -z "$data" ]] && return 1
    local output
    output="${data/"extra_arguments = []"/"extra_arguments = [ \"-config\", \"$HOME/Theme/p-shell/Theme/rofi/config.rasi\" ]"}"
    printf "%b" "$output" > "$cache_dir/temp" || return 1
    mv "$cache_dir/temp" "$dir/clipcat-menu.toml"
}
setup_mpd() { 
    is_command mpd || return 1
    local mpd_conf="p-shell/Theme/mpd/mpd.conf"
    local data
    data="$(< "$mpd_conf")"
    [[ -z "$data" ]] && return 1
    local output
    output="${data//"{ThemePath}"/"${HOME}/Theme/p-shell"}"
    printf "%b" "$output" > "$cache_dir/temp" || return 1
    mv "$cache_dir/temp" "$mpd_conf"
}
# }}}

main() {
    print_welcome 
    setup_cache 
    detect_or_install_aur_helper || fatal "Could not install AUR helper.."
    resolve_soft_deps 
    install_packages 
    setup_dirs 
    setup_clipcat 
    setup_mpd 
    move_project_files 
    install_wpgtk_templates 
    move_wpg_config 
    install_vim_config 
    install_gtk_themes 
    install_flatpak 
    move_fonts 
    change_shell 
    install_zshenv 
    rm -rf "$cache_dir"
    log "Installation complete."
}
main


