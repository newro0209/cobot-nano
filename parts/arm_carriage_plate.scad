// parts/arm_carriage_plate.scad - Top carriage plate: motor recess, leadnut/bearing seats, and standoff holes cut into the shared blank.
// Keeps the base blank separate so the housing reuses the same datums without re-deriving coordinates.
//
// 암 캐리지 상판(top plate) — 공유 블랭크에 J2 모터 리세스(recess), 리드넛·베어링 시트(seat), 스탠드오프 홀을 가공한다.
// 기본 판(base blank)을 분리해 두어 하우징(housing)이 같은 기준 좌표를 그대로 쓴다.

include <arm_carriage_plate_base.scad>
use <../parts/bearing_seat.scad>

module arm_carriage_plate() {
    difference() {
        arm_carriage_plate_blank();
        arm_carriage_axis_cuts();

        // J2 모터 2단 시트(motor seat) — 위에서 삽입하는 뒤집힌 모터용 음형(공유 모듈).
        translate(ac_motor_center)
            nema_motor_seat(ac_motor_type);

        // J1 리드넛 리세스 — 플랜지·섕크 포켓 + 스크류 홀(공유 모듈, 양 판 동일).
        arm_carriage_leadnut_recess();

        // J1 선형 베어링 리세스 — LM8UU 상단이 바닥면에서 안착(상판은 바깥=아래 면).
        arm_carriage_linear_bearing_recess(from_top = false);

        // J2 종동축 베어링 시트(driven axis bearing seat) — 윗면에서 외륜(outer race)을 지지한다.
        translate(ac_driven_axis_center)
            bearing_seat_pocket(ac_driven_axis_ball_bearing_type, bore_depth = ac_plate_thickness, from_top = true);
    }
}

arm_carriage_plate();
