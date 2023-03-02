#!/usr/bin/env zsh

ZHOME=$HOME/.zgen
ZGEN_INIT="${ZHOME}/init.zsh"
CFG_HOME=$HOME/.my_config
ZLHOME=$CFG_HOME/zsh_custom
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#reset all zgen plugin
zgen-plugin-reset() {
    #check --doit parameter.
    if ! [[ ${1} = '--doit' ]]; then
        echo "Execute reset must with --doit parameter."
        echo "Exit..."
        exit 1
    fi

    source $ZHOME/zgen.zsh
    zgen reset
    # #remove all installed plugin
    for item in $(find $ZHOME/* -maxdepth 0 -type d); do
        rm -rf $item
    done

    # remove zwc
    for item in $(find $ZHOME/*.zwc -maxdepth 0); do
        rm -f $item
    done

    zgen-comp-reset

    git -C $ZHOME reset --hard

    echo 'Zgen cleanup finish.'
}

zgen-comp-reset () {
    # remove zcompdump_5.9
    for item in $(find $ZHOME/zcomp* -maxdepth 0); do
        rm -f $item
    done

    for item in $(find $HOME/.zcomp* -maxdepth 0); do
        rm -f $item
    done
}


#install zgen plugin
zgen-install-plugin() {
    #load zgen
    if [[ -e $ZHOME/zgen.zsh ]]; then
        source $ZHOME/zgen.zsh
    else
        echo "No Zgen found, exit."
        exit 1
    fi

    if zgen saved; then
        echo "Zgen already initiated, try reset first."
        exit 1
    fi

    #zgen
    # zgen load unixorn/autoupdate-zgen

    # common plugin
    zgen ohmyzsh
    zgen ohmyzsh plugins/cp
    zgen ohmyzsh plugins/sudo
    zgen ohmyzsh plugins/history
    zgen ohmyzsh plugins/rsync
    zgen ohmyzsh plugins/colored-man-pages
    #zgen ohmyzsh plugins/compleat

    zgen ohmyzsh plugins/tmux
    zgen ohmyzsh plugins/tmux-cssh
    zgen ohmyzsh plugins/tmuxinator

    #git
    zgen ohmyzsh plugins/git
    zgen ohmyzsh plugins/gh
    zgen ohmyzsh plugins/gitignore

    #tools
    zgen ohmyzsh plugins/urltools
    zgen ohmyzsh plugins/encode64
    zgen ohmyzsh plugins/httpie
    zgen ohmyzsh plugins/ag
    #zgen ohmyzsh plugins/autojump

    #python
    zgen ohmyzsh plugins/pip
    zgen ohmyzsh plugins/python
    zgen ohmyzsh plugins/pyenv
    zgen ohmyzsh plugins/pylint

    zgen ohmyzsh plugins/yarn
    zgen ohmyzsh plugins/zoxide

    #zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-completions src
    # zgen load psprint/history-search-multi-word
    #zgen load zdharma-continuum/history-search-multi-word
    zgen load joshskidmore/zsh-fzf-history-search

    zgen load supercrabtree/k
    #zgen load rupa/z
    # zgen load skywind3000/z.lua

    # zgen load lincheney/fzf-tab-completion zsh/fzf-zsh-completion.sh
    zgen load Aloxaf/fzf-tab

    zgen bin bigH/git-fuzzy

    #zsh themes
    # zgen load $ZLHOME/themes/pygmalion.zsh-theme

    #load custom zgen plugins
    zgen load $ZLHOME/completion.zsh
    zgen load $ZLHOME/editor.zsh

    # load custom shell scripts
    zgen load $CFG_HOME/shellrc

    # zsh completion
    GENCOMPL_FPATH=$HOME/.zsh/complete
    zgen load RobSis/zsh-completion-generator

    zgen load $ZLHOME/completion
    zgen load $HOME/.zsh_completion

    # local bins
    zgen bin $CFG_HOME/mybin
    zgen bin $CFG_HOME/mybin/local

    case $(uname) in
        "Darwin"*)
            zgen ohmyzsh plugins/brew
            #zgen ohmyzsh plugins/cask
            zgen ohmyzsh plugins/macos

            zgen ohmyzsh plugins/sublime

            zgen bin $CFG_HOME/mybin/macos
            ;;
        "Linux"*)
            command -v yum >/dev/null 2>&1 && zgen ohmyzsh plugins/yum
            command -v apt-get >/dev/null 2>&1 && zgen ohmyzsh plugins/debian

            zgen bin $CFG_HOME/mybin/linux
            ;;
    esac

    zgen save
}

zgen-check-update() {
    if [[ ! -e $ZGEN_INIT ]]; then
        zgen-install-plugin
    else
        source $ZHOME/zgen.zsh
        zgen autoupdate
    fi
}


if [[ ${1} = "reset" ]]; then
    zgen-plugin-reset $2
elif [[ ${1} = "creset" ]]; then
    zgen-comp-reset
elif [[ ${1} = "update" ]]; then
    zgen-check-update
else
    zgen-install-plugin
fi
