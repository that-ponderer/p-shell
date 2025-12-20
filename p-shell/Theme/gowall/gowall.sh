#!/usr/bin/zsh

anime_logos=(
    [1]="${ThemePath}/Theme/gowall/fastfetch-anime"
    [2]="${ThemePath}/Theme/fastfetch/logos/anime"
    [3]="${ThemePath}/Theme/gowall/colors.json"
    )

anime_logos_jojo=(
    [1]="${ThemePath}/Theme/gowall/fastfetch-anime-jojo"
    [2]="${ThemePath}/Theme/fastfetch/logos/anime"
    [3]="${ThemePath}/Theme/gowall/colors.json"
    )

gowall_apply() {
    
    rm -r "${(P)1[2]}"
    mkdir "${(P)1[2]}"
   
    gowall convert --dir "${(P)1[1]}" \
    --output "${(P)1[2]}" \
    --theme "${(P)1[3]}"
}

gowall_apply anime_logos_jojo
