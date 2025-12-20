# Convert hex string to RGBA or RGB
TYPES = ("rgb", "rgba")
def hex_to_rgba(hex: str, format: str = "rgba", opacity: float = 1.0) -> str:
    if format not in TYPES:
        raise ValueError(f'Only possible formats : {TYPES} ; Given "{format}"')

    hex_num = hex.lstrip("#")
    if len(hex_num) != 6:
        raise ValueError(
            f"Hex Values Must be Under 6 Chars : {hex_num} -> {len(hex_num)}"
        )

    r = int(hex_num[:2], 16)
    g = int(hex_num[2:4], 16)
    b = int(hex_num[4:6], 16)
    if format == TYPES[0]:
        return f"rgb({r},{g},{b})"
    return f"rgba({r},{g},{b},{opacity})"


def hex_to_rgba_dict(
    hex_dict: dict, format_dict: str = "rgba", opacity_dict: float = 1.0
) -> dict:
    for key, value in hex_dict.items():
        hex_dict.update({key: hex_to_rgba(value, format_dict, opacity_dict)})
    return hex_dict


# Replace the placeholders and write it to the destination
def switcher(source: str, dest: str, colors: dict, include_hash: bool = True):
    with open(source, "r") as _source:
        content = _source.read()
        for j, i in colors.items():
            old = "{" + str(j) + "}"
            new = i
            if include_hash:
                content = content.replace(old, new)
            else:
                content = content.replace(old, new.lstrip("#"))
    with open(dest, "w") as _dest:
        _dest.write(content)

