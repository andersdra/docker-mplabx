#!/bin/sh
docker run -it \
 --name mplab_bash \
 --user root \
 --device-cgroup-rule='c 189:* rmw' \
 -e DISPLAY \
 -e TZ="$(timedatectl show | grep Timezone | cut -d '=' -f2)" \
 -v /dev/bus/usb:/dev/bus/usb \
 -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
andersdra/mplabx /bin/bash
