# Containerized MPLAB X IDE, IPE

AVR GCC, ARM GCC  
Microchip XC8, XC16, XC32

- Easy update of IDE + toolchains  
- Simple storage and sharing of specific environments

MPLAB X runs as an unprivileged user (inside container, docker daemon is always root!) with all container capabilities dropped except `mknod` which is needed for replugging to work.

Mounts the hosts X11 socket read-only so beware, never use untrusted prebuilt images that does this.  
Assumes host user is in `docker` group.

# Getting started

To avoid permission problems run `./folder_structure.sh` to generate local runtime/settings folders plus a project folder.  
Keep a backup when updating the image, you will be asked what you want to import including plugins.  
**To use USB from inside the container** it is necessary that udev rules from `z99-custom-microchip.rules` are active.

#### Adding toolchains:  
**Tools -> Options -> Embedded -> Build Tools -> Scan for Build Tools**  
If that does not work the toolchains `/mplabx/toolchains/*/bin` folder must be manually added.

## Building  

#### Default build

	docker build --tag andersdra/mplabx .
	docker-compose build

#### Default build args

	C_USER=mplabx
	C_UID=1000
	C_GUID=1000
	MPLABX=1
	AVRGCC=0
	ARMGCC=0
	MCPXC8=0
	MCPXC16=0
	MCPXC32=0
	
#### Custom tool version args

	MPLABX_URL *.run
	AVRGCC_URL * .tar
	ARMGCC_URL * .tar
	MCPXC8_URL * .run
	MCPXC16_URL
	MCPXC32_URL
#### Local user UID, GUID + AVRGCC

	docker build \
	--tag andersdra/mplabx \
	--build-arg C_UID=$(id --user) \
	--build-arg C_GUID=$(id --group) \
	--build-arg AVRGCC=1 .
	
	docker-compose build \
	-e C_UID=$(id --user) \
	-e C_GUID=$(id --group) \
	-e AVRGCC=1

### Running

	docker run \
	--name mplab_ide \
	--cap-drop=all \
	--cap-add=MKNOD \
	--device-cgroup-rule='c 189:* rmw' \
	-e DISPLAY \
	-e TZ=Europe/Oslo \
	-v /dev/bus/usb:/dev/bus/usb \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	-v $PWD/MPLABX_Folders/MPLABXProjects:/mplabx/MPLABXProjects \
	-v $PWD/MPLABX_Folders/cache:/mplabx/.cache \
	-v $PWD/MPLABX_Folders/java:/mplabx/.java \
	-v $PWD/MPLABX_Folders/mchp_packs:/mplabx/.mchp_packs \
	-v $PWD/MPLABX_Folders/mplab_ide:/mplabx/.mplab_ide \
	-v $PWD/MPLABX_Folders/mplabcomm:/mplabx/.mplabcomm \
	-v $PWD/MPLABX_Folders/oracle_jre_usage:/mplabx/.oracle_jre_usage \
	andersdra/mplabx
	
# Info/Troubleshooting

`No protocol specified` or nothing happens when trying to start `mplab_ide`/`mplab_ipe`: Run `xhost +local:$USER` to allow access to X server.

Use `ide/ipe_usb.sh` to create default containers that allow re-plugging of devices connected when IDE/IPE is started.

Re-run created containers by their name from any folder  
`docker start mplab_ide` || `docker start mplab_ipe`

`ide_xforward.sh` creates a container that can be X-forwarded, ideal for remote debugging etc.

Delete cache folder content if anything stops working as expected in IDE.

[List of TZ database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) 

### Microchip XC Compiler License options

[Microchip MPLAB](https://www.microchip.com/mplab)  
[Installing and Licensing MPLAB XC C Compilers](https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en557685)

MPLAB XC8 C Compiler can be installed to run in Free mode,with a workstation license, or as a network client.  
Default: **Free**  
Allowed: `FreeMode` `WorkstationMode` `NetworkMode`  
AVR and MPLAB are registered trademarks of Microchip in the U.S.A. and other countries.  

# Known Issues/Limitations

- Current udev rules will allow only 1 PICKit4, 1 Atmel ICE, 1 mEDBG at the same time.  
- ModemManager can mess with ttyACMx devices under re-enumeration: `root@host:# systemctl stop ModemManager.service`  
- Moving a floating window to another workspace under GNOME crashes IDE.

# License

This software is licensed under the BSD-2-Clause License.  
See LICENSE for more information.
