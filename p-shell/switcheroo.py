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
try:
    THEME_PATH = os.environ["ThemePath"]
    HOME = os.environ["HOME"]
except KeyError as e:
    raise RuntimeError(f"Missing environment variable: {e}") from None

WORKING_DIR = THEME_PATH
TEMPLATES_DIR = os.path.join(WORKING_DIR, "Templates")
GENERATED_THEME_DIR = os.path.join(WORKING_DIR, "Theme")

VS_CODE_PATH = os.path.join(
    HOME, ".config/Code - OSS/User/settings.json"
)

SPECIAL_CASES = {"clipcat-menu", "mpd"}


# -------------------- LOAD DATA --------------------

with open(os.path.join(WORKING_DIR, "locations.json")) as f:
    DEST_FILES_CONF = json.load(f)["DEST_FILES_CONF"]

with open(os.path.join(WORKING_DIR, "database.json")) as f:
    DATABASE = json.load(f)


# -------------------- HELPERS --------------------

def apply_vscode_theme(vs_code_path: str, theme_name: str) -> None:
    if not os.path.isfile(vs_code_path):
        print("VS Code config not found — skipping")
        return

    with open(vs_code_path) as f:
        data = json.load(f)

    data["workbench.colorTheme"] = theme_name

    with open(vs_code_path, "w") as f:
        json.dump(data, f, indent=4)


def apply_theme(scheme: str) -> None:
    if scheme not in DATABASE:
        raise ValueError(f"Available schemes: {', '.join(DATABASE)}")

    colors = DATABASE[scheme]["colors"]

    for file_name, (destination, fmt, keep_hash) in DEST_FILES_CONF.items():
        color_dict = colors.copy()

        if fmt in methods.TYPES:
            color_dict = methods.hex_to_rgba_dict(color_dict, fmt)

        if file_name in SPECIAL_CASES:
            color_dict["ThemePath"] = THEME_PATH

        methods.switcher(
            os.path.join(TEMPLATES_DIR, file_name),
            os.path.join(GENERATED_THEME_DIR, destination),
            color_dict,
            keep_hash,
        )

    # VS Code
    apply_vscode_theme(
        VS_CODE_PATH,
        DATABASE[scheme]["vs-code-theme"]
    )

    # GTK
    subprocess.run(
        [
            "gsettings", "set",
            "org.gnome.desktop.interface",
            "gtk-theme",
            DATABASE[scheme]["gtk-theme"],
        ],
        capture_output=True,
    )

    subprocess.run(
        [
            "gsettings", "set",
            "org.gnome.desktop.interface",
            "font-name",
            "JetBrainsMono Nerd Font Propo 12",
        ],
        capture_output=True,
    )



# -------------------- MAIN --------------------

def main() -> None:
    args = parse_arguments()

    if args.themes:
        for name in DATABASE:
            print(name)
        return

    if args.theme:
        pywal_data, wallpaper = pywal.pywalcolgen(HOME)
        DATABASE.update(pywal_data)

        apply_theme(args.theme)
        misc.Gen_Blur_Wall(THEME_PATH, wallpaper)
        misc.Parse_Clipcat_Toml(THEME_PATH)


if __name__ == "__main__":
    main()
