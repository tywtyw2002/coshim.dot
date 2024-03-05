#LESS man page colors -------------------------------------------------

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# zgenom functions -----------------------------------------------------
function zcomp-reset() {
    # remove zcompdump_5.9
    for item in $(find $ZGEN_PATH/zcomp* -maxdepth 0); do
        rm -f $item
    done

    for item in $(find $HOME/.zcomp* -maxdepth 0); do
        rm -f $item
    done
}

function zgen-reset () {
    if ! [[ ${1} = '--doit' ]]; then
        echo "Execute reset must with --doit parameter."
        echo "Exit..."
        return 1
    fi

    zgenom reset

    # #remove all installed plugin
    for item in $(find $ZGEN_PATH/* -maxdepth 0 -type d); do
        rm -rf $item
    done

    # remove zwc
    for item in $(find $ZGEN_PATH/*.zwc -maxdepth 0); do
        rm -f $item
    done

    # restore repo
    git -C $ZGEN_PATH checkout -- .

    # reset comp
    zgen-comp-reset

    echo 'Zgen cleanup finish.'
}


# functions ------------------------------------------------------------

function mkcd() { mkdir "$1" && cd "$1"; }
function hex2dec { awk 'BEGIN { printf "%d\n",0x$1}'; }
function dec2hex { awk 'BEGIN { printf "%x\n",$1}'; }

# mktar - tarball wrapper
# usage: mktar <filename | dirname>
function mktar() { tar czf "${1%%/}.tar.gz" "${1%%/}/"; }

# calc - simple calculator
# usage: calc <equation>
function calc() { echo "$*" | bc; }

# mkmine - recursively change ownership to $USER:$USER
# usage:  mkmine, or
#         mkmine <filename | dirname>
function mkmine() { sudo chown -R ${USER} ${1:-.}; }

# nohup - run command detached from terminal and without output
# usage: nh <command>
function nh() { nohup "$@" &>/dev/null & }

# send public key to remote server
# usage: sendkey <user@remotehost>
sendkey()
{
    if [ $# -ge 1 ]; then
       echo $1
       ssh-copy-id -i ~/.ssh/id_ed25519 $1
    fi
}

function http_server() {
    local port="${1:-8000}"
    python3 -m SimpleHTTPServer "$port"
}

# function ssht(){
#   ssh $* -t 'tmux  -u a || tmux -u || /bin/zsh ||/bin/bash'
# }

# function sshcc(){
#   ssh $* -t 'tmux  -CC -u a || tmux -CC -u || /bin/zsh || /bin/bash'
# }

function cssh(){
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $*
}

function rssh(){
  local host=$(echo $1 | sed -n 's/^[a-zA-Z0-9]*@\(.*\)/\1/p')
  ssh-keygen -R ${host:-$1}
}

function pss() {
    ps aux | grep $1
}

function fixssh() {
    if [[ -n $TMUX && -n $SSH_AUTH_SOCK ]]; then
        eval $(tmux show-env    \
            | sed -n 's/^\(SSH_[^=]*\)=\(.*\)/export \1="\2"/p')
    fi
}

function fps() {
    command -v fzf >/dev/null 2>&1 || { echo "Fzf not found."; return 1; }

    (date; ps aux) |
      fzf --bind='ctrl-r:reload(date; ps aux)' \
          --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
          --preview='echo {}' --preview-window=down,3,wrap \
          --layout=reverse --height=80% | awk '{print $2}' | xargs kill -9
}

function certv() {
    command -v openssl > /dev/null 2>&1 || {echo "openssl not found."; return 1;}
    if [[ -f $1 ]]; then
        openssl x509 -in $1 -text -noout
    end
}
