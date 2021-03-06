#!/bin/bash
# docker-mplabx
# install script for MPLAB X IDE/IPE

install_cmd="USER=root /tmp/*-linux-installer.sh -- \
           --mode unattended \
           --collectInfo $MPLABX_TELEMETRY"

CUSTOM_VERSION=$(bc -l <<< "$MPLABX_VERSION > 0")
V510PLUS=$(bc -l <<< "$MPLABX_VERSION >= 5.10")

# install with new/old installer
if [ "$CUSTOM_VERSION" -eq 0 ] || [ "$V510PLUS" -eq 1 ];then
    if [ "$MPLABX_IDE" -eq 0 ] && [ "$MPLABX_IPE" -eq 0 ];then
        exit 0 # no IDE/IPE
    fi

    install_cmd+=$(printf " %q" '--ide' "$MPLABX_IDE")
    install_cmd+=$(printf " %q" '--ipe' "$MPLABX_IPE")

    if [ "$AVRGCC" -eq 1 ] || [ "$MCPXC8" -eq 1 ];then
        install_cmd+=$(printf " %q" '--8bitmcu' 1)
      else
        install_cmd+=$(printf " %q" '--8bitmcu' 0)
    fi

    install_cmd+=$(printf " %q" '--16bitmcu' "$MCPXC16")

    if [ "$ARMGCC" -eq 1 ] || [ "$MCPXC32" -eq 1 ];then
        install_cmd+=$(printf " %q" '--32bitmcu' 1)
      else
        install_cmd+=$(printf " %q" '--32bitmcu' 0)
    fi

    V520PLUS=$(bc -l <<< "$MPLABX_VERSION >= 5.20")
    if [ "$V520PLUS" -eq 1 ];then
      install_cmd+=$(printf " %q" '--othermcu' "$OTHERMCU")
    fi
else # Older version
    if [ "$MPLABX_IDE" -eq 1 ];then
        echo "Installing MPLAB X version < 5.10"
    else
        echo "Not installing MPLAB X"
        exit 0 # no IDE/IPE
    fi
fi

if [ "$CUSTOM_VERSION" -gt 0 ];then
  # confirm version ending in [.05, .10] etc
    if perl -e "if ($MPLABX_VERSION * 100 % 5 == 0){ exit 0 } else { exit 1 }";then
      if grep .microchip <<< "$MPLABX_URL" &> /dev/null;then
        MPLABX_URL="https://ww1.microchip.com/downloads/en/DeviceDoc/MPLABX-v$MPLABX_VERSION-linux-installer.tar"
      fi
    else
      echo "Invalid MPLABX version: $MPLABX_VERSION"
      exit 1
    fi
fi

printf '\nMPLAB X\n'

curl --location "$MPLABX_URL" > '/tmp/mplabx_installer.tar' 2> /dev/null
tar xf '/tmp/mplabx_installer.tar' -C /tmp
rm /tmp/mplabx_installer.tar

bash -c "$install_cmd"

# save ide version
MPLABX_V="$(basename "$(find /opt/microchip/mplabx/ -mindepth 1 -maxdepth 1 -type d)")"
echo "MPLABX_V=$MPLABX_V" >> "$TOOLCHAINS"

if [ "$MPLABX_DARCULA" -eq 1 ];then
    echo "Downloading Darcula Theme"
    curl "$DARCULA_URL" > "$C_HOME/darcula_theme.nbm" 2> /dev/null
fi

cd "$C_HOME" \
&& mkdir MPLABXProjects \
      mplabx


rm --recursive --force /tmp/*
