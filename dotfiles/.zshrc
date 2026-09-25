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

# Widget TAB should ultimately run. fzf-tab (loaded above) installs its own
# completion widget; without it, fall back to plain zsh completion.
if (( $+widgets[fzf-tab-complete] )); then
    ZSH_TAB_WIDGET=fzf-tab-complete
else
    ZSH_TAB_WIDGET=expand-or-complete
fi

if [[ -o interactive && ! -o zle ]]; then
    ZSH_TAB_BOOTSTRAP_WIDGET=""
elif [[ "${ZSH_LAZY_COMPINIT:-1}" == "1" ]]; then
    # First TAB press pays for compinit, then hands TAB over to the real widget.
    # Re-queue the TAB with `zle -U` instead of calling the widget directly:
    # fzf-tab accepts a selection via a `zle -C` completion widget, and invoking
    # that from inside another widget crashes zsh. Ungetting the key makes ZLE
    # dispatch it at top level once this widget returns.
    _lazy_compinit() {
        zle -D _lazy_compinit
        _run_compinit
        bindkey '^I' "$ZSH_TAB_WIDGET"
        zle -U $'\t'
    }
    zle -N _lazy_compinit
    ZSH_TAB_BOOTSTRAP_WIDGET=_lazy_compinit
else
    _run_compinit
    ZSH_TAB_BOOTSTRAP_WIDGET="$ZSH_TAB_WIDGET"
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
# menu must stay off: fzf-tab replaces zsh's own menu with an fzf picker.
zstyle ':completion:*' menu no
# Navigate the fzf-tab menu with Tab / Shift-Tab (arrows and ^N/^P work too).
zstyle ':fzf-tab:*' fzf-bindings 'tab:down' 'btab:up'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Shell integrations
# mise must activate first: it puts mise-managed tools like fzf and zoxide on PATH.
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# `fzf --zsh` binds TAB to its own fzf-completion widget, which shadows fzf-tab.
# Claim TAB back now that every integration has been evaluated.
if [[ -n "${ZSH_TAB_BOOTSTRAP_WIDGET:-}" ]]; then
    bindkey '^I' "$ZSH_TAB_BOOTSTRAP_WIDGET"
fi
if command -v mise >/dev/null 2>&1; then
    source <(mise completion zsh)
fi
if command -v junoctl >/dev/null 2>&1; then
    source <(junoctl completion zsh)
fi
if command -v dtctl >/dev/null 2>&1; then
    source <(dtctl completion zsh)
fi
if command -v bbctl >/dev/null 2>&1; then
    source <(bbctl completion zsh)
fi
