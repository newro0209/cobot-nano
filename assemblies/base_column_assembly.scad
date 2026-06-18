// assemblies/base_column_assembly.scad - Fixed BASE_COLUMN linear-axis preview.
// From top to bottom: motor plate, shaft coupling, upper rod/lead-screw support plate, and lower rod/lead-screw
// support plate. The moving arm carriage is composed with this in column_carriage_assembly.scad.
//
// BASE_COLUMN 조립체 — 위에서부터 모터 판 → 샤프트 커플링 → 상부 로드/리드스크류 지지 판 →
// 하부 로드/리드스크류 지지 판 순서로 고정 컬럼을 보여준다. 움직이는 ARM_CARRIAGE는 별도 상위 조립체에서 합성한다.

// NopSCADlib rod.scad resolves show_threads through global_defs at include time, so this must be set before includes.
$show_threads = true;

hide_part_self_preview = true;
include <../parts/base_column_plate_base.scad>

use <../parts/base_column_motor_plate.scad>
use <../parts/base_column_rod_plate.scad>
use <../parts/motor_seat.scad>
use <../vitamins/flange_bearing_blocks.scad>
use <../vitamins/flange_couplings.scad>

use <NopSCADlib/vitamins/pillar.scad>
use <NopSCADlib/vitamins/screw.scad>
use <NopSCADlib/vitamins/nut.scad>
use <NopSCADlib/vitamins/shaft_coupling.scad>
use <NopSCADlib/vitamins/stepper_motor.scad>

/* [Preview] */
bc_exploded = 0; // [0:0.5:30]
show_hardware = true;
show_preview_rods = true;

bc_col_upper_rod_plate = [0.20, 0.36, 0.44];
bc_col_lower_rod_plate = [0.14, 0.28, 0.34];
bc_col_motor_plate = [0.18, 0.42, 0.62];

function bc_ez(level) = level * bc_exploded;
module bc_place(base_z, level) {
    translate_z(base_z + bc_ez(level))
        children();
}

bc_ex_lower_kfl         = -3;
bc_ex_lower_rod_plate   = -2;
bc_ex_rods              =  0;
bc_ex_upper_kfl         =  1;
bc_ex_upper_rod_plate   =  2;
bc_ex_gap               =  3;
bc_ex_motor_plate       =  4;
bc_ex_motor             =  5;

bc_fc_seat_depth = min(fc_flange_thickness(j1_flange_coupling_type),
                       bc_plate_thickness - seat_shoulder_thickness);
bc_kfl_seat_depth = min(kfl_thickness(j1_flange_bearing_block_type),
                        bc_plate_thickness - seat_shoulder_thickness);
bc_fc_top_seat_z = bc_plate_thickness - bc_fc_seat_depth;
bc_fc_bottom_seat_z = bc_fc_seat_depth;
bc_kfl_top_seat_z = bc_plate_thickness - bc_kfl_seat_depth;
bc_kfl_bottom_seat_z = bc_kfl_seat_depth;

bc_motor_face_inset = nema_motor_seat_face_inset(j1_motor_type, bc_plate_thickness);
bc_motor_face_local_z = bc_plate_thickness - bc_motor_face_inset;
bc_motor_face_z = bc_motor_plate_z + bc_motor_face_local_z;
bc_motor_shaft_tip_z = bc_motor_face_z - NEMA_shaft_length(j1_motor_type);
bc_fc_screw_type = fc_screw(j1_flange_coupling_type);
bc_fc_screw_length = screw_length(bc_fc_screw_type, bc_plate_thickness, 2, nut = true);
bc_kfl_screw_type = kfl_screw(j1_flange_bearing_block_type);
bc_kfl_screw_length = screw_length(bc_kfl_screw_type, bc_plate_thickness, 2, nut = true);
bc_motor_screw_type = M3_cap_screw;
bc_motor_screw_length = screw_longer_than(bc_motor_face_local_z + 4);
bc_shaft_coupling_center_local_z = bc_plate_thickness + bc_plate_gap / 2;
bc_shaft_coupling_center_z = bc_upper_rod_plate_z + bc_shaft_coupling_center_local_z;
bc_shaft_coupling_bottom_z = bc_shaft_coupling_center_z - sc_length(j1_shaft_coupling_type) / 2;
bc_shaft_coupling_top_z = bc_shaft_coupling_center_z + sc_length(j1_shaft_coupling_type) / 2;

bc_preview_guide_rod_bottom_z = bc_fc_top_seat_z;
bc_preview_guide_rod_length = smooth_rod_length(j1_guide_rod_type);
bc_preview_guide_rod_top_z = bc_preview_guide_rod_bottom_z + bc_preview_guide_rod_length;
bc_preview_lead_screw_bottom_z = bc_kfl_top_seat_z;
bc_preview_lead_screw_length = lead_screw_length(j1_lead_screw_type);
bc_preview_lead_screw_top_z = bc_preview_lead_screw_bottom_z + bc_preview_lead_screw_length;

