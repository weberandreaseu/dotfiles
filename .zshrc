# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# oh my zsh theme
ZSH_THEME="robbyrussell"

# oh my zsh plugins
plugins=(git autojump)

source $ZSH/oh-my-zsh.sh

# file with aliases
source $HOME/.zsh_aliases


# fiel with environment variables
source $HOME/.zsh_env

# begin conda initialize
__conda_setup="$('/home/andreas/.miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/andreas/.miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/andreas/.miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/andreas/.miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# end conda initialize 

