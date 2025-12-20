import os
import subprocess
import re

def pywalcolgen(HOME:str,ThemePath:str) -> tuple[dict,str]:
    PYWAL_COLORS_PATH = ""
    VS_CODE_THEME_PYWAL = "Wal Bordered"
    WALLPAPER = ""
    WALLNAME = ""
    BLUR_WALL = ""

    # open that pywal color dump and grab the colors
    PYWAL_COLORS_PATH = os.path.join(HOME, ".cache/wal/colors")
    # grab the wallpaper from the output of swww query
    try:
        Str = (
            subprocess.run(
                ["swww query"],
                shell=True,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
            )
            .stdout.rstrip("\n")
        )
        SWW_WALLPAPER = re.search(r"image:\s*(/.+)$", Str).group(1)
    except:
        raise Exception("Can not query swww")
    WALLPAPER = SWW_WALLPAPER
    WALLNAME = WALLPAPER.split("/")[-1]
    
    # Generate colrs based on that wallpaper
    try:
        subprocess.run(
            [f"wal -n -s -i {SWW_WALLPAPER}"],
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
    except:
        raise IOError("pywall colors did not generate . :( Maybe you dont have pywal")
    try:
        subprocess.run(
            [f"wpg -a {SWW_WALLPAPER} &&  wpg -s {WALLNAME} && wpg -d {WALLNAME}"],
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
    except:
        raise IOError("wpgtk colors did not generate . :( Maybe you dont have pywal")

    # Generating a Blured Wallpaper
    BLUR_WALL = os.path.join(ThemePath,"Theme/assets/blured_wall.png")

    subprocess.run(
        [f'magick  "{SWW_WALLPAPER}[0]" -resize 1920x1080 -blur 0x35 "{BLUR_WALL}"'],shell=True,capture_output=False
    )

    GENERATED_COLORS = {}
    with open(PYWAL_COLORS_PATH, "r") as wal:
        count = 0
        for i in wal.readlines():
            GENERATED_COLORS.update({str(count): i.rstrip("\n")})
            count += 1
    ZSH_PYCOLOR = GENERATED_COLORS["8"]
    GENERATED_COLORS.update({"zsh": ZSH_PYCOLOR})
    GENERATED_COLORS_DICT = {
        "WAL": 
            {"colors": GENERATED_COLORS, 
            "vs-code-theme": VS_CODE_THEME_PYWAL, 
            "gtk-theme": "linea-nord-color"}
        } 
    return (
        GENERATED_COLORS_DICT,WALLPAPER
       )

