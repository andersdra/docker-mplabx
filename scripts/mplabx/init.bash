#!/bin/bash
# shellcheck disable=SC2046

mkdir -p /usr/share/man/man1 # long forgotten, but fixes some error

apt-get update &> /dev/null
apt-get -qq install --yes --no-install-recommends \
    bc \
    ca-certificates \
    curl \
    findutils \
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
    python3 \
    xz-utils \
    x11-utils &> /dev/null

export $(xargs < /mplabx.env)

echo 'Installing 32bit libraries'
dpkg --add-architecture i386
apt-get update &> /dev/null
apt-get -qq install --yes --no-install-recommends \
  libc6:i386 \
  libx11-6:i386 \
  libxext6:i386 \
  libstdc++6:i386 \
  libexpat1:i386 &> /dev/null

V530MINUS=0
if python3 -c "exit(0) if $MPLABX_VERSION > 0 else exit(1)";then
    V530MINUS=$(bc -l <<< "$MPLABX_VERSION <= 5.30")
    if [ "$V530MINUS" -eq 1 ];then
      echo 'Installing Java'
      # is this even needed after adding JAVA_HOME?
      apt-get install --yes --no-install-recommends default-jre &> /dev/null
    fi
fi

/create_user.bash \
&& /mplabx_install.bash \
&& /toolchain_install.bash \
&& /startup_script.bash
mkdir /home/$C_USER/.firefox_profile

if [ ! "$C_USER" = root ];then
    chmod --recursive 755 "$C_HOME" \
    && chown --recursive --from=0:0 "$C_USER:$C_USER" "$C_HOME"
fi

echo 'Cleanup'
/cleanup.bash
apt-get purge --yes bc curl procps python3 make xz-utils &> /dev/null
apt-get -qq clean autoclean &> /dev/null

if [ $NO_PIC_DFP -eq 1 ];then
    echo "Deleting PIC DFP's"
    find $(find /opt/microchip -name "v*[05]")/packs/Microchip -name "PIC*_DFP" -exec rm -r {} +
: '
PIC*_DFP folders
./PIC16Fxxx_DFP
./PIC18F-J_DFP
./PIC10-12Fxxx_DFP
./PIC18Fxxxx_DFP
./PIC18F-K_DFP
./PIC12-16F1xxx_DFP
./PIC18F-Q_DFP
./PIC-8bitAC_DFP
./PIC12-16Cxxx_DFP
./PIC16F1xxxx_DFP
./PIC18Cxxx_DFP
'
fi

# cleanup removes firefox even with pinning..
if [ -n "$ADDITIONAL_PACKAGES" ];then
    echo "Installing $ADDITIONAL_PACKAGES"
    apt-get install --yes --no-install-recommends $ADDITIONAL_PACKAGES &> /dev/null
fi

rm --recursive --force /usr/share/man/* \
&& rm --recursive --force /tmp/* \
&& rm --recursive --force /var/log/* \
&& rm --recursive --force /var/lib/{apt,dpkg,cache,log}/* \
&& find / -maxdepth 1 -name "*.bash" -delete
