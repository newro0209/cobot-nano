// parts/base_column_plate_base.scad - Shared blank and spacing for the fixed J1 base-column plates.
// Reuses the column-carriage plate outline so the central lead-screw stack and the three guide-rod anchors share
// the same packing geometry. The upper rod plate mates to the motor plate through a common standoff bolt circle.
//
// BASE_COLUMN 판 공통 블랭크 — column_carriage_plate_base.scad의 중앙 리드스크류 스택 + 3점 가이드 로드 배치를
// 그대로 쓴다. 상부 로드/베어링 판과 모터 판은 같은 스탠드오프 볼트 서클로 맞물린다.

include <column_carriage_plate_base.scad>
use <../utils/placement.scad>

// 두 base-column 판은 FC8/KFL08 플랜지 체결과 NEMA 보스 리세스를 동시에 버틸 수 있는 공통 두께를 쓴다.
bc_plate_thickness = max(
    6,
    max(
        fc_flange_thickness(j1_flange_coupling_type),
        kfl_thickness(j1_flange_bearing_block_type),
        NEMA_boss_height(j1_motor_type)
    ) + seat_shoulder_thickness
);

// 모터 판과 상부 로드 판 사이 간격 — SC_5x8_rigid 길이에 조립 여유를 주기 위해 base-column 전용 30mm FF 필러를 쓴다.
bc_standoff_pillar_type = M3x30_ff_hex_pillar;
bc_plate_gap = pillar_height(bc_standoff_pillar_type);
bc_column_span = smooth_rod_length(j1_guide_rod_type)
               - bc_plate_thickness
               - bc_plate_gap
               - fc_height(j1_flange_coupling_type);
bc_carriage_preview_z = 60;
bc_upper_rod_plate_z = bc_column_span;
bc_motor_plate_z = bc_upper_rod_plate_z + bc_plate_thickness + bc_plate_gap;

// 스탠드오프 볼트 서클 — 3개 가이드 로드 사이 공간에 6점을 두어 FC8 플랜지와 중앙 KFL08을 피한다.
bc_standoff_count = 6;
bc_standoff_bolt_circle_radius = cc_j1_guide_rod_distance_from_center - component_margin;
bc_standoff_start_angle = 0;
bc_standoff_screw_length = screw_longer_than(bc_plate_thickness + 6);

assert(sc_length(j1_shaft_coupling_type) <= bc_plate_gap + eps,
       "J1 샤프트 커플링 길이는 base-column plate gap 이하여야 한다");
assert(bc_column_span > 0, "J1 가이드 로드 길이는 base-column 상/하부 지지 구조보다 길어야 한다");

module bc_standoff_positions() {
    for (i = [0 : bc_standoff_count - 1])
        at_radial(i, bc_standoff_count, bc_standoff_bolt_circle_radius, bc_standoff_start_angle)
            children();
}

module bc_plate_base() {
    difference() {
        cc_plate_with_profile_2d(bc_plate_thickness);

        // 로드 판과 모터 판이 같은 볼트 서클로 필러에 체결된다.
        bc_standoff_positions()
            translate_z(-eps)
                cylinder(r = screw_clearance_radius(standoff_screw_type), h = bc_plate_thickness + eps * 2);
    }
}

if ($preview && is_undef(hide_part_self_preview))
    bc_plate_base();
