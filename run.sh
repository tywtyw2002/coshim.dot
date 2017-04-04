#!/bin/bash

# curl -L http://bootstrap.saltstack.org | bash -s -- -M -N stable

FLAG_NOBACKUP=false
FLAG_FORCE=false

BACKUP_LIST=()
REPO_LIST=()
CLINK_LIST=()
PRECMD_LIST=()
POSTCMD_LIST=()

INSTALL_LOG="$HOME/dotfiles-install-`date +%Y%m%d`.log"

function args_hookup() {
    [ -z "$@" ] && return

    for arg in "$@"
    do
        case $arg in
            --force)
                FLAG_FORCE=true
                ;;
            --no-backup)
                FLAG_NOBACKUP=true
                ;;
            *)
                ;;
        esac
    done
}

args_hookup $@

function _do_shell() {
    echo "> $*" >> $INSTALL_LOG
    eval "$@" 2>&1 >> $INSTALL_LOG ||  {
        echo -e "\033[0;31mExecute command $@ failed. \033[0m"
        echo -e "\033[0;32mSee logs at $INSTALL_LOG\033[0m"
        exit 1
    }
}

function precheck_command () {
    echo -e "\033[0;34mCheck Required Commands.....\033[0m"
    local check_failed=false
    for cmd in "$@"
    do
        if ! cmd_loc=$(type -p "$cmd") || [ -z "$cmd_loc" ]; then
            echo -e "  >\033[0;32mCommand $cmd not found.\033[0m"
            check_failed=false
          fi
    done

    # check result.
    if [ "$check_failed" = true ] ; then
        echo "Pre-process Check Failed, Please install above commands."
        exit -1
    fi
}

function precheck_repo() {
    echo -e "\033[0;34mCheck Exists Git Repo.....\033[0m"
    local check_failed=false

    for item in "${REPO_LIST[@]}"
    do
        args=($=item)
        [ -d "$HOME/$args[2]" ] && check_failed=true && \
            echo -e "  >\033[0;32mRepo: $args[2] exists.\033[0m"
    done

    if [ "$check_failed" = true ] ; then
        if [ "$FLAG_FORCE" = true ]; then
            echo -e "\033[0;34mOverride Repo Checking Result, Continue.\033[0m"
        fi
        echo -e "\033[0;33mRepo check failed."
        echo "Use --force flag or remove exists repo."
        exit 1
    fi
}

function pre_backup () {
    if [ "$FLAG_NOBACKUP" = false ]; then
        echo -e "\033[0;35mSkipping Backup....\033[0m"
        return 0
    fi

    local backup="dotfile-backup-`date +%Y%m%d`"
    local backup_path="/tmp/$backup"
    mkdir $backup_path

    echo -e "\033[0;34mStarting backup.\033[0m"

    for item in "${BACKUP_LIST[@]}"
    do
        printf "  >\032[0;33mProcessing $item.........."
        [ -f "$item" -a ! -h "$item "] && mv $item $backup_path
        [ -d "$item" ] && mv $item $backup_path
        printf "\033[0;32mDone\033[0m\n"
    done

    tar czf "$HOME/$backup.tar.gz" $backup_path
    rm -r $backup_path
    echo -e "\033[0;32mBackup Done.\033[0m"
    echo "Backup Location: $HOME/$backup.tar.gz"
}

function pre_cleanup() {
    printf "\033[0;33mCleanup dotfile............"
    for item in "${BACKUP_LIST[@]}"
    do
        [ -f $item ] && rm $item
        [ -d $item ] && rm -r $item
    done
    printf "\033[0;32mOK\033[0m\n"

    printf "\033[0;33mCleanup dot repo............"
    for item in "${REPO_LIST[@]}"
    do
        args=($=item)
        [ -d $args[2] ] && rm -r $args[2]
    done
    printf "\033[0;32mDone\033[0m\n"
}

function _do_link() {
    for item in "${CLINK_LIST[@]}"
    do
        args=($=item)
        printf -e "\033[0;33mClone Repo $args[0]........."
        local spath="$HOME/$args[1]"
        if [ ! -e $spath ]; then
            echo -e "\033[0;31mCannot link file $spath, file is not exists.\033[0m"
            exit 2
        fi
        _do_shell ln -sf $spath $HOME/$args[2]
        printf "\033[0;32mDone\033[0m\n"
    done

}

function _do_repoclone() {
    for item in "${REPO_LIST[@]}"
    do
        args=($=item)
        printf "\033[0;33mClone Repo $args[0]........."
        _do_shell git clone --quiet $args[0] $HOME/$args[1]
        printf "\033[0;32mDone\033[0m\n"
    done
}

function _do_zegn_setup() {
    printf "Configuring local zsh........."
    if ! cmd_loc=$(type -p zsh) || [ -z "$cmd_loc" ]; then
        echo -e "\033[0;32mSkipping (No ZSH)\033[0m"
        return 1
    fi
    _do_shell zsh $HOME/.my_config/zgen_init.sh
    echo -e "\033[0;34mDone\033[0m"
}

function ccommit() {
    echo -e "\033[0;34mInstalling Dotfiles......."
    precheck_command git

    precheck_repo
    pre_backup
    pre_cleanup

    # do command in precmd list
    for cmd in "${PRECMD_LIST[@]}"
    do
        _do_shell cmd
    done

    # running install.
    _do_repoclone
    _do_link

    # zsh install zgen
    _do_zegn_setup

    # post running cmd
    for cmd in "${POSTCMD_LIST[@]}"
    do
        _do_shell cmd
    done
    echo -e "\033[0;32mInstalling Done"
}

function cclean() {
    BACKUP_LIST+=("$HOME/$1")
}

function clink() {
    if (( $# != 2 )); then
        echo "\033[0;31mError: Unexcepted clink arguments.\033[0m"
        echo "  >clink $*"
        exit -2
    fi

    BACKUP_LIST+=("$HOME/$1")
    CLINK_LIST+=("$1 $2")
}

function crepo() {
    # crepo <source>
    if (( $# != 2 )); then
        echo "\033[0;31mError: Unexcepted crepo arguments.\033[0m"
        echo "  >crepo $*"
        exit -2
    fi
    REPO_LIST+=("https://github.com/$1.git $2")
}

function crepo_ssh() {
   if (( $# != 2 )); then
        echo "\033[0;31mError: Unexcepted crepo_ssh arguments.\033[0m"
        echo "  >crepo_ssh $*"
        exit -2
    fi
    REPO_LIST+=("git@github.com:$1.git $2")
}

function ccmd_pre() {
    PRECMD_LIST+=("$*")
}

function ccmd_post() {
    POSTCMD_LIST+=("$*")
}

cclean .zshrc
cclean .zsh_local

clink .vim/vimrc .vimrc
clink .my_config/screenrc .screenrc
clink .my_config/bashrc .bashrc
clink .my_config/tmux.conf .tmux.conf
clink .my_config/Xresources .Xdefaults
clink .my_config/Xresources .Xresources
clink .my_config/xsession .xsession
clink .my_config/xinitrc .xinitrc

crepo_ssh tywtyw2002/my.vim .vim
crepo_ssh tywtyw2002/coshim.dot .my_config
crepo gmarik/vundle .vim/bundle/vundle

ccmd_post echo "source $HOME/.zsh_local" >.zshrc \
          echo "source $HOME/.my_config/zshrc" >> .zshrc

ccommit
