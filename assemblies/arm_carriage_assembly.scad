// assemblies/arm_carriage_assembly.scad - Arm carriage stack preview.
// Places the top/bottom printed plates and the vitamins seated in their pockets:
// BB608 bearings on the J2 driven axis, one LM8UU linear bearing on each J1 guide rod,
// the J1 lead-nut in the top-plate underside seat, and the J2 motor / belt pulleys.
//
// 암 캐리지 조립체 — 상/하판과 각 포켓에 안착되는 부품을 함께 배치한다.
// J2 종동축 BB608, 각 J1 가이드 로드의 LM8UU 1개, 상판 아랫면 리드너트, J2 모터와 벨트 풀리를 포켓 방향에 맞춰 보여준다.

include <../parts/arm_carriage_plate_base.scad>

use <../parts/arm_carriage_bottom_plate.scad>
use <../parts/arm_carriage_top_plate.scad>
use <../parts/motor_seat.scad>

use <NopSCADlib/vitamins/ball_bearing.scad>
use <NopSCADlib/vitamins/belt.scad>
use <NopSCADlib/vitamins/leadnut.scad>
use <NopSCADlib/vitamins/linear_bearing.scad>
use <NopSCADlib/vitamins/pillar.scad>
use <NopSCADlib/vitamins/pulley.scad>
use <NopSCADlib/vitamins/stepper_motor.scad>

/* [Preview] */
ac_exploded = 0; // 0 = seated stack, increase to separate top/bottom groups.
show_hardware = true; // false = printed plates only.
show_belt = true;     // exploded view에서는 풀리와 어긋나지 않도록 자동으로 숨긴다.

// 조립체 색상 — 라벨 오버레이가 추가되면 같은 변수를 공유한다(A-3).
ac_col_top_plate      = [0.18, 0.42, 0.62];
ac_col_bottom_plate   = [0.16, 0.30, 0.40];
ac_col_drive_pulley   = [0.85, 0.58, 0.18];
ac_col_driven_pulley  = [0.78, 0.38, 0.18];
ac_col_belt           = [0.02, 0.02, 0.025];
ac_col_belt_tooth     = [0.18, 0.18, 0.18];

// 상/하판 간격과 LM8UU 시트 깊이는 arm_carriage_plate_base.scad의 공통 치수를 따른다.
ac_top_plate_z = ac_thickness + ac_plate_gap;
ac_pulley_bottom_clearance_z = ac_thickness + clearance / 2;
ac_pulley_top_clearance_z = ac_top_plate_z - clearance / 2;
ac_motor_face_inset = nema_motor_seat_face_inset(j2_motor_type, ac_thickness);
ac_motor_face_local_z = ac_thickness - ac_motor_face_inset;
ac_motor_face_z = ac_top_plate_z + ac_motor_face_local_z;
ac_motor_shaft_tip_z = ac_motor_face_z - NEMA_shaft_length(j2_motor_type);
ac_drive_pulley_bottom_rel_z = pulley_offset(j2_drive_pulley_type);
ac_drive_pulley_top_rel_z = pulley_offset(j2_drive_pulley_type) + pulley_height(j2_drive_pulley_type);
ac_pulley_center_min_for_plates = max(
    ac_pulley_bottom_clearance_z - pulley_offset(j2_drive_pulley_type),
    ac_pulley_bottom_clearance_z - pulley_offset(j2_driven_pulley_type)
);
ac_pulley_center_max_for_plates = min(
    ac_pulley_top_clearance_z - (pulley_offset(j2_drive_pulley_type) + pulley_height(j2_drive_pulley_type)),
    ac_pulley_top_clearance_z - (pulley_offset(j2_driven_pulley_type) + pulley_height(j2_driven_pulley_type))
);
ac_drive_pulley_center_min_for_shaft = ac_motor_shaft_tip_z - ac_drive_pulley_bottom_rel_z + clearance / 2;
ac_drive_pulley_center_max_for_shaft = ac_motor_face_z - ac_drive_pulley_top_rel_z - clearance / 2;
ac_belt_center_z = max(ac_pulley_center_min_for_plates, ac_drive_pulley_center_min_for_shaft) + eps;
ac_drive_pulley_local_z = ac_belt_center_z - ac_top_plate_z;
ac_drive_pulley_screw_z = ac_belt_center_z + pulley_offset(j2_drive_pulley_type) + pulley_screw_z(j2_drive_pulley_type);

function ac_timing_belt_path(motor_center) = [
    [motor_center.x, motor_center.y, j2_drive_pulley_type],
    [j2_driven_axis_center.x, j2_driven_axis_center.y, j2_driven_pulley_type]
];

ac_timing_belt_type         = pulley_belt(j2_drive_pulley_type);
ac_timing_belt_path_min     = ac_timing_belt_path(ac_j2_motor_near_center);
ac_timing_belt_path_current = ac_timing_belt_path(ac_j2_motor_center);
ac_timing_belt_path_max     = ac_timing_belt_path(ac_j2_motor_far_center);

ac_timing_belt_length_min     = belt_length(ac_timing_belt_type, ac_timing_belt_path_min);
ac_timing_belt_length_current = belt_length(ac_timing_belt_type, ac_timing_belt_path_current);
ac_timing_belt_length_max     = belt_length(ac_timing_belt_type, ac_timing_belt_path_max);
ac_timing_belt_pitch          = belt_pitch(ac_timing_belt_type);
ac_timing_belt_standard_min   = ceil(ac_timing_belt_length_min / ac_timing_belt_pitch) * ac_timing_belt_pitch;
ac_timing_belt_standard_max   = floor(ac_timing_belt_length_max / ac_timing_belt_pitch) * ac_timing_belt_pitch;
ac_timing_belt_standard_mid   = round(ac_timing_belt_length_current / ac_timing_belt_pitch) * ac_timing_belt_pitch;

