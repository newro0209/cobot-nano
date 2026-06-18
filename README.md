# cobot-nano

SCARA robot arm, 3D-printed (FDM). Off-the-shelf parts (NopSCADlib vitamins)
maximized.

## Design
- **SCARA** kinematic chain: vertical Z translation (J1) + horizontal shoulder
  and elbow rotation (J2/J3) + tool roll (J4). See [docs/kinematic_chain.md](docs/kinematic_chain.md).
- **3D-printed (FDM)**, off-the-shelf parts maximized. Recesses, counterbores
  and press-fit seats are used freely; high-load seats are machined after
  printing (`[CNC-LATER]`).

## Layout
```
config.scad        shared spec, allowances, render settings; NopSCADlib + local vitamin includes
vitamins/          local vitamins not in NopSCADlib (mirror NopSCADlib's family-per-file layout)
  screws.scad        local M6_shoulder_screw added to NopSCADlib's screw family
  pulleys.scad       local GT2x60x8_pulley added to NopSCADlib's pulley family
parts/             fabricated parts (NopSCADlib printed/ analog) — 2D profile + extrude/pockets per module
assemblies/        integrated robot assembly preview — parts + vitamins, exploded view
docs/              kinematic chain, BOM
main.scad          full robot + animation hooks (incomplete scaffolding)
export/            cut-file generation (not yet wired)
```

## Conventions
Structure and style follow **NopSCADlib's actual layout first, then
`OPENSCAD_CONVENTIONS.md`**. There is no `plates/` / `fabrications/` split;
fabricated parts live in `parts/` like NopSCADlib's `printed/`. See `CLAUDE.md`.

## Workflow
1. Tune shared values in `config.scad` and subsystem values in
   `parts/arm_carriage_plate_base.scad`.
2. Preview: open `assemblies/robot_assembly.scad` in OpenSCAD
   (use the `bc_exploded`, `ac_exploded`, and `ua_exploded` sliders to explode stacks).
3. Headless check: `openscad -o out.echo assemblies/robot_assembly.scad`
   (only NopSCADlib's internal `2p54` deprecation should appear).

## BOM
See [docs/BOM.md](docs/BOM.md) for the arm carriage bill of materials with
CAD-derived dimensions (plate thickness, screw lengths, spacer heights).

## NopSCADlib (required)
NopSCADlib must be installed in your OpenSCAD libraries folder:
```
git clone https://github.com/nophead/NopSCADlib.git \
  "$HOME/Documents/OpenSCAD/libraries/NopSCADlib"
```
This machine's actual path: `C:\Program Files\OpenSCAD\libraries\NopSCADlib`.

Project vitamin files mirror NopSCADlib's family-per-file pattern only for parts
not provided by NopSCADlib (e.g. `M6_shoulder_screw`, `GT2x60x8_pulley`).
Existing NopSCADlib vitamins are used directly, without local wrappers.
