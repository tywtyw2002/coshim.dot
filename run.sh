#!/bin/bash


FLAG_NOBACKUP=false
FLAG_FORCE=false
FLAG_SKIPSSH=false
FLAG_RELINK=false
FLAG_UPATE=false

BACKUP_LIST=()
REPO_LIST=()
CLINK_LIST=()
PRECMD_LIST=()
POSTCMD_LIST=()

GIT_SSH=false
INSTALL_LOG="$HOME/dotfiles-install-`date +%Y%m%d`.log"

LINE='------------------------------------------------- '

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
            --no-ssh)
                FLAG_SKIPSSH=true
                ;;
            --relink)
                FLAG_RELINK=true
                ;;
            --update)
                FLAG_UPDATE=true
                ;;
            *)
                ;;
        esac
    done
}

args_hookup $@

function _do_shell() {
    echo "> $*" >> $INSTALL_LOG
    eval "$*" >> $INSTALL_LOG 2>&1 ||  {
        echo -e "\033[0;31mExecute command $@ failed. \033[0m"
        echo -e "\033[0;35mSee logs at $INSTALL_LOG\033[0m"
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
            check_failed=true
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
        args=(${(s: :)${item}})
        [ -d "$HOME/${args[2]}" ] && check_failed=true && \
            echo -e "  >\033[0;31mRepo: ${args[2]} exists.\033[0m"
    done

    if [ "$check_failed" = true ] ; then
        if [ "$FLAG_FORCE" = true ] || [ "$FLAG_UPDATE" = true ] ; then
            echo -e "\033[0;35mOverride Repo Checking Result, Continue.\033[0m"
            return 1
        fi
        echo -e "\033[0;31mRepo check failed.\033[0m"
        echo "Use --force flag or remove exists repo."
        exit 1
    fi
}

function pre_backup () {
    if [ "$FLAG_NOBACKUP" = true ] || [ "$FLAG_UPDATE" = true ] ; then
        echo -e "\033[0;35mSkipping Backup....\033[0m"
        return 0
    fi

    local backup="dotfile-backup-`date +%Y%m%d`"
    local backup_path="/tmp/$backup/"
    mkdir $backup_path

    echo -e "\033[0;34mStarting backup.\033[0m"

    for item in "${BACKUP_LIST[@]}"
    do
        printf "  >\033[0;33mProcessing %s %s\033[0m" $item "${LINE:${#item}}"
        [ -f "$item" -a ! -h "$item " ] && mv $item $backup_path
        [ -d "$item" ] && mv $item $backup_path
        printf "[\033[0;32mDone\033[0m]\n"
    done

    tar czf "$HOME/$backup.tar.gz" -C /tmp $backup
    rm -rf $backup_path
    echo -e "\033[0;32mBackup Done.\033[0m"
    echo "Backup Location: $HOME/$backup.tar.gz"
}

function pre_cleanup() {
    if [ "$FLAG_UPDATE" = true ] ; then
        echo -e "\033[0;35mSkipping Cleanup....\033[0m"
        return 0
    fi

    printf "\033[0;33mCleanup Dotfile %s\033[0m" "${LINE:1}"
    for item in "${BACKUP_LIST[@]}"
    do
        [ -f $item ] && rm $item
        [ -d $item ] && rm -r $item
    done
    printf "[\033[0;32mDone\033[0m]\n"

    printf "\033[0;33mCleanup Dot Repo %s\033[0m" "${LINE:2}"
    for item in "${REPO_LIST[@]}"
    do
        args=($item)
        [ -d ${args[1]} ] && {
            _do_shell "find $HOME/${args[1]} -name *.git* -exec rm -rf {} +"
            _do_shell rm -r $HOME/${args[1]}
        }
    done
    printf "[\033[0;32mDone\033[0m]\n"
}

function precheck_github() {
    if [ "$GIT_SSH" = true ] ; then
        echo "ssh -T git@github.com" >> INSTALL_LOG
        ssh -T git@github.com >> INSTALL_LOG 2>&1
        [ "$?" = 255 ] && {
            echo "Pre check GitHub ssh connecting failed."
            echo "Use --no-ssh to disable ssh or add public key."
            exit 1
        }
    fi
}

function _do_link() {
    for item in "${CLINK_LIST[@]}"
    do
        args=(${(s: :)${item}})
        local name=${args[1]}
        printf "  >\033[0;33mProcessing %s %s\033[0m" $name "${LINE:${#name}}"
        local spath="$HOME/${args[1]}"
        if [ ! -e $spath ]; then
            echo -e "\033[0;31mCannot link file $spath, file is not exists.\033[0m"
            exit 2
        fi
        if [ "$FLAG_UPDATE" = true ] && [ ! -L $HOME/${args[2]} ] && [ ! "$FLAG_RELINK" = true ]; then
            echo -e "\033[0;31mFile $HOME/${args[2]} exists, use --relink to override.\033[0m"
            continue
        fi
        _do_shell ln -sf $spath $HOME/${args[2]}
        printf "[\033[0;32mDone\033[0m]\n"
    done

}

function _do_repoclone() {
    for item in "${REPO_LIST[@]}"
    do
        args=(${(s: :)${item}})
        local name=${args[1]}
        printf "  >\033[0;33mProcessing %s %s\033[0m" $name "${LINE:${#name}}"
        [ ! -d $HOME/${args[2]} ] && _do_shell git clone --quiet ${args[1]} $HOME/${args[2]}
        printf "[\033[0;32mDone\033[0m]\n"
    done
}

function _do_zegn_setup() {
    printf "\033[0;33mConfiguring local zsh %s\033[0m" "${LINE:7}"
    if ! cmd_loc=$(type -p zsh) || [ -z "$cmd_loc" ]; then
        echo -e "\033[0;32mSkipping (No ZSH)\033[0m"
        return 1
    fi
    [ "$FLAG_RELINK" = true ] && _do_shell zsh $HOME/.my_config/zgen_init.sh reset --doit
    [ ! "$FLAG_UPDATE" = true ] && _do_shell zsh $HOME/.my_config/zgen_init.sh
    printf "[\033[0;32mDone\033[0m]\n"
}

function ccommit() {
    echo -e "\033[0;34mStarting Dotfile Install Preocess."
    precheck_command git ssh

    precheck_github
    precheck_repo
    pre_backup
    pre_cleanup

    # do command in precmd list
    for cmd in "${PRECMD_LIST[@]}"
    do
        _do_shell $cmd
    done

    # running install.
    echo -e "\033[0;34mInstalling.......\033[0m"
    _do_repoclone
    _do_link

    # zsh install zgen
    _do_zegn_setup

    # post running cmd
    for cmd in "${POSTCMD_LIST[@]}"
    do
        _do_shell $cmd
    done
    echo -e "\033[0;34m#################################"
    echo -e "#        \033[0;35mInstalling Done\033[0;34m        #"
    echo -e "#################################\033[0m"
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
    if [ "$FLAG_SKIPSSH" = true ] ; then
        crepo $1 $2
        return 1
    fi
    GIT_SSH=true
    REPO_LIST+=("git@github.com:$1.git $2")
}

function ccmd_pre() {
    PRECMD_LIST+=("$*")
}

function ccmd_post() {
    POSTCMD_LIST+=("$*")
}

cclean .zgen
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
clink .my_config/gitconfig .gitconfig
clink .my_config/alacritty.yml .alacritty.yml

crepo_ssh tywtyw2002/my.vim .vim
crepo_ssh tywtyw2002/coshim.dot .my_config
crepo gmarik/vundle .vim/bundle/vundle
crepo tarjoilija/zgen .zgen
crepo tmux-plugins/tpm .tmux/plugins/tpm

ccmd_post 'touch $HOME/.zsh_local'
ccmd_post 'cp -f $HOME/.my_config/template_zshrc $HOME/.zshrc'

ccommit
