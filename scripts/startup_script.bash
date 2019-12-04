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
    printf '#!/bin/sh\nexport PATH="%s%s" && mplab_ide' "$path" "$PATH" > /mplab_start.sh
  else
    printf '#!/bin/bash\nbash --login' > /mplab_start.sh
fi
chmod 775 /mplab_start.sh
