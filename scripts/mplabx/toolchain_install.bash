#!/bin/bash
# docker-mplabx
# download and install toolchains

# ARDUINO
if [ "$ARDUINO" -eq 1 ]
  then
    printf '\nARDUINO\n'
    if [ "$ARDUINO_URL" ]
      then
        printf 'Custom ARDUINO version\n'
      else
        # get latest x64 arduino release for linux
        current_release="$(curl https://www.arduino.cc/en/Main/Software 2> /dev/null \
          | grep -io "arduino-[0-9.]*-linux64.tar.xz")"
      ARDUINO_URL="https://downloads.arduino.cc/$current_release"
    fi
    curl --location "$ARDUINO_URL" > /tmp/arduino_x64.tar.xz \
    && unxz /tmp/arduino_x64.tar.xz \
    && tar xf /tmp/arduino_x64.tar -C /opt/ \
    && rm /tmp/arduino_x64.tar \
    && /opt/arduino-[0-9.]*/install.sh
fi

# AVR GCC
if [ "$AVRGCC" -eq 1 ]
  then
    printf '\nAVRGCC\n' \
    && tar xf "$DOWNLOAD_DIR"/avr8-gnu*.tar.gz -C /opt/
fi

# ARM GCC
if [ "$ARMGCC" -eq 1 ]
  then
    printf '\nARMGCC\n' \
    && tar xf "$DOWNLOAD_DIR"/arm-gnu*.tar.gz -C /opt/
fi

# XC8
if [ "$MCPXC8" -eq 1 ]
  then
    printf '\nMCP XC8\n' \
    && chmod u+x "$DOWNLOAD_DIR"/xc8*.run \
    && USER=root "$DOWNLOAD_DIR"/xc8*.run \
       --mode unattended \
       --netservername localhost \
       --LicenseType FreeMode
fi

# XC16
if [ "$MCPXC16" -eq 1 ]
  then
    printf '\nMCP XC16\n' \
    && chmod u+x "$DOWNLOAD_DIR"/xc16*.run \
    && USER=root "$DOWNLOAD_DIR"/xc16*.run \
       --mode unattended \
       --netservername localhost \
       --LicenseType FreeMode
else
    V535PLUS=$(bc -l <<< "$MPLABX_VERSION >= 5.35")
    if [ "$MPLABX_VERSION" -eq 0 ] || [ "$V535PLUS" -eq 1 ]
    then
      rm -rf /opt/microchip/mplabx/v5.35/packs/Microchip/PIC*_DFP
      rm -rf /opt/microchip/mplabx/v5.35/packs/Microchip/MCPxxxx_DFP
      rm -rf /opt/microchip/mplabx/v5.35/mpasmx
    fi
fi

# 32 bit PIC stuff
# legacy or harmony requires XC32, make sure it gets installed
if [ "$PIC32_LEGACY" -eq 1 ] || [ "$MPLAB_HARMONY" -eq 1 ]
  then
    MCPXC32=1
fi

# XC32 needs to be installed before legacy or harmony
if [ "$MCPXC32" -eq 1 ]
  then
    printf '\nMCP XC32\n'
    if grep -q ".tar" <<< "$MCPXC32_URL"
      then
        tar xf /tmp/xc32-installer -C /tmp \
        && mv /tmp/xc32-*.run /tmp/xc32-installer
    fi
    chmod u+x "$DOWNLOAD_DIR"/xc32*.run \
    && USER=root "$DOWNLOAD_DIR"/xc32*.run \
      --mode unattended \
      --netservername localhost \
      --LicenseType FreeMode

    if [ "$PIC32_LEGACY" -eq 1 ]
      then
        printf '\nPIC32 Legacy\n' \
        && tar xf "$DOWNLOAD_DIR"/'pic32 legacy peripheral libraries linux (2).tar' -C /tmp \
        && "$(find $DOWNLOAD_DIR -name *Libraries.run)" --mode unattended \
           --prefix /opt/microchip/
    fi

    if [ "$MPLAB_HARMONY" -eq 1 ]
      then
        printf '\nMPLAB Harmony\n' \
        && chmod +x /tmp/mplab_harmony \
        && /tmp/mplab_harmony --mode unattended \
           --prefix /opt/microchip/
    fi
fi

rm --recursive --force /tmp/* "$DOWNLOAD_DIR"
