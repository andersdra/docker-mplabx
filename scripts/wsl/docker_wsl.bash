#!/bin/bash
# docker-ce wsl2 install script for debian
# install deps, add docker repo, install docker-ce
# start docker, add user to docker group

apt-get update
apt-get install --no-install-recommends --yes \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2 \
  software-properties-common

curl -fsSL "https://download.docker.com/linux/debian/gpg" | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable"
apt-get update
apt-get install --yes docker-ce

update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
touch /etc/fstab
/etc/init.d/docker start
usermod -aG docker "$SUDO_USER"

