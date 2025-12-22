"""A friendly theme switcher that supports pywal"""

import os
import json
import subprocess
import argparse

import methods
import pywal
import misc


# -------------------- ARGUMENTS --------------------

def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="p-shell-switcher",
        description="Switch home-made themes"
    )

    parser.add_argument(
        "-t",
        "--theme",
        type=str,
        help="Choose a theme"
    )

    parser.add_argument(
        "--themes",
        action="store_true",
        help="Display available themes"
    )

    return parser.parse_args()


HOME = ""
ThemePath = ""
DEST_FILES_CONF = {} 
DATABASE = {} 
VS_CODE_PATH = ""
WALLPAPER = ""
SPECIAL_CASE = ["clipcat-menu","mpd"]

# Reletive File System and VS code Paths
try:
    ThemePath = os.environ["ThemePath"]
    HOME = os.environ["HOME"]
except KeyError:
    raise Exception("Env Vars not Found")

WORKING_DIR = ThemePath
TEMPLATES_DIR = os.path.join(WORKING_DIR, "Templates")
GENERATED_THEME_DIR = os.path.join(WORKING_DIR, "Theme")

with open(os.path.join(WORKING_DIR, "locations.json"), "r") as locations:
    location_data = json.load(locations)
    DEST_FILES_CONF = location_data["DEST_FILES_CONF"]
with open(os.path.join(WORKING_DIR, "database.json"), "r") as database:
    database_data = json.load(database)
    DATABASE = database_data

VS_CODE_PATH = os.path.join(HOME, ".config/Code - OSS/User/settings.json")

def vs_code_apply_theme(vs_code_path:str,theme_name:str):
    if not os.path.isfile(vs_code_path):
        print("vs code config not found: skiping...")
        return
    with open(vs_code_path, "r") as vs_code:
        data = json.load(vs_code)
    data["workbench.colorTheme"] = theme_name
    with open(VS_CODE_PATH, "w") as vs_code:
        json.dump(data, vs_code, indent=4)

def apply_theme(scheme: str):
    if scheme not in DATABASE:
        raise ValueError(f"scheme options : {DATABASE.keys()}")

    # Format the colors correctly and send them to the Themes folder
    for file_name, (destination, color_format, keep_hash) in DEST_FILES_CONF.items():
        colored_dict = DATABASE[scheme]["colors"].copy()
        if color_format in methods.TYPES:
            colored_dict = methods.hex_to_rgba_dict(colored_dict, color_format)
        if file_name not in SPECIAL_CASE:
            methods.switcher(
                os.path.join(TEMPLATES_DIR, file_name),
                os.path.join(GENERATED_THEME_DIR, destination),
                colored_dict,
                keep_hash,
            )
        # Handle special cases here
        if file_name == SPECIAL_CASE[0] or file_name == SPECIAL_CASE[1]:
            # note the cheeky ThemePath update
            colored_dict.update({"ThemePath":ThemePath })
            methods.switcher(
                os.path.join(TEMPLATES_DIR, file_name),
                os.path.join(GENERATED_THEME_DIR, destination),
                colored_dict,
                keep_hash,
            )
            del colored_dict["ThemePath"]

    # apply the vs code theme
    vs_code_apply_theme(VS_CODE_PATH,DATABASE[scheme]["vs-code-theme"])
    # apply the gtk theme
    GTK_THEME = DATABASE[scheme]["gtk-theme"]
    subprocess.run(
        [
            "gsettings", 
            "set", 
            "org.gnome.desktop.interface", 
            "gtk-theme", 
            GTK_THEME
         ],
         capture_output=True,
    )
    subprocess.run(
        [
            "gsettings", 
            "set", 
            "org.gnome.desktop.interface", 
            "font-name", 
            "JetBrainsMono Nerd Font Propo 12" 
         ],
         capture_output=True,
    )


    

if parse_arguments().t:
    pywal_dict,WALLPAPER = pywal.pywalcolgen(HOME)
    DATABASE.update(pywal_dict)
    apply_theme(parse_arguments().t)
    misc.Gen_Blur_Wall(ThemePath,WALLPAPER)
    misc.Parse_Clipcat_Toml(ThemePath)

if parse_arguments().themes:
    for i in DATABASE.keys():
        print(i)


