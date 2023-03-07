# fzf tab
bindkey "^I" expand-or-complete
bindkey "^ " fzf-tab-complete

# fzf history search
typeset -g ZSH_FZF_HISTORY_SEARCH_END_OF_LINE='true'
typeset -g ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES='5'
typeset -g ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS='--ansi --height 40% --reverse'

# ======== #
#  Editor  #
# ======== #
local edit='vi'
(( $+commands[vim] )) && alias vi=vim
(( $+commands[nvim] )) && edit='nvim'

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

# ================ #
#  theme starship  #
# ================ #
if (( $+commands[starship] )); then
    source <(starship init zsh --print-full-init)
else
    zgenom load $Z_DOT_PATH/stores/pygmalion.zsh-theme
fi

# ======== #
#  zoxide  #
# ======== #
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
    unset zi
fi

# =========== #
#  dircolors  #
# =========== #
(( $+commands[gdircolors] )) && eval $(gdircolors $Z_DOT_PATH/stores/DIR_COLORS)
(( $+commands[dircolors] )) && eval $(dircolors $Z_DOT_PATH/stores/DIR_COLORS)