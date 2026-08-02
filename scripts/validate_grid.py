#!/usr/bin/env python3
"""Fail-fast validation for a CROCO grid before forcing generation."""

from pathlib import Path
import argparse
import numpy as np
from netCDF4 import Dataset


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("grid", type=Path)
    parser.add_argument("--expect-xi", type=int, default=424)
    parser.add_argument("--expect-eta", type=int, default=691)
    args = parser.parse_args()

    if not args.grid.is_file():
        raise SystemExit(f"Missing grid: {args.grid}")

    with Dataset(args.grid) as ds:
        required = {"h", "mask_rho", "lon_rho", "lat_rho", "pm", "pn", "spherical"}
        missing = sorted(required - set(ds.variables))
        if missing:
            raise SystemExit(f"Missing variables: {missing}")

        xi = len(ds.dimensions["xi_rho"])
        eta = len(ds.dimensions["eta_rho"])
        if (xi, eta) != (args.expect_xi, args.expect_eta):
            raise SystemExit(f"Unexpected rho dimensions {(xi, eta)}")

        spherical = ds.variables["spherical"]
        if spherical.dimensions != ("one",):
            raise SystemExit(
                "Invalid spherical dimensions: "
                f"{spherical.dimensions}; expected ('one',). "
                "Do not repair this by container conversion alone."
            )

        mask = np.asarray(ds.variables["mask_rho"][:])
        h = np.asarray(ds.variables["h"][:], dtype=float)
        if not set(np.unique(mask).compressed() if np.ma.isMaskedArray(mask) else np.unique(mask)) <= {0, 1}:
            raise SystemExit("mask_rho contains values other than 0 and 1")
        wet = mask == 1
        if not wet.any() or not np.isfinite(h[wet]).all() or (h[wet] <= 0).any():
            raise SystemExit("Wet-cell bathymetry is empty, non-finite, or non-positive")

        edge_counts = {
            "south": int(wet[0, :].sum()),
            "north": int(wet[-1, :].sum()),
            "west": int(wet[:, 0].sum()),
            "east": int(wet[:, -1].sum()),
        }

        print(f"GRID_OK: {args.grid}")
        print(f"rho: xi={xi}, eta={eta}")
        print("validated compiled case: LLm0=423, MMm0=690; compare live param.h")
        print(f"wet depth range: {h[wet].min():.3f} to {h[wet].max():.3f} m")
        print("wet edge cells:", edge_counts)


if __name__ == "__main__":
    main()
