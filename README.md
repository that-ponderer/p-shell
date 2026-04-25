<p align="center"><img  width="100" alt="Mob_logo1_Cat" src="https://github.com/user-attachments/assets/42d05b09-635f-4024-b98f-94565975354c" /></p>
<h1 align="center">P-Shell</h1>

<p align="center">A Ponderer's Shell</p>

[groovy.webm](https://github.com/user-attachments/assets/739f8c46-8c41-465c-b829-a993c32666bd)

# About:

🥪 These Are My Personal Suckless Dotfiles Intended To Be As Minimal As Possible While Also Looking Edible. 
- 🐧 **Arch/Artix** based btw :)
- 🎨 **Switchable themes** with keyboard shortcuts.  
- 🩷 **Dynamic color integration** using Pywal.
- 💜 **GTK theme gen** using wpgtk.  
- 🪟 Built on **Niri** for maximum minimalism.

> [!IMPORTANT]
> Expect a few bugs. While I try to keep it as modular as possible, it’s still 
> based heavily on my personal use.

# TODO:

- 🔔 Replace **dunst** with swaync. 🚧
- 🥭 Add **mangowc** support.
- 📝 Include my **vim** config. ✅
- 🗣️ Add OSD with **swayosd** 
- 📚 Add Global Dictionary 
- 🔎 Add OCR/Text Extractor ✅ 

# Features:
- Wayland Compositor `niri`
- Bar `waybar`
- Lockscreen `swaylock`
- Browser `qutebrowser`
- Fetcher `fastfetch` + `gowall`
- File Browser `yazi` with plugins
- Background `swww` & `swaybg` + `gowall`
- Background Picker `waypaper`
- Screenshot `grim` + `slurp`
- Screenrecord `gpu-screen-recorder` + `slurp`
- Music Player `rmpc` ( <= v0.10.0 )
- Audio Visualizer `cava`
- Terminal `kitty`
- Prompt `oh-my-posh`
- Drun `rofi`
- Emoji Picker `rofimoji` + `rofi`
- Clipboard Manager `clipcat` + `rofi`
- Notification Manager `dunst`
- OCR `tesserect`
- Editor `vim` *Not the 'neo' kind*
# Installation:
```
# Clone the repo
git clone https://github.com/that-ponderer/p-shell.git

cd p-shell

# Run the installer
./installer.sh
```
---
> [!CAUTION]
> You will be asked to backup and replace your .zshenv file.
> if you would like to do that manually select `n` and add these lines to your .zshenv
> ```
> export ThemePath="${HOME}/Theme/p-shell"
> export ZDOTDIR="${ThemePath}/Theme/zsh"
> source ${ZDOTDIR}/.zshenv
> ```

---
