// assemblies/column_carriage_assembly.scad - J1 column + moving arm-carriage preview.
// Composes the fixed BASE_COLUMN subassembly with the ARM_CARRIAGE subassembly at a preview position on the J1
// linear axis. Keep base_column_assembly.scad and arm_carriage_assembly.scad independently renderable.
//
// COLUMN_CARRIAGE 조립체 — 고정 BASE_COLUMN 서브 어셈블리와 이동 ARM_CARRIAGE 서브 어셈블리를 합성해
// J1 컬럼-캐리지 관계를 보여준다.

// Keep J1 lead-screw threads visible when this top-level assembly imports base_column_assembly() via use<>.
$show_threads = true;

hide_part_self_preview = true;
include <../parts/base_column_plate_base.scad>

use <base_column_assembly.scad>
use <arm_carriage_assembly.scad>

/* [Preview] */
column_carriage_z = bc_carriage_preview_z; // [0:1:150]

module column_carriage_assembly() {
    base_column_assembly();

    translate_z(column_carriage_z)
        arm_carriage_assembly();
}

column_carriage_assembly();
