#!/bin/bash
#SBATCH --job-name=crs_force_jan24
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --mem=64G
#SBATCH --output=LOGS/forcing_jan2024_%j.out
#SBATCH --error=LOGS/forcing_jan2024_%j.err

set -euo pipefail
set +H

cd /ibex/user/meleg/CROCO_SETUP/CONFIGS/CENTRAL_RED_SEA_PARENT_GEBCO
source case.env.local
source "$CROCO_ROOT/SCRIPTS/load_croco_netcdf_intel.sh"
export MAMBA_ROOT_PREFIX=$CROCO_ROOT/MICROMAMBA_ROOT
eval "$($CROCO_ROOT/MICROMAMBA/bin/micromamba shell hook -s bash)"
micromamba activate "$PYENV"
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export MKL_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OPENBLAS_NUM_THREADS=$SLURM_CPUS_PER_TASK

python scripts/validate_grid.py "$CRS_GRID"
bash scripts/write_jan2024_forcing_configs.sh

cd "$PREPRO"
python download_mercator.py "$CRS_DIR/CONFIG/download_mercator_CRS_JAN2024.ini"
python download_era5.py "$CRS_DIR/CONFIG/download_era5_CRS_JAN2024.ini"
python make_ini.py "$CRS_DIR/CONFIG/ibc_CRS_JAN2024.ini"
python make_bry.py "$CRS_DIR/CONFIG/ibc_CRS_JAN2024.ini"

for f in \
  "$CRS_DIR/CROCO_FILES/croco_ini_GLORYS_mercator_Y2024M01.nc" \
  "$CRS_DIR/CROCO_FILES/croco_bry_GLORYS_mercator_Y2024M01.nc"; do
  test -s "$f"
  ncdump -h "$f" | sed -n '1,100p'
done

echo "FORCING_PREP_OK"
