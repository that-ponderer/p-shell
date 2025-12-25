import os
import re
import subprocess
from typing import Tuple, Dict


# -------------------- CONSTANTS --------------------

VS_CODE_THEME_PYWAL = "Wal Bordered"
GTK_THEME_PYWAL = "linea-nord-color"


# -------------------- MAIN --------------------

def pywalcolgen(home: str) -> Tuple[Dict, str]:
    """
    Generate pywal + wpgtk colors from the current swww wallpaper.

    Returns:
        (database_fragment, wallpaper_path)
    """

    wal_colors_path = os.path.join(home, ".cache", "wal", "colors")

    wallpaper = _get_current_wallpaper()
    wall_name = os.path.basename(wallpaper)

    _generate_pywal_colors(wallpaper)
    _generate_wpgtk_colors(wallpaper, wall_name)

    colors = _read_wal_colors(wal_colors_path)

    return (
        {
            "WAL": {
                "colors": colors,
                "vs-code-theme": VS_CODE_THEME_PYWAL,
                "gtk-theme": GTK_THEME_PYWAL,
            }
        },
        wallpaper,
    )


# -------------------- HELPERS --------------------

def _get_current_wallpaper() -> str:
    try:
        result = subprocess.run(
            "swww query",
            shell=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        ).stdout

        match = re.search(r"image:\s*(/.+)$", result)
        if not match:
            raise RuntimeError

        return match.group(1)

    except Exception as e:
        raise RuntimeError("Could not query swww wallpaper") from e


def _generate_pywal_colors(wallpaper: str) -> None:
    try:
        subprocess.run(
            ["wal", "-n" ,"-s", "-t", "-i", wallpaper],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError("pywal color generation failed") from e


def _generate_wpgtk_colors(wallpaper: str, wall_name: str) -> None:
    try:
        subprocess.run(
            f"""
            wpg -n --noterminal -a "{wallpaper}" &&
            wpg -s "{wall_name}" &&
            wpg -d "{wall_name}"
            """,
            shell=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError("wpgtk color generation failed") from e


def _read_wal_colors(path: str) -> Dict[str, str]:
    colors: Dict[str, str] = {}

    with open(path) as f:
        for idx, line in enumerate(f):
            colors[str(idx)] = line.strip()

    # extra convenience color
    colors["zsh"] = colors.get("8")

    return colors

