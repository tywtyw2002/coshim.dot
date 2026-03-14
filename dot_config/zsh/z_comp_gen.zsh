# https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh

# Abort in dumb terminals (e.g., inside some minimal editors/CI)
[[ "$TERM" == dumb ]] && return 1

#############
#  Options  #
#############

# Reset completion menu style to avoid inheriting unexpected settings.
zstyle -d ':completion:*:*:*:*:*' menu

# Keep completion behavior predictable and fast.
unsetopt MENU_COMPLETE   # do not cycle completion with successive tabs
unsetopt AUTO_LIST       # do not automatically list on ambiguous completion
unsetopt CASE_GLOB       # respect case in globbing (we add matchers below instead)

setopt AUTO_MENU         # show menu on second Tab (or immediately with menu style)
setopt COMPLETE_IN_WORD  # complete from cursor position, not only at end
setopt ALWAYS_TO_END     # move cursor to end after completion

############
#  Styles  #
############

# List/menu behavior
zstyle ':completion:*' menu select
zstyle ':completion:*' list-ambiguous true
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-packed true
zstyle ':completion:*' insert-sections yes
zstyle ':completion:*' separate-sections yes

# Grouping and verbosity
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Case-insensitive + smarter separators matching
zstyle ':completion:*' matcher-list \
  'm:{[:lower:]}={[:upper:]}' \
  'm:{[:upper:]}={[:lower:]}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# Manuals
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# Sorting
# NOTE: Many people prefer "modification" sort for files, but no sort for some commands.
zstyle ':completion:*' file-sort modification
zstyle ':completion:files' sort false
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*:eza' sort false

###############
#  Caching    #
###############

# Enable completion cache (helps large completion sets).
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"

############################
#  Output / UI formatting  #
############################

