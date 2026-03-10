##zsh comppletion copy from prezto
# https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh

if [[ "$TERM" == 'dumb' ]]; then
    return 1
fi

##############
#   Styles   #
##############
LISTMAX=200
# Group matches and describe.
# fuck omh
# setopt menu_complete
zstyle -d ':completion:*:*:*:*:*' menu
# zstyle ':completion:*' menu yes select
zstyle ':completion:*' list-ambiguous true
zstyle ':completion:*' insert-unambiguous true
# zstyle ':completion:*' insert-tab false
# zstyle ':completion:*' original true
zstyle ':completion:*' list-packed true

zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

zstyle -e ':completion:*' menu '
  # echo "=========" >> /tmp/zsh1123
  # typeset -p >> /tmp/zsh1123
  if [[ -z "$PREFIX" && -z "$SUFFIX" ]]; then
      reply=( yes select )
  else
      if [[ "$LASTWIDGET" == "complete-word" ]]; then
          reply=( yes select )
     else
          reply=( select )
     fi
  fi
'

zstyle -e ':completion:*' format '
  if (( IN_FZF_TAB )); then
    reply=("[%d]")
  else
    reply=(" %F{yellow}-- %d --%f")  # 自带 menu：带颜色
  fi
'

zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
# zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*' file-sort modification
zstyle ':completion:*:eza' sort false
zstyle ':completion:files' sort false



# copy from autocompletion
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"

# _expand: 展开别名/变量, _complete: 基础补全, _ignored: 之前忽略的也尝试, _approximate: 允许 1-2 个错别字
zstyle ':completion:*' completer \
      _expand _complete _complete:-fuzzy _correct _approximate _ignored
#
# 根据输入长度动态决定允许多少个错别字：(长度/3)
zstyle ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'

# zstyle ':completion:*:-command-:*' group-name commands
zstyle ':completion:*:all-expansions' group-name 'expansion'
zstyle ':completion:*' group-order \
    expansions options aliases functions builtins reserved-words \
    executables all-files local-directories directories suffix-aliases

zstyle ':completion:*:options' matcher 'b:-=+'

zstyle ':completion:*' prefix-needed yes
zstyle ':completion:*:functions'  ignored-patterns '*.*' '*:*' '+*'
zstyle ':completion:*:users'      ignored-patterns '_*'
zstyle ':completion:*:widgets'    ignored-patterns '*.*' '*:*'
zstyle ':completion:*' single-ignored ''
zstyle ':completion:*:expand-alias:*' complete yes

zstyle ':completion:*:expand:*' tag-order 'expansions all-expansions' -
zstyle ':completion:*:expand:*' accept-exact continue
zstyle ':completion:*:expand:*' add-space no
zstyle ':completion:*:expand:*' glob yes
zstyle ':completion:*:expand:*' keep-prefix no  # Needed for file type highlighting
zstyle ':completion:*:expand:*' substitute yes
zstyle ':completion:*:expand:*' subst-globs-only yes

