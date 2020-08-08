#!/bin/bash

verify_toolchains(){
  sha256sum -c "$HOME/sha256.sums" 2> "$HOME/sha.errors" 1>/dev/null
  if [ -s sha.errors ]
  then
    cat sha.errors
    exit 1
  else
    echo Toolchains OK
  fi
  rm -f sha.errors
}

shasum_toolchains(){
  rm -f sha256.sums
  find "$TOOLCHAIN_DIR" -type f -exec sha256sum "{}" + > "$HOME/sha256.sums"
}


if [ -z "$1" ];then
  echo 'verify or sum'
fi

if [ "$1" = 'verify' ];then
  verify_toolchains
fi

if [ "$1" = 'sum' ];then
  shasum_toolchains
fi
