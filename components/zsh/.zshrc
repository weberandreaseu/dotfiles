# Source: https://github.com/dreamsofautonomy/zensh/blob/main/.zshrc

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -o zle ]] && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source "${HOME}/.alias.zsh"

if [[ -n "${ZSH_EXECUTION_STRING:-}" && "${ZSH_FORCE_FULL_INIT:-0}" != "1" ]]; then
    if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
    fi
    return
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
# zinit light jirutka/zsh-shift-select

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git

# Load completions
autoload -Uz compinit
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_COMPDUMP_FILE="${ZSH_CACHE_DIR}/.zcompdump"

if ! mkdir -p "$ZSH_CACHE_DIR" >/dev/null 2>&1; then
    ZSH_COMPDUMP_FILE=""
fi

_run_compinit() {
    if [[ -z "$ZSH_COMPDUMP_FILE" ]]; then
        compinit -C -i
        return
    fi

    if [[ -n ${ZSH_COMPDUMP_FILE}(#qN.mh+24) ]]; then
        compinit -i -d "$ZSH_COMPDUMP_FILE"
    else
        compinit -C -i -d "$ZSH_COMPDUMP_FILE"
    fi
}

if [[ -o interactive && ! -o zle ]]; then
    :
elif [[ "${ZSH_LAZY_COMPINIT:-1}" == "1" ]]; then
    _lazy_compinit() {
        zle -D _lazy_compinit
        bindkey '^I' expand-or-complete
        _run_compinit
        zle expand-or-complete
    }
    zle -N _lazy_compinit
    bindkey '^I' _lazy_compinit
else
    _run_compinit
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
# Enables prefix search
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
# Word navigation with Ctrl + Arrow
bindkey "^[[1;5C" forward-word    # Ctrl + Right
bindkey "^[[1;5D" backward-word   # Ctrl + Left
# Start / end of line with Ctrl + Arrow
bindkey "^[[1;5H" beginning-of-line  # Ctrl + Home
bindkey "^[[1;5F" end-of-line        # Ctrl + End
bindkey "^H" backward-kill-word   # Ctrl + Backspace

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi
