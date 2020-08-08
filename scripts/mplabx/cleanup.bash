#!/bin/bash

if [ "$DIRTY_CLEANUP" -eq 1 ]
then
rm /usr/lib/x86_64-linux-gnu/dri/radeon_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/r200_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/nouveau_vieux_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/i965_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/i915_dri.so

rm /usr/lib/x86_64-linux-gnu/dri/vmwgfx_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/virtio_gpu_dri.so
#rm /usr/lib/x86_64-linux-gnu/dri/swrast_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/radeonsi_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/r600_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/r300_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/nouveau_dri.so
rm /usr/lib/x86_64-linux-gnu/dri/kms_swrast_dri.so
fi
