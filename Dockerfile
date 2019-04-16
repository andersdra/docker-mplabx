# MPLAB X IDE/IPE
# AVR, ARM GCC
# Microchip XC8, XC16, XC32 
# Source and docs: https://gitlab.com/andersdra/docker-mplabx
FROM debian:buster-20190326-slim

LABEL maintainer="Anders Drågen <andersdra@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG C_USER=mplabx
ARG C_UID=1000
ARG C_GUID=1000

ARG MPLABX=1
ARG AVRGCC=0
ARG ARMGCC=0
ARG MCPXC8=0
ARG MCPXC16=0
ARG MCPXC32=0

ARG MPLABX_URL='https://www.microchip.com/mplabx-ide-linux-installer'
ARG AVRGCC_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en607660'
ARG ARMGCC_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en603996'
ARG MCPXC8_URL='https://www.microchip.com/mplabxc8linux'
ARG MCPXC16_URL='https://www.microchip.com/mplabxc16linux'
ARG MCPXC32_URL='https://www.microchip.com/mplabxc32linux'
 
RUN mkdir -p /usr/share/man/man1 \
    && dpkg --add-architecture i386 \
    && apt-get -qq update \
    && apt-get -qq install --yes --no-install-recommends \
    ca-certificates \
    curl \
    default-jre \
    libc6:i386 \
    libx11-6:i386 \
    libxext6:i386 \
    libstdc++6:i386 \
    libexpat1:i386 \
    libgail18 \
    libgtk2.0-0 \
    libgtk2.0-bin \
    libgtk2.0-common \
    libice6 \
    libsm6 \
    libxaw7 \
    libxcb-shape0 \
    libxft2 \
    libxmu6 \
    libxmuu1 \
    libxpm4 \
    libxt6 \
    libxv1 \
    libxxf86dga1 \
    make \
    procps \
    x11-utils \
    && bash -c \
    'if [ ! $C_USER = root ] ; then \
    groupadd \
    --system $C_USER \
    --gid $C_GUID \
    && useradd \
    --no-log-init --uid $C_UID \
    --system --gid $C_USER \
    --create-home --home-dir /$C_USER \
    --shell /sbin/nologin \
    --comment "mplabx" $C_USER \
    ;fi' \
# IDE + IPE
    && bash -c \
    'if [ $MPLABX -gt 0 ] ; then \
    curl --location $MPLABX_URL > /tmp/mplabx_installer.tar \
    && tar xf /tmp/mplabx_installer.tar -C /tmp \
    && USER=root /tmp/*-installer.sh -- \
    --mode unattended \
    --installdir /$C_USER \
    && rm -rf /tmp/* \
    ;fi' \
    && mkdir /$C_USER/toolchains \
# AVR
    && bash -c \
    'if [ $AVRGCC -gt 0 ] ; then \
    curl --location $AVRGCC_URL > /tmp/avr-toolchain \
    && tar xf '/tmp/avr-toolchain' -C /$C_USER/toolchains \
    && rm -rf /tmp/* \
    ;fi' \
# ARM
    && bash -c \
    'if [ $ARMGCC -gt 0 ] ; then \
    curl --location $ARMGCC_URL > /tmp/arm-toolchain \
    && tar xf '/tmp/arm-toolchain' -C /$C_USER/toolchains \
    && rm -rf /tmp/* \
    ;fi' \
# XC8
    && bash -c \
    'if [ $MCPXC8 -gt 0 ] ; then \
    curl --location $MCPXC8_URL > /tmp/xc8-installer \
    && chmod u+x /tmp/xc8-installer \
    && USER=root /tmp/xc8-installer \
    --mode unattended \
    --netservername localhost \
    --LicenseType FreeMode \
    --prefix /$C_USER/toolchains/xc8 \
    && rm -rf /tmp/* \
    ;fi' \
# XC16
    && bash -c \
    'if [ $MCPXC16 -gt 0 ] ; then \
    curl --location $MCPXC16_URL > /tmp/xc16-installer \
    && chmod u+x /tmp/xc16-installer \
    && USER=root /tmp/xc16-installer \
    --mode unattended \
    --netservername localhost \
    --LicenseType FreeMode \
    --prefix /$C_USER/toolchains/xc16 \
    && rm -rf /tmp/* \
    ;fi' \
# XC32
    && bash -c \
    'if [ $MCPXC32 -gt 0 ] ; then \
    curl --location $MCPXC32_URL > /tmp/xc32-installer \
    && chmod u+x /tmp/xc32-installer \
    && USER=root /tmp/xc32-installer \
    --mode unattended \
    --netservername localhost \
    --LicenseType FreeMode \
    --prefix /$C_USER/toolchains/xc32 \
    && rm -rf /tmp/* \
    ;fi' \
# Hackishly add toolchains to PATH
# mplab_ide must be delimited or installation will exit
    && bash -c \
    'tcs=$(find /$C_USER/toolchains/ -maxdepth 1 -mindepth 1 -type d) \
    && path='' \
    && for entry in $tcs; do path=$entry/bin:$path ; done \
    && printf "#!/bin/sh\nPATH="$path$PATH" && mplab\_\ide" > /mplab_start.sh \
    && chmod 775 /mplab_start.sh' \
# If root owns anything in $HOME chown
    && bash -c \
    'if [ ! $C_USER = root ] ; then \
    chmod --recursive 755 /$C_USER \
    && chown --recursive --from=0:0 $C_USER:$C_USER /$C_USER \
    ;fi' \
# Remove install dependencies etc.
    && apt-get -qq purge --auto-remove --yes \
    curl \
    libasound2 \
    libasound2-data \
    procps \
    systemd \
    systemd-sysv \
    && apt-get -qq clean autoclean \
    && apt-get -qq autoremove --yes \
    && rm -rf /usr/share/man/* \
    && rm -rf /tmp/* \
    && rm -rf /var/log/* \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

ENV USER=$C_USER
ENV SHELL=/bin/bash
ENV HOME=/$C_USER

USER $C_USER
WORKDIR /$C_USER

CMD ["/mplab_start.sh"]
