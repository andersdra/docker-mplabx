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

ARG MPLABX_V520PLUS=1
ARG MPLABX_IDE=1
ARG MPLABX_IPE=0
ARG MPLABX_TELEMETRY=0
ARG MPLABX_DARCULA=1

ARG AVRGCC=0
ARG ARMGCC=0
ARG MCPXC8=0
ARG MCPXC16=0
ARG MCPXC32=0
ARG OTHERMCU=0

ARG MPLABX_URL='https://www.microchip.com/mplabx-ide-linux-installer'
ARG AVRGCC_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en607660'
ARG ARMGCC_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en603996'
ARG MCPXC8_URL='https://www.microchip.com/mplabxc8linux'
ARG MCPXC16_URL='https://www.microchip.com/mplabxc16linux'
ARG MCPXC32_URL='https://www.microchip.com/mplabxc32linux'

COPY scripts/create_user.bash /
COPY scripts/startup_script.bash /
COPY scripts/mplabx_install.bash /
COPY scripts/toolchain_install.bash /
 
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
    && chmod u+x /create_user.bash \
    && /create_user.bash \
# IDE/IPE install
    && chmod u+x /mplabx_install.bash \
    && /mplabx_install.bash \
# Toolchains
    && chmod u+x /toolchain_install.bash \
    && /toolchain_install.bash \
# Setup startup script with updated PATH
    && /startup_script.bash \
# If root owns anything in $HOME chown
    && bash -c \
      'if [ ! $C_USER = root ] ; then \
        chmod --recursive 755 /home/$C_USER \
        && chown --recursive --from=0:0 $C_USER:$C_USER /home/$C_USER \
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
    && rm --recursive --force /usr/share/man/* \
    && rm --recursive --force /tmp/* \
    && rm --recursive --force /var/log/* \
    && rm --recursive --force /var/lib/{apt,dpkg,cache,log}/ \
    && find / -maxdepth 1 -name "*.bash" -delete

ENV USER=$C_USER
ENV SHELL=/bin/bash
ENV HOME=/home/$C_USER

USER $C_USER
WORKDIR /home/$C_USER

CMD ["/mplab_start.sh"]
