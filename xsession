#/bin/bash

#set minxer
#urxvt -title "alsamixer" -e bash -c alsamixer &

if [ -f $HOME/.bashrc -a -x $HOME/.xinitrc ]; then
    /bin/bash -c "(. $HOME/.bashrc; exec $HOME/.xinitrc)"
else
    /usr/bin/X11/xterm
fi
