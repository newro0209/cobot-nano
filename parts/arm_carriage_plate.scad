// parts/arm_carriage_plate.scad - Top carriage plate: motor recess, leadnut/bearing seats, and standoff holes cut into the shared blank.
// Keeps the base blank separate so the housing reuses the same datums without re-deriving coordinates.
//
// 암 캐리지 상판(top plate) — 공유 블랭크에 J2 모터 리세스(recess), 리드넛·베어링 시트(seat), 스탠드오프 홀을 가공한다.
// 기본 판(base blank)을 분리해 두어 하우징(housing)이 같은 기준 좌표를 그대로 쓴다.

include <arm_carriage_plate_base.scad>
use <../parts/bearing_seat.scad>

module arm_carriage_plate() {
    difference() {
        arm_carriage_plate_base();

        translate(ac_motor_center) {
            // J2 모터 스크류 클리어런스 홀(screw clearance holes) — NEMA 홀 피치(hole pitch) 기준 플랜지 체결 경로.
            NEMA_screw_positions(ac_motor_type)
                translate([0, 0, -eps])
                    cylinder(h = ac_plate_thickness + eps * 2, r = M3_clearance_radius);

            // J2 모터 바디 리세스(motor body recess) — 위에서 2단 시트 숄더(seat shoulder)를 남기는 플랜지 안착면.
            translate([0, 0, ac_motor_recess_floor_z])
                linear_extrude(height = ac_motor_recess_depth + eps)
                    offset(delta = clearance)
                        NEMA_outline(ac_motor_type);

            // J2 센터링 보스 리세스(centering boss recess) — 가장 깊은 단도 바닥에 1단 숄더를 남기는 동축 공간.
            translate([0, 0, ac_motor_boss_recess_floor_z])
                cylinder(h = ac_motor_boss_recess_depth + eps, r = ac_motor_boss_recess_radius);
        }

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

        // J1 선형 베어링 리세스(linear bearing recess) — 두 판 사이 LM8UU 상단이 하부에서 안착한다.
        for (bearing_center = [ac_left_linear_bearing_center, ac_right_linear_bearing_center])
            translate(bearing_center)
                translate([0, 0, -eps])
                    cylinder(h = ac_linear_bearing_recess_depth + eps, r = ac_linear_bearing_recess_radius);

        // J2 종동축 베어링 시트(driven axis bearing seat) — 윗면에서 외륜(outer race)을 지지한다.
        translate(ac_driven_axis_center)
            bearing_seat_pocket(ac_driven_axis_ball_bearing_type, bore_depth = ac_plate_thickness, from_top = true);

        // 스탠드오프 스크류 클리어런스 홀(standoff screw clearance holes) — 상부 스크류가 암나사 스탠드오프로 내려간다.
        for (standoff_center = ac_standoff_centers)
            translate(standoff_center)
                translate([0, 0, -eps])
                    cylinder(h = ac_plate_thickness + eps * 2, r = ac_standoff_screw_clearance_radius);
    }
}

arm_carriage_plate();
