// plates/motor_bracket.scad - Defines the 2D cut profile for a NEMA motor bracket.
// Motor interface dimensions are read from NopSCADlib accessors instead of duplicating NEMA constants.
//
// NEMA 모터 브래킷(motor bracket)의 2D 절단 프로파일(cut profile)을 정의한다.
// 모터 인터페이스 치수(motor interface dimensions)는 NopSCADlib 접근자(accessor)로 읽어 NEMA 상수 복사를 피한다.

include <../config.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>

function motor_bracket_span(stepper_motor_type, corner_radius = 4) =
    NEMA_width(stepper_motor_type) + 2 * corner_radius;

module motor_bracket_2d(stepper_motor_type, small_bolt_diameter, corner_radius = 4) {
    bsd = small_bolt_diameter + clearance;
    difference() {
        // 모터 몸체 폭(motor body width)을 기준으로 브래킷 외곽을 잡아 NEMA 타입 변경 시 장착판이 함께 따라간다.
        offset(r = corner_radius)
            square([NEMA_width(stepper_motor_type), NEMA_width(stepper_motor_type)], center = true);
        // 보스 클리어런스(boss clearance)는 돌출 보스(raised boss)가 판재와 간섭하지 않도록 중심 구멍을 확보한다.
        circle(r = NEMA_big_hole(stepper_motor_type));
        // NEMA 장착 구멍(mounting holes)은 라이브러리 홀 위치(hole positions)를 사용해 모터 플랜지(motor flange)와 정렬된다.
        for (x = NEMA_holes(stepper_motor_type))
            for (y = NEMA_holes(stepper_motor_type))
                translate([x, y]) circle(d = bsd);
    }
}

motor_bracket_2d(NEMA17_40, 3);
