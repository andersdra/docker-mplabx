SHELL = /bin/bash
VERSION ?= latest

USB_BUS = -v /dev/bus/usb:/dev/bus/usb
X11_SOCKET = -v /tmp/.X11-unix:/tmp/.X11-unix:ro
MPLABX_FOLDER = -v $(PWD)/mplabx:/home/mplabx/mplabx
PROJECT_FOLDER = -v $(PWD)/MPLABXProjects:/home/mplabx/MPLABXProjects
XAUTH = -v $(HOME)/.Xauthority:/home/mplabx/.Xauthority:ro

IMAGE_NAME ?= mpavrgcc
CONTAINER_NAME ?= mplab_ide
CONAINER_CMD ?= /entrypoint.sh
USB_CONTAINER_NAME ?= mplab_usb

XFORWARD_CONTAINER_NAME ?= mplab_xforward
ENVIRONMENT ?= -e DISPLAY -e TZ=$(shell timedatectl -p Timezone show | cut -d = -f2)
OPTIONS ?= --cap-drop=ALL --cap-add=MKNOD
MOUNTS ?= $(USB_BUS) $(X11_SOCKET) $(MPLABX_FOLDER) $(PROJECT_FOLDER)

.PHONY: build shell root-shell run-ide run-ipe run-xforward udev start rm hadolint 
.PHONY: sc usb pylint todo args-toolchain args

run:
	docker run --name $(CONTAINER_NAME) $(OPTIONS) $(ENVIRONMENT) $(MOUNTS) $(IMAGE_NAME) $(CONTAINER_CMD)

build: Dockerfile
	docker build --no-cache --rm -t $(IMAGE_NAME):$(VERSION) $(BUILD_ARGS) .

argfile: build-args.env
argfile: BUILD_ARGS = $(shell for arg in $$(< build.args);do args+="--build-arg $$arg ";done; echo $$arg)
argfile: build

run-usb: CONTAINER_NAME = mplab_usb
run-usb: OPTIONS += --device-cgroup-rule='c 189:* rmw'
run-usb: MOUNTS += $(USB_BUS)
run-usb: run

run-ipe: CONTAINER_NAME = mplab_ipe
run-ipe: CONTAINER_CMD = mplab_ipe
run-ipe: run

run-xforward: CONTAINER_NAME = $(XFORWARD_CONTAINER_NAME)
run-xforward: OPTIONS += --net=host
run-xforward: MOUNTS += $(XAUTH)
run-xforward: run

start:
	docker start $(CONTAINER_NAME)

rm:
	docker rm -f $(CONTAINER_NAME)

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
	egrep -I -n -R --exclude='.gitignore' --exclude="*.bak" --exclude-dir='var' \
	--exclude-dir='config' --exclude-dir='.git' --exclude=Makefile 'TODO|todo' || true

stats:
	cloc --exclude-list-file=.cloc_exclude .

grep-args-toolchain:
	grep ARG Dockerfile | sed -n '/AVRGCC/,/DOWNLOAD_DIR/p' | cut -d ' ' -f2 | cut -d = -f1

grep-args:
	grep ARG Dockerfile | cut -d ' ' -f2

shell:
	docker run -it --rm $(IMAGE_NAME) /bin/bash

root-shell:
	docker run --user root -it --rm $(IMAGE_NAME) /bin/bash

default: build