zstyle -e ':completion:*:-command-:*' tag-order autocomplete:config_tag-order_command
autocomplete:config_tag-order_command() {
  if [[ $PREFIX == (|.|*/*) ]]; then
    typeset -ga reply=( 'suffix-aliases (|*-)directories executables (|*-)files' - )
  else
    typeset -ga reply=( 'aliases suffix-aliases functions reserved-words builtins' )
    if (( path[(I).] )); then
      reply[1]+=' (|*-)directories executables (|*-)files commands'
    else
      reply[1]+=' commands (|*-)directories executables (|*-)files'
    fi
  fi
}

zstyle ':completion:*:-tilde-:*' tag-order directory-stack named-directories

zstyle ':completion:*:(approximate|correct):*' tag-order '! original' -

# Don't show the giant list of history lines.
zstyle ':completion:*:fc:*' tag-order options -

zstyle -e ':completion:*:git-*:*' tag-order 'autocomplete_config_tag-order_git "$@"'
autocomplete_config_tag-order_git() {
  reply=()
  (( compstate[nmatches] )) &&
      reply=(
          '! heads(|-*) *-remote remote-* blob-*'
          -
      )
}

# Complete only the tail of a path.
zstyle ':completion:*' ignore-parents 'parent pwd directory'
zstyle ':completion:*:paths' expand suffix
zstyle ':completion:*:paths' list-suffixes yes
zstyle -d ':completion:*' special-dirs
zstyle ':completion:*:paths' special-dirs no

# zstyle ':completion:*' file-patterns '*(-/):directories:directory %p(#q^-/):globbed-files'

# zstyle ':completion:*' file-patterns '*(-/):directories:directory %p(#q^-/):globbed-files %p:all-files:all'

zstyle -e ':completion:*' file-patterns autocomplete:config_file-patterns
autocomplete:config_file-patterns() {
    if (( IN_FZF_TAB )); then
        # typeset -ga reply=( '*(-/):directories:directory %p(#q^-/):globbed-files %p:all-files:all' )
        typeset -ga reply=( '%p:all-files:all *(-/):directories:directory %p(#q^-/):globbed-files' )
    else
        typeset -ga reply=( '*(-/):directories:directory %p(#q^-/):globbed-files' )
    fi
}
# zstyle -e ':completion:*' tag-order '
#   if (( IN_FZF_TAB )); then
#     reply=("all-files directories globbed-files")
#   else
#     reply=("directories globbed-files" "-")
#   fi
# '

# zstyle ':completion:*'  tag-order directories globbed-files

zstyle -e ':completion:*:-command-:*'   file-patterns autocomplete:config_file-patterns_command
autocomplete:config_file-patterns_command() {
  [[ $PREFIX$SUFFIX != */* ]] &&
      typeset -ga reply=( '*(-/):directories:directory ./*(-*^/):executables:"executable file"' )
}

zstyle ':completion:*:(.|source):*'  file-patterns \
    '%p(#q-/):directories:directory %p~*.zwc(-.^*):globbed-files' '%p~*.zwc(-^/):globbed-files'



# Don't combine parameters with same values.
zstyle ':completion:*:parameters' list-grouped no

# zstyle -e ':completion:*:-command-:*'    format autocomplete:config:format command
zstyle -e ':completion:*:descriptions'   format autocomplete:config:format %d
zstyle -e ':completion:*:all-expansions' format autocomplete:config:format expansion
autocomplete:config:format() {
  reply=( $'%{\e[0;1;2m%}'$1$'%{\e[0m%}' )
}
zstyle -e ':completion:*:all-expansions' format autocomplete:config:format expansion
zstyle -e ':completion:*:expansions'     format autocomplete:config:format '"globbed files"'

zstyle -e ':completion:*:warnings'    format autocomplete:config:format:warnings
autocomplete:config:format:warnings() {
  [[ $CURRENT == 1 && -z $PREFIX$SUFFIX ]] ||
      autocomplete:config:format 'no matching %d completions'
}

zstyle ':completion:*:messages'       format '%F{9}%d%f'
zstyle ':completion:*:history-lines'  format ''

zstyle ':completion:*' auto-description '%d'
zstyle ':completion:*:parameters' extra-verbose yes
zstyle ':completion:*:default' select-prompt '%F{black}%K{12}line %l %p%f%k'

zstyle ':completion:*' insert-sections yes
zstyle ':completion:*' separate-sections yes

function _instant_menu_trigger() {
    # 只有输入第一个字母，且不是删除/回车时触发
    if [[ $#BUFFER -gt 0 && $LASTWIDGET == (self-insert|vi-self-insert) ]]; then
        # 强制显示补全列表
        zle list-choices
    fi
}
# autoload -Uz add-zle-hook-widget
# add-zle-hook-widget line-pre-redraw _instant_menu_trigger


hosts=()
CACHE_FILE="${TMPDIR:-/tmp}/zsh-${UID}/ssh-hosts.zsh"
if [[ -f ~/.ssh/config ]] || [[ -f ~/.ssh/known_hosts ]] ; then
  if [[ "$CACHE_FILE" -nt "$HOME/.ssh/config" ]] && [[ "$CACHE_FILE" -nt "$HOME/.ssh/known_hosts" ]]; then
    source "$CACHE_FILE"
  else
    mkdir -p "${CACHE_FILE:h}"
    # hosts=$(grep '^Host ' ~/.ssh/config | awk '{first = $1; $1 = ""; print $0; }' )
    [[ -f ~/.ssh/config ]] && hosts+=(${=$(grep '^Host ' ~/.ssh/config | awk '{first = $1; $1 = ""; print $0; }' )})
    # hosts="$hosts$(cat ~/.ssh/known_hosts | awk '{first=$1; print $1} ')"
    [[ -f ~/.ssh/known_hosts ]] && hosts+=(${="$(cat ~/.ssh/known_hosts | awk '{first=$1; print $1} ')"})
    hosts=(${(u)hosts})
    # hosts=($(echo $hosts | uniq |xargs))
    typeset -p hosts >! "$CACHE_FILE" 2> /dev/null
    zcompile "$CACHE_FILE"
  fi
fi

zstyle ':completion:*:hosts' hosts $hosts


# SSH/SCP/RSYNC
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' sort false
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' format ' %F{yellow}-- %d --%f'

zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' group-name ''
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' verbose yes

zstyle ':completion:*:(scp|rsync|sshfs):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync|sshfs):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr

zstyle ':completion:*:(ssh|mosh):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(ssh|mosh):*' group-order users hosts-domain hosts-host users hosts-ipaddr

zstyle ':completion:*:(ssh|scp|sshfs|mosh):*:hosts-host' ignored-patterns '*(.|:)*' loopback localhost broadcasthost 'ip6-*'
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.*' '255.255.255.255' '::1' 'fe80::*' 'ff02::*'


############
#   deno   #
############
if (( $+commands[deno] )); then
    # If the completion file doesn't exist yet, we need to autoload it and
    # bind it to `deno`. Otherwise, compinit will have already done that.
    if [[ ! -f "$ZSH_CACHE_DIR/completions/_deno" ]]; then
      typeset -g -A _comps
      autoload -Uz _deno
      _comps[deno]=_deno
    fi

    deno completions zsh >| "$ZSH_CACHE_DIR/completions/_deno" &|
fi
