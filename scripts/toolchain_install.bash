#!/bin/bash
# docker-mplabx
# download and install toolchains

mkdir "/$C_USER/toolchains"

# AVR GCC
if [ "$AVRGCC" -eq 1 ] ; then \
  curl --location "$AVRGCC_URL" > /tmp/avr-toolchain \
  && tar xf '/tmp/avr-toolchain' -C "/$C_USER/toolchains" \
  && rm --recursive --force /tmp/* \
;fi

# ARM GCC
if [ "$ARMGCC" -eq 1 ] ; then \
  curl --location "$ARMGCC_URL" > /tmp/arm-toolchain \
  && tar xf '/tmp/arm-toolchain' -C "/$C_USER/toolchains" \
  && rm --recursive --force /tmp/* \
;fi

# XC8
if [ "$MCPXC8" -eq 1 ] ; then \
  curl --location "$MCPXC8_URL" > /tmp/xc8-installer \
  && chmod u+x /tmp/xc8-installer \
  && USER=root /tmp/xc8-installer \
    --mode unattended \
    --netservername localhost \
    --LicenseType FreeMode \
    --prefix "/$C_USER/toolchains/xc8" \
  && rm --recursive --force /tmp/* \
;fi

# XC16
if [ "$MCPXC16" -eq 1 ] ; then \
  curl --location "$MCPXC16_URL" > /tmp/xc16-installer \
  && chmod u+x /tmp/xc16-installer \
  && USER=root /tmp/xc16-installer \
    --mode unattended \
    --netservername localhost \
    --LicenseType FreeMode \
    --prefix "/$C_USER/toolchains/xc16" \
  && rm --recursive --force /tmp/* \
;fi

# XC32
if [ "$MCPXC32" -eq 1 ] ; then \
  curl --location "$MCPXC32_URL" > /tmp/xc32-installer \
  && chmod u+x /tmp/xc32-installer \
  && USER=root /tmp/xc32-installer \
    --mode unattended \
    --netservername localhost \
    --LicenseType FreeMode \
    --prefix "/$C_USER/toolchains/xc32" \
  && rm --recursive --force /tmp/* \
;fi