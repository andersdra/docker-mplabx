#!/bin/bash
# docker-mplabx
# install script for MPLAB X IDE/IPE

install_cmd="USER=root /tmp/*-linux-installer.sh -- \
           --mode unattended \
           --installdir /home/$C_USER"

if [ "$MPLABX_V520PLUS" -eq 1 ]
  then
    if [ "$MPLABX_IDE" -eq 0 ] && [ "$MPLABX_IPE" -eq 0 ]
      then
        exit 0 # only building with toolchains
    fi
    install_cmd+=$(printf " %q" '--ide' "$MPLABX_IDE")
    install_cmd+=$(printf " %q" '--ipe' "$MPLABX_IPE")
    install_cmd+=$(printf " %q" '--collectInfo' "$MPLABX_TELEMETRY")

    if [ "$AVRGCC" -eq 1 ] || [ "$MCPXC8" -eq 1 ]
      then
        install_cmd+=$(printf " %q" '--8bitmcu' 1)
      else
        install_cmd+=$(printf " %q" '--8bitmcu' 0)
    fi

install_cmd+=$(printf " %q" '--16bitmcu' "$MCPXC16")

if [ "$ARMGCC" -eq 1 ] || [ "$MCPXC32" -eq 1 ]
  then
    install_cmd+=$(printf " %q" '--32bitmcu' 1)
  else
    install_cmd+=$(printf " %q" '--32bitmcu' 0)
fi

install_cmd+=$(printf " %q" '--othermcu' "$OTHERMCU")
echo "STARTING INSTALLATION OF MPLAB X"
echo "$install_cmd"

else # Older version
    if [ "$MPLABX_IDE" -eq 1 ]
      then
        echo "Installing MPLAB X version < 5.20"
    else
        echo "Not installing MPLAB X"
        exit 0 # 'toolchain only' container
    fi
fi

curl --location "$MPLABX_URL" > '/tmp/mplabx_installer.tar' \
&& tar xf '/tmp/mplabx_installer.tar' -C /tmp

bash -c "$install_cmd"

rm --recursive --force "/tmp/*"
