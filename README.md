<p align="center"><img  width="100" alt="Mob_logo1_Cat" src="https://github.com/user-attachments/assets/42d05b09-635f-4024-b98f-94565975354c" /></p>
<h1 align="center">P-Shell</h1>

<p align="center">A Ponderer's Shell</p>

<div style="display: flex; justify-content: center; gap: 10px;">
<img width=48% height=auto alt="2026-05-09_23-23-42_grim" src="https://github.com/user-attachments/assets/9455d04a-7aeb-4698-850d-5aad3c8e4518" />
<img width=48% height=auto alt="2026-05-09_23-28-13_grim" src="https://github.com/user-attachments/assets/4971f2cb-c7f4-47be-97b0-a8b01fafc240" />
</div>

# About:

🥪 These Are My Personal Suckless Dotfiles Intended To Be As Minimal As Possible While Also Looking Edible. 
- 🐧 **Arch/Artix** based btw :)
- 🎨 **Switchable themes** with keyboard shortcuts.  
- 🩷 **Dynamic color integration** using Pywal16.
- 💜 **GTK theme gen** using colloid gtk themes.  
- 🪟 Built on **Niri** for maximum minimalism.

> [!IMPORTANT]
> Expect a few bugs. While I try to keep it as modular as possible, it’s still 
> based heavily on my personal use.

# TODO:

- 📝 Include my **vim** config. ✅
- 🗣️ Add OSD with **swayosd** 
- 📚 Add Dictionary Lookup
- 🔎 Add OCR/Text Extractor ✅ 

# Features:
- Wayland Compositor `niri`
- Bar `eww` and `waybar`
- Lockscreen `swaylock`
- Browser `qutebrowser`
- Fetcher `fastfetch` + `gowall`
- File Browser `yazi` (tested on v26.1.22)
- Background `swww` & `swaybg` + `gowall`
- Background Picker `waypaper`
- Screenshot `grim` + `slurp`
- Screenrecord `gpu-screen-recorder` + `slurp`
- Music Player `rmpc` ( <= v0.10.0 )
- Audio Visualizer `cava`
- Terminal `kitty`
- Drun `rofi`
- Emoji Picker `rofimoji` + `rofi`
- Clipboard Manager `clipcat` + `rofi`
- Notification Manager `dunst`
- OCR `tesserect`
- Editor `neovim`
- support for `whisper.cpp`
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
