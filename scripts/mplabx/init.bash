#!/bin/bash

mkdir -p /usr/share/man/man1 # long forgotten, but fixes some error

apt-get update
apt-get -qq install --yes --no-install-recommends \
    bc \
    ca-certificates \
    curl \
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
    x11-utils "$ADDITIONAL_PACKAGES"


V535MINUS=$(bc -l <<< "$MPLABX_VERSION <= 5.35")

# mplabx >= v5.40 will be 64bit
if [ "$V535MINUS" -eq 1 ]
then
  dpkg --add-architecture i386
  apt-get update
  apt-get -qq install --yes --no-install-recommends \
    libc6:i386 \
    libx11-6:i386 \
    libxext6:i386 \
    libstdc++6:i386 \
    libexpat1:i386
fi

V530MINUS=0
if [ "$MPLABX_VERSION" -gt 0 ]
  then
    V530MINUS=$(bc -l <<< "$MPLABX_VERSION <= 5.30")
    if [ "$V530MINUS" -eq 1 ]
    then
      # is this even needed after adding JAVA_HOME?
      apt-get install --yes --no-install-recommends default-jre
    fi
fi

/create_user.bash \
&& /mplabx_install.bash \
&& /toolchain_install.bash \
&& /startup_script.bash

if [ ! "$C_USER" = root ]
  then
    chmod --recursive 755 "$C_HOME" \
    && chown --recursive --from=0:0 "$C_USER:$C_USER" "$C_HOME"
fi

/cleanup.bash
apt-get purge --yes bc curl procps make xz-utils
apt-get -qq clean autoclean \
&& rm --recursive --force /usr/share/man/* \
&& rm --recursive --force /tmp/* \
&& rm --recursive --force /var/log/* \
&& rm --recursive --force /var/lib/{apt,dpkg,cache,log}/* \
&& find / -maxdepth 1 -name "*.bash" -delete
