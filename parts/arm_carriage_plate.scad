// parts/arm_carriage_plate.scad - Cuts functional recesses and seats into the arm carriage base plate.
// The base blank is kept separate so housing assemblies can include the same datums without re-deriving coordinates.
//
// 암 캐리지 기본 판(base plate)에 모터 리세스(recess), 리드넛 체결부, 베어링 시트(bearing seat)를 가공한다.
// 하우징 조립체(housing assembly)가 같은 기준 좌표를 쓰도록 기본 판 파일을 include한다.

include <arm_carriage_plate_base.scad>
use <../vitamins/ball_bearings.scad>

module arm_carriage_plate() {
    assert(ac_thickness >= 2 * seat_shoulder_thickness,
           "ac_thickness는 중첩 리세스의 2단 시트 숄더 이상이어야 한다");

    difference() {
        arm_carriage_plate_base();

        translate(ac_motor_center) {
            // J2 모터 스크류 클리어런스 홀(screw clearance holes) — NEMA 홀 피치(hole pitch) 기준 플랜지 체결 경로.
            NEMA_screw_positions(ac_shoulder_motor_type)
                translate([0, 0, -boolean_epsilon])
                    cylinder(h = ac_thickness + boolean_epsilon * 2, r = M3_clearance_radius);

            // J2 모터 바디 리세스(motor body recess) — 중첩 리세스를 고려해 두 단계 시트 숄더(seat shoulder)를 남기는 플랜지 안착면.
            translate([0, 0, ac_motor_recess_floor_z])
                linear_extrude(height = ac_motor_recess_depth + boolean_epsilon)
                    offset(delta = clearance)
                        NEMA_outline(ac_shoulder_motor_type);

            // J2 센터링 보스 리세스(centering boss recess) — 가장 깊은 단계도 바닥에 한 단계 시트 숄더(seat shoulder)를 남기는 동축 공간.
            translate([0, 0, ac_motor_boss_recess_floor_z])
                cylinder(h = ac_motor_boss_recess_depth + boolean_epsilon, r = ac_motor_boss_recess_radius);
        }

        translate(ac_leadnut_center) {
            // J1 리드넛 플랜지 오프셋 리세스(leadnut flange offset recess) — 아래쪽 장착 플랜지(flange)의 섕크(shank) 간섭 공간.
            translate([0, 0, -boolean_epsilon])
                cylinder(h = ac_leadnut_flange_offset_recess_depth + boolean_epsilon,
                         r = ac_leadnut_flange_offset_recess_radius);

            // J1 리드넛 스크류 클리어런스 홀(screw clearance holes) — NopSCADlib 플랜지 홀 위치와 같은 체결 경로.
            leadnut_screw_positions(ac_leadnut_type)
                translate([0, 0, -ac_leadnut_flange_thickness - boolean_epsilon])
                    cylinder(h = ac_thickness + boolean_epsilon * 2, r = ac_leadnut_screw_clearance_radius);
        }

        // J2 종동 베어링 시트(driven bearing seat) — 벨트 장력(belt tension)을 캐리지 윗면의 외륜 지지부로 전달.
        translate(ac_shoulder_bearing_center)
            bb_seat_pocket(ac_shoulder_joint_bearing_type, bore_depth = ac_thickness, from_top = true);
    }
}

arm_carriage_plate();
