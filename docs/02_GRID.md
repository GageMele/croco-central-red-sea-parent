# Step 2 - Create and validate the Central Red Sea grid

## 2.1 Choose the domain and source data

The active parent was designed as an approximately 1 km Central Red Sea grid covering the target latitude band around 21.5-23 N. GEBCO 2026 source coverage was deliberately larger:

```text
north=25.0, south=20.5, west=34.5, east=39.75
```

That box is source-data coverage, not a substitute for the exact model-grid corners. Record the final `lon_rho` and `lat_rho` ranges directly from `croco_grd.nc`.

## 2.2 Use CROCO_PYTOOLS

Copy the installed example configuration, then edit the domain, point count/resolution, GEBCO path, minimum/maximum depth, mask, and `rfact` target. The installed version is authoritative:

```bash
source case.env.local
cd "$PREPRO"

# Inspect the local interface before editing a config.
python make_grid.py --help 2>&1 | less
find . -maxdepth 2 -type f \( -name '*.ini' -o -name '*.jsonc' \) | sort

# EDIT HERE: replace with the config name used by the installed version.
python make_grid.py "$CRS_GRID_CONFIG"
```

Do not use the previous hand-built xarray grid writer. It did not reproduce CROCO's required character-variable schema reliably.

## 2.3 Required checks

```bash
source "$CROCO_ROOT/SCRIPTS/load_croco_netcdf_intel.sh"
ncdump -k "$CRS_GRID"
ncdump -h "$CRS_GRID" | sed -n '1,160p'
ncdump -v spherical "$CRS_GRID"
```

Then run:

```bash
python scripts/validate_grid.py "$CRS_GRID"
```

Expected horizontal dimensions:

```text
xi_rho=424 (recorded active header)
eta_rho=691 (recorded active header)
LLm0=423
MMm0=690
```

The validator also checks finite positive wet-cell depths, mask values, forcing-edge wet-cell counts, and the exact `spherical` shape.

## 2.4 Visual approval

Before forcing generation, submit a plotting job that shows:

- bathymetry and land mask;
- all four grid edges and their wet cells;
- target reef/child footprint;
- minimum/maximum depth;
- bathymetric stiffness (`rx0`) and locations exceeding the chosen threshold.

Archive the approved plot and grid checksum:

```bash
sha256sum "$CRS_GRID" | tee "SUMMARY/croco_grd.sha256"
```

## 2.5 Match `param.h` to the validated case

```text
grid header: xi_rho=424, eta_rho=691
successful param.h: LLm0=423, MMm0=690
```

This pairing differs from the simple `rho minus two` rule used by some CROCO grids and by the earlier Al Fahal case. Confirm it from the live header and saved successful `param.h`, then recompile. Never infer dimensions from the GEBCO source raster.
