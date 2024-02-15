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
# In Macos, use neovim replace the vi/vim.
# In Linux, do not link vi to nvim by default.
local edit='vi'
(( $+commands[vim] )) && alias vi=vim

if (( $+commands[nvim] )); then
    edit='nvim'
    (($(uname) == "Darwin")) && alias vi=nvim
fi

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

# Tmux
ZSH_TMUX_CONFIG=$HOME/.config/tmux/tmux.conf
ZSH_TMUX_FIXTERM=false
unset _ZSH_TMUX_FIXED_CONFIG
unset ZSH_TMUX_TERM

# ================ #
#  theme starship  #
# ================ #
if (( $+commands[starship] )); then
    source <(starship init zsh --print-full-init)
else
    source load $Z_DOT_PATH/stores/pygmalion.zsh-theme
fi

# ======== #
#  zoxide  #
# ======== #
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
    unalias zi
fi

# =========== #
#  dircolors  + LS #
# =========== #
(( $+commands[gdircolors] )) && eval $(gdircolors $Z_DOT_PATH/stores/DIR_COLORS)
(( $+commands[dircolors] )) && eval $(dircolors $Z_DOT_PATH/stores/DIR_COLORS)
(( $+commands[gls] )) && alias ls='gls --color=auto'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# =========== #
#   atuin     #
# =========== #
# Manual bind ^p as local dir search
if (( $+commands[atuin] )); then
    eval "$(atuin init zsh --disable-up-arrow)"
    bindkey -M emacs '^p' _atuin_up_search_widget
fi

