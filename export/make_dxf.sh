#!/usr/bin/env bash
# Batch export 2D-cut sheets to DXF.
# Usage:  bash export/make_dxf.sh
# Requires openscad on PATH.
set -e
cd "$(dirname "$0")"

openscad -o sheet_6mm.dxf sheet_6mm.scad
echo "wrote sheet_6mm.dxf"

# Add more sheets here as thicknesses/materials grow:
# openscad -o sheet_3mm.dxf sheet_3mm.scad
