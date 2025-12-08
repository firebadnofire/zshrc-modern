# Exit if noninteractive
[[ -o interactive ]] || return

# Universal environment
export EDITOR="vim"
export GPG_TTY=$(tty)
export MAIL="$HOME/Maildir"

# Universal aliases (POSIX, no system assumptions)
alias cls="clear"
alias x="exit"

# Prompt (universally portable)
#PROMPT='[%T] %n@%m:%~$ '

# Ensure .zshrc.d exists
mkdir -p "$HOME/.zshrc.d"
[ -f "$HOME/.zshrc.d/suppress-warning.zrc" ] || echo "# placeholder" > "$HOME/.zshrc.d/suppress-warning.zrc"

### OMZ

export ZSH="$HOME/.oh-my-zsh"
DISABLE_UPDATE_PROMPT=true

THEME_FILE="$HOME/.oh-my-zsh/themes/firebadnofire.zsh-theme"
THEME_URL="https://live.archuser.org/firebadnofire.zsh-theme"

if [[ ! -f "$THEME_FILE" ]]; then
    curl -fLo "$THEME_FILE" "$THEME_URL"
fi

ZSH_THEME="firebadnofire"
plugins=(git cmdtime)

source "$ZSH/oh-my-zsh.sh"

### Load extra

# Load all additional configs
for f in "$HOME/.zshrc.d"/*.zrc; do
  [ -r "$f" ] && source "$f"
done