echo(str("Base column plate thickness / motor standoff gap / column span = ",
         bc_plate_thickness, " / ", bc_plate_gap, " / ", bc_column_span, " mm"));
echo(str("Base column J1 coupling length = ", sc_length(j1_shaft_coupling_type), " mm"));
echo(str("Base column J1 coupling Z range = ",
         bc_shaft_coupling_bottom_z, " .. ", bc_shaft_coupling_top_z, " mm"));
echo(str("Base column guide rod / lead screw length = ",
         bc_preview_guide_rod_length, " / ", bc_preview_lead_screw_length, " mm"));

assert(NEMA_thread_d(j1_motor_type) == screw_radius(bc_motor_screw_type) * 2,
       "J1 NEMA 모터 고정 스크류 지름은 모터 탭 지름과 같아야 한다");
assert(abs(bc_preview_guide_rod_top_z - (bc_motor_plate_z + bc_fc_top_seat_z + fc_height(j1_flange_coupling_type))) <= eps,
       "J1 가이드 로드 길이는 하부 FC8부터 모터 판 위 FC8 허브 끝까지 닿아야 한다");
assert(abs(bc_preview_lead_screw_top_z - bc_shaft_coupling_center_z) <= eps,
       "J1 리드스크류 길이는 하부 KFL08부터 샤프트 커플러 중심까지 닿아야 한다");
module bc_standoffs() {
    bc_standoff_positions()
        translate_z(bc_plate_thickness)
            pillar(bc_standoff_pillar_type);
}

module bc_standoff_top_fasteners() {
    bc_standoff_positions()
        translate_z(bc_plate_thickness)
            screw_and_washer(standoff_screw_type, bc_standoff_screw_length);
}

module bc_standoff_bottom_fasteners() {
    bc_standoff_positions()
        rotate([180, 0, 0])
            screw_and_washer(standoff_screw_type, bc_standoff_screw_length);
}

module bc_j1_flange_bearing_block_upper() {
    // 상부 KFL08은 상부 로드 판 아랫면에 매달아, 위쪽 25mm 갭을 샤프트 커플링 공간으로 남긴다.
    translate_z(bc_kfl_bottom_seat_z)
        rotate([180, 0, 0])
            kfl_flange_bearing_block(j1_flange_bearing_block_type);
}

module bc_j1_flange_bearing_block_lower() {
    // 하부 KFL08은 하부 로드 판 윗면에서 리드스크류 하단을 받는다.
    translate_z(bc_kfl_top_seat_z)
        kfl_flange_bearing_block(j1_flange_bearing_block_type);
}

module bc_j1_guide_rod_couplings_upper() {
    // 상부 FC8 허브는 아래쪽으로 향해, 상부 지지 판에서 내려오는 가이드 로드를 붙잡는다.
    cc_at_guide_rods()
        translate_z(bc_fc_bottom_seat_z)
            rotate([180, 0, 0])
                FC(j1_flange_coupling_type);
}

module bc_j1_guide_rod_couplings_lower() {
    // 하부 FC8 허브는 위쪽으로 향해, 하부 지지 판에서 올라가는 가이드 로드를 붙잡는다.
    cc_at_guide_rods()
        translate_z(bc_fc_top_seat_z)
            FC(j1_flange_coupling_type);
}

module bc_j1_guide_rod_couplings_motor() {
    // 모터 판 위 FC8이 가이드 로드 상단을 한 번 더 잡아, 로드가 모터 판 위까지 이어진다.
    cc_at_guide_rods()
        translate_z(bc_fc_top_seat_z)
            FC(j1_flange_coupling_type);
}

module bc_fc_fasteners_top_side() {
    cc_at_guide_rods()
        fc_screw_positions(j1_flange_coupling_type)
            translate_z(bc_plate_thickness)
                screw_and_washer(bc_fc_screw_type, bc_fc_screw_length);
}

module bc_fc_nuts_bottom_side() {
    cc_at_guide_rods()
        fc_screw_positions(j1_flange_coupling_type)
            rotate([180, 0, 0])
                nut_and_washer(screw_nut(bc_fc_screw_type), false);
}

module bc_fc_fasteners_bottom_side() {
    cc_at_guide_rods()
        fc_screw_positions(j1_flange_coupling_type)
            rotate([180, 0, 0])
                screw_and_washer(bc_fc_screw_type, bc_fc_screw_length);
}

module bc_fc_nuts_top_side() {
    cc_at_guide_rods()
        fc_screw_positions(j1_flange_coupling_type)
            translate_z(bc_plate_thickness)
                nut_and_washer(screw_nut(bc_fc_screw_type), false);
}

module bc_kfl_fasteners_top_side() {
    kfl_screw_positions(j1_flange_bearing_block_type)
        translate_z(bc_plate_thickness)
            screw_and_washer(bc_kfl_screw_type, bc_kfl_screw_length);
}

