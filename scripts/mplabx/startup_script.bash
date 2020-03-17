#!/bin/bash
# docker-mplabx
# hackish PATH startup script

tcs=$(find /opt -maxdepth 1 -mindepth 1 -type d)
path=''

for entry in $tcs;
do
  path="$entry/bin:$path"
done

if [ "$MPLABX_IDE_START" -eq 1 ]
  then
    JAVA_HOME="$(grep 'jdkhome=' /opt/microchip/mplabx/*/mplab_platform/etc/mplab_ide.conf | cut -d '"' -f2)"
    cat > /mplab_start.sh << EOF
#!/bin/sh
export JAVA_HOME="$JAVA_HOME"
export PATH="$path$PATH"
mplab_ide
EOF
  else
    printf '#!/bin/bash\nbash --login' > /mplab_start.sh
fi
chmod 775 /mplab_start.sh