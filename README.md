# MPLAB X IDE/IPE docker container 

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/andersdra/mplabx?style=plastic)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/andersdra/mplabx?style=plastic)

AVR GCC, ARM GCC  
Microchip XC8, XC16, XC32

- Easy update of IDE + toolchains  
- Simple storage and sharing of specific environments

As of v5.10 the installer allows for skipping of 8/16/32bit support, shrinking the size of IDE + AVRGCC from >5GB to aprox 2.27GB.  
16bit, 32bit and harmony is untested  

## Getting started

Assumes host user is in `docker` group.

MPLAB X runs as an unprivileged user inside container, docker daemon is always root!  
All container capabilities are dropped except `mknod` which is needed for replugging of development boards/programmers to work.

Mounts the hosts X11 socket read-only so beware, never use untrusted prebuilt images that does this.  

MPLAB X userdir defaults to 'mplabx', project folder 'MPLABXProjects'  
Keep a backup when updating the image, you will be asked what you want to import including plugins.  
**To use USB from inside the container** it is necessary that udev rules from `z99-custom-microchip.rules` are active.


## Building  

Edit build.args, Makefile or use --build-args.  

**Downloading {AVR,ARM}GCC from Microchip now requires a user**  

    MCP_USER='valid_microchip@user.required'
    MCP_PASS='blaAET13f'
    
#### Default build

	docker build --tag andersdra/mplabx .
	docker-compose build
	make build

#### Default build args

	C_USER=mplabx
	C_UID=1000
	C_GUID=1000
    C_HOME="/home/${C_USER}"

    MPLABX_IDE_ENTRY=1 // for toolchain only container
	MPLABX_IDE=1
    MPLABX_IPE=0
    MPLABX_TELEMETRY=0
    MPLABX_DARCULA=1
    MPLABX_VERSION=0 # latest version
    ADDITIONAL_PACKAGES='' // added to apt-get
    
    ARDUINO=0
	AVRGCC=0
	ARMGCC=0
	MCPXC8=0
	MCPXC16=0
	MCPXC32=0

	PIC32_LEGACY=0
	MPLAB_HARMONY=0
	OTHERMCU=0 # only valid for >= V5.20 (SERIALEE, HCSxxxx) (2.0MB)
	NO_PIC_DFP=0 # removes ~3GB of PIC related DFP's
	
#### Custom tool version args
    
    ARDUINO_URL *.tar.xz
	AVRGCC_URL *.tar
	ARMGCC_URL *.tar
	MCPXC8_URL *.run
	MCPXC16_URL
	MCPXC32_URL
	
	MPLAB_HARMONY_URL *.run
	PIC32_LEGACY_URL *.tar
	DARCULA_URL	*.nbm

Example for building v5.15:

`docker build --tag andersdra/mplabx515 --build-arg MPLABX_VERSION=5.15 .`

#### Local user UID, GUID + AVRGCC

	docker build \
	--tag andersdra/mplabx \
	--build-arg C_UID=$(id --user) \
	--build-arg C_GUID=$(id --group) \
	--build-arg AVRGCC=1 .
	
### Running

	make run-ide

### WSL2  
Probably only works on windows insider slow/fast ring.  
IDE/IPE requires an X-server running on Windows host. (MobaXterm etc. (remote access needs to be enabled since communication is via TCP/IP))  
Docker for Desktop with WSL backend support enabled for MPLABX WSL image will mess with docker context, this method uses WSL2's native docker socket.  

Not working:  
- Terminal does not load shell  
- unable to create a project because of 'invalid project name'

Run commands in powershell as administrator.  

#### Enable WSL and HYPER-V  
	dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
	dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /promptrestart  

#### Download and install latest WSL kernel, set WSL2 as default  
	kernel_url = https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
	download_dir = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
	Invoke-WebRequest $kernel_url -OutFile $download_dir\wsl_update_x64.msi
	msiexec /a $download_dir\wsl_update_x64.msi /passive /norestart
	Remove-Item $download_dir\wsl_update_x64.msi
	wsl --set-default-version 2

Start a Debian WSL image downloaded from Microsoft store, install git, clone repo, sudo ./docker-mplabx/scripts/wsl/init.bash, build, run
	

# Info/Troubleshooting

When using Firefox instead of the embedded webkit browser, edit browser arguments to `--profile /home/mplabx/.firefox_profile {URL}`  

[**Missing header files**](doc/header_include_path.png)

`No protocol specified` or nothing happens when trying to start `mplab_ide`/`mplab_ipe`: Run `xhost +local:$USER` to allow access to X server.

Re-run created containers by their name from any folder  
`docker start mplab_ide` || `docker start mplab_ipe`

Delete cache folder content if anything stops working as expected in IDE.

For sound events in IDE use ADDITIONAL_PACKAGES to install `libcanberra-gtk-module`  

[**List of TZ database time zones**](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) 

### Microchip XC Compiler License options

[Microchip MPLAB](https://www.microchip.com/mplab)  
[Installing and Licensing MPLAB XC C Compilers](https://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en557685)

MPLAB XC8 C Compiler can be installed to run in Free mode,with a workstation license, or as a network client.  
Default: **Free**  
Allowed: `FreeMode` `WorkstationMode` `NetworkMode`  
AVR and MPLAB are registered trademarks of Microchip in the U.S.A. and other countries.  

# Known Issues/Limitations

- ~~Current udev rules will allow only 1 PICKit4, 1 Atmel ICE, 1 mEDBG at the same time.~~  
- ModemManager can mess with ttyACMx devices under re-enumeration:  
`root@host:# systemctl stop ModemManager.service`  
- ~~Moving a floating window to another workspace under GNOME crashes IDE.~~

# Todo

- Avoid mounting whole USB bus


# License

This software is licensed under the MIT License.  
See LICENSE for more information.
