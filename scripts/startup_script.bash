#!/bin/bash
# docker-mplabx
# hackish PATH startup script

tcs=$(find /opt -maxdepth 1 -mindepth 1 -type d)
path=''

for entry in $tcs;
do
  path="$entry/bin:$path"
done

printf '#!/bin/sh\nPATH="%s%s" && mplab_ide' "$path" "$PATH" > /mplab_start.sh
chmod 775 /mplab_start.sh
