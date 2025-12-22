import toml 
import subprocess
import os


def Parse_Clipcat_Toml(ThemePath:str):
    Clipcat_menu_path=os.path.join(ThemePath,
        "Theme/clipcat/clipcat-menu.toml"
    )
    clipcat_menu_data = toml.load(Clipcat_menu_path)
    clipcat_menu_data["rofi"]["extra_arguments"] = [
        "-config",
        os.path.join(ThemePath, "Theme/rofi/config.rasi"),
    ]
    with open(Clipcat_menu_path,"w") as f:
        toml.dump(clipcat_menu_data,f)
        
def Gen_Blur_Wall(ThemePath,SWW_WALLPAPER):
    BLURED_WALL = os.path.join(ThemePath,
        "Theme/assets/blured_wall.png"
        )

    subprocess.run(
        f"""\
        magick  "{SWW_WALLPAPER}[0]"  \
        -resize 1920x1080 \
        -blur 0x35 \
        "{BLURED_WALL}"
        """,
        shell=True,
        capture_output=False
    )