module bc_kfl_nuts_bottom_side() {
    kfl_screw_positions(j1_flange_bearing_block_type)
        rotate([180, 0, 0])
            nut_and_washer(screw_nut(bc_kfl_screw_type), false);
}

module bc_kfl_fasteners_bottom_side() {
    kfl_screw_positions(j1_flange_bearing_block_type)
        rotate([180, 0, 0])
            screw_and_washer(bc_kfl_screw_type, bc_kfl_screw_length);
}

module bc_kfl_nuts_top_side() {
    kfl_screw_positions(j1_flange_bearing_block_type)
        translate_z(bc_plate_thickness)
            nut_and_washer(screw_nut(bc_kfl_screw_type), false);
}

module bc_j1_motor_fasteners() {
    translate(j1_axis_center)
        NEMA_screw_positions(j1_motor_type)
            rotate([180, 0, 0])
                screw_and_washer(bc_motor_screw_type, bc_motor_screw_length);
}

module bc_j1_motor() {
    translate([0, 0, bc_motor_face_z])
        rotate([180, 0, 0])
            NEMA(j1_motor_type);
}

module bc_j1_shaft_coupling() {
    // SC_5x8_rigid의 작은 보어(5mm)가 위쪽 모터축, 큰 보어(8mm)가 아래쪽 리드스크류를 향하도록 뒤집는다.
    translate_z(bc_shaft_coupling_center_local_z)
        rotate([180, 0, 0])
            shaft_coupling(j1_shaft_coupling_type);
}

module bc_preview_rods() {
    cc_at_guide_rods()
        translate_z(bc_preview_guide_rod_bottom_z)
            rod(smooth_rod_diameter(j1_guide_rod_type),
                bc_preview_guide_rod_length,
                center = false);

    translate_z(bc_preview_lead_screw_bottom_z)
        leadscrew(lead_screw_diameter(j1_lead_screw_type),
                  bc_preview_lead_screw_length,
                  lead_screw_lead(j1_lead_screw_type),
                  lead_screw_starts(j1_lead_screw_type),
                  center = false);
}

module base_column_assembly() {
    // ── 하부 지지 판: 리드스크류 하단과 가이드 로드 하단을 잡는다. ──
    bc_place(0, bc_ex_lower_rod_plate)
        color(bc_col_lower_rod_plate)
            base_column_rod_plate();

    if (show_hardware) {
        bc_place(0, bc_ex_lower_kfl) bc_j1_flange_bearing_block_lower();
        bc_place(0, bc_ex_lower_rod_plate) {
            bc_j1_guide_rod_couplings_lower();
            bc_fc_fasteners_top_side();
            bc_fc_nuts_bottom_side();
            bc_kfl_fasteners_top_side();
            bc_kfl_nuts_bottom_side();
        }
    }

    if (show_hardware && show_preview_rods)
        bc_place(0, bc_ex_rods) bc_preview_rods();

    // ── 상부 지지 판: 리드스크류 상단과 가이드 로드 상단을 잡고, 위 모터 판과 스탠드오프로 맞물린다. ──
    bc_place(bc_upper_rod_plate_z, bc_ex_upper_rod_plate)
        color(bc_col_upper_rod_plate)
            base_column_rod_plate(seat_from_top = false);

    if (show_hardware) {
        bc_place(bc_upper_rod_plate_z, bc_ex_upper_kfl) bc_j1_flange_bearing_block_upper();
        bc_place(bc_upper_rod_plate_z, bc_ex_upper_rod_plate) {
            bc_j1_guide_rod_couplings_upper();
            bc_fc_fasteners_bottom_side();
            bc_fc_nuts_top_side();
            bc_kfl_fasteners_bottom_side();
            bc_kfl_nuts_top_side();
        }
        bc_place(bc_upper_rod_plate_z, bc_ex_gap) {
            bc_standoffs();
            bc_j1_shaft_coupling();
        }
        bc_place(bc_upper_rod_plate_z, bc_ex_upper_rod_plate) bc_standoff_bottom_fasteners();
    }

    // ── 모터 판: base column 위에 놓이고, 모터는 윗면에 체결되어 축이 아래 커플링으로 내려간다. ──
    bc_place(bc_motor_plate_z, bc_ex_motor_plate)
        color(bc_col_motor_plate)
            base_column_motor_plate();

    if (show_hardware) {
        bc_place(bc_motor_plate_z, bc_ex_motor_plate) bc_standoff_top_fasteners();
        bc_place(bc_motor_plate_z, bc_ex_motor_plate) {
            bc_j1_guide_rod_couplings_motor();
            bc_fc_fasteners_top_side();
            bc_fc_nuts_bottom_side();
            bc_j1_motor_fasteners();
        }
        bc_place(0, bc_ex_motor) bc_j1_motor();
    }
}

base_column_assembly();
