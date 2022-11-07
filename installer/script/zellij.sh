#!/usr/bin/env zsh

SCRIPT_URL="https://api.github.com/repos/zellij-org/zellij/releases/latest"
LOCALBIN=$HOME/.my_config/mybin/local
OUTPUT_BIN="zellij"
MAC_PKG="zellij-x86_64-apple-darwin.tar.gz"
LINUX_PKG="zellij-x86_64-unknown-linux-musl.tar.gz"

confirm() {
  echo -n "You already have $OUTPUT_BIN installed. Update? [y/N]"
  read REPLY

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 1
  fi
  return 0
}

echo -e "\033[0;34m#################################"
echo -e "#        \033[0;35mInstalling $OUTPUT_BIN\033[0;34m        #"
echo -e "#################################\033[0m"


if [[ -f $LOCALBIN/$OUTPUT_BIN ]]; then
    confirm && exit 0
fi

PKG_NAME=$LINUX_PKG

if [[ $(uname) = "Darwin" ]]; then
    PKG_NAME=$MAC_PKG
fi

command -v jq >/dev/null 2>&1 || { echo "jq not found. Please install jq." ; exit 1 }
command -v curl >/dev/null 2>&1 || { echo "CURL not found. Please install curl." ; exit 1 }

# Get download url
DOWNLOAD_URL=`curl -s $SCRIPT_URL \
  | jq -r '.assets[].browser_download_url' \
  | grep $PKG_NAME`

ZTMPDIR="$(mktemp -d)"

curl -fSL $DOWNLOAD_URL > $ZTMPDIR/pkg.tar.gz
tar zxf $ZTMPDIR/pkg.tar.gz -C $ZTMPDIR
mv $ZTMPDIR/$OUTPUT_BIN $LOCALBIN/$OUTPUT_BIN
chmod +x $LOCALBIN/$OUTPUT_BIN

# Update local bins
source $HOME/.zgen/zgen.zsh
zgen bin $LOCALBIN

echo "Done."