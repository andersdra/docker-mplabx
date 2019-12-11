# MPLAB X IDE/IPE
# AVR, ARM GCC
# Microchip XC8, XC16, XC32 
# Source and docs: https://gitlab.com/andersdra/docker-mplabx
FROM debian:buster-20190910-slim

LABEL maintainer="Anders Draagen <andersdra@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG C_USER=mplabx
ARG C_HOME="/home/${C_USER}"
ARG C_UID=1000
ARG C_GUID=1000

ARG ADDITIONAL_PACKAGES=

ARG MPLABX_IDE=1
ARG MPLABX_IDE_START=1
ARG MPLABX_IPE=0
ARG MPLABX_TELEMETRY=0
ARG MPLABX_DARCULA=1
ARG MPLABX_VERSION=0

ARG ARDUINO=0
ARG AVRGCC=0
ARG ARMGCC=0
ARG MCPXC8=0
ARG MCPXC16=0
ARG MCPXC32=0
ARG PIC32_LEGACY=0
ARG MPLAB_HARMONY=0
ARG OTHERMCU=0

ARG ARDUINO_URL=''
ARG DARCULA_URL='http://plugins.netbeans.org/download/plugin/9293'
ARG MPLABX_URL='https://www.microchip.com/mplabx-ide-linux-installer'
ARG AVRGCC_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en607660'
ARG ARMGCC_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en603996'
ARG MCPXC8_URL='https://www.microchip.com/mplabxc8linux'
ARG MCPXC16_URL='https://www.microchip.com/mplabxc16linux'
ARG MCPXC32_URL='https://www.microchip.com/mplabxc32linux'
ARG MPLAB_HARMONY_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en606318'
ARG PIC32_LEGACY_URL='http://ww1.microchip.com/downloads/en//softwarelibrary/pic32%20peripheral%20library/pic32%20legacy%20peripheral%20libraries%20linux%20(2).tar'

COPY scripts/create_user.bash /
COPY scripts/startup_script.bash /
COPY scripts/mplabx_install.bash /
COPY scripts/toolchain_install.bash /
 
RUN mkdir -p /usr/share/man/man1 \
    && dpkg --add-architecture i386 \
    && apt-get -qq update \
    && apt-get -qq install --yes --no-install-recommends \
      bc \
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
      xz-utils \
      x11-utils \
      $ADDITIONAL_PACKAGES \
    && chmod u+x /*.bash \
    && /create_user.bash \
# IDE/IPE install
    && /mplabx_install.bash \
# Toolchains
    && /toolchain_install.bash \
# Setup startup script with updated PATH
    && /startup_script.bash \
# If root owns anything in $HOME chown
    && bash -c \
      'if [ ! $C_USER = root ] ; then \
        chmod --recursive 755 $C_HOME \
        && chown --recursive --from=0:0 $C_USER:$C_USER $C_HOME \
      ;fi' \
    && apt-get -qq clean autoclean \
    && rm --recursive --force /usr/share/man/* \
    && rm --recursive --force /tmp/* \
    && rm --recursive --force /var/log/* \
    && bash -c 'rm --recursive --force /var/lib/{apt,dpkg,cache,log}/*' \
    && find / -maxdepth 1 -name "*.bash" -delete

ENV USER=$C_USER
ENV SHELL=/bin/bash
ENV HOME=$C_HOME

USER $C_USER
WORKDIR $C_HOME

CMD ["/mplab_start.sh"]