echo(str("J2 timing belt length min/current/max = ",
         ac_timing_belt_length_min, " / ",
         ac_timing_belt_length_current, " / ",
         ac_timing_belt_length_max, " mm"));
echo(str("J2 GT2 closed-loop belt usable standard range = ",
         ac_timing_belt_standard_min, " .. ",
         ac_timing_belt_standard_max, " mm, nominal ",
         ac_timing_belt_standard_mid, " mm"));

assert(ac_timing_belt_type == pulley_belt(j2_driven_pulley_type),
       "J2 구동 풀리와 종동 풀리는 같은 벨트 타입이어야 한다");
assert(!is_list(NEMA_shaft_length(j2_motor_type)), "J2 모터 샤프트 길이는 숫자여야 한다");
assert(ac_belt_center_z < min(ac_pulley_center_max_for_plates, ac_drive_pulley_center_max_for_shaft),
       "모터 샤프트와 상/하판 사이에 공통 풀리 높이를 잡을 공간이 있어야 한다");
assert(ac_drive_pulley_screw_z > ac_motor_shaft_tip_z,
       "J2 구동 풀리 세트스크류 위치는 모터 샤프트 끝보다 위에 있어야 한다");
assert(ac_belt_center_z + min(
           pulley_offset(j2_drive_pulley_type),
           pulley_offset(j2_driven_pulley_type)
       ) > ac_pulley_bottom_clearance_z,
       "풀리는 하판 윗면과 간섭하지 않아야 한다");
assert(ac_belt_center_z + max(
           pulley_height(j2_drive_pulley_type) + pulley_offset(j2_drive_pulley_type),
           pulley_height(j2_driven_pulley_type) + pulley_offset(j2_driven_pulley_type)
       ) < ac_pulley_top_clearance_z,
       "풀리는 상판 아랫면과 간섭하지 않아야 한다");

module ac_bottom_seated_vitamins() {
    // 하판 J2 BB608 — 하판 아랫면 포켓(from_top=false)에 안착, 베어링 외측면은 하판 바닥면과 flush.
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1], bb_width(j2_driven_ball_bearing_type) / 2])
        ball_bearing(j2_driven_ball_bearing_type);
}

module ac_top_seated_vitamins() {
    // 상판 J2 BB608 — 상판 윗면 포켓(from_top=true)에 안착, 베어링 외측면은 상판 윗면과 flush.
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1], ac_thickness - bb_width(j2_driven_ball_bearing_type) / 2])
        ball_bearing(j2_driven_ball_bearing_type);

    // 상판 J1 리드너트 — 아랫면 포켓(from_top=false)에 플랜지를 맞춰 안착.
    translate(j1_axis_center)
        leadnut(j1_leadnut_type);

    // J2 스텝모터 — 상판 윗면 시트(from_top=true)에 모터 전면을 맞추고, 축은 판 아래쪽 풀리로 내려간다.
    translate([ac_j2_motor_center[0], ac_j2_motor_center[1], ac_motor_face_local_z])
        rotate([180, 0, 0])
            NEMA(j2_motor_type);

    // J2 구동 풀리 — 모터 샤프트에 물린 부품이므로 모터와 같은 top 그룹 좌표를 따른다.
    translate([ac_j2_motor_center[0], ac_j2_motor_center[1], ac_drive_pulley_local_z])
        pulley_assembly(j2_drive_pulley_type, ac_col_drive_pulley);
}

module ac_shared_linear_bearings() {
    // LM8UU — 필러 간격 중앙에 두며, 시트 깊이가 있으면 상/하판 시트가 양끝을 물고 없으면 축방향 여유를 둔다.
    for (center = cc_j1_guide_rod_centers)
        translate([center[0], center[1], ac_thickness + ac_plate_gap / 2])
            linear_bearing(j1_linear_bearing_type);
}

module ac_standoffs() {
    ac_standoff_positions()
        translate_z(ac_thickness)
            pillar(standoff_pillar_type);
}

module ac_shared_pulleys() {
    // J2 종동 풀리 — BB608로 지지되는 어깨축의 회전 출력 풀리.
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1], ac_belt_center_z])
        pulley_assembly(j2_driven_pulley_type, ac_col_driven_pulley);
}

module ac_timing_belt() {
    translate_z(ac_belt_center_z)
        belt(ac_timing_belt_type,
             ac_timing_belt_path_current,
             belt_colour = ac_col_belt,
             tooth_colour = ac_col_belt_tooth);
}

module arm_carriage_assembly() {
    translate_z(-ac_exploded) {
        color(ac_col_bottom_plate)
            arm_carriage_bottom_plate();
        if (show_hardware)
            ac_bottom_seated_vitamins();
    }

    if (show_hardware) {
        ac_shared_linear_bearings();
        ac_standoffs();
        ac_shared_pulleys();
        if (show_belt && ac_exploded == 0)
            ac_timing_belt();
    }

    translate_z(ac_top_plate_z + ac_exploded) {
        color(ac_col_top_plate)
            arm_carriage_top_plate();
        if (show_hardware)
            ac_top_seated_vitamins();
    }
}

arm_carriage_assembly();
