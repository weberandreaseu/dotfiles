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
# Escape hatch back to plain compsys when a completion misbehaves under fzf-tab.
(( $+widgets[toggle-fzf-tab] )) && bindkey '^X^T' toggle-fzf-tab

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
# Group support. fzf-tab needs a descriptions format to render group headers at
# all -- without it there are no groups for switch-group to cycle through.
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
# Offer branches by recency rather than alphabetically.
zstyle ':completion:*:git-checkout:*' sort false

# fzf-tab. Defaults already cover Tab/Shift-Tab to move, Ctrl+Space to
# multi-select, `/` for continuous completion and Alt+Enter to insert the raw
# query, so only the deviations are set here.
# F1/F2 are frequently swallowed by the terminal; use < and > to switch groups.
zstyle ':fzf-tab:*' switch-group '<' '>'
# Inherit the FZF_DEFAULT_OPTS theme (off by default in fzf-tab).
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# Uncomment with tmux >= 3.2 to render the picker in a popup instead of inline.
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# Previews. eza/bat when present, coreutils otherwise -- previews run in a bare
# child shell that never sources this file, so the fallback has to be inline.
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
    'eza -1A --color=always --icons -- $realpath 2>/dev/null || ls --color=always -1A -- $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview \
    'eza -1A --color=always --icons -- $realpath 2>/dev/null || ls --color=always -1A -- $realpath'
# Generic fallback: list directories, head readable files, stay quiet otherwise.
zstyle ':fzf-tab:complete:*:*' fzf-preview \
    '{ [[ -d $realpath ]] && { eza -1A --color=always --icons -- $realpath 2>/dev/null || ls --color=always -1A -- $realpath } } || { [[ -f $realpath ]] && { bat --color=always --style=numbers --line-range=:200 -- $realpath 2>/dev/null || head -n 200 -- $realpath } } 2>/dev/null'
zstyle ':fzf-tab:complete:git-(add|diff|restore|stash):*' fzf-preview \
    'git diff --color=always -- $word 2>/dev/null | head -n 200'
zstyle ':fzf-tab:complete:git-(checkout|switch|rebase|merge|log|show):*' fzf-preview \
    'git log --color=always --oneline --graph --decorate -20 $word 2>/dev/null'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview \
    'SYSTEMD_COLORS=1 systemctl status -- $word 2>/dev/null'
# _journalctl does not override curcontext, so the unit argument lands under
# :complete:journalctl:option-u-1 and friends. Non-unit arguments just preview
# empty, which is why the error is swallowed.
zstyle ':fzf-tab:complete:journalctl:*' fzf-preview \
    'SYSTEMD_COLORS=1 journalctl --no-pager -n 50 -u $word 2>/dev/null'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
    'ps -p $word -o cmd --no-headers -w -w 2>/dev/null'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:-command-:*' fzf-preview 'whence -a -- $word 2>/dev/null | head -n 20'

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

# Upgrade the ls family to eza. This cannot live in .alias.zsh: that is sourced
# at the top of this file, before `mise activate` puts eza on PATH, so a guard
# there would always fail. `cat` is deliberately left alone -- see AGENTS.md.
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --group-directories-first'
    alias ll='eza -lh  --group-directories-first --git'
    alias la='eza -lAh --group-directories-first --git'
    alias l='eza  -lah --group-directories-first --git'
    alias lt='eza --tree --level=2 --group-directories-first'
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
