#!/bin/bash
#SBATCH --job-name=crs_compile
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=02:00:00
#SBATCH --mem=24G
#SBATCH --output=LOGS/compile_%j.out
#SBATCH --error=LOGS/compile_%j.err

set -euo pipefail
cd /ibex/user/meleg/CROCO_SETUP/CONFIGS/CENTRAL_RED_SEA_PARENT_GEBCO
source case.env.local
source "$CROCO_ROOT/SCRIPTS/load_croco_netcdf_intel.sh"

grep -nE 'REGIONAL|COASTAL|MPI|OBC_|BULK_FLUX|ONLINE|ERA_ECMWF' cppdefs.h
grep -nE 'LLm0|MMm0|NP_XI|NP_ETA|NNODES' param.h
./jobcomp > "LOGS/jobcomp_${SLURM_JOB_ID}.log" 2>&1
test -x croco
echo "COMPILE_OK"
