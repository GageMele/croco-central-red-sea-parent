#!/bin/bash
# Write case-local January 2024 forcing configs. Compare keys with the installed
# CROCO_PYTOOLS scripts before submitting downloads.
set -euo pipefail
set +H

: "${CRS_DIR:?source case.env.local first}"
: "${CRS_GLORYS_DIR:?}"
: "${CRS_ERA5_DIR:?}"
: "${CRS_GLORYS_DATASET:?}"
: "${CRS_THETA_S:?copy from validated January IBC/croco.in}"
: "${CRS_THETA_B:?copy from validated January IBC/croco.in}"
: "${CRS_N:?copy from validated January param.h}"
: "${CRS_HC:?copy from validated January IBC/croco.in}"
: "${CRS_OBC_SOUTH:?set 0 or 1 from validated cppdefs.h}"
: "${CRS_OBC_NORTH:?set 0 or 1 from validated cppdefs.h}"
: "${CRS_OBC_WEST:?set 0 or 1 from validated cppdefs.h}"
: "${CRS_OBC_EAST:?set 0 or 1 from validated cppdefs.h}"

mkdir -p "$CRS_DIR/CONFIG" "$CRS_GLORYS_DIR" "$CRS_ERA5_DIR"

cat > "$CRS_DIR/CONFIG/download_mercator_CRS_JAN2024.ini" <<EOF
[Times]
Ystart = 2024
Mstart = 1
Yend = 2024
Mend = 1

[Download_Options]
use_grd_extent = False
grd_extent_padding = 1.0
custom_extent = [$CRS_FORCE_NORTH, $CRS_FORCE_WEST, $CRS_FORCE_SOUTH, $CRS_FORCE_EAST]

[Croco_Files]
croco_files_dir = $CRS_DIR/CROCO_FILES
croco_grd_prefix = croco_grd

[IBC_Input_Files]
ibc_dir = $CRS_GLORYS_DIR
ibc_prefix = GLORYS

[Mercator_Download]
dataset = $CRS_GLORYS_DATASET
variables = ["thetao","so","uo","vo","zos"]
depths = all
EOF

cat > "$CRS_DIR/CONFIG/download_era5_CRS_JAN2024.ini" <<EOF
[Times]
Ystart = 2024
Mstart = 1
Dstart = 1
Hstart = 0
Yend = 2024
Mend = 1
Dend = 31
Hend = 23
Yorig = 2000
Morig = 1
Dorig = 1
Horig = 0
use_calendar = False

[Download_Options]
use_grd_extent = False
grd_extent_padding = 1.0
custom_extent = [$CRS_FORCE_NORTH, $CRS_FORCE_WEST, $CRS_FORCE_SOUTH, $CRS_FORCE_EAST]

[Croco_Files]
croco_files_dir = $CRS_DIR/CROCO_FILES
croco_grd_prefix = croco_grd

[ERA5_Files]
era5_dir = $CRS_ERA5_DIR
era5_prefix = ERA5

[ERA5_Download]
variables = ["T2M","Q","TP","SSR","STRD","U10M","V10M","SST"]
n_overlap = 1
EOF

cat > "$CRS_DIR/CONFIG/ibc_CRS_JAN2024.ini" <<EOF
[Croco_Files]
croco_files_dir = $CRS_DIR/CROCO_FILES
croco_grd_prefix = croco_grd
croco_ini_prefix = croco_ini_GLORYS
croco_bry_prefix = croco_bry_GLORYS
croco_bry_format = MONTHLY

[Times]
Ystart = 2024
Mstart = 1
Dstart = 1
Hstart = 12
Yend = 2024
Mend = 1
Dend = 31
Hend = 12
Yorig = 2000
Morig = 1
Dorig = 1
Horig = 0
use_calendar = False

[Sigma_Params]
theta_s = $CRS_THETA_S
theta_b = $CRS_THETA_B
N = $CRS_N
hc = $CRS_HC

[IBC_Options]
obc_dict = {'south':$CRS_OBC_SOUTH, 'north':$CRS_OBC_NORTH, 'west':$CRS_OBC_WEST, 'east':$CRS_OBC_EAST}
tracers = ["temp", "salt"]
uv_conserv = 1
min_nb_valid_data = 4

[IBC_Input_Files]
ibc_reader = mercator
ibc_dir = $CRS_GLORYS_DIR
ibc_prefix = GLORYS
ibc_extension = .nc
ibc_freq = 1M
ibc_multi_files = False
EOF

echo "Wrote January configs under $CRS_DIR/CONFIG"
echo "PRE-FLIGHT: compare all section names and keys with $PREPRO scripts."
