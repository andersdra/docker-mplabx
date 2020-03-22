# MPLAB X IDE/IPE
# AVR, ARM GCC
# Microchip XC8, XC16, XC32 
# Source and docs: https://gitlab.com/andersdra/docker-mplabx
# TOOLCHAIN DOWNLOAD
FROM python:3.8 AS toolchains

ARG MCP_USER
ARG MCP_PASS

ARG AVRGCC
ARG ARMGCC
ARG MCPXC8
ARG MCPXC16
ARG MCPXC32
ARG PIC32_LEGACY
ARG MPLAB_HARMONY

ARG AVRGCC_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en607660'
ARG ARMGCC_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en603996'
ARG MCPXC8_URL='https://www.microchip.com/mplabxc8linux'
ARG MCPXC16_URL='https://www.microchip.com/mplabxc16linux'
ARG MCPXC32_URL='https://www.microchip.com/mplabxc32linux'
ARG MPLAB_HARMONY_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en606318'
ARG PIC32_LEGACY_URL='http://ww1.microchip.com/downloads/en//softwarelibrary/pic32%20peripheral%20library/pic32%20legacy%20peripheral%20libraries%20linux%20(2).tar'
ARG DOWNLOAD_DIR='/toolchains'

COPY scripts/tool_dl /

RUN chmod +x /*.bash /*.py && /init.bash

# MPLAB X
FROM debian:buster-slim
LABEL maintainer="Anders Draagen <andersdra@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG C_USER=mplabx
ARG C_HOME="/home/${C_USER}"
ARG C_UID=1000
ARG C_GUID=1000

ARG MPLABX_IDE=1
ARG MPLABX_IDE_START=1
ARG MPLABX_IPE=0
ARG MPLABX_TELEMETRY=0
ARG MPLABX_DARCULA=1
ARG MPLABX_VERSION=0
ARG DIRTY_CLEANUP=0
ARG ADDITIONAL_PACKAGES

ARG ARDUINO=0
ARG AVRGCC=0
ARG ARMGCC=0
ARG MCPXC8=0
ARG MCPXC16=0
ARG MCPXC32=0
ARG PIC32_LEGACY=0
ARG MPLAB_HARMONY=0
ARG OTHERMCU=0

ARG AVRGCC_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en607660'
ARG ARMGCC_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en603996'
ARG MCPXC8_URL='https://www.microchip.com/mplabxc8linux'
ARG MCPXC16_URL='https://www.microchip.com/mplabxc16linux'
ARG MCPXC32_URL='https://www.microchip.com/mplabxc32linux'
ARG MPLAB_HARMONY_URL='https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en606318'
ARG PIC32_LEGACY_URL='http://ww1.microchip.com/downloads/en//softwarelibrary/pic32%20peripheral%20library/pic32%20legacy%20peripheral%20libraries%20linux%20(2).tar'

ARG ARDUINO_URL=''
ARG DARCULA_URL='http://plugins.netbeans.org/download/plugin/9293'
ARG MPLABX_URL='https://www.microchip.com/mplabx-ide-linux-installer'
ARG DOWNLOAD_DIR='/toolchains'

COPY --from=toolchains /toolchains/ /toolchains
COPY scripts/mplabx /

RUN chmod +x /*.bash && /init.bash

ENV USER=${C_USER}
ENV SHELL=/bin/bash
ENV HOME=${C_HOME}

USER $C_USER
WORKDIR $C_HOME

CMD ["/mplab_start.sh"]
