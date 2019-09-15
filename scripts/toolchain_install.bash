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
    printf '\nAVRGCC\n'
    curl --location "$AVRGCC_URL" > /tmp/avr-toolchain \
    && tar xf '/tmp/avr-toolchain' -C /opt/ \
    && rm --recursive --force /tmp/*
fi

# ARM GCC
if [ "$ARMGCC" -eq 1 ]
  then
    printf '\nARMGCC\n'
    curl --location "$ARMGCC_URL" > /tmp/arm-toolchain \
    && tar xf '/tmp/arm-toolchain' -C /opt/ \
    && rm --recursive --force /tmp/*
fi

# XC8
if [ "$MCPXC8" -eq 1 ]
  then
    printf '\nMCP XC8\n'
    curl --location "$MCPXC8_URL" > /tmp/xc8-installer \
    && chmod u+x /tmp/xc8-installer \
    && USER=root /tmp/xc8-installer \
       --mode unattended \
       --netservername localhost \
       --LicenseType FreeMode \
    && rm --recursive --force /tmp/*
fi

# XC16
if [ "$MCPXC16" -eq 1 ]
  then
    printf '\nMCP XC16\n'
    curl --location "$MCPXC16_URL" > /tmp/xc16-installer \
    && chmod u+x /tmp/xc16-installer \
    && USER=root /tmp/xc16-installer \
       --mode unattended \
       --netservername localhost \
       --LicenseType FreeMode \
    && rm --recursive --force /tmp/*
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
    curl --location "$MCPXC32_URL" > /tmp/xc32-installer \
    && chmod u+x /tmp/xc32-installer \
    && USER=root /tmp/xc32-installer \
      --mode unattended \
      --netservername localhost \
      --LicenseType FreeMode \
    && rm --recursive --force /tmp/*

    if [ "$PIC32_LEGACY" -eq 1 ]
      then
        printf '\nPIC32 Legacy\n'
        curl "$PIC32_LEGACY_URL" > /tmp/pic32_legacy \
        && tar xf /tmp/pic32_legacy -C /tmp \
        && rm /tmp/pic32_legacy \
        && $(find /tmp -name "*Libraries.run") --mode unattended \
           --prefix /opt/microchip/ \
        && rm -rf /tmp/*
    fi

    if [ "$MPLAB_HARMONY" -eq 1 ]
      then
        printf '\nMPLAB Harmony\n'
        curl -L "$MPLAB_HARMONY_URL" > /tmp/mplab_harmony \
        && chmod +x /tmp/mplab_harmony \
        && /tmp/mplab_harmony --mode unattended \
           --prefix /opt/microchip/ \
        && rm -rf /tmp/*
    fi
fi
