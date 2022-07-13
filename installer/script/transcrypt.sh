#!/usr/bin/env zsh

SCRIPT_URL="https://raw.githubusercontent.com/elasticdog/transcrypt/main/transcrypt"
LOCALBIN=$HOME/.my_config/mybin/local
OUTPUT_BIN="transcrypt"

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

command -v curl >/dev/null 2>&1 || { echo "CURL not found. Please install curl." ; exit 1 }

curl -fSL $DOWNLOAD_URL > $LOCALBIN/$OUTPUT_BIN
chmod +x $LOCALBIN/$OUTPUT_BIN

# Update local bins
source $HOME/.zgen/zgen.zsh
zgen bin $LOCALBIN

echo "Done."