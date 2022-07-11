#!/usr/bin/env zsh

INSTALL_PATH=$HOME/.my_config/mybin/local
BASE_URL="https://bypass.c70.dev/"
LINUX_KEY="cdot.starship.linux"
MACOS_KEY="cdot.starship.macos"
OUTPUT_BIN="starship"


confirm() {
  echo -n "You already have $OUTPUT_BIN installed. Update? "
  read REPLY

  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    return 1
  fi
  return 0
}

echo -e "\033[0;34m#################################"
echo -e "#        \033[0;35mInstalling $OUTPUT_BIN\033[0;34m        #"
echo -e "#################################\033[0m"


if [[ -f $INSTALL_PATH/$OUTPUT_BIN ]]; then
    confirm && exit 0
fi

DOWNLOAD_URL=$BASE_URL$LINUX_KEY

if [[ $(uname) = "Darwin" ]]; then
    DOWNLOAD_URL=$BASE_URL$MACOS_KEY
fi

command -v curl >/dev/null 2>&1 || { echo "CURL not found. Please install curl." ; exit 1 }

curl -fSL $DOWNLOAD_URL > $INSTALL_PATH/$OUTPUT_BIN
chmod +x $INSTALL_PATH/$OUTPUT_BIN

# Update local bins
source $HOME/.zgen/zgen.zsh
zgen bin $INSTALL_PATH

echo "Done."