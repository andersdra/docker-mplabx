#!/bin/bash

mkdir /toolchains # IDE only build fails at copy stage without this..

# save build-args for second stage
(
  IFS=$'\n'
  for env in $(< build-args.env)
  do
    echo "$env=$(printenv $env)" >> mplabx.env
  done
)

if [ "$MCP_USER" ] && [ "$MCP_PASS" ]
then
  apt-get update \
  && apt-get install --yes firefox-esr \
     findutils \
     xvfb
  pip3 install selenium \
  && latest_release="$(curl https://github.com/mozilla/geckodriver/releases 2> /dev/null \
    | grep -io \
"/mozilla/geckodriver/releases/download/v0.[0-9]*.[0-9]*/geckodriver-v0.[0-9]*.[0-9]*-linux64.tar.gz" \
    | head -1)" \
  && echo 'Downloading geckodriver' \
  && wget --quiet "https://github.com$latest_release" \
  && tar xf geckodriver*.tar.gz \
  && mv geckodriver /bin
  /kill_firefox.bash &
  echo 'Starting download of toolchain(s)'
  xvfb-run /toolchains.py
else
  echo 'No user/password input for myMicrochip downloads'
  exit 0 # self provided url's or ide/ipe only
fi
