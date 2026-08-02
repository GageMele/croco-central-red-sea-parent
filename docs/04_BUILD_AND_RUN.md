# Step 4 - Stage, compile, and run January 2024

## 4.1 Stage clean control files

Start from fresh CROCO source files rather than carrying edits from another case:

```bash
source case.env.local

cp -p "$CROCO_ROOT/croco/OCEAN/cppdefs.h" "$CRS_DIR/cppdefs.h"
cp -p "$CROCO_ROOT/croco/OCEAN/param.h"   "$CRS_DIR/param.h"
cp -p "$CROCO_ROOT/croco/OCEAN/jobcomp"  "$CRS_DIR/jobcomp"
```

Copy the appropriate regional `croco.in` template from the installed CROCO distribution or the validated case backup.

## 4.2 Edit `cppdefs.h`

- Activate only the intended top-level configuration (`REGIONAL`, not a test case).
- Confirm `MPI`, spherical curvilinear grid and masking keys.
- Confirm 3-D, temperature/salinity, nonlinear equation of state, surface bulk forcing, online ERA5 reader, and the exact open boundaries.

Copy the switches from the successful January backup. Do not infer open boundaries from a generic example.

## 4.3 Edit `param.h`

```fortran
! Validated horizontal dimensions
parameter (LLm0=423, MMm0=690, N=YOUR_VALIDATED_N)

! Validated January layout: four total MPI ranks.
! EDIT HERE only if compiling a separate benchmark executable.
parameter (NP_XI=YOUR_VALIDATED_NP_XI,
     &     NP_ETA=YOUR_VALIDATED_NP_ETA,
     &     NNODES=NP_XI*NP_ETA)
```

Use the actual successful `NP_XI`/`NP_ETA` orientation from the saved `param.h`; only the total of four ranks is confirmed here.

## 4.4 Edit `jobcomp`

Set `SOURCE`, `SCRDIR`, `RUNDIR`, and `ROOT_DIR` to the Central Red Sea case and source tree. Confirm the Intel/OpenMPI/NetCDF stack matches the runtime job.

## 4.5 Edit `croco.in`

Point to:

```text
grid = CROCO_FILES/croco_grd.nc
ini  = CROCO_FILES/croco_ini_GLORYS_mercator_Y2024M01.nc
bry  = CROCO_FILES/croco_bry_GLORYS_mercator_Y2024M01.nc
ERA5 = /ibex/user/meleg/CROCO_SETUP/DATA/CENTRAL_RED_SEA_ERA5
```

Copy the validated `time_stepping`, S-coordinate, `wkb_boundary`, online forcing, output frequency, and mixing blocks from the successful January control file. Initial-condition and boundary vertical parameters must match preprocessing.

## 4.6 Compile as a Slurm job

```bash
sbatch slurm/02_compile.slurm
```

After it finishes:

```bash
tail -n 120 LOGS/compile_*.out
tail -n 120 LOGS/jobcomp_*.log
test -x croco && echo 'COMPILE OK'
```

## 4.7 Run January

```bash
sbatch slurm/03_run_jan2024.slurm
squeue --me
```

Monitor without running model work on the login node:

```bash
tail -n 80 "$(ls -1t LOGS/run_jan2024_*.out | head -n 1)"
tail -n 120 croco.out
```

Completion requires both a zero Slurm exit and:

```bash
grep -F 'MAIN: DONE' croco.out
```

Archive the exact `cppdefs.h`, `param.h`, `jobcomp`, `croco.in`, compile log, run log, and grid checksum with the January milestone.
