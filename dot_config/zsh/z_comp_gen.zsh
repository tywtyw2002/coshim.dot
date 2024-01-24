##zsh comppletion copy from prezto
# https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh

if [[ "$TERM" == 'dumb' ]]; then
    return 1
fi

##############
#   Styles   #
##############
# Group matches and describe.
#zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
#zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

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

