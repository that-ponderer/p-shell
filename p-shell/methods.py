from typing import Dict


# -------------------- CONSTANTS --------------------

COLOR_FORMATS = ("rgb", "rgba")


# -------------------- COLOR CONVERSION --------------------

def hex_to_rgb_string(
    hex_color: str,
    format: str = "rgba",
    opacity: float = 1.0,
) -> str:
    """
    Convert a hex color (#RRGGBB) to rgb(...) or rgba(...).
    """

    if format not in COLOR_FORMATS:
        raise ValueError(
            f"Unsupported format '{format}'. "
            f"Valid options: {COLOR_FORMATS}"
        )

    hex_value = hex_color.lstrip("#")
    if len(hex_value) != 6:
        raise ValueError(
            f"Invalid hex color '{hex_color}'. Expected 6 characters."
        )

    r = int(hex_value[0:2], 16)
    g = int(hex_value[2:4], 16)
    b = int(hex_value[4:6], 16)

    if format == "rgb":
        return f"rgb({r},{g},{b})"

    return f"rgba({r},{g},{b},{opacity})"


def hex_dict_to_rgb_dict(
    color_dict: Dict[str, str],
    format: str = "rgba",
    opacity: float = 1.0,
) -> Dict[str, str]:
    """
    Convert all hex values in a dict to rgb / rgba strings.
    """

    return {
        key: hex_to_rgb_string(value, format, opacity)
        for key, value in color_dict.items()
    }


# -------------------- TEMPLATE SWITCHING --------------------

def switcher(
    source_path: str,
    dest_path: str,
    colors: Dict[str, str],
    include_hash: bool = True,
) -> None:
    """
    Replace placeholders in a template file and write output.
    Placeholders are expected in the form: {key}
    """

    with open(source_path) as src:
        content = src.read()

    for key, value in colors.items():
        placeholder = f"{{{key}}}"
        replacement = value if include_hash else value.lstrip("#")
        content = content.replace(placeholder, replacement)

    with open(dest_path, "w") as dst:
        dst.write(content)

