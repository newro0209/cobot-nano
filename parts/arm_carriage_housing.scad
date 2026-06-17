// parts/arm_carriage_housing.scad - Bottom carriage plate: leadnut/bearing seats and standoff holes cut from the underside of the shared blank.
// Hardware placement and exploded views live in the assemblies layer; this file is just the part geometry.
//
// 암 캐리지 하판(housing) — 공유 블랭크 아랫면에서 리드넛·베어링 시트(seat)와 스탠드오프 홀을 가공한다.
// 하드웨어 배치(hardware placement)와 exploded view는 assemblies 계층이 담당한다.

include <arm_carriage_plate_base.scad>
use <../parts/bearing_seat.scad>

module arm_carriage_housing() {
    difference() {
        arm_carriage_plate_blank();
        arm_carriage_axis_cuts();

        // J1 리드넛 리세스 — 플랜지·섕크 포켓 + 스크류 홀(공유 모듈, 양 판 동일).
        arm_carriage_leadnut_recess();

        // J1 선형 베어링 리세스 — LM8UU 하단이 윗면에서 안착(하판은 바깥=위 면).
        arm_carriage_linear_bearing_recess(from_top = true);

        // J2 종동축 베어링 시트(driven axis bearing seat) — 바닥면에서 외륜(outer race)을 지지한다.
        translate(ac_driven_axis_center)
            bearing_seat_pocket(ac_driven_axis_ball_bearing_type, bore_depth = ac_plate_thickness, from_top = false);
    }
}

arm_carriage_housing();
