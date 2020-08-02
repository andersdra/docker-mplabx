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
  apt-get update &> /dev/null \
  && apt-get install --yes bzip2 \
      curl \
      findutils \
      libdbus-glib-1-2 \
      libgtk-3-0 \
      procps \
      xvfb \
      wget &> /dev/null
  pip3 install selenium
  latest_release="$(curl https://github.com/mozilla/geckodriver/releases 2> /dev/null \
    | grep -io \
"/mozilla/geckodriver/releases/download/v0.[0-9]*.[0-9]*/geckodriver-v0.[0-9]*.[0-9]*-linux64.tar.gz" \
    | head -1)"
  echo 'Downloading geckodriver'
  wget --quiet "https://github.com$latest_release"
  tar xf geckodriver*.tar.gz
  mv geckodriver /bin
  # get latest firefox release to match geckodriver, change to nightly if new mismatch occurs
  curl -L 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64' > /tmp/firefox.tar 2> /dev/null
  tar xf /tmp/firefox.tar -C /tmp
  /kill_firefox.bash &
  echo 'Starting download of toolchain(s)'
  MOZ_HEADLESS_HEIGHT=1080 MOZ_HEADLESS_WIDTH=1920 xvfb-run /toolchains.py
  printf "\nls %s\n" $DOWNLOAD_DIR
  ls "$DOWNLOAD_DIR"
  echo ''
else
  echo 'No user/password input for myMicrochip downloads'
  exit 0 # self provided url's or ide/ipe only
fi
