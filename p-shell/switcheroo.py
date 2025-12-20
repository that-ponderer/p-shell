"""A Family Friendly Theme Switer that supports pywall"""

import os
import json
from os.path import isfile
import subprocess
import argparse
import methods
import pywal

# PASRSER
def parse_arguments() -> argparse.Namespace :
    # Create the parser obj and give a name and description for the script
    PARSER = argparse.ArgumentParser(
    "The P-Shell Switcher", "Switching Home Made Themes"
    )
    # Add the optional args
    PARSER.add_argument(
    "-t", type=str, metavar="", help="Choose a theme"
    )
    PARSER.add_argument(
        "--themes", action="count", default=0,
        help="Display the available themes`"
    )
    # Store the user input into a into a Namespace object
    # which is just a dictionary wraped in a object and uses dot (.) notation
    return PARSER.parse_args()

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
        ["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", GTK_THEME],
        capture_output=True,
    )

if parse_arguments().t:
    DATABASE.update(pywal.pywalcolgen(HOME,ThemePath)[0])
    WALLPAPER = pywal.pywalcolgen(HOME,ThemePath)[1]
    apply_theme(parse_arguments().t)
if parse_arguments().themes:
    for i in DATABASE.keys():
        print(i)


