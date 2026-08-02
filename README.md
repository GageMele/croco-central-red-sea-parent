# CROCO Central Red Sea Parent

Reproducible, beginner-readable documentation for the Central Red Sea parent configuration developed on KAUST Ibex.

The repository records the workflow from domain design and GEBCO bathymetry through GLORYS/ERA5 forcing, CROCO compilation, a January 2024 run, monthly restarts, and scheduled QC. Large NetCDF inputs, outputs, executables, and credentials are intentionally excluded.

## Validation status

| Component | Status | Evidence / note |
|---|---|---|
| Grid | Validated for the active case | Recorded grid header: `xi_rho=424`, `eta_rho=691`; compiled case: `LLm0=423`, `MMm0=690`. Re-read both live files before rebuilding. |
| Bathymetry source | Validated | GEBCO 2026 subset; source coverage recorded as north 25.0, south 20.5, west 34.5, east 39.75 |
| January 2024 forcing | Validated | GLORYS/Mercator initial and boundary files plus ERA5 online forcing |
| January 2024 model run | Validated | Four MPI ranks on one compute node; `MAIN: DONE` |
| February-April restart chain | Next validation target | Planned consecutive monthly restarts; do not treat as completed |
| Eight-rank/two-node build | Experimental | Candidate `NP_XI=4`, `NP_ETA=2`; requires a separate recompile and benchmark |
| Full 2024 run | Planned | Run only after the restart-chain test passes |

## Read in this order

1. [Workflow status](docs/00_STATUS.md)
2. [Ibex setup](docs/01_IBEX_SETUP.md)
3. [Grid creation and validation](docs/02_GRID.md)
4. [GLORYS and ERA5 forcing](docs/03_FORCING.md)
5. [Compilation and January run](docs/04_BUILD_AND_RUN.md)
6. [Monthly chaining and QC](docs/05_MONTH_CHAINING_AND_QC.md)

Copy [case.env.example](config/case.env.example) to `case.env.local`, edit only the block marked `EDIT HERE`, then submit the Slurm templates rather than doing heavy work on a login node.

## Case identity

```text
Case:       CENTRAL_RED_SEA_PARENT_GEBCO
Ibex root:  /ibex/user/meleg/CROCO_SETUP
Case dir:   /ibex/user/meleg/CROCO_SETUP/CONFIGS/CENTRAL_RED_SEA_PARENT_GEBCO
Python:     /ibex/user/meleg/CROCO_SETUP/ENVS/croco_pyenv/bin/python
Grid:       recorded as 424 x 691 rho points
param.h:    LLm0=423, MMm0=690
Baseline:   January 2024, four MPI ranks, one node
```

## Repository rules

- Do not commit `.cdsapirc`, Copernicus credentials, tokens, or passwords.
- Do not commit `*.nc`, `*.grib*`, `*.tif`, compiled `croco`, or run directories.
- Save exact configuration files and small text summaries for every stable milestone.
- A change to `cppdefs.h` or `param.h` requires recompilation.
- `NNODES` in `param.h`, Slurm `--ntasks`, and `srun -n` must agree.

## Source basis

This workflow combines the validated Ibex run record with CROCO Beginner Training 2025 guidance: use `make_grid.py`, `make_ini.py`, and `make_bry.py`; keep preprocessing and runtime settings coherent; compile with `jobcomp`; and use `MAIN: DONE` only as the run-completion marker. Always compare local scripts with the installed CROCO/CROCO_PYTOOLS version because configuration keys change between releases.