# Section/header formatting
zstyle -e ':completion:*' format '
  if (( IN_FZF_TAB )); then
    reply=("[%d]")
  elif (( ${#CARAPACE_COMPLINE} )); then
    reply=("%K{5}%F{252}Completing %d%f%k")
  else
    reply=(" %F{yellow}-- %d --%f")
  fi
'

# Group labels and messages
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'

zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:messages'    format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings'    format ' %F{red}-- no matches found --%f'

# List prompt and selection prompt
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*:default' select-prompt '%F{black}%K{12}line %l %p%f%k'

# Keep some message groups quiet (avoid huge history line lists)
zstyle ':completion:*:history-lines' format ''
zstyle ':completion:*:fc:*' tag-order options -

##############################
#  Completers (core logic)   #
##############################

# Command completer tuning
zstyle ':completion:*:*(approximate|correct):-command-:*:*' max-errors 0
zstyle ':completion:*:*(approximate|correct):-command-:*:*' tag-order '-'

# Choose completers depending on cursor position:
# - At first word: only complete/ignored (faster, avoids noisy corrections)
# - Otherwise: expand + fuzzy + correct + approximate
zstyle -e ':completion:*' completer '
  if [[ $CURRENT -eq 1 ]]; then
    reply=(_complete _ignored)
  else
    reply=(_expand _complete _complete:-fuzzy _correct _approximate _ignored)
  fi
'

# Approximate matching aggressiveness (cap at 5)
zstyle -e ':completion:*:approximate:*' max-errors \
  'reply=($((($#PREFIX+$#SUFFIX)/3>5?5:($#PREFIX+$#SUFFIX)/3))numeric)'

##############################
#  Group ordering / tags     #
##############################

zstyle ':completion:*:all-expansions' group-name 'expansion'
zstyle ':completion:*' group-order \
  expansions options aliases functions builtins reserved-words \
  executables all-files local-directories directories suffix-aliases

# Option matching for flags like -foo / --bar
zstyle ':completion:*:options' matcher 'b:-=+'

# Misc ignore rules
zstyle ':completion:*' prefix-needed yes
zstyle ':completion:*:functions' ignored-patterns '*.*' '*:*' '+*'
zstyle ':completion:*:users'     ignored-patterns '_*'
zstyle ':completion:*:widgets'   ignored-patterns '*.*' '*:*'
zstyle ':completion:*' single-ignored ''
zstyle ':completion:*:expand-alias:*' complete yes

# Expansion style
zstyle ':completion:*:expand:*' tag-order 'expansions all-expansions' -
zstyle ':completion:*:expand:*' accept-exact continue
zstyle ':completion:*:expand:*' add-space no
zstyle ':completion:*:expand:*' glob yes
zstyle ':completion:*:expand:*' keep-prefix no
zstyle ':completion:*:expand:*' substitute yes
zstyle ':completion:*:expand:*' subst-globs-only yes

# Command tag order logic (kept from your original, just cleaned)
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

# Tilde completion order
zstyle ':completion:*:-tilde-:*' tag-order directory-stack named-directories

# Correction tag ordering
zstyle ':completion:*:approximate:*' tag-order 'corrections'
zstyle ':completion:*:(approximate|correct):*' tag-order '! original' -

# Git tag ordering (reduce noise when there are matches)
zstyle -e ':completion:*:git-*:*' tag-order 'autocomplete_config_tag-order_git "$@"'
autocomplete_config_tag-order_git() {
  reply=()
  (( compstate[nmatches] )) && reply=( '! heads(|-*) *-remote remote-* blob-*' - )
}

##############################
#  Path completion behavior  #
##############################

# Complete only the tail of a path (less noisy)
zstyle ':completion:*' ignore-parents 'parent pwd directory'

# Path expansion and suffix listing
zstyle ':completion:*:paths' expand suffix
zstyle ':completion:*:paths' list-suffixes yes

# Special dirs (., ..) handling
zstyle -d ':completion:*' special-dirs
zstyle ':completion:*:paths' special-dirs no

# File patterns: show directories first; in fzf-tab mode, also show "all files" group
zstyle -e ':completion:*' file-patterns autocomplete:config_file-patterns
autocomplete:config_file-patterns() {
  if (( IN_FZF_TAB )); then
    typeset -ga reply=( '%p:all-files:all *(-/):directories:directory %p(#q^-/):globbed-files' )
  else
    typeset -ga reply=( '*(-/):directories:directory %p(#q^-/):globbed-files' )
  fi
}

# Command position file patterns (avoid listing files unless it looks like a path)
zstyle -e ':completion:*:-command-:*' file-patterns autocomplete:config_file-patterns_command
autocomplete:config_file-patterns_command() {
  [[ $PREFIX$SUFFIX != */* ]] && typeset -ga reply=( '*(-/):directories:directory ./*(-*^/):executables:"executable file"' )
}

# Completion for dot/source commands: skip zwc, handle dirs
zstyle ':completion:*:(.|source):*' file-patterns \
  '%p(#q-/):directories:directory %p~*.zwc(-.^*):globbed-files' \
  '%p~*.zwc(-^/):globbed-files'

##############################
#  Parameter listing tweaks  #
##############################

# Do not combine parameters that share the same value
zstyle ':completion:*:parameters' list-grouped no
zstyle ':completion:*:parameters' extra-verbose yes

##############################
#  Formatting helpers        #
##############################

# Use a subtle bold-ish style for description headers.
zstyle -e ':completion:*:descriptions'   format autocomplete:config:format %d
zstyle -e ':completion:*:all-expansions' format autocomplete:config:format expansion
zstyle -e ':completion:*:expansions'     format autocomplete:config:format '"globbed files"'

autocomplete:config:format() {
  reply=( $'%{\e[0;1;2m%}'$1$'%{\e[0m%}' )
}

zstyle -e ':completion:*:warnings' format autocomplete:config:format:warnings
autocomplete:config:format:warnings() {
  autocomplete:config:format 'no matching %d completions'
}

# Messages styling
zstyle ':completion:*:messages' format '%F{9}%d%f'

##############################
#  SSH hosts completion      #
##############################

# Build a hosts list from ~/.ssh/config and ~/.ssh/known_hosts and cache it.
# The cache is stored under $TMPDIR (or /tmp) to keep it fast and ephemeral.

typeset -ga hosts
hosts=()

CACHE_FILE="${TMPDIR:-/tmp}/zsh-${UID}/ssh-hosts.zsh"
SSH_CONFIG="$HOME/.ssh/config"
SSH_KNOWN="$HOME/.ssh/known_hosts"

# Extract host patterns from ssh config ("Host x y z")
__ssh_hosts_from_config() {
  [[ -f "$SSH_CONFIG" ]] || return 0
  # Skip wildcard-only hosts to reduce noise, keep explicit patterns.
  grep -E '^[[:space:]]*Host[[:space:]]+' "$SSH_CONFIG" \
    | awk '{
        $1="";
        for (i=1;i<=NF;i++) {
          if ($i !~ /[*?]/) print $i
        }
      }'
}

# Extract hosts from known_hosts (handle comma-separated, bracketed, and ignore hashed entries).
__ssh_hosts_from_known_hosts() {
  [[ -f "$SSH_KNOWN" ]] || return 0
  awk '
    $1 ~ /^\|1\|/ { next }                 # ignore hashed known_hosts entries
    {
      n = split($1, a, ",");
      for (i=1;i<=n;i++) {
        h=a[i];
        gsub(/^\[/, "", h);                # [host]:port
        sub(/\](:[0-9]+)?$/, "", h);
        sub(/:[0-9]+$/, "", h);            # host:port
        if (h != "" && h !~ /^[0-9.]+$/) print h
      }
    }
  ' "$SSH_KNOWN"
}

# Load from cache if it is newer than inputs
if [[ -f "$SSH_CONFIG" || -f "$SSH_KNOWN" ]]; then
  if [[ -f "$CACHE_FILE" ]] \
     && { [[ ! -f "$SSH_CONFIG" ]] || [[ "$CACHE_FILE" -nt "$SSH_CONFIG" ]] } \
     && { [[ ! -f "$SSH_KNOWN"  ]] || [[ "$CACHE_FILE" -nt "$SSH_KNOWN"  ]] }; then
    source "$CACHE_FILE"
  else
    mkdir -p "${CACHE_FILE:h}"

    hosts+=(${(f)$(__ssh_hosts_from_config)})
    hosts+=(${(f)$(__ssh_hosts_from_known_hosts)})

    # Unique + stable
    hosts=(${(u)hosts})

    # Persist cache (and compile if possible)
    typeset -p hosts >! "$CACHE_FILE" 2>/dev/null
    (( $+functions[zcompile] )) && zcompile "$CACHE_FILE" 2>/dev/null
  fi
fi

zstyle ':completion:*:hosts' hosts $hosts

##############################
#  SSH/SCP/RSYNC completion  #
##############################

# Do not sort hosts (keep input order / cached order)
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' sort false

# Keep SSH completion formatting consistent with your base style
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' group-name ''
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' verbose yes

# Tag ordering for scp/rsync-like tools
zstyle ':completion:*:(scp|rsync|sshfs):*' tag-order \
  'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync|sshfs):*' group-order \
  users files all-files hosts-domain hosts-host hosts-ipaddr

# Tag ordering for ssh/mosh
zstyle ':completion:*:(ssh|mosh):*' tag-order \
  'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(ssh|mosh):*' group-order \
  users hosts-domain hosts-host users hosts-ipaddr

# Ignore noise in host groups
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*:hosts-host' ignored-patterns \
  '*(.|:)*' loopback localhost broadcasthost 'ip6-*'
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*:hosts-domain' ignored-patterns \
  '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*:hosts-ipaddr' ignored-patterns \
  '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' \
  '127.0.*' '255.255.255.255' '::1' 'fe80::*' 'ff02::*'
