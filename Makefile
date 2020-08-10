SHELL = /bin/bash
VERSION ?= latest

USB_BUS = -v /dev/bus/usb:/dev/bus/usb
X11_SOCKET = -v /tmp/.X11-unix:/tmp/.X11-unix:ro
MPLABX_FOLDER = -v $(PWD)/mplabx:/home/mplabx/mplabx
PROJECT_FOLDER = -v $(PWD)/MPLABXProjects:/home/mplabx/MPLABXProjects
XAUTH = -v $(HOME)/.Xauthority:/home/mplabx/.Xauthority:ro

IMAGE_NAME ?= mpavrgcc
CONTAINER_NAME ?= mplab_ide
USB_CONTAINER_NAME ?= mplab_usb
IPE_CONTAINER_NAME ?= mplab_ipe
XFORWARD_CONTAINER_NAME ?= mplab_xforward
CONTAINER_CMD ?= 

SESSION_TYPE ?= x11
ENVIRONMENT  = -e TZ=$(shell timedatectl -p Timezone show | cut -d = -f2)
ENVIRONMENT += -e XDG_SESSION_TYPE=$(SESSION_TYPE) -e XDG_RUNTIME_DIR=/tmp -e WAYLAND_DISPLAY
ENVIRONMENT += -e DISPLAY
OPTIONS ?= --cap-drop=ALL --cap-add=MKNOD --security-opt=no-new-privileges
OPTIONS += --shm-size 128m # Microchip's page is heavy... only needed for Firefox
MOUNTS = $(X11_SOCKET)
MOUNTS += $(MPLABX_FOLDER) $(PROJECT_FOLDER)
BUILD_ARGS ?=

.PHONY: build shell root-shell run-ide run-ipe run-xforward udev start rm hadolint
.PHONY: sc usb pylint todo

run:
	docker run --name $(CONTAINER_NAME) $(OPTIONS) $(ENVIRONMENT) $(MOUNTS) $(IMAGE_NAME) $(CONTAINER_CMD)

build: Dockerfile
	docker build --no-cache --rm -t $(IMAGE_NAME):$(VERSION) $(BUILD_ARGS) .

argfile: build.args
argfile: BUILD_ARGS += $(shell IFS=$$'\n';for arg in $$(< build.args);do args+="--build-arg $$arg ";done;echo $$args)
argfile: build

run-usb: CONTAINER_NAME = $(USB_CONTAINER_NAME)
run-usb: OPTIONS += --device-cgroup-rule='c 189:* rmw'
run-usb: MOUNTS += $(USB_BUS)
run-usb: run

run-ipe: CONTAINER_NAME = $(IPE_CONTAINER_NAME)
run-ipe: CONTAINER_CMD = mplab_ipe
run-ipe: OPTIONS += --device-cgroup-rule='c 189:* rmw'
run-ipe: MOUNTS += $(USB_BUS)
run-ipe: run

run-xforward: CONTAINER_NAME = $(XFORWARD_CONTAINER_NAME)
run-xforward: OPTIONS += --net=host
run-xforward: OPTIONS += --device-cgroup-rule='c 189:* rmw'
run-xforward: MOUNTS += $(USB_BUS)
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

update-args:
	@grep ARG Dockerfile | sed -n '/AVRGCC/,/DOWNLOAD_DIR/p' | cut -d ' ' -f2 | cut -d = -f1 > scripts/tool_dl/build-args.env

args:
	grep ARG Dockerfile | cut -d ' ' -f2

shell:
	docker run -it --rm $(IMAGE_NAME) /bin/bash

root-shell:
	docker run --user root -it --rm $(IMAGE_NAME) /bin/bash

default: build
