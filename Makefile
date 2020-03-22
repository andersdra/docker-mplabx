SHELL := /bin/bash
VERSION ?= latest

MCP_USER ?= valid@user.needed
MCP_PASS ?= 
BUILD_ARGS ?= --build-arg MCP_USER=$(MCP_USER) --build-arg MCP_PASS=$(MCP_PASS)
BUILD_ARGS += --build-arg DIRTY_CLEANUP=1 --build-arg AVRGCC=1 --build-arg ARMGCC=1

USB_BUS = /dev/bus/usb:/dev/bus/usb
X11_SOCKET = /tmp/.X11-unix:/tmp/.X11-unix:ro
MPLABX_FOLDER = mplabx:/home/mplabx
XAUTH = $(HOME)/.Xauthority:/home/mplabx/.Xauthority:ro

IMAGE_NAME ?= mpavrgcc
IDE_CONTAINER_NAME ?= mplab_ide
IPE_CONTAINER_NAME ?= mplab_ipe
XFORWARD_CONTAINER_NAME ?= mplab_xforward
ENVIRONMENT ?= -e DISPLAY -e TZ=$(shell timedatectl -p Timezone show | cut -d = -f2)
OPTIONS ?= --cap-drop=ALL --cap-add=MKNOD --device-cgroup-rule='c 189:* rmw'
FOLDERS ?= -v $(USB_BUS) -v $(X11_SOCKET) -v $(MPLABX_FOLDER)


.PHONY: build shell root-shell run-ide run-ipe run-xforward udev start rm lint sc

build: Dockerfile
	docker build --no-cache --rm -t $(IMAGE_NAME):$(VERSION) $(BUILD_ARGS) -f Dockerfile .

shell:
	docker run -it --rm $(IMAGE_NAME) /bin/bash

root-shell:
	docker run --user root -it --rm $(IMAGE_NAME) /bin/bash

run-ide:
	docker run --name $(IDE_CONTAINER_NAME) $(OPTIONS) $(ENVIRONMENT) $(FOLDERS) mpavrgcc

run-ipe:
	docker run --name $(IPE_CONTAINER_NAME) $(OPTIONS) $(ENVIRONMENT) $(FOLDERS) mpavrgcc mplab_ide

run-xforward: 
	docker run --name $(XFORWARD_CONTAINER_NAME) $(OPTIONS) --net=host $(ENVIRONMENT) $(FOLDERS) -v $(XAUTH) mpavrgcc

start:
	docker start mplab_ide

rm:
	docker rm -f mplab_ide

udev:
	echo 'Will install ./z99-custom-microchip.rules to /etc/udev/rules.d, press enter to continue'
	read
	sudo cp ./z99-custom-microchip.rules /etc/udev/rules.d/
	sudo udevadm control --reload-rules && sudo udevadm trigger

lint:
	docker run --rm -i hadolint/hadolint < Dockerfile

sc:
	shellcheck scripts/tool_dl/*.bash || true
	shellcheck scripts/mplabx/*.bash || true

default: build
