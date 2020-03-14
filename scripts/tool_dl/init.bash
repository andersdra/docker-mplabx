#!/bin/sh

if [ "$MCP_USER" ]
then
  apt-get update \
  && apt-get install --yes firefox-esr \
    findutils \
    xvfb
  pip3 install selenium \
  && latest_release="$(curl https://github.com/mozilla/geckodriver/releases | grep -io "/mozilla/geckodriver/releases/download/v0.[0-9]*.[0-9]*/geckodriver-v0.[0-9]*.[0-9]*-linux64.tar.gz" | head -1)" \
  && echo 'Downloading geckodriver' \
  && wget --quiet "https://github.com$latest_release" \
  && tar xf geckodriver*.tar.gz \
  && mv geckodriver /bin \
  && mkdir /toolchains
    /kill_firefox.bash &
    xvfb-run /toolchains.py
else
  /toolchains.py
fi
