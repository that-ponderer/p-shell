import os
import subprocess
from typing import Final

import toml


# -------------------- CONSTANTS --------------------

BLURRED_WALL_FILENAME: Final = "blured_wall.png"


# -------------------- CLIPCAT --------------------

def parse_clipcat_toml(theme_path: str) -> None:
    """
    Update clipcat-menu.toml to point to the generated rofi config.
    """

    clipcat_menu_path = os.path.join(
        theme_path,
        "Theme",
        "clipcat",
        "clipcat-menu.toml",
    )

    rofi_config_path = os.path.join(
        theme_path,
        "Theme",
        "rofi",
        "config.rasi",
    )

    data = toml.load(clipcat_menu_path)
    data["rofi"]["extra_arguments"] = [
        "-config",
        rofi_config_path,
    ]

    with open(clipcat_menu_path, "w") as f:
        toml.dump(data, f)


# -------------------- WALLPAPER --------------------

def generate_blurred_wallpaper(
    theme_path: str,
    wallpaper_path: str,
    resolution: str = "1920x1080",
    blur_strength: str = "0x35",
) -> None:
    """
    Generate a blurred wallpaper using ImageMagick.
    """

    output_path = os.path.join(
        theme_path,
        "Theme",
        "assets",
        BLURRED_WALL_FILENAME,
    )

    subprocess.run(
        [
            "magick",
            f"{wallpaper_path}[0]",
            "-resize", resolution,
            "-blur", blur_strength,
            output_path,
        ],
        check=True,
    )

