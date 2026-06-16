// parts/arm_carriage_plate_base.scad - Defines shared arm carriage dimensions and the base plate blank.
// Interface centers are materialized as shared values so downstream plate and housing files use the same mechanical datum.
//
// 암 캐리지 판(arm carriage plate)의 공통 치수와 기본 판 형상(base plate blank)을 정의한다.
// 인터페이스 중심(interface center)은 값으로 공유해 플레이트(plate)와 하우징(housing)의 기준 좌표가 어긋나지 않게 한다.

include <../config.scad>

ac_leadnut_type = LSN8x2;
ac_linear_bearing_type = LM8UU;
ac_shoulder_motor_type = NEMA17_40;
ac_shoulder_joint_bearing_type = BB608;

ac_thickness = bb_width(ac_shoulder_joint_bearing_type) + seat_shoulder_thickness;

ac_leadnut_bore = leadnut_bore(ac_leadnut_type);
ac_leadnut_od = leadnut_od(ac_leadnut_type);
ac_leadnut_flange_radius = leadnut_flange_dia(ac_leadnut_type) / 2;
ac_leadnut_flange_offset = leadnut_flange_offset(ac_leadnut_type);
ac_leadnut_flange_thickness = leadnut_flange_t(ac_leadnut_type);
ac_leadnut_flange_offset_recess_radius = ac_leadnut_od / 2 + bearing_clearance / 2;
ac_leadnut_flange_offset_recess_depth = ac_leadnut_flange_offset;
ac_leadnut_screw_clearance_radius = leadnut_hole_dia(ac_leadnut_type) / 2;

ac_linear_bearing_bore = bearing_rod_dia(ac_linear_bearing_type);
ac_linear_bearing_radius = bearing_dia(ac_linear_bearing_type) / 2;

ac_motor_radius = NEMA_radius(ac_shoulder_motor_type);
ac_motor_shaft_clearance_radius = NEMA_shaft_dia(ac_shoulder_motor_type) / 2 + shaft_clearance / 2;
ac_motor_recess_floor_z = seat_shoulder_thickness * 2;
ac_motor_recess_depth = ac_thickness - ac_motor_recess_floor_z;
ac_motor_boss_recess_radius = NEMA_big_hole(ac_shoulder_motor_type);
ac_motor_boss_recess_floor_z = seat_shoulder_thickness;
ac_motor_boss_recess_depth = ac_thickness - ac_motor_boss_recess_floor_z;

ac_shoulder_bearing_radius = bb_diameter(ac_shoulder_joint_bearing_type) / 2;

ac_z_shaft_radius = max(ac_leadnut_flange_radius, ac_linear_bearing_radius);
ac_z_shaft_center_distance = ac_motor_radius + ac_z_shaft_radius + component_margin;
ac_shoulder_bearing_center_distance = ac_motor_radius + ac_shoulder_bearing_radius + component_margin;

ac_motor_center = [0, 0];
ac_shoulder_bearing_center = [ac_shoulder_bearing_center_distance, 0];
ac_leadnut_center = [-ac_z_shaft_center_distance, 0];
ac_left_linear_bearing_center = [
    ac_z_shaft_center_distance * cos(60),
    ac_z_shaft_center_distance * sin(60)
];
ac_right_linear_bearing_center = [
    ac_z_shaft_center_distance * cos(-60),
    ac_z_shaft_center_distance * sin(-60)
];

ac_outer_radius = ac_z_shaft_center_distance + ac_z_shaft_radius;

module arm_carriage_plate_base() {
    linear_extrude(height = ac_thickness)
    difference() {
        // 캐리지 외곽 디스크(carriage outer disc) — 모터와 3점 Z축 풋프린트(footprint)가 한 판 안에 남는 원형 경계.
        circle(d = ac_outer_radius * 2 + component_margin);

        // J1 Z축 클리어런스 보어(clearance bore) — 리드스크류(lead screw)와 가이드 로드(guide rod)의 자유 이동 공간.
        translate(ac_leadnut_center)
            circle(d = ac_leadnut_bore + shaft_clearance);
        translate(ac_left_linear_bearing_center)
            circle(d = ac_linear_bearing_bore + shaft_clearance);
        translate(ac_right_linear_bearing_center)
            circle(d = ac_linear_bearing_bore + shaft_clearance);

        // J2 샤프트 클리어런스 보어(shaft clearance bore) — 모터 리세스 후 남는 판 두께를 축이 통과하는 경로.
        translate(ac_motor_center)
            circle(r = ac_motor_shaft_clearance_radius);
    }
}
