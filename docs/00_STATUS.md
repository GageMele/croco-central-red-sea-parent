# Workflow status and provenance

## Validated baseline

The latest validated Central Red Sea baseline is the January 2024 run of `CENTRAL_RED_SEA_PARENT_GEBCO` on KAUST Ibex.

```text
Grid dimensions:     recorded header xi_rho=424, eta_rho=691
param.h dimensions:  LLm0=423, MMm0=690
Vertical levels:     confirm from the active param.h before reproducing
MPI layout:          four ranks on one compute node
Ocean forcing:       GLORYS/Mercator
Atmospheric forcing: ERA5, online bulk forcing
Completion marker:   MAIN: DONE
```

The recorded rho dimensions and compiled `LLm0/MMm0` do not follow the simple `rho minus two` relationship used by some other CROCO grids. Treat the active `croco_grd.nc` and successful `param.h` as a paired baseline; do not “correct” either from a generic formula. The repository also does not guess values that are not preserved in the run record. Copy the active, successful `N`, vertical stretching parameters, time step, open-boundary switches, and `croco.in` blocks before declaring a replica exact.

## Known resolved issues

### ERA5 configuration keys

The installed `download_era5.py` expected `n_overlap`. A preparation attempt also failed until `era5_dir` was written directly into `[ERA5_Files]`. The supplied preflight script checks both conditions before submission.

### Grid `spherical` variable

A reconstructed NetCDF4 grid contained `spherical(one,string1)` with value `T`. CROCO expected a one-character variable on dimension `one`, and `GET_GRID` failed. A later attempt to copy the file to `NETCDF3_64BIT_OFFSET` failed while copying `_FillValue`; merely changing the container format did not repair the variable schema.

The safe rule is:

1. Create the grid with the installed CROCO_PYTOOLS `make_grid.py`.
2. Validate the dimensions and `spherical` declaration before forcing generation.
3. Do not hand-rebuild the grid with xarray unless every CROCO variable, dimension, type, attribute, and encoding is preserved.

## Planned, not yet validated

- Chain February-April 2024 from monthly restart files.
- Benchmark a separately compiled eight-rank executable with `NP_XI=4`, `NP_ETA=2` on two nodes.
- After the chain passes, run and QC January-December 2024.
- Only after the parent year is complete, proceed to the full Red Sea plus Gulf of Aden domain.

This wording prevents planned experiments from being mistaken for stable settings.
