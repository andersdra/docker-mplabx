SHELL := /bin/bash
VERSION ?= latest

MCP_USER ?= valid@user.needed
MCP_PASS ?= 
BUILD_ARGS ?= --build-arg MCP_USER=$(MCP_USER) --build-arg MCP_PASS=$(MCP_PASS)
BUILD_ARGS += --build-arg DIRTY_CLEANUP=1 --build-arg AVRGCC=1

USB_BUS = /dev/bus/usb:/dev/bus/usb
X11_SOCKET = /tmp/.X11-unix:/tmp/.X11-unix:ro
MPLABX_FOLDER = $(PWD)/mplabx:/home/mplabx/mplabx
PROJECT_FOLDER = $(PWD)/MPLABXProjects:/home/mplabx/MPLABXProjects
XAUTH = $(HOME)/.Xauthority:/home/mplabx/.Xauthority:ro

IMAGE_NAME ?= mpavrgcc
IDE_CONTAINER_NAME ?= mplab_ide
IPE_CONTAINER_NAME ?= mplab_ipe
USB_CONTAINER_NAME ?= mplab_usb

XFORWARD_CONTAINER_NAME ?= mplab_xforward
ENVIRONMENT ?= -e DISPLAY -e TZ=$(shell timedatectl -p Timezone show | cut -d = -f2)
OPTIONS ?= --cap-drop=ALL --cap-add=MKNOD --device-cgroup-rule='c 189:* rmw'
FOLDERS ?= -v $(USB_BUS) -v $(X11_SOCKET) -v $(MPLABX_FOLDER) -v $(PROJECT_FOLDER)


.PHONY: build shell root-shell run-ide run-ipe run-xforward udev start rm hadolint sc usb pylint todo count

build: Dockerfile
	docker build --no-cache --rm -t $(IMAGE_NAME):$(VERSION) $(BUILD_ARGS) -f Dockerfile .

shell:
	docker run -it --rm $(IMAGE_NAME) /bin/bash

root-shell:
	docker run --user root -it --rm $(IMAGE_NAME) /bin/bash

run-ide:
	docker run --name $(IDE_CONTAINER_NAME) $(OPTIONS) $(ENVIRONMENT) $(FOLDERS) mpavrgcc

usb:
	docker run --name $(USB_CONTAINER_NAME) $(OPTIONS) $(ENVIRONMENT)  -v /tmp/.X11-unix:/tmp/.X11-unix:ro -v /dev/bus/usb/mcp:/dev/bus/usb -v $(MPLABX_FOLDER)  mpavrgcc

run-ipe:
	docker run --name $(IPE_CONTAINER_NAME) $(OPTIONS) $(ENVIRONMENT) $(FOLDERS) mpavrgcc mplab_ide

run-xforward:
	docker run --name $(XFORWARD_CONTAINER_NAME) $(OPTIONS) --net=host $(ENVIRONMENT) $(FOLDERS) -v $(XAUTH) mpavrgcc

start:
	docker start mplab_ide

rm:
	docker rm -f mplab_ide

udev:
	echo 'Will add ./z99-custom-microchip.rules to /etc/udev/rules.d, press enter to continue'
	read
	sudo cp ./z99-custom-microchip.rules /etc/udev/rules.d/
	sudo udevadm control --reload-rules && sudo udevadm trigger

lint: hadolint sc pylint

hadolint:
	docker run --rm -i hadolint/hadolint < Dockerfile || true

sc:
	shellcheck scripts/tool_dl/*.bash || true
	shellcheck scripts/mplabx/*.bash || true

pylint:
	pylint scripts/tool_dl/*.py || true

todo:
	grep -n -R --exclude='.gitignore' --exclude=Makefile TODO || true
	grep -n -R --exclude='.gitignore' --exclude=Makefile todo || true

stats:
	cloc --exclude-dir=mplabx,MPLABXProjects .

default: build
