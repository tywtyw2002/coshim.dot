# =========== #
#  FZF-Tab    #
# =========== #
zstyle ':fzf-tab:*' fzf-flags --color=bg+:23
zstyle ':fzf-tab:*' show-group full
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' prefix ''

zstyle ':fzf-tab:complete:*' group-desc '[ %d ]'

zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
zstyle ':fzf-tab:complete:kill:*' popup-pad 0 3

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0

# fzf tab
bindkey "^I" expand-or-complete
bindkey "^ " fzf-tab-complete

bindkey -M menuselect '^[' send-break
bindkey -M menuselect 'q' send-break

# TODO: carapace

# ===========  #
#  autosuggest #
# ===========  #
ZSH_AUTOSUGGEST_STRATEGY+=(match_prev_cmd completion)
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(expand-or-complete)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
# ZSH_AUTOSUGGEST_COMPLETION_IGNORE='( |man |pikaur -S )*'
# 太长的行不用触发建议
ZSH_AUTOSUGGEST_HISTORY_IGNORE='?(#c80,)'


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
fi

# =========== #
#  dircolors  + LS #
# =========== #
(( $+commands[gdircolors] )) && eval $(gdircolors $Z_DOT_PATH/stores/DIR_COLORS)
(( $+commands[dircolors] )) && eval $(dircolors $Z_DOT_PATH/stores/DIR_COLORS)
(( $+commands[gls] )) && alias ls='gls --color=auto'
# zstyle ":completion:*" list-colors "${(s.:.)ZLS_COLORS}"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# =========== #
#   atuin     #
# =========== #
# Manual bind ^p as local dir search
if (( $+commands[atuin] )); then
    eval "$(atuin init zsh --disable-up-arrow)"
    bindkey -M emacs '^p' atuin-up-search
fi

# ============= #
#   Rust Tools  #
# ============= #
(( $+commands[bat] )) && alias cat='bat'
(( $+commands[difft])) && alias diff='difft'

if (( $+commands[eza] )); then
    alias ls='eza'
    alias ll='eza -lh --icons'
    alias la='eza -a --icons'
    alias tree='eza --tree --icons'
fi


# ============= #
#   carapace    #
# ============= #
if (( $+commands[carapace] )); then
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
    # eval "$(carapace _carapace zsh)"
    source <(carapace _carapace)
    zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'
fi
