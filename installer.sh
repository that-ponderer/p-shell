#!/usr/bin/bash

Hard_Deps=(
    "python-pywal"
    "imagemagick"
    "wpgtk"
    "swww"
    "glib2"
    "python"
    "zsh"
    "bash"
    "waypaper"
    "dunst"
    "libnotify"
    "catppuccin-gtk-theme-mocha"
    "gruvbox-dark-gtk"
    "bibata-cursor-theme"
    "nordic-theme"
    "polkit-gnome"
    "unzip"
        )
Opt_Deps=(
    "cava"
    "clipcat"
    "gowall"
    "kitty"
    "mpd"
    "niri"
    "xwayland-satellite"
    "xdg-desktop-portal-gnome"
    "xdg-desktop-portal-gtk"
    "rmpc"
    "qutebrowser"
    "rofi"
    "swaylock"
    "waybar"
    "wofi"
    "yazi"
    "mediainfo"
    "fastfetch"
    "networkmanager"
    "gvfs-mtp"
    "network-manager-applet"
    "swaybg"
    "swayidle"
    "openssh"
    "gpu-screen-recorder"
    "rofimoji"
    "grim"
    "slurp"
    "wl-clipboard"
    "bat"
    "chromium"
    "bluetuith"
    "fzf"
    "zoxide"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
        )

export Cache="$HOME/.cache/p-shell"
[[ -d "${Cache}" ]] && \
echo "Cache Exists: Removing -> ${Cache}" && \
rm -rf "$Cache"
mkdir -p "${Cache}"
export Aur_Helper=""
export Current_dir="$(pwd)"

install_omp(){
    echo "Installing oh-my-posh..."
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s || \
    echo "Could not Install oh-my-posh. Skipping..."
}
install_wpgtk(){
    echo "Installing wpgtk Templates.."
    /usr/bin/wpg-install.sh -gG || \
    echo "Could not Install wpgtk Templates. Skipping..."
}
install_aur_helper(){
    local helpers=("yay" "paru")
    for i in "${helpers[@]}" ; do
        if command -v "${i}" &> /dev/null ; then
            echo "found ${i}"
            Aur_Helper="${i}"
            break
        fi
    done
    [[ -z ${Aur_Helper} ]] && echo "yay or paru Not Found..."
    local choice
    while [[ -z ${Aur_Helper} ]] ; do
        read -p "Select One to Install: (0:yay 1:paru) : " choice
        if [[ "${choice}" == "0" ]] ; then
            Aur_Helper="yay"
            echo Installing yay...
            sudo pacman -S --needed git base-devel
            git clone https://aur.archlinux.org/yay.git "${Cache}/yay" || \
            { echo "Installation Failed..." ; exit 1 ; }
            cd "${Cache}/yay" || exit 1
            makepkg -si --noconfirm
            break
        fi
        if [[ "${choice}" == "1" ]] ; then
            Aur_Helper="paru"
            echo Installing paru...
            sudo pacman -S --needed git base-devel
            git clone https://aur.archlinux.org/paru.git "${Cache}/paru" || \
            {  echo "Installation Failed..." ; exit 1 ; }
            cd "${Cache}/paru" || exit 1
            makepkg -si --noconfirm
            break
        fi
        echo "You Have to Choose A Number.."
    done
    cd "${Current_dir}"
}

Total_Deps=()

remove_unwanted_opt_deps(){
    echo "----------------------"
    echo "Optional Dependencies:"
    echo "----------------------"
    local counter=0
    for i in "${Opt_Deps[@]}" ; do 
        echo "[${counter}] ${i}" 
        counter=$((counter + 1))
    done
    echo    "----------------------------------------------------"
    read -p "Enter Space Separated nums To Exclude Dependencies: " -a choice
    echo    "----------------------------------------------------"
    for i in "${!Opt_Deps[@]}" ; do 
       local skip=false
       for j in "${choice[@]}" ; do 
           [[ "${i}" == "${j}" ]] && skip=true
       done
       ! $skip && Total_Deps+=(${Opt_Deps[i]})
    done 
}

