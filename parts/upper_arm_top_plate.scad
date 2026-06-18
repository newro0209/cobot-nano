// parts/upper_arm_top_plate.scad - UPPER_ARM top plate (NopSCADlib printed-part style).
// Takes the shared upper-arm blank and cuts the top-side features: the J3 elbow-bearing seat and the J3 motor seat
// at the proximal J2 axis (motor sits on top, shaft pointing down to the 20T drive pulley).
//
// 상완 상판 — 공유 상완 블랭크에 윗면 가공 형상을 깎는다: J3 팔꿈치 베어링 시트,
// J2 축 위 J3 스텝모터 시트(모터는 윗면에 앉고 축은 아래 20T 구동 풀리로 내려간다).

include <upper_arm_plate_base.scad>
use <ball_bearing_seat.scad>
use <motor_seat.scad>

module upper_arm_top_plate() {
    difference() {
        ua_plate_base();

        // J3 종동 베어링 시트(driven-bearing seat) — 윗면에서 BB608을 외륜(outer race)만 무는 단차 포켓으로 앉힌다.
        translate([j3_elbow_axis_center[0], j3_elbow_axis_center[1], -eps])
            bb_bearing_seat_pocket(j3_driven_ball_bearing_type, part_thickness = ua_thickness + eps, from_top = true);

        // J3 스텝모터 시트 — AC J2 driven axis와 같은 축에 모터 전면을 윗면에 맞추고, 축은 판 아래 20T 풀리로 내려간다.
        translate(ua_j3_motor_center)
            nema_motor_seat_pocket(j3_motor_type, part_thickness = ua_thickness, from_top = true);
    }
}

upper_arm_top_plate();
