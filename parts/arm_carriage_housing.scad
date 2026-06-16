// parts/arm_carriage_housing.scad - Bottom carriage plate: leadnut/bearing seats and standoff holes cut from the underside of the shared blank.
// Hardware placement and exploded views live in the assemblies layer; this file is just the part geometry.
//
// 암 캐리지 하판(housing) — 공유 블랭크 아랫면에서 리드넛·베어링 시트(seat)와 스탠드오프 홀을 가공한다.
// 하드웨어 배치(hardware placement)와 exploded view는 assemblies 계층이 담당한다.

include <arm_carriage_plate_base.scad>
use <../parts/bearing_seat.scad>

module arm_carriage_housing() {
    difference() {
        arm_carriage_plate_base();

        translate(ac_leadnut_center) {
            // J1 리드넛 플랜지 리세스(flange recess) — 하부 장착 플랜지가 판 안으로 안착하는 포켓.
            translate([0, 0, -eps])
                cylinder(h = ac_leadnut_flange_recess_depth + eps, r = ac_leadnut_flange_recess_radius);

            // J1 리드넛 섕크 리세스(shank recess) — 플랜지 위 원통 섕크의 간섭 공간.
            translate([0, 0, ac_leadnut_flange_recess_depth])
                cylinder(h = ac_leadnut_shank_recess_depth + eps, r = ac_leadnut_shank_recess_radius);

            // J1 리드넛 스크류 클리어런스 홀(screw clearance holes) — NopSCADlib 플랜지 홀 위치와 같은 체결 경로.
            leadnut_screw_positions(ac_leadnut_type)
                translate([0, 0, -ac_leadnut_flange_thickness - eps])
                    cylinder(h = ac_plate_thickness + eps * 2, r = ac_leadnut_screw_clearance_radius);
        }

        // J1 선형 베어링 리세스(linear bearing recess) — 두 판 사이 LM8UU 하단이 윗면에서 안착한다.
        for (bearing_center = [ac_left_linear_bearing_center, ac_right_linear_bearing_center])
            translate(bearing_center)
                translate([0, 0, ac_plate_thickness - ac_linear_bearing_recess_depth])
                    cylinder(h = ac_linear_bearing_recess_depth + eps, r = ac_linear_bearing_recess_radius);

        // J2 종동축 베어링 시트(driven axis bearing seat) — 바닥면에서 외륜(outer race)을 지지한다.
        translate(ac_driven_axis_center)
            bearing_seat_pocket(ac_driven_axis_ball_bearing_type, bore_depth = ac_plate_thickness, from_top = false);

        // 스탠드오프 스크류 클리어런스 홀(standoff screw clearance holes) — 하부 스크류가 암나사 스탠드오프로 올라간다.
        for (standoff_center = ac_standoff_centers)
            translate(standoff_center)
                translate([0, 0, -eps])
                    cylinder(h = ac_plate_thickness + eps * 2, r = ac_standoff_screw_clearance_radius);
    }
}

arm_carriage_housing();
