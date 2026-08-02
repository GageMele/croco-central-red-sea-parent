# Step 1 - Prepare the Ibex environment

## 1.1 Set paths

Copy the example and edit only the marked block:

```bash
cd /ibex/user/meleg/CROCO_SETUP/CONFIGS/CENTRAL_RED_SEA_PARENT_GEBCO
cp /path/to/this/repository/config/case.env.example case.env.local
nano case.env.local
source case.env.local
```

## 1.2 Activate the validated Python environment

```bash
export MAMBA_ROOT_PREFIX=/ibex/user/meleg/CROCO_SETUP/MICROMAMBA_ROOT
eval "$(/ibex/user/meleg/CROCO_SETUP/MICROMAMBA/bin/micromamba shell hook -s bash)"
micromamba activate /ibex/user/meleg/CROCO_SETUP/ENVS/croco_pyenv

which python
python --version
```

Expected executable:

```text
/ibex/user/meleg/CROCO_SETUP/ENVS/croco_pyenv/bin/python
```

## 1.3 Load the compiler and NetCDF stack

```bash
source /ibex/user/meleg/CROCO_SETUP/SCRIPTS/load_croco_netcdf_intel.sh
module list
which mpif90
which ncdump
```

The working run used Intel 2022.3, OpenMPI 4.1.4, and parallel NetCDF 4.9.1. Use the helper script so compilation and execution see the same stack.

## 1.4 Create the case layout

```bash
mkdir -p "$CRS_DIR"/{CROCO_FILES,LOGS,SLURM,PLOTS,RUN_BACKUPS,SUMMARY}
mkdir -p "$CRS_GLORYS_DIR" "$CRS_ERA5_DIR"
```

## 1.5 Compute-node rule

Use the login node for editing, `sbatch`, `squeue`, and short log inspection. Submit downloads, preprocessing, compilation, simulation, QC, and plotting through Slurm.
