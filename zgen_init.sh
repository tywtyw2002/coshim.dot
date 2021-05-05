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
    #remove all installed plugin
    for item in $(find $ZHOME/* -maxdepth 0 -type d); do
        rm -rf $item
    done

    echo 'Zgen cleanup finish.'
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
    zgen load unixorn/autoupdate-zgen

    # common plugin
    zgen oh-my-zsh
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/history
    zgen oh-my-zsh plugins/rsync
    zgen oh-my-zsh plugins/colored-man-pages
    #zgen oh-my-zsh plugins/compleat

    zgen oh-my-zsh plugins/tmux
    zgen oh-my-zsh plugins/tmux-cssh
    zgen oh-my-zsh plugins/tmuxinator

    #tools
    zgen oh-my-zsh plugins/urltools
    zgen oh-my-zsh plugins/encode64
    #zgen oh-my-zsh plugins/autojump

    #python
    zgen oh-my-zsh plugins/pip
    zgen oh-my-zsh plugins/python


    #zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-completions src
    zgen load psprint/history-search-multi-word

    zgen load supercrabtree/k
    #zgen load rupa/z
    zgen load skywind3000/z.lua

    zgen load lincheney/fzf-tab-completion zsh/fzf-zsh-completion.sh

    #zsh themes
    zgen load $ZLHOME/themes/pygmalion.zsh-theme

    #load custom zgen plugins
    zgen load $ZLHOME/completion.zsh
    zgen load $ZLHOME/editor.zsh

    #load custom shell scripts
    zgen load $CFG_HOME/shellrc

    #zsh completion
    GENCOMPL_FPATH=$HOME/.zsh/complete
    zgen load RobSis/zsh-completion-generator

    case $(uname) in
        "Darwin"*)
            zgen oh-my-zsh plugins/brew
            #zgen oh-my-zsh plugins/cask
            zgen oh-my-zsh plugins/osx

            zgen oh-my-zsh plugins/sublime
            ;;
        "Linux"*)
            command -v yum >/dev/null 2>&1 && zgen oh-my-zsh plugins/yum
            command -v apt-get >/dev/null 2>&1 && zgen oh-my-zsh plugins/debian

        ;;
    esac

    zgen save
}

zgen-check-update() {
    if [[ ! -e $ZGEN_INIT ]]; then
        zgen-install-plugin
    fi
}


if [[ ${1} = "reset" ]]; then
    zgen-plugin-reset $2
elif [[ ${1} = "update" ]]; then
    zgen-check-update
else
    zgen-install-plugin
fi
