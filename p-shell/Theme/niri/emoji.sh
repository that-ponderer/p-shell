#!/usr/bin/env bash

# Use rofimoji with custom rofi args and copy to clipboard
# Auto pasting does not work 
rofimoji \
--selector-args="-config ${ThemePath}/Theme/rofi/config.rasi" \
--max-recent 9 \
-a copy


