source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

source ${ThemePath}/Theme/theme.zsh

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

#aliases
alias ls="ls -AhX --color"
alias lls="ls -AhXlh --color"
alias du="du --max-depth=1 -h | sort -hr | lolcat" #disk usage
alias cava="cava -p ${ThemePath}/Theme/cavaconfig"
alias rmpc="rmpc -c ${ThemePath}/Theme/rmpc/config.ron -t \
    $ThemePath/Theme/themes.ron"
alias fastfetch="fastfetch -c ${ThemePath}/Theme/fastfetch/config.jsonc --logo-recache"
alias chromium="chromium"
alias cat="bat"

#VIM like binds:
bindkey -v
#Command History Setup

# Where to save the history file
HISTFILE="${ZDOTDIR}/.zsh_history"


# How many lines to keep in memory and file
HISTSIZE=5000
SAVEHIST=5000

# Options to control behavior
setopt APPEND_HISTORY       # Append to history instead of overwriting
setopt INC_APPEND_HISTORY   # Save every command immediately
setopt SHARE_HISTORY        # Share history across sessions




# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
# fzf commands and options (fd for the finder and bat for the previewer)
export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
export FZF_DEFAULT_OPTS='--height 50% --layout reverse --border'
export FZF_CTRL_T_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
export FZF_ALT_C_COMMAND='fd --type=d --hidden --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_OPTS='--preview "bat -n --color=always {}"'
export FZF_ALT_C_OPTS='--preview "tree -C {}"'

#fish style Tab complition highlights
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

#zoxide
eval "$(zoxide init zsh --cmd cd)"


#omp
eval "$(oh-my-posh init zsh  --config ${ThemePath}/Theme/omp.json)"

#yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}


