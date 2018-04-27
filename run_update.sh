#!/bin/bash

# update repo
(cd $HOME/.my_config && git pull)

# relink zshrc
cp -f $HOME/.my_config/template_zshrc $HOME/.zshrc

