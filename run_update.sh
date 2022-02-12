#!/bin/bash

# update repo
(cd $HOME/.my_config && git pull)

# relink zshrc
cp -f $HOME/.my_config/template_zshrc $HOME/.zshrc

# reset zgen plugins
$HOME/.my_config/zgen_init.sh reset --doit