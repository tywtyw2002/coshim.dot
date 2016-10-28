#!/usr/bin/env zsh

ZHOME=$HOME/.zgen
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#check git
command -v git >/dev/null 2>&1 || {
echo "Abort, Git is not installed."
exit 1
}

#clone zgen
git clone https://github.com/tarjoilija/zgen.git $ZHOME

#load zgen
source $ZHOME/zgen.zsh

#reset all zgen plugin
zgen-plugin-reset() {
    #check --doit parameter.
    if ! [[ ${2} = '--doit' ]]; then
        echo "Execute reset must with --doit parameter."
        echo "Exit..."
        exit 1
    fi

    zgen reset
    #remove all installed plugin
    for item in $(find $ZHOME/* -maxdepth 0 -type d); do
        rm -rf $item
    done
}


#install zgen plugin
zgen-install-plugin() {
    if zgen saved; then
        echo "Zgen already initiated, try reset first."
        exit 1
    fi

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
    zgen oh-my-zsh plugins/autojump

    #python
    zgen oh-my-zsh plugins/pip
    zgen oh-my-zsh plugins/python


    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-completions src
    zgen load psprint/history-search-multi-word

    zgen load supercrabtree/k
    #zgen load rupa/z


    #zsh themes
    zgen load $HOME/.my_config/zsh_custom/themes/pygmalion.zsh-theme

    case $(uname) in
        "Darwin"*)
            zgen oh-my-zsh plugins/brew
            zgen oh-my-zsh plugins/cask
            zgen oh-my-zsh plugins/osx

            zgen oh-my-zsh plugins/sublime
            ;;
        "Linux"*)
            command -v yum >/dev/null 2>&1 || zgen oh-my-zsh plugins/yum
            command -v apt-get >/dev/null 2>&1 || zgen oh-my-zsh plugins/debian

        ;;
    esac

    zgen save
}


cmd() {
    if [[ ${1} = "reset" ]]; then
        zgen-plugin-reset
    fi

    zgen-install-plugin
}

cmd
