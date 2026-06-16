# cobot-nano

Parallel-link (4-bar) palletizing robot arm. Off-the-shelf parts maximized;
fabricated parts are **2D-cut sheet** (plywood/acrylic) only — no 3D printing.

## Design
- **Parallelogram linkage** → drive motors mounted at the base, end-effector
  stays level through the whole reach (classic palletizer trait).
- **Sandwich plates** → links are 2+ stacked sheet plates for rigidity.
- **Thickness via stacking** → thick parts (motor bracket) = N identical sheets,
  never machined depth.

## Layout
```
config.scad        shared specification, process allowances, render settings
vitamins/          off-the-shelf parts (bought, not made)
  *s.scad            local type lists for vitamins not in NopSCADlib
  *.scad             local modules/accessors for vitamins not in NopSCADlib
plates/            2D-cut profiles — xxx_2d() is the DXF source; links.scad holds link types
fabrications/      3D fabricated plate parts and stacks from plates/
assemblies/        base / arm / gripper sub-assemblies
main.scad          full robot + animation hooks
export/            nest plates -> DXF for cutting
```

## Workflow
1. Tune shared values in `config.scad` and link-family values in `plates/links.scad`.
2. Preview robot: open `main.scad` in OpenSCAD (View > Animate to sweep pose).
3. Cut files: `bash export/make_dxf.sh` → `sheet_6mm.dxf`.

## Part rule
Every `plates/*.scad` defines only `name_2d()` profiles. `fabrications/*.scad`
extrudes those profiles into sheet parts, stacks, and sandwiches for assembly
preview.

## Off-the-shelf BOM (fill in)
| Part | Spec | Qty |
|------|------|-----|
| Stepper | NEMA17 | 3 |
| Lazy-susan bearing | OD 100mm | 1 |
| Ball bearing | 608 (8x22x7) | TBD |
| Bolts | M5, M3 | TBD |
| GT2 belt + pulleys | 20T, 5mm bore | TBD |

## NopSCADlib (required)
NopSCADlib must be installed in your OpenSCAD libraries folder:
```
git clone https://github.com/nophead/NopSCADlib.git \
  "$HOME/Documents/OpenSCAD/libraries/NopSCADlib"
```
Project vitamin files mirror NopSCADlib's `vitamins/` pattern only for parts not
provided by NopSCADlib. Existing NopSCADlib vitamins are used directly, without
local wrappers. The lazy-susan turntable is modeled locally because it is not
provided by NopSCADlib.
