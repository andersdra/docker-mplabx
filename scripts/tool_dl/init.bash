#!/bin/sh

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
  && mv geckodriver /bin \
  && mkdir /toolchains
    /kill_firefox.bash &
    echo 'Starting downloader'
    xvfb-run /toolchains.py
else
  echo 'No user/password combo input for myMicrochip downloads'
  exit 0 # self provided url's or ide/ipe only
fi
