#!/bin/bash
# docker-mplabx
# hackish PATH startup script

tcs=$(find /opt -maxdepth 3 -type d -name bin)
path=''

for tool_path in $tcs;
do
  path="$tool_path:$path"
done

mplabx_bin="$(find /opt/microchip/mplabx/v*/mplab_platform/bin -maxdepth 1 -print -quit)"

if [ "$MPLABX_IDE_ENTRY" -eq 1 ]
then
    JAVA_HOME="$(realpath "$(grep 'jdkhome=' /opt/microchip/mplabx/*/mplab_platform/etc/mplab_ide.conf | cut -d '"' -f2)")"
    cat > /entrypoint.sh << EOF
#!/bin/bash
JAVA_HOME=$JAVA_HOME
PATH=$path$PATH
/usr/bin/mplab_ide --userdir $C_HOME/mplabx --jdkhome "$JAVA_HOME"
EOF
    cat >> "$C_HOME"/.bashrc << EOF
#.bashrc mplabx
JAVA_HOME="$JAVA_HOME"
PATH="$path$PATH:$mplabx_bin"
export JAVA_HOME
export PATH
shopt -s checkwinsize
alias l='ls'
alias -- -='cd -'
EOF
else # toolchain container
    cat > /entrypoint.sh << EOF
#!/bin/bash
/bin/bash --login
EOF
    cat >> "$C_HOME"/.bashrc << EOF
PATH="$path$PATH:$mplabx_bin"
export PATH
alias l='ls'
alias -- -='cd -'
EOF
fi

chmod 775 /entrypoint.sh

