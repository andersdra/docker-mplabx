#!/bin/bash
# docker-mplabx
if [ ! "$C_USER" = root ]
then
  groupadd \
    --system "$C_USER" \
    --gid "$C_GUID" \
&& useradd \
    --no-log-init --uid "$C_UID" \
    --system --gid "$C_USER" \
    --create-home --home-dir /home/"$C_USER" \
    --shell /sbin/nologin "$C_USER" \
;fi
