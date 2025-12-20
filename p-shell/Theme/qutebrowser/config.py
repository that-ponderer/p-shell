import os
import theme

c.colors.webpage.darkmode.enabled = True
theme.apply(c)
#catppuccin.setup(c, 'mocha', True)

# Fonts
c.fonts.default_family = ["JetBrainsMono Nerd Font Propo"]
c.fonts.web.family.serif = "JetBrainsMono Nerd Font Propo"
c.fonts.web.family.sans_serif = "JetBrainsMono Nerd Font Propo"
c.fonts.web.family.standard = "JetBrainsMono Nerd Font Propo"
c.fonts.web.family.cursive = "JetBrainsMono Nerd Font Propo"
c.fonts.web.family.fantasy =  "JetBrainsMono Nerd Font Propo"
c.fonts.default_size = "12pt"

# Binds
config.bind('<Ctrl-v>', 'spawn mpv {url}')
config.bind('P','open -p')

# Ad-Block
c.content.blocking.method = "both"

ThemePath = os.environ["ThemePath"]
Start_File = f"file://{ThemePath}/Theme/qutebrowser/start_page.html"
c.url.default_page = Start_File
c.url.start_pages = [Start_File]
