local edit='nvim'

command -v vim >/dev/null 2>&1 && {
    edit='vim'
    alias vi=vim
}

export EDITOR=$edit

# Allow command line editing in an external editor.
autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line

zle -N edit-command-line


# Updates editor information when the keymap changes.
function zle-keymap-select() {
    zle reset-prompt
    zle -R
}

zle -N zle-keymap-select
