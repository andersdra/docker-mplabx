#!/bin/bash
# docker-mplabx
# download and install toolchains

#set -x

toolchain_append(){
  echo "$1" >> "$TOOLCHAINS"
}

extract_toolchain(){
    tar xf "$1" -C "$2"
    rm "$1"
}

# ARDUINO
# TODO: this has never worked, problem with plugin/procedure
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
    && extract_toolchain /tmp/arduino_x64.tar "$TOOLCHAIN_DIR" \
    && arduino_install="$(find "$TOOLCHAIN_DIR"/arduino*/install.sh)" \
    && bash "$arduino_install"
fi

# AVR GCC
if [ "$AVRGCC" -eq 1 ]
  then
    printf '\nAVRGCC\n'
    if ! grep '.microchip.com' <<< "$AVRGCC_URL" > /dev/null
    then
      echo 'Downloading AVRGCC'
      curl --location "$AVRGCC_URL" -o "$DOWNLOAD_DIR/avr8-gnu-custom.tar.gz"
    fi
    extract_toolchain "$(find "$DOWNLOAD_DIR" -name 'avr8-gnu*.tar.gz')" "$TOOLCHAIN_DIR"
    AVR_TOOLCHAIN_VERSION="$($(find "$TOOLCHAIN_DIR" -name avr-gcc) -v 2>&1 | grep 'gcc version' | xargs)" # xargs for whitespace removal
    toolchain_append "AVR_TOOLCHAIN_VERSION='$AVR_TOOLCHAIN_VERSION'"
fi

# ARM GCC
if [ "$ARMGCC" -eq 1 ]
  then
    printf '\nARMGCC\n'
    if ! grep '.microchip.com' <<< "$ARMGCC_URL" > /dev/null
    then
      echo 'Downloading ARMGCC'
      curl --location "$ARMGCC_URL" -o "$DOWNLOAD_DIR/arm-gnu-custom.tar.gz"
    fi
    extract_toolchain "$(find "$DOWNLOAD_DIR" -name 'arm-gnu*.tar.gz')" "$TOOLCHAIN_DIR"
fi

# XC8
if [ "$MCPXC8" -eq 1 ]
  then
    if [ "$MCP_LOGIN" -eq 0 ];then
      curl --location "$MCPXC8_URL" -o "$DOWNLOAD_DIR/xc8.run"
    fi
    printf '\nMCP XC8\n'
    xc8_installer="$(find "$DOWNLOAD_DIR" -name 'xc8*.run')" \
    && chmod u+x "$xc8_installer" \
    && USER=root "$xc8_installer" \
       --mode unattended \
       --netservername localhost \
       --LicenseType FreeMode \
       --prefix "$TOOLCHAIN_DIR"
    rm "$xc8_installer"
fi

# XC16
if [ "$MCPXC16" -eq 1 ]
  then
    if [ "$MCP_LOGIN" -eq 0 ];then
      curl --location "$MCPXC16_URL" -o "$DOWNLOAD_DIR/xc16.run"
    fi
    printf '\nMCP XC16\n'
    xc16_installer="$(find "$DOWNLOAD_DIR" -name 'xc16*.run')" \
    && chmod u+x "$xc16_installer" \
    && USER=root "$xc16_installer" \
       --mode unattended \
       --netservername localhost \
       --LicenseType FreeMode \
       --prefix "$TOOLCHAIN_DIR"
    rm "$xc16_installer"
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
    if [ "$MCP_LOGIN" -eq 0 ];then
      curl --location "$MCPXC32_URL" -o "$DOWNLOAD_DIR/xc32.run"
    fi
    printf '\nMCP XC32\n'
    if ! grep '.microchip.com' <<< "$MCPXC32_URL" > /dev/null
    then
      echo 'Downloading MCPXC32'
      curl --location "$MCPXC32_URL" > "$DOWNLOAD_DIR"/xc32-installer.tar
    fi
    if grep -q ".tar" <<< "$MCPXC32_URL"
      then
        xc32_installer="$DOWNLOAD_DIR"/xc32-installer.tar
        tar xf "$xc32_installer" -C "$DOWNLOAD_DIR"
    fi
    xc32_installer="$(find "$DOWNLOAD_DIR" -name 'xc32*.run')"
    chmod u+x "$xc32_installer" \
    && USER=root "$xc32_installer" \
      --mode unattended \
      --netservername localhost \
      --LicenseType FreeMode \
      --prefix "$TOOLCHAIN_DIR"
    rm "$xc32_installer"

    if [ "$PIC32_LEGACY" -eq 1 ]
      then
        printf '\nPIC32 Legacy\n' \
        && tar xf "$DOWNLOAD_DIR"/'pic32 legacy peripheral libraries linux (2).tar' -C /tmp \
        && "$(find "$DOWNLOAD_DIR" -name '*Libraries.run')" --mode unattended \
        --prefix "$TOOLCHAIN_DIR"
    fi

    if [ "$MPLAB_HARMONY" -eq 1 ]
      then
        printf '\nMPLAB Harmony\n' \
        && chmod +x /tmp/mplab_harmony \
        && /tmp/mplab_harmony --mode unattended \
        --prefix "$TOOLCHAIN_DIR"
    fi
fi

rm --recursive --force /tmp/* "$DOWNLOAD_DIR"
