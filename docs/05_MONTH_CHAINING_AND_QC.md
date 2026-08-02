# Step 5 - Chain months and QC every hand-off

## Validation sequence

Use this order:

1. Preserve the successful January 2024 baseline.
2. Run February 2024 from January's restart.
3. QC February and verify the restart date.
4. Run March from February's restart, then QC.
5. Run April from March's restart, then QC.
6. Only after the three-month chain passes, extend through December 2024.

## Monthly hand-off

For each month:

- set the correct month length and `NTIMES` (or validated calendar dates);
- select that month's boundary file;
- use the previous month's restart as the initial file;
- select the correct restart record after inspecting its time dimension;
- write outputs into a unique archive directory;
- preserve one active restart for the next month only after QC passes.

Do not hard-code `NRREC=2` without checking the restart file:

```bash
ncdump -h CROCO_FILES/croco_rst.nc | sed -n '1,120p'
```

## Minimum scheduled QC

Submit QC as a Slurm job after every month. Check:

- `MAIN: DONE` and absence of blow-up/NaN messages;
- expected start/end model times and number of records;
- finite `zeta`, `ubar`, `vbar`, `u`, `v`, `temp`, and `salt`;
- plausible min/max values and changes from the prior month;
- restart existence, time, and record count;
- grid/forcing filenames recorded in the log;
- surface and vertical-section plots.

## Two-node experiment

The candidate experiment is:

```text
NP_XI=4
NP_ETA=2
NNODES=8
Slurm: --nodes=2 --ntasks=8 --ntasks-per-node=4
```

This is not the validated January executable. Copy the stable case, edit `param.h`, recompile, and benchmark the same short interval. Compare wall time, numerical completion, and output statistics before adopting it.

## Recovery rule

Never overwrite a validated restart until the next month has completed and passed QC. Keep the previous restart, control files, and logs so the chain can resume without rerunning earlier months.
