#!/bin/bash

# shellcheck disable=SC2046
export $(xargs < /mplabx.env)

mkdir -p /usr/share/man/man1 # long forgotten, but fixes some error
mkdir -p "$TOOLCHAIN_DIR"

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
    xz-utils \
    x11-utils &> /dev/null

if [ "$MPLABX_VERSION" -ne 0 ];then
  V540MINUS=$(bc -l <<< "$MPLABX_VERSION <= 5.40")
  if [ "$V540MINUS" -eq 1 ];then
    echo 'Installing 32bit libraries'
    dpkg --add-architecture i386
    apt-get update &> /dev/null
    apt-get -qq install --yes --no-install-recommends \
      libc6:i386 \
      libx11-6:i386 \
      libxext6:i386 \
      libstdc++6:i386 \
      libexpat1:i386 &> /dev/null
  fi
fi

V530MINUS=0
if perl -e "if ($MPLABX_VERSION > 0){ exit 0 } else { exit 1 }";then
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

mkdir "/home/$C_USER/.firefox_profile"
mv /verify.bash "$C_HOME"

HOME=$C_HOME "$C_HOME/verify.bash" sum
sha256sum "$TOOLCHAINS" > "$C_HOME/toolchains.shasum"

echo 'Cleanup'
/cleanup.bash
apt-get purge --yes bc curl procps make xz-utils &> /dev/null
apt-get -qq clean autoclean &> /dev/null

if [ "$NO_PIC_DFP" -eq 1 ];then
    echo "Deleting PIC DFP's"
    find "$(find /opt/microchip/mplabx -name "v*[05]")"/packs/Microchip -name "PIC*_DFP" -exec rm -r {} +
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
    for package in $ADDITIONAL_PACKAGES;do
      apt-get install --yes --no-install-recommends "$package"
    done
fi

if [ "$FIREFOX" -eq 1 ];then
    echo 'Installing firefox-esr'
    apt-get install --yes --no-install-recommends firefox-esr &> /dev/null
fi

if [ ! "$C_USER" = root ];then
    chmod --recursive 755 "$C_HOME" \
    && chown --recursive --from=0:0 "$C_USER:$C_USER" "$C_HOME"
fi

rm --recursive --force /usr/share/man/* \
&& rm --recursive --force /tmp/* \
&& rm --recursive --force /var/log/* \
&& rm --recursive --force /var/lib/{apt,dpkg,cache,log}/* \
&& find / -maxdepth 1 -name "*.bash" -delete
