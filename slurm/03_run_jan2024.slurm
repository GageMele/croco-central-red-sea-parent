#!/bin/bash
# Validated resource shape: four MPI ranks on one compute node.
#SBATCH --job-name=crs_jan2024
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=64G
#SBATCH --output=LOGS/run_jan2024_%j.out
#SBATCH --error=LOGS/run_jan2024_%j.err

set -euo pipefail
cd /ibex/user/meleg/CROCO_SETUP/CONFIGS/CENTRAL_RED_SEA_PARENT_GEBCO
source case.env.local
source "$CROCO_ROOT/SCRIPTS/load_croco_netcdf_intel.sh"

test -x croco
test -s CROCO_FILES/croco_grd.nc
test -s CROCO_FILES/croco_ini_GLORYS_mercator_Y2024M01.nc
test -s CROCO_FILES/croco_bry_GLORYS_mercator_Y2024M01.nc

cp -p croco.in "RUN_BACKUPS/croco.in.jan2024.${SLURM_JOB_ID}"
srun -n "$SLURM_NTASKS" ./croco croco.in > croco.out 2>&1
grep -Fq 'MAIN: DONE' croco.out
echo "JAN2024_RUN_OK"