Install_Paks(){
    local -n final_paks=$1
    $Aur_Helper -Suy --needed --noconfirm ${final_paks[@]} || \
    {
        echo "Aur Helper Failed...:("
        echo "----------------------"
        echo "exiting......"
        sleep 3
        exit 1
     }
}
Move_files() {
    local theme_path="$HOME/Theme/p-shell"
    local backup_path="$HOME/Theme/p-shell-bak"

    if [[ -d "$theme_path" ]]; then
        echo "P-Shell Dir Exists..."
        echo "Making Backup -> $backup_path"

        rm -rf "$backup_path" || return 1
        cp -r "$theme_path" "$backup_path" || return 1
        rm -rf "$theme_path" || return 1
    fi

    if [[ ! -d "$HOME/Theme" ]]; then
        mkdir -p "$HOME/Theme" || return 1
    else
        echo "$HOME/Theme Already Exists, Skipping Creation..."
    fi

    cp -r "p-shell" "$theme_path" || return 1
}

Move_Waypaper_Config(){
    local waypaper_path="${HOME}/.config/waypaper"
    local waypaper_path_bak="${HOME}/.config/waypaper_bak"
    if [[ -d "$waypaper_path" ]] ; then
        echo "Waypaper Config Exists: -> $waypaper_path" 
        echo "Making Backup: -> $waypaper_path_bak"
        rm -rf "$waypaper_path_bak"
        cp -r "$waypaper_path" "$waypaper_path_bak"
        rm -rf "$waypaper_path"
    fi
    cp -r "config-overrides/waypaper" "$waypaper_path"
}

Move_Wpg_Config(){
    local wpg_path="${HOME}/.config/wpg"
    local wpg_path_bak="${HOME}/.config/wpg_bak"
    if [[ -d "$wpg_path" ]] ; then
        echo "Waypaper Config Exists: -> $wpg_path" 
        echo "Making Backup: -> $wpg_path_bak"
        rm -rf "$wpg_path_bak"
        cp -r "$wpg_path" "$wpg_path_bak"
        rm -rf "$wpg_path"
    fi
    cp -r "config-overrides/wpg" "$wpg_path"
}
Move_Fonts(){
    fonts_path="${HOME}/.local/share/fonts"
    echo "Moving Fonts to: -> $fonts_path"
    cp -rn "fonts" "$fonts_path"
}
Change_Shell(){
    echo "----------------------------"
    echo "Changing Shell is Required: "
    chsh -s /usr/bin/zsh
}

Move_zshenv(){
    echo    "-------------------------------------"
    read -p "Install zshenv and Make Backup: [y/n]" choice
    [[ "$choice" =~ ^[yY]$  ]] && cp "zshenv" "${HOME}/.zshenv"
    [[ "$choice" == "" ]] && cp "zshenv" "${HOME}/.zshenv"
}
Make_some_dir(){
    mkdir -p "$Current_dir/p-shell/Theme/assets"
    mkdir -p "$Current_dir/p-shell/Theme/clipcat"
}
Install_clipcat(){
    local clipcat_dir="$Current_dir/p-shell/Theme/clipcat"
    clipcatd default-config      > "$clipcat_dir/clipcatd.toml"
    clipcatctl default-config    > "$clipcat_dir/clipcatctl.toml"
    clipcat-menu default-config  > "$clipcat_dir/clipcat-menu.toml"
}
install_aur_helper
for i in "${Hard_Deps[@]}" ; do
    Total_Deps+=("${i}")
done
remove_unwanted_opt_deps
Install_Paks Total_Deps
install_wpgtk
install_omp
Make_some_dir
Install_clipcat
Move_files
Move_Waypaper_Config
Move_Wpg_Config
Move_Fonts
Change_Shell
Move_zshenv
rm -rf "$Cache"
