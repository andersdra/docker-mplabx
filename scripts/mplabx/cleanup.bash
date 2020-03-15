#!/bin/bash
# deletes stuff *I* dont need to reduce image size down to 2.04 with avr gcc

if [ "$DIRTY_CLEANUP" -eq 1 ]
then
rm /opt/microchip/mplabx/v5.35/packs/Microchip/Snap_TP/1.0.44/firmware/scripts.xml
rm /opt/microchip/mplabx/v5.35/packs/Microchip/PKOB4_TP/1.0.36/firmware/scripts.xml
rm /opt/microchip/mplabx/v5.35/packs/Microchip/ICD4_TP/1.0.70/firmware/scripts.xml
rm /opt/microchip/mplabx/v5.35/packs/Microchip/ICE4_TP/1.0.20/firmware/scripts.xml

rm /usr/lib/x86_64-linux-gnu/dri/radeon_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/r200_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/nouveau_vieux_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/i965_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/i915_dri.so

rm /usr/lib/x86_64-linux-gnu/dri/vmwgfx_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/virtio_gpu_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/swrast_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/radeonsi_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/r600_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/r300_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/nouveau_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/kms_swrast_dri.so

rm /usr/bin/perl
fi
