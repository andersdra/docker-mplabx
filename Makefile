SHELL = /bin/bash
VERSION ?= latest

CONTAINER_ENGINE ?= podman
USB_BUS = -v /dev/bus/usb:/dev/bus/usb
X11_SOCKET = -v /tmp/.X11-unix:/tmp/.X11-unix:ro
XAUTH = -v ${XAUTHORITY}:${XAUTHORITY}:ro
SHADOW = -v $(PWD)/shadow:/etc/shadow:ro
PASSWD = -v $(PWD)/passwd:/etc/passwd:ro
HOME_FOLDER = mplabx
HOME_MOUNT = -v $(PWD)/$(HOME_FOLDER):/home/mplabx

IMAGE_TAG ?= mpavrgcc
CONTAINER_NAME ?= mplab_ide
USB_CONTAINER_NAME ?= mplab_usb
IPE_CONTAINER_NAME ?= mplab_ipe
XFORWARD_CONTAINER_NAME ?= mplab_xforward
CONTAINER_CMD ?=

SESSION_TYPE ?= ${XDG_SESSION_TYPE}
ENVIRONMENT  = -e TZ=$(shell timedatectl -p Timezone show | cut -d = -f2)
ENVIRONMENT += -e XDG_SESSION_TYPE=$(SESSION_TYPE) -e XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}
ENVIRONMENT += -e DISPLAY
OPTIONS ?=
OPTIONS += --cap-drop=ALL --cap-add=MKNOD --security-opt=no-new-privileges
OPTIONS += --shm-size 128m # Microchip's page is heavy... only needed for Firefox
MOUNTS = $(X11_SOCKET)
MOUNTS += $(HOME_MOUNT)
MOUNTS += $(SHADOW) $(PASSWD)

BUILD_ARGS ?=

ifeq ($(CONTAINER_ENGINE),podman)
       OPTIONS += --userns=keep-id
endif

.PHONY: build shell root-shell run-ide run-ipe run-xforward udev start rm hadolint
.PHONY: sc usb pylint todo home

run:
	$(CONTAINER_ENGINE) run --name $(CONTAINER_NAME) $(OPTIONS) $(ENVIRONMENT) $(MOUNTS) $(IMAGE_TAG) $(CONTAINER_CMD)

build: Dockerfile
	$(CONTAINER_ENGINE) build --no-cache --rm -t $(IMAGE_TAG):$(VERSION) $(BUILD_ARGS) .

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

# copy home folder from image, chown if not writeable
home:
	$(eval ID=$(shell $(CONTAINER_ENGINE) create $(IMAGE_TAG)))
	$(CONTAINER_ENGINE) cp $(ID):/home/mplabx mplabx
	$(CONTAINER_ENGINE) rm $(ID)
	$(SHELL) -c "test -d $(HOME_FOLDER) -a -w $(HOME_FOLDER) || sudo chown -R $$(id --user):$$(id --group) $(HOME_FOLDER)"

# makes container run with user that has different UID:GUID from the one that built the image
update-ids:
	sed -i "s/\mplabx:x:[0-9]*:[0-9]*/mplabx:x:$$(id --user):$$(id --group)/g" passwd
	sed -i "s/\mplabx:x:[0-9]*:[0-9]*/mplabx:x:$$(id --user):$$(id --group)/g" shadow

copy-toolchains:
	$(eval ID=$(shell $(CONTAINER_ENGINE) create $(IMAGE_TAG)))
	$(CONTAINER_ENGINE) cp $(ID):/opt/toolchains toolchains
	$(CONTAINER_ENGINE) rm $(ID)

start:
	$(CONTAINER_ENGINE) start $(CONTAINER_NAME)

rm:
	$(CONTAINER_ENGINE) rm -f $(CONTAINER_NAME)

udev:
	echo 'Will add ./z99-custom-microchip.rules to /etc/udev/rules.d, press enter to continue'
	read
	sudo cp ./z99-custom-microchip.rules /etc/udev/rules.d/
	sudo udevadm control --reload-rules && sudo udevadm trigger

lint: hadolint sc pylint

hadolint:
	$(CONTAINER_ENGINE) run --rm -i hadolint/hadolint < Dockerfile || true

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
	$(CONTAINER_ENGINE) run -it --rm $(IMAGE_TAG) /bin/bash

root-shell:
	$(CONTAINER_ENGINE) run --user root -it --rm $(IMAGE_TAG) /bin/bash

default: build
