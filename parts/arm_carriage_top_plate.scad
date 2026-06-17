// parts/arm_carriage_top_plate.scad - J1 carriage top plate (NopSCADlib printed-part style).
// Takes the shared arm-carriage blank and cuts the top-side features: the J2 driven-bearing seat, the J1 lead-nut
// flange recess and screw holes, the lead-screw clearance bore, and the LM8UU linear-bearing seats for the guide rods.
//
// J1 캐리지 상판 — 공유 암 캐리지 블랭크에 윗면 가공 형상을 깎는다: J2 종동 베어링 시트, J1 리드너트 플랜지 리세스와
// 고정 스크류 홀, 리드스크류 관통 보어, 가이드 로드용 LM8UU 직선 베어링 시트.

include <arm_carriage_plate_base.scad>
use <ball_bearing_seat.scad>
use <leadnut_seat.scad>
use <linear_bearing_seat.scad>
use <motor_seat.scad>

module arm_carriage_top_plate() {
    difference() {
        // 뒤쪽(−Y) 로브 = 모터 마운트 로브 — 실제 모터 외곽(NEMA_outline)에 가장자리 여유(component_margin/2)를 둘러 풋프린트를 덮는다.
        union() {
            ac_plate_base()
                translate(ac_j2_motor_center)
                    offset(r = component_margin / 2) NEMA_outline(j2_motor_type);

            // LM8UU 양형 시트 — 25mm 필러처럼 판 간격이 베어링보다 길 때, 상판 아랫면 외곽 칼라로 베어링 OD를 잡는다.
            if (ac_linear_bearing_boss_height > eps)
                for (center = cc_j1_guide_rod_centers)
                    translate(center)
                        linear_bearing_seat_boss(j1_linear_bearing_type,
                                                  part_thickness = ac_thickness,
                                                  height = ac_linear_bearing_boss_height,
                                                  from_top = false);
        }

        // J2 종동 베어링 시트(driven-bearing seat) — 윗면에서 BB608을 외륜(outer race)만 무는 단차 포켓으로 앉힌다.
        translate([j2_driven_axis_center[0], j2_driven_axis_center[1], -eps])
            bb_bearing_seat_pocket(j2_driven_ball_bearing_type, part_thickness = ac_thickness + eps, from_top = true);

        // J1 리드너트(lead nut) 자리 — 리드스크류 관통 보어 + 플랜지·몸통 리세스 + 플랜지 스크류 홀을 한 번에 깎는다.
        // 상판은 너트를 아랫면에 묻는다(from_top=false) — 하판은 같은 모듈을 from_top=true로 호출해 반대 면에 묻는다.
        translate(j1_axis_center)
            leadnut_seat_pocket(j1_leadnut_type, part_thickness = ac_thickness, from_top = false);

        // 가이드 로드 LM8UU 시트 — 필러 간격이 베어링보다 짧을 때만 상판 아랫면에서 필요한 깊이만 판다.
        if (ac_linear_bearing_seat_depth > eps)
            for (center = cc_j1_guide_rod_centers)
                translate(center)
                    linear_bearing_seat_pocket(j1_linear_bearing_type, part_thickness = ac_thickness,
                                               seat_depth = ac_linear_bearing_seat_depth, from_top = false);

        // J2 스텝모터 시트 — 리드너트 뒤(−Y)에서 판 윗면에 모터를 앉힌다(from_top=true). 바디 리세스 + 센터링 보스 리세스 + 샤프트 보어 + 스크류 홀.
        translate(ac_j2_motor_center)
            nema_motor_seat_pocket(j2_motor_type, part_thickness = ac_thickness, from_top = true);

        // J2 아이들러 슬롯 — 리드너트 좌우(±X)에 아이들러 축(M5)을 통과시키는 X 방향 장공(slot). 슬롯 안에서 좌우로 밀어 벨트 텐션을 잡는다.
        // 슬롯은 리드너트 옆(ac_idler_center_distance)에서 바깥으로 travel만큼 뻗는 두 끝점을 hull로 이은 장공이다.
        for (side = [-1, 1])
            hull()
                for (x = [ac_idler_center_distance, ac_idler_center_distance + ac_idler_slot_travel])
                    translate([side * x, 0, -eps])
                        cylinder(d = pulley_bore(j2_idler_pulley_type) + clearance, h = ac_thickness + eps * 2);
    }
}

arm_carriage_top_plate();
