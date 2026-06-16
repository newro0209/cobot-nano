// parts/arm_carriage_housing.scad - Provides the arm carriage housing geometry.
// Assembly render files place motors, leadnuts, bearings, and fasteners around this module.
//
// 암 캐리지 하우징(arm carriage housing)의 출력 형상을 제공한다.
// 하드웨어 배치(hardware placement)와 exploded view는 assemblies 계층에서 담당한다.

include <arm_carriage_plate_base.scad>
use <../vitamins/ball_bearings.scad>

module arm_carriage_housing() {
    difference() {
        arm_carriage_plate_base();

        translate(ac_leadnut_center) {
            // J1 리드넛 플랜지 리세스(leadnut flange recess) — 하부 장착 플랜지(flange)가 판 안으로 안착하는 포켓.
            translate([0, 0, -boolean_epsilon])
                cylinder(h = ac_leadnut_flange_recess_depth + boolean_epsilon,
                         r = ac_leadnut_flange_recess_radius);

            // J1 리드넛 섕크 리세스(leadnut shank recess) — 플랜지 위 오프셋(offset) 구간의 원통부 간섭 공간.
            translate([0, 0, ac_leadnut_flange_recess_depth])
                cylinder(h = ac_leadnut_shank_recess_depth + boolean_epsilon,
                         r = ac_leadnut_shank_recess_radius);

            // J1 리드넛 스크류 클리어런스 홀(screw clearance holes) — NopSCADlib 플랜지 홀 위치와 같은 체결 경로.
            leadnut_screw_positions(ac_leadnut_type)
                translate([0, 0, -ac_leadnut_flange_thickness - boolean_epsilon])
                    cylinder(h = ac_thickness + boolean_epsilon * 2, r = ac_leadnut_screw_clearance_radius);
        }

        // J1 선형 베어링 리세스(linear bearing recess) — 두 판 사이의 LM8UU 하단이 윗면에서 안착한다.
        for (bearing_center = [ac_left_linear_bearing_center, ac_right_linear_bearing_center])
            translate(bearing_center)
                translate([0, 0, ac_thickness - ac_linear_bearing_recess_depth])
                    cylinder(h = ac_linear_bearing_recess_depth + boolean_epsilon,
                             r = ac_linear_bearing_recess_radius);

        // J2 종동축 베어링 시트(driven axis bearing seat) — 선형 링크(linear link) 끝단에서 바닥면으로 외륜을 지지한다.
        translate(ac_driven_axis_center)
            bb_seat_pocket(ac_driven_axis_ball_bearing_type, bore_depth = ac_thickness, from_top = false);

        // 스탠드오프 스크류 클리어런스 홀(standoff screw clearance holes) — 하부 스크류가 암암 스탠드오프로 올라가는 경로.
        for (standoff_center = ac_standoff_centers)
            translate(standoff_center)
                translate([0, 0, -boolean_epsilon])
                    cylinder(h = ac_thickness + boolean_epsilon * 2,
                             r = ac_standoff_screw_clearance_radius);
    }
}

arm_carriage_housing();
