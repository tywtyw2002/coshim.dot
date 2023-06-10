# fzf tab
bindkey "^I" expand-or-complete
bindkey "^ " fzf-tab-complete

# fzf history search
typeset -g ZSH_FZF_HISTORY_SEARCH_END_OF_LINE='true'
typeset -g ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES='5'
typeset -g ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS='--ansi --height 40% --reverse'


# theme
if (( $+commands[starship] )); then
    source <(starship init zsh --print-full-init)
else
    zgen load $ZLHOME/themes/pygmalion.zsh-theme
fi


# ls themes
(( $+commands[gdircolors] )) && eval $(gdircolors ~/.my_config/DIR_COLORS.less)
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}