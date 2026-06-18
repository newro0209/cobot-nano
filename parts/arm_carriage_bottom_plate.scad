// parts/arm_carriage_bottom_plate.scad - J1 carriage bottom plate (NopSCADlib printed-part style).
// The Z-mirror of the top plate, sharing the same arm-carriage blank, but with no motor: the motor mounts on the top
// plate only. Its back (-Y) lobe is sized to the 20T drive pulley footprint over the motor-slot travel instead of
// the motor footprint, since only the pulley reaches this plate. The remaining bearing seats mirror the top plate.
//
// J1 캐리지 하판 — 상판과 같은 블랭크를 쓰는 Z 미러. 단, 모터는 없다(모터는 상판에만 단다).
// 뒤쪽(−Y) 로브는 모터 풋프린트가 아니라 20T 구동 풀리 풋프린트(풀리 외경 + component_margin)에 맞추고,
// 모터 슬롯 가동 길이 전체를 덮는다 — 이 판엔 풀리만 닿기 때문이다.
// 리드너트도 없다(너트는 상판에만) — 하판은 리드스크류만 자유 관통한다.
// 나머지 형상(종동 베어링·가이드 로드 베어링 시트)은 상판과 같되, 시트가 열리는 면만 뒤집는다(from_top 반전).

include <arm_carriage_plate_base.scad>
use <ball_bearing_seat.scad>
use <linear_bearing_seat.scad>

module arm_carriage_bottom_plate() {
    difference() {
        // 뒤쪽(−Y) 로브 = 20T 풀리 슬롯 로브 — 구동 풀리의 Y 방향 이동 범위를 모두 덮는다.
        union() {
            ac_plate_base()
                ac_drive_pulley_slot_lobe();

            // LM8UU 양형 시트 — 25mm 필러처럼 판 간격이 베어링보다 길 때, 하판 윗면 외곽 칼라로 베어링 OD를 잡는다.
            if (ac_linear_bearing_boss_height > eps)
                for (center = cc_j1_guide_rod_centers)
                    translate(center)
                        linear_bearing_seat_boss(j1_linear_bearing_type,
                                                  part_thickness = ac_thickness,
                                                  height = ac_linear_bearing_boss_height,
                                                  from_top = true);
        }

        // J2 종동 베어링 시트 — 상판(from_top=true)의 Z 미러: 아랫면으로 연다.
        translate(j2_driven_axis_center)
            bb_bearing_seat_pocket(j2_driven_ball_bearing_type, part_thickness = ac_thickness, from_top = false);

        // J1 리드스크류 관통 보어 — 하판엔 리드너트가 없다(너트는 상판에만). 리드스크류만 판을 자유 관통한다.
        translate([j1_axis_center[0], j1_axis_center[1], -eps])
            cylinder(d = leadnut_bore(j1_leadnut_type) + shaft_clearance, h = ac_thickness + eps * 2);

        // 가이드 로드 LM8UU 시트 — 필러 간격이 베어링보다 짧을 때만 하판 윗면에서 필요한 깊이만 판다.
        if (ac_linear_bearing_seat_depth > eps)
            for (center = cc_j1_guide_rod_centers)
                translate(center)
                    linear_bearing_seat_pocket(j1_linear_bearing_type, part_thickness = ac_thickness,
                                               seat_depth = ac_linear_bearing_seat_depth, from_top = true);

    }
}

arm_carriage_bottom_plate();
