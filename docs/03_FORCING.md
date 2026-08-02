# Step 3 - Select, download, and preprocess forcing

## 3.1 Match products to the experiment

For the validated January 2024 baseline:

| Purpose | Product family | Fields |
|---|---|---|
| Initial and lateral boundary state | GLORYS/Mercator via Copernicus Marine | `thetao`, `so`, `uo`, `vo`, `zos` |
| Online atmospheric bulk forcing | ERA5 via CDS | `T2M`, `Q`, `TP`, `SSR`, `STRD`, `U10M`, `V10M`, `SST` as expected by the installed reader |

The run used the monthly GLORYS physical reanalysis configuration. Dataset identifiers and variable aliases can change, so first inspect the installed `download_mercator.py`, `download_era5.py`, and `readers.jsonc`; do not silently substitute a different product.

## 3.2 Credentials

Configure Copernicus Marine and CDS credentials outside the repository. Never paste them into a Slurm file or commit them.

## 3.3 Inspect the installed configuration contract

```bash
source case.env.local
cd "$PREPRO"

grep -n 'config\[' download_mercator.py | head -n 120
grep -n 'config\[' download_era5.py | head -n 160
grep -nE 'era5_dir|n_overlap|ERA5_Download|ERA5_Files' download_era5.py
```

This is mandatory because the active Ibex script required `n_overlap`, and `era5_dir` had to be present in `[ERA5_Files]`.

## 3.4 Write January 2024 configs

```bash
source case.env.local
bash scripts/write_jan2024_forcing_configs.sh
```

The script creates three case-local files:

```text
CONFIG/download_mercator_CRS_JAN2024.ini
CONFIG/download_era5_CRS_JAN2024.ini
CONFIG/ibc_CRS_JAN2024.ini
```

Open all three and compare every section name/key against the installed scripts before submission. Change values only where marked `EDIT HERE`.

## 3.5 Submit forcing preparation

```bash
sbatch slurm/01_prepare_jan2024_forcing.slurm
squeue --me
```

The job performs, in order:

1. GLORYS download.
2. ERA5 download.
3. `make_ini.py`.
4. `make_bry.py`.
5. NetCDF header and finite-value checks.

If GLORYS and ERA5 have already downloaded successfully, do not re-download them. Run only `make_ini.py` and `make_bry.py` from `$PREPRO` with the same IBC configuration.

## 3.6 Expected January files

```text
CROCO_FILES/croco_ini_GLORYS_mercator_Y2024M01.nc
CROCO_FILES/croco_bry_GLORYS_mercator_Y2024M01.nc
DATA/CENTRAL_RED_SEA_ERA5/...
```

Check time coverage, coordinate order, requested variables, finite values, and actual file names before editing `croco.in`.
