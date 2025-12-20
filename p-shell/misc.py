import toml 
import os


def Parse_Clipcat_Toml(ThemePath:str):
    Clipcat_menu_path=os.path.join(ThemePath,"Theme/clipcat/clipcat-menu.toml")
    clipcat_menu_data = toml.load(Clipcat_menu_path)
    clipcat_menu_data["rofi"]["extra_arguments"] = [
        "-config",
        os.path.join(ThemePath, "Theme/rofi/config.rasi"),
    ]
    with open(Clipcat_menu_path,"w") as f:
        toml.dump(clipcat_menu_data,f)
    
