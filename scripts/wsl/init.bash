#!/bin/bash
# shellcheck source=/dev/null
# install docker-ce
# append docker init, DISPLAY to bashrc
# set iptables to legacy

if [ $EUID -gt 0 ] || [ -z $SUDO_USER ];then
    echo 'run with sudo '
    exit 1
fi

chmod +x docker_wsl.bash
sudo ./docker_wsl.bash

echo 'sudo /etc/init.d/docker start' >> ~/.bashrc
echo "export DISPLAY=$(grep nameserver /etc/resolv.conf | cut -d' ' -f2):0" >> ~/.bashrc
source "$HOME"/.bashrc
newgrp docker
docker run hello-world

