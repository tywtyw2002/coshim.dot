Z_DOT_PATH=${NIX_Z_CONFIG:-$HOME/.config/zsh}
ZGEN_PATH=${NIX_ZGEN_PATH:-$HOME/.zgen}
Z_LOCAL=$HOME/.zsh_local

# zgenom bootstrap
if [[ ! -e $ZGEN_PATH/zgenom.zsh ]]; then
    echo "Downloading zgenom..."
    git clone https://github.com/jandamm/zgenom.git $ZGEN_PATH
fi

# OMZ Configs
DISABLE_LS_COLORS=true

# load zgenom & plugins
source $ZGEN_PATH/zgenom.zsh
source $Z_DOT_PATH/zgen_init.zsh
zgenom init

# Local ZSH Configs
if [[ ! -e $Z_LOCAL ]]; then
    touch $Z_LOCAL
fi
source $Z_LOCAL
unset Z_LOCAL