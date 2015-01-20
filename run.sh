#!/bin/sh


if [ -f $HOME/.screenrc ]; then
    echo "move .screenrc to .screenrc.old"
    mv -f $HOME/.screenrc $HOME/.screenrc.old
fi

if [ -f $HOME/.zshrc ]; then
    echo "move .zshrc to .zshrc.old"
    mv -f $HOME/.zshrc $HOME/.zshrc.old
fi

if [ -f $HOME/.vimrc ]; then
    echo "move .vimrc to .vimrc.old"
    mv -f $HOME/.vimrc $HOME/.vimrc.old
fi

if [ -f $HOME/.Xresources ]; then
    echo "move .Xresource to .Xresource.old"
    mv -f $HOME/.Xresources $HOME/.Xresources.old
fi

if [ -f $HOME/.Xdefaults ]; then
    echo "move .Xdefaults to .Xdefaults.old"
    mv -f $HOME/.Xdefaults $HOME/.Xdefaults.old
fi


if [ -f $HOME/.tmux.conf ]; then
    echo "move tmux.conf to tmux.conf.old"
    mv -f $HOME/.tmux.conf $HOME/.tmux.conf.old
fi

if [ -e $HOME/.vim ]; then
    echo "Move .vim to .vim.old"
    mv -f "$HOME/.vim $HOME/.vim.old"
fi

echo "START INSTALL oh-my-sh"
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh



echo "\033[0;34mCloning my_vim...\033[0m""]]"
git clone https://github.com/tywtyw2002/my.vim.git ~/.vim
echo "\033[0;34mCloning vim bunble...\033[0m""]]"
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle


echo "\033[0;34mCloning my_config...\033[0m""]]"
git clone https://github.com/tywtyw2002/coshim.dot.git ~/.my_config

touch $HOME/.zshrc
echo "source $HOME/.zsh_local" >.zshrc
echo "source $HOME/.my_config/zshrc" >> .zshrc
touch $HOME/.zsh_local
ln -sf $HOME/.my_config/screenrc $HOME/.screenrc
ln -sf $HOME/.my_config/bashrc $HOME/.bashrc
ln -sf $HOME/.vim/vimrc $HOME/.vimrc
ln -sf $HOME/.my_config/tmux.conf $HOME/.tmux.conf
ln -sf $HOME/.my_config/Xresources $HOME/.Xresources
ln -sf $HOME/.my_config/Xresources $HOME/.Xdefaults
echo "DONE!"
