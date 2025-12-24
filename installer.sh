#!/usr/bin/bash

######################################
# Globals & Config
######################################

HARD_DEPS=(
    python-pywal imagemagick wpgtk swww glib2 python
    zsh bash waypaper dunst libnotify
    catppuccin-gtk-theme-mocha gruvbox-dark-gtk
    bibata-cursor-theme nordic-theme polkit-gnome
    unzip
)

OPT_DEPS=(
    cava clipcat gowall kitty mpd niri xwayland-satellite
    xdg-desktop-portal-gnome xdg-desktop-portal-gtk
    rmpc qutebrowser rofi swaylock waybar wofi yazi
    mediainfo fastfetch networkmanager gvfs-mtp
    network-manager-applet swaybg swayidle openssh
    gpu-screen-recorder rofimoji grim slurp wl-clipboard
    bat chromium bluetuith fzf zoxide
    zsh-autosuggestions zsh-syntax-highlighting
)

CACHE_DIR="$HOME/.cache/p-shell"
CURRENT_DIR="$(pwd)"
AUR_HELPER=""

######################################
# Helpers
######################################

log() {
    echo "[installer] $*"
}

fail() {
    echo "[error] $*" >&2
    return 1
}

######################################
# Cache Setup
######################################

setup_cache() {
    if [[ -d "$CACHE_DIR" ]]; then
        log "Removing old cache: $CACHE_DIR"
        rm -rf "$CACHE_DIR" || return 1
    fi
    mkdir -p "$CACHE_DIR" || return 1
}

######################################
# AUR Helper
######################################

detect_or_install_aur_helper() {
    for helper in yay paru; do
        if command -v "$helper" &>/dev/null; then
            AUR_HELPER="$helper"
            log "Using AUR helper: $AUR_HELPER"
            return 0
        fi
    done

    log "No AUR helper found."
    select choice in yay paru; do
        [[ -z "$choice" ]] && continue
        AUR_HELPER="$choice"
        sudo pacman -S --needed git base-devel || return 1
        git clone "https://aur.archlinux.org/$choice.git" "$CACHE_DIR/$choice" || return 1
        cd "$CACHE_DIR/$choice" || return 1
        makepkg -si --noconfirm || return 1
        cd "$CURRENT_DIR" || return 1
        break
    done
}

######################################
# Dependencies
######################################

select_optional_deps() {
    log "Optional dependencies:"
    for i in "${!OPT_DEPS[@]}"; do
        echo "[$i] ${OPT_DEPS[i]}"
    done

    read -rp "Enter numbers to EXCLUDE (space-separated): " -a exclude

    FINAL_DEPS=("${HARD_DEPS[@]}")
    for i in "${!OPT_DEPS[@]}"; do
        skip=false
        for j in "${exclude[@]}"; do
            [[ "$i" == "$j" ]] && skip=true
        done
        ! $skip && FINAL_DEPS+=("${OPT_DEPS[i]}")
    done
}

install_packages() {
    log "Installing packages..."
    "$AUR_HELPER" -Suy --needed --noconfirm "${FINAL_DEPS[@]}" || fail "Package install failed"
}

######################################
# Installers
######################################

install_oh_my_posh() {
    log "Installing oh-my-posh"
    curl -fsSL https://ohmyposh.dev/install.sh | bash || log "Skipped oh-my-posh"
}

install_wpgtk_templates() {
    log "Installing wpgtk templates"
    mkdir -p "$HOME/.config/wpg/templates"
    /usr/bin/wpg-install.sh -G || log "Skipped wpgtk templates"
}

######################################
# File Operations
######################################

backup_and_copy() {
    local src="$1"
    local dest="$2"

    if [[ -d "$dest" ]]; then
        log "Backing up $dest → ${dest}_bak"
        rm -rf "${dest}_bak"
        cp -r "$dest" "${dest}_bak" || return 1
        rm -rf "$dest"
    fi

    cp -r "$src" "$dest"
}
backup_and_copy_file() {
    local src="$1"
    local dest="$2"

    if [[ -f "$dest" ]]; then
        log "Backing up $dest → ${dest}.bak"
        rm -f "${dest}.bak"
        cp "$dest" "${dest}.bak" || return 1
        rm -f "$dest"
    fi

    cp "$src" "$dest"
}

move_project_files() {
    mkdir -p "$HOME/Theme"
    backup_and_copy "p-shell" "$HOME/Theme/p-shell"
}

move_waypaper_config() {
    backup_and_copy "config-overrides/waypaper" "$HOME/.config/waypaper"
}

move_wpg_config() {
    backup_and_copy "config-overrides/wpg" "$HOME/.config/wpg"
}

move_fonts() {
    log "Installing fonts"
    mkdir -p "$HOME/.local/share/fonts"
    cp -rn fonts "$HOME/.local/share/fonts"
}

######################################
# Zsh
######################################

change_shell() {
    log "Changing default shell to zsh"
    chsh -s /usr/bin/zsh
}

install_zshenv() {
    read -rp "Install .zshenv? [Y/n] " choice
    [[ "$choice" =~ ^[nN]$ ]] && return
    backup_and_copy_file zshenv "$HOME/.zshenv" 
}

######################################
# App Setup
######################################

setup_dirs() {
    mkdir -p p-shell/Theme/{clipcat,mpd/playlists}
}

setup_clipcat() {
    local dir="p-shell/Theme/clipcat"
    clipcatd default-config     > "$dir/clipcatd.toml"
    clipcatctl default-config   > "$dir/clipcatctl.toml"
    clipcat-menu default-config > "$dir/clipcat-menu.toml"
}

######################################
# Main
######################################

main() {
    setup_cache || return 1
    detect_or_install_aur_helper || return 1
    select_optional_deps
    install_packages
    install_oh_my_posh
    setup_dirs
    setup_clipcat
    move_project_files
    move_waypaper_config
    move_wpg_config
    install_wpgtk_templates
    move_fonts
    change_shell
    install_zshenv
    rm -rf "$CACHE_DIR"
    log "Installation complete."
}

main

