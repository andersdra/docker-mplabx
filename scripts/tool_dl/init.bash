#!/bin/bash

mkdir /toolchains # IDE only build fails at copy stage without this..

cat > /mplabx.env << EOF
AVRGCC=$AVRGCC
ARMGCC=$ARMGCC
MCPXC8=$MCPXC8
MCPXC16=$MCPXC16
MCPXC32=$MCPXC32
PIC32_LEGACY=$PIC32_LEGACY
MPLAB_HARMONY=$MPLAB_HARMONY
OTHERMCU=$OTHERMCU
AVRGCC_URL=$AVRGCC_URL
ARMGCC_URL=$ARMGCC_URL
MCPXC8_URL=$MCPXC8_URL
MCPXC16_URL=$MCPXC16_URL
MCPXC32_URL=$MCPXC32_URL
MPLAB_HARMONY_URL=$MPLAB_HARMONY_URL
PIC32_LEGACY_URL=$PIC32_LEGACY_URL
DOWNLOAD_DIR=$DOWNLOAD_DIR
EOF

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
