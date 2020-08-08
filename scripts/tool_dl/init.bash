#!/bin/bash
set -x

mkdir /toolchains # IDE only build fails at copy stage without this..

# Check if MPLABX_VERSION is set when not downloading IDE from Microchip
if [ "$MPLABX_IDE" = 1 ];then
  if ! grep .microchip <<< "$MPLABX_URL" &> /dev/null;then
    if [ "$MPLABX_VERSION" = 0 ];then
      echo 'MPLABX_VERSION must be set when not downloading from Microchip'
      exit 1
    else
      echo "MPLAB X v$MPLABX_VERSION will be downloaded from $MPLABX_URL"
    fi
  fi
fi

# save build-args for second stage
(
  IFS=$'\n'
  for env in $(< build-args.env)
  do
# shellcheck disable=SC2086
    env_var="$env=$(printenv $env)"
    echo "$env_var" >> mplabx.env
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
  curl -L "$FIREFOX_URL" > /tmp/firefox.tar 2> /dev/null
  tar xf /tmp/firefox.tar -C /tmp
  /kill_firefox.bash &
  echo 'Starting download of toolchain(s)'
  MOZ_HEADLESS_HEIGHT=1080 MOZ_HEADLESS_WIDTH=1920 xvfb-run /toolchains.py
  printf "\nls %s\n%s\n\n" "$DOWNLOAD_DIR" "$(ls /toolchains)"
else
  echo 'No user/password input for myMicrochip downloads'
  exit 0 # self provided url's or ide/ipe only
fi
