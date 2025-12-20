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
    "ttf-jetbrains-mono-nerd"
    "ttf-nerd-fonts-symbols"
    "otf-departure-mono"
    "catppuccin-gtk-theme-mocha"
    "gruvbox-dark-gtk"
    "nordic-theme"
    "polkit-gnome"
        )
Opt_Deps=(
    "cava"
    "clipcat"
    "dunst"
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
    "fastfetch"
    "network-manager-applet"
    "swaybg"
    "swayidle"
    "ssh"
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
rm -rf "${Cache}"
mkdir -p "${Cache}"
export Aur_Helper="yay"

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
            makepkg -si
            break
        fi
        if [[ "${choice}" == "1" ]] ; then
            Aur_Helper="paru"
            echo Installing paru...
            sudo pacman -S --needed git base-devel
            git clone https://aur.archlinux.org/paru.git "${Cache}/paru" || \
            {  echo "Installation Failed..." ; exit 1 ; }
            cd "${Cache}/paru" || exit 1
            makepkg -si 
            break
        fi
        echo "You Have to Choose A Number.."
    done
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
    $Aur_Helper -Suy --needed --noconfirm ${final_paks} || \
    {
        echo "Aur Helper Failed...:("
        echo "----------------------"
        echo "exiting......"
        sleep 3
        exit 1
     }
}
