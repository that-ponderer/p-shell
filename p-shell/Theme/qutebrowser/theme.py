from colors import colors

def apply(c,samecolorrows=False):
    # completion {{{
    ## Background color of the completion widget category headers.
    c.colors.completion.category.bg = colors["0"]
    ## Bottom border color of the completion widget category headers.
    c.colors.completion.category.border.bottom = colors["0"]
    ## Top border color of the completion widget category headers.
    c.colors.completion.category.border.top = colors["zsh"]
    ## Foreground color of completion widget category headers.
    c.colors.completion.category.fg = colors["2"]
    ## Background color of the completion widget for even and odd rows.
    if samecolorrows:
        c.colors.completion.even.bg = colors["0"]
        c.colors.completion.odd.bg = c.colors.completion.even.bg
    else:
        c.colors.completion.even.bg = colors["0"]
        c.colors.completion.odd.bg = colors["0"]
    ## Text color of the completion widget.
    c.colors.completion.fg = colors["15"]

    ## Background color of the selected completion item.
    c.colors.completion.item.selected.bg = colors["zsh"]
    ## Bottom border color of the selected completion item.
    c.colors.completion.item.selected.border.bottom = colors["zsh"]
    ## Top border color of the completion widget category headers.
    c.colors.completion.item.selected.border.top = colors["zsh"]
    ## Foreground color of the selected completion item.
    c.colors.completion.item.selected.fg = colors["7"]
    ## Foreground color of the selected completion item.
    c.colors.completion.item.selected.match.fg = colors["9"]
    ## Foreground color of the matched text in the completion.
    c.colors.completion.match.fg = colors["7"]

    ## Color of the scrollbar in completion view
    c.colors.completion.scrollbar.bg = colors["0"]
    ## Color of the scrollbar handle in completion view.
    c.colors.completion.scrollbar.fg = colors["zsh"]
    # }}}

    # downloads {{{
    c.colors.downloads.bar.bg = colors["0"]
    c.colors.downloads.error.bg = colors["0"]
    c.colors.downloads.start.bg = colors["0"]
    c.colors.downloads.stop.bg = colors["0"]

    c.colors.downloads.error.fg = colors["1"]
    c.colors.downloads.start.fg = colors["4"]
    c.colors.downloads.stop.fg = colors["2"]
    c.colors.downloads.system.fg = "none"
    c.colors.downloads.system.bg = "none"
    # }}}

    # hints {{{
    ## Background color for hints. Note that you can use a `rgba(...)` value
    ## for transparency.
    c.colors.hints.bg = colors["3"]

    ## Font color for hints.
    c.colors.hints.fg = colors["0"]

    ## Hints
    c.hints.border = "1px solid " + colors["0"]

    ## Font color for the matched part of hints.
    c.colors.hints.match.fg = colors["15"]
    # }}}

    # keyhints {{{
    ## Background color of the keyhint widget.
    c.colors.keyhint.bg = colors["0"]

    ## Text color for the keyhint widget.
    c.colors.keyhint.fg = colors["7"]

    ## Highlight color for keys to complete the current keychain.
    c.colors.keyhint.suffix.fg = colors["15"]
    # }}}

    # messages {{{
    ## Background color of an error message.
    c.colors.messages.error.bg = colors["zsh"]
    ## Background color of an info message.
    c.colors.messages.info.bg = colors["zsh"]
    ## Background color of a warning message.
    c.colors.messages.warning.bg = colors["zsh"]

    ## Border color of an error message.
    c.colors.messages.error.border = colors["0"]
    ## Border color of an info message.
    c.colors.messages.info.border = colors["0"]
    ## Border color of a warning message.
    c.colors.messages.warning.border = colors["0"]

    ## Foreground color of an error message.
    c.colors.messages.error.fg = colors["1"]
    ## Foreground color an info message.
    c.colors.messages.info.fg = colors["7"]
    ## Foreground color a warning message.
    c.colors.messages.warning.fg = colors["3"]
    # }}}

    # prompts {{{
    ## Background color for prompts.
    c.colors.prompts.bg = colors["0"]

    # ## Border used around UI elements in prompts.
    c.colors.prompts.border = "1px solid " + colors["zsh"]

    ## Foreground color for prompts.
    c.colors.prompts.fg = colors["7"]

    ## Background color for the selected item in filename prompts.
    c.colors.prompts.selected.bg = colors["zsh"]

    ## Background color for the selected item in filename prompts.
    c.colors.prompts.selected.fg = colors["9"]
    # }}}

    # statusbar {{{
    ## Background color of the statusbar.
    c.colors.statusbar.normal.bg = colors["0"]
    ## Background color of the statusbar in insert mode.
    c.colors.statusbar.insert.bg = colors["0"]
    ## Background color of the statusbar in command mode.
    c.colors.statusbar.command.bg = colors["0"]
    ## Background color of the statusbar in caret mode.
    c.colors.statusbar.caret.bg = colors["0"]
    ## Background color of the statusbar in caret mode with a selection.
    c.colors.statusbar.caret.selection.bg = colors["0"]

    ## Background color of the progress bar.
    c.colors.statusbar.progress.bg = colors["0"]
    ## Background color of the statusbar in passthrough mode.
    c.colors.statusbar.passthrough.bg = colors["0"]

    ## Foreground color of the statusbar.
    c.colors.statusbar.normal.fg = colors["7"]
    ## Foreground color of the statusbar in insert mode.
    c.colors.statusbar.insert.fg = colors["9"]
    ## Foreground color of the statusbar in command mode.
    c.colors.statusbar.command.fg = colors["7"]
    ## Foreground color of the statusbar in passthrough mode.
    c.colors.statusbar.passthrough.fg = colors["3"]
    ## Foreground color of the statusbar in caret mode.
    c.colors.statusbar.caret.fg = colors["3"]
    ## Foreground color of the statusbar in caret mode with a selection.
    c.colors.statusbar.caret.selection.fg = colors["3"]

    ## Foreground color of the URL in the statusbar on error.
    c.colors.statusbar.url.error.fg = colors["1"]

    ## Default foreground color of the URL in the statusbar.
    c.colors.statusbar.url.fg = colors["7"]

    ## Foreground color of the URL in the statusbar for hovered links.
    c.colors.statusbar.url.hover.fg = colors["14"]

    ## Foreground color of the URL in the statusbar on successful load
    c.colors.statusbar.url.success.http.fg = colors["10"]

    ## Foreground color of the URL in the statusbar on successful load
    c.colors.statusbar.url.success.https.fg = colors["2"]

    ## Foreground color of the URL in the statusbar when there's a warning.
    c.colors.statusbar.url.warn.fg = colors["11"]

    ## PRIVATE MODE COLORS
    ## Background color of the statusbar in private browsing mode.
    c.colors.statusbar.private.bg = colors["0"]
    ## Foreground color of the statusbar in private browsing mode.
    c.colors.statusbar.private.fg = colors["15"]
    ## Background color of the statusbar in private browsing + command mode.
    c.colors.statusbar.command.private.bg = colors["0"]
    ## Foreground color of the statusbar in private browsing + command mode.
    c.colors.statusbar.command.private.fg = colors["15"]

    # }}}

    # tabs {{{
    ## Background color of the tab bar.
    c.colors.tabs.bar.bg = colors["0"]
    ## Background color of unselected even tabs.
    c.colors.tabs.even.bg = colors["0"]
    ## Background color of unselected odd tabs.
    c.colors.tabs.odd.bg = colors["0"]

    ## Foreground color of unselected even tabs.
    c.colors.tabs.even.fg = colors["zsh"]
    ## Foreground color of unselected odd tabs.
    c.colors.tabs.odd.fg = colors["zsh"]

    ## Color for the tab indicator on errors.
    c.colors.tabs.indicator.error = colors["1"]
    ## Color gradient interpolation system for the tab indicator.
    ## Valid values:
    ##	 - rgb: Interpolate in the RGB color system.
    ##	 - hsv: Interpolate in the HSV color system.
    ##	 - hsl: Interpolate in the HSL color system.
    ##	 - none: Don't show a gradient.
    c.colors.tabs.indicator.system = "none"

    # ## Background color of selected even tabs.
    c.colors.tabs.selected.even.bg = colors["0"]
    # ## Background color of selected odd tabs.
    c.colors.tabs.selected.odd.bg = colors["0"]

    # ## Foreground color of selected even tabs.
    c.colors.tabs.selected.even.fg = colors["4"]
    # ## Foreground color of selected odd tabs.
    c.colors.tabs.selected.odd.fg = colors["4"]
    # }}}

    # context menus {{{
    c.colors.contextmenu.menu.bg = colors["0"]
    c.colors.contextmenu.menu.fg = colors["7"]

    c.colors.contextmenu.disabled.bg = colors["0"]
    c.colors.contextmenu.disabled.fg = colors["zsh"]

    c.colors.contextmenu.selected.bg = colors["zsh"]
    c.colors.contextmenu.selected.fg = colors["9"]
    # }}none}

