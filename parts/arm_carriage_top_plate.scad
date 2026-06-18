// parts/arm_carriage_top_plate.scad - J1 carriage top plate (NopSCADlib printed-part style).
// Takes the shared arm-carriage blank and cuts the top-side features: the J2 driven-bearing seat, the J1 lead-nut
// flange recess and screw holes, the lead-screw clearance bore, and the LM8UU linear-bearing seats for the guide rods.
//
// J1 캐리지 상판 — 공유 암 캐리지 블랭크에 윗면 가공 형상을 깎는다: J2 종동 베어링 시트, J1 리드너트 플랜지 리세스와
// 고정 스크류 홀, 리드스크류 관통 보어, 가이드 로드용 LM8UU 직선 베어링 시트.

include <arm_carriage_plate_base.scad>
use <ball_bearing_seat.scad>
use <leadnut_seat.scad>
use <motor_seat.scad>

module arm_carriage_top_plate() {
    difference() {
        // 뒤쪽(−Y) 로브 = 모터 슬롯 로브 + LM8UU 캡처 칼라(양형, 아랫면).
        union() {
            ac_plate_base()
                ac_motor_slot_lobe();

            ac_linear_bearing_bosses(from_top = false);
        }

        // J2 종동 베어링 시트(driven-bearing seat) — 윗면에서 BB608을 외륜(outer race)만 무는 단차 포켓으로 앉힌다.
        translate([j2_driven_axis_center[0], j2_driven_axis_center[1], -eps])
            bb_bearing_seat_pocket(j2_driven_ball_bearing_type, part_thickness = ac_thickness + eps, from_top = true);

        // J1 리드너트(lead nut) 자리 — 보어+플랜지·몸통 리세스+플랜지 스크류 홀을 아랫면에 묻는다(from_top=false; 하판은 같은 모듈을 반대 면으로).
        translate(j1_axis_center)
            leadnut_seat_pocket(j1_leadnut_type, part_thickness = ac_thickness, from_top = false);

        // 가이드 로드 LM8UU 시트(음형, 아랫면) — 필러 간격이 베어링보다 짧을 때만 깎인다.
        ac_linear_bearing_seats(from_top = false);

        // J2 스텝모터 슬롯 시트 — 아이들러 대신 모터가 Y 방향으로 이동해 벨트 장력을 조절한다.
        translate(ac_j2_motor_center_at(0))
            nema_motor_seat_slot_pocket(j2_motor_type,
                                         part_thickness = ac_thickness,
                                         travel_vector = ac_j2_motor_slot_vector,
                                         from_top = true);
    }
}

arm_carriage_top_plate();
