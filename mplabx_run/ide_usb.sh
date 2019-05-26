#!/bin/bash
# Run from same folder as MPLABX_Folders
docker run \
 --name mplab_ide \
 --cap-drop=all \
 --cap-add=MKNOD \
 --device-cgroup-rule='c 189:* rmw' \
 -e DISPLAY \
 -e TZ=Europe/Oslo \
 -v /dev/bus/usb:/dev/bus/usb \
 -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
 -v $PWD/MPLABX_Folders/MPLABXProjects:/home/mplabx/MPLABXProjects \
 -v $PWD/MPLABX_Folders/cache:/home/mplabx/.cache \
 -v $PWD/MPLABX_Folders/java:/home/mplabx/.java \
 -v $PWD/MPLABX_Folders/mchp_packs:/home/mplabx/.mchp_packs \
 -v $PWD/MPLABX_Folders/mplab_ide:/home/mplabx/.mplab_ide \
 -v $PWD/MPLABX_Folders/mplabcomm:/home/mplabx/.mplabcomm \
 -v $PWD/MPLABX_Folders/oracle_jre_usage:/home/mplabx/.oracle_jre_usage \
andersdra/mplabx
