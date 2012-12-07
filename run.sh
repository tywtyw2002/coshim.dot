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

if [ -e $HOME/.vim ]; then
    echo "Move .vim to .vim.old"
    mv -fr "$HOME/.vim $HOME/.vim.old"


echo "START INSTALL oh-my-sh"
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh



echo "\033[0;34mCloning my_vim...\033[0m""]]"
git clone https://github.com/tywtyw2002/my.vim.git ~/.vim


echo "\033[0;34mCloning my_config...\033[0m""]]"
git clone https://github.com/tywtyw2002/coshim.dot.git ~/.my_config

ln -sf $HOME/.my_config/zshrc $HOME/.zshrc
ln -sf $HOME/.my_config/screenrc $HOME/.screenrc
ln -sf $HOME/.my_config/bashrc $HOME/.bashrc
ln -sf $HOME/.vim/vimrc $HOME/.vimrc

echo "DONE!"
