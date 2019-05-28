#!/bin/bash
# docker-mplabx
# download and install toolchains

# AVR GCC
if [ "$AVRGCC" -eq 1 ]
  then
    curl --location "$AVRGCC_URL" > /tmp/avr-toolchain \
    && tar xf '/tmp/avr-toolchain' -C /opt/ \
    && rm --recursive --force /tmp/* \
;fi

# ARM GCC
if [ "$ARMGCC" -eq 1 ]
  then
    curl --location "$ARMGCC_URL" > /tmp/arm-toolchain \
    && tar xf '/tmp/arm-toolchain' -C /opt/ \
    && rm --recursive --force /tmp/* \
;fi

# XC8
if [ "$MCPXC8" -eq 1 ]
  then
    curl --location "$MCPXC8_URL" > /tmp/xc8-installer \
    && chmod u+x /tmp/xc8-installer \
    && USER=root /tmp/xc8-installer \
       --mode unattended \
       --netservername localhost \
       --LicenseType FreeMode \
    && rm --recursive --force /tmp/* \
;fi

# XC16
if [ "$MCPXC16" -eq 1 ]
  then
    curl --location "$MCPXC16_URL" > /tmp/xc16-installer \
    && chmod u+x /tmp/xc16-installer \
    && USER=root /tmp/xc16-installer \
       --mode unattended \
       --netservername localhost \
       --LicenseType FreeMode \
    && rm --recursive --force /tmp/* \
;fi

# 32 bit PIC stuff
# legacy or harmony requires XC32, make sure it gets installed
if [ "$PIC32_LEGACY" -eq 1 ] || [ "$MPLAB_HARMONY" -eq 1 ]
  then
    MCPXC32=1
fi

# XC32 needs to be installed before legacy or harmony
if [ "$MCPXC32" -eq 1 ]
  then
    curl --location "$MCPXC32_URL" > /tmp/xc32-installer \
    && chmod u+x /tmp/xc32-installer \
    && USER=root /tmp/xc32-installer \
      --mode unattended \
      --netservername localhost \
      --LicenseType FreeMode \
    && rm --recursive --force /tmp/*

    if [ "$PIC32_LEGACY" -eq 1 ]
      then
        echo 'PIC32 Legacy'
        curl "$PIC32_LEGACY_URL" > /tmp/pic32_legacy \
        && tar xf /tmp/pic32_legacy -C /tmp \
        && rm /tmp/pic32_legacy \
        && /tmp/*Libraries.run --mode unattended \
           --prefix /opt/microchip/ \
        && rm -rf /tmp/*
    fi

    if [ "$MPLAB_HARMONY" -eq 1 ]
      then
        echo 'MPLAB Harmony'
        curl -L "$MPLAB_HARMONY_URL" > /tmp/mplab_harmony \
        && chmod +x /tmp/mplab_harmony \
        && /tmp/mplab_harmony --mode unattended \
        && rm -rf /tmp/*
    fi
fi
