// assemblies/base_column_assembly.scad - Renders the fixed J1 base column for fit checks.
// Flange holders bolted to two end plates capture the rotating lead screw (KFL08 flange bearing top and bottom) and
// the two fixed guide rods (FC8 flange couplers), spanning the carriage's vertical travel. A central NEMA17
// mounts on the upper plate pointing down and turns the lead screw through a GT2 belt (motor pulley -> lead-screw pulley).
//
// 고정 J1 베이스 기둥(base column) 조립체 — 두 단판에 볼트 체결된 플랜지 홀더가 회전 리드스크류(상·하 KFL08 플랜지 베어링)와
// 고정 가이드 로드 2개(FC8 플랜지 커플러)를 잡아 캐리지 행정을 가른다.
// 중앙 NEMA17이 상단 단판에 아래로 달려 GT2 벨트(모터 풀리 → 리드스크류 풀리)로 리드스크류를 돌린다.

bc_exploded = 0; // [0:0.05:1]
show_hardware = true;   // 기성품 하드웨어(홀더·모터·풀리·벨트) 표시 — false면 출력물 단판만

include <../parts/base_column_plate_base.scad>
use <../parts/base_column_bottom_plate.scad>
use <../parts/base_column_top_plate.scad>
use <NopSCADlib/vitamins/belt.scad>

bc_explode_distance = 40;

// ── J1 벨트 드라이브(belt drive) — 모터를 상단 단판에 아래로 달고, 풀리·벨트를 단판 아래 같은 벨트면에 뒤집어 매단다 ──
bc_motor_pulley_type = GT2x20um_pulley;   // 모터 구동 풀리(GT2 20T)
bc_screw_pulley_type = GT2x20x8_pulley;   // 리드스크류 종동 풀리 — 보어 8mm가 스크류 8mm에 맞는다(모터 20T와 1:1)
bc_belt_type         = pulley_belt(bc_motor_pulley_type);
bc_drive_gap         = 3;   // 가장 높은 풀리 끝(허브)과 상단 단판 아랫면 사이 여유

// pulley()는 원점이 바닥, 벨트면이 원점 위로 |pulley_offset| 떨어져 있다 — 뒤집어 매달면 벨트면이 원점 아래로 |offset| 내려간다.
// 두 풀리 중 큰 오프셋에 여유를 더해 벨트면을 잡으면 두 풀리 모두 상단 단판 아래로 내려온다(허브 위끝이 단판 아래로 ≥ bc_drive_gap).
bc_belt_center_z         = bc_clear_height - bc_drive_gap - max(-pulley_offset(bc_screw_pulley_type), -pulley_offset(bc_motor_pulley_type));
bc_screw_pulley_origin_z = bc_belt_center_z - pulley_offset(bc_screw_pulley_type);
bc_motor_pulley_origin_z = bc_belt_center_z - pulley_offset(bc_motor_pulley_type);
bc_drive_bottom_z        = min(bc_screw_pulley_origin_z - pulley_height(bc_screw_pulley_type),
                               bc_motor_pulley_origin_z - pulley_height(bc_motor_pulley_type));
bc_motor_seat_z          = bc_clear_height + ac_motor_recess_floor_z;   // NEMA 앞면(플랜지)이 상단 단판 리세스 바닥에 짚는 z

// ── 색(part colours) — 출력물 단판은 블루, 풀리는 주황, 홀더/모터 등 vitamin은 내부 재질색 ──
bc_col_plate        = [0.20, 0.45, 0.78];
bc_col_screw_pulley = [0.88, 0.50, 0.12];
bc_col_motor_pulley = [0.92, 0.62, 0.28];

// ── 조립 정합 검증(fit asserts) ───────────────────────────────────────────
assert(bc_belt_type == pulley_belt(bc_screw_pulley_type),
       "모터 풀리와 리드스크류 풀리는 같은 벨트 타입이어야 한다");
assert(bc_end_margin >= bc_clear_height - bc_drive_bottom_z + clearance,
       "행정 끝 여유(bc_end_margin)는 상단 단판 아래 벨트 드라이브 깊이를 넘겨 캐리지와 안 닿게 해야 한다");
assert(norm(ac_leadnut_center - ac_motor_center) >= NEMA_radius(bc_motor_type) + kfl_housing_diameter(bc_screw_support_type) / 2 + clearance,
       "모터 바디와 리드스크류 플랜지 베어링 하우징은 평면에서 겹치면 안 된다");

// 플랜지 홀더 배치 — 접선 정렬(bc_at_support와 같은 각) + 높이 z. flip이면 홀더 돌출부(KFL 하우징·FC 허브)가 단판 바깥을 향하게 뒤집는다.
module bc_place_support(center, z, flip) {
    translate([center.x, center.y, z])
        rotate(bc_tangential_angle(center))
            if (flip)
                rotate([180, 0, 0]) children();
            else
                children();
}

// 한 축의 상·하 단판 바깥 면에 홀더를 한 쌍 배치 — 하단은 뒤집어 explode 아래로, 상단은 explode 위로. children = 홀더.
module bc_place_support_ends(center) {
    explode([0, 0, -bc_explode_distance])
        bc_place_support(center, -bc_plate_thickness, true)
            children();
    explode([0, 0, bc_explode_distance])
        bc_place_support(center, bc_top_face_z, false)
            children();
}

module base_column_assembly(show_hardware = show_hardware) {
    let($explode = bc_exploded) {
        // ── 단판(end plates) — 하단은 평판, 상단은 모터 ──
        color(bc_col_plate) translate_z(-bc_plate_thickness) base_column_bottom_plate();
        explode([0, 0, bc_explode_distance * 2])
            color(bc_col_plate) translate_z(bc_clear_height) base_column_top_plate();

        // 기성품 하드웨어(holders·motor·pulleys·belt) — show_hardware=false면 출력물 단판만 남긴다.
        if (show_hardware) {

        // ── 리드스크류 플랜지 베어링(KFL08) — 상·하 단판 바깥 면, 하우징이 바깥을 향한다 ──
        bc_place_support_ends(ac_leadnut_center)
            flange_bearing(bc_screw_support_type);

        // ── 가이드 로드 끝단 플랜지 커플러(FC8) — 로드마다 상·하 커플러로 봉을 문다(공유 리드스크류·봉은 결합 조립에서 그린다) ──
        for (rod_center = bc_rod_centers)
            bc_place_support_ends(rod_center)
                flange_coupler(bc_rod_support_type);

        // ── J1 구동 모터(NEMA17) — 상단 단판에 아래로 삽입(캐리지 J2 모터처럼). 바디는 판 위, 샤프트는 아래 풀리로 내려간다 ──
        explode([0, 0, bc_explode_distance * 2])
            translate([ac_motor_center.x, ac_motor_center.y, bc_motor_seat_z])
                rotate([180, 0, 0]) {
                    NEMA(bc_motor_type);
                    NEMA_screws(bc_motor_type, M3_cap_screw);
                }

        // ── 벨트 드라이브 풀리 — 상단 단판 아래에 뒤집어 매단다. 모터(중앙)·리드스크류(−X)를 같은 벨트면에 두고 GT2 벨트로 잇는다 ──
        explode([0, 0, bc_explode_distance])
            translate([ac_motor_center.x, ac_motor_center.y, bc_motor_pulley_origin_z])
                rotate([180, 0, 0])
                    pulley(bc_motor_pulley_type, colour = bc_col_motor_pulley);
        explode([0, 0, bc_explode_distance])
            translate([ac_leadnut_center.x, ac_leadnut_center.y, bc_screw_pulley_origin_z])
                rotate([180, 0, 0])
                    pulley(bc_screw_pulley_type, colour = bc_col_screw_pulley);

        if (bc_exploded == 0)
            translate_z(bc_belt_center_z)
                belt(bc_belt_type, [
                    [ac_motor_center.x,   ac_motor_center.y,   bc_motor_pulley_type],
                    [ac_leadnut_center.x, ac_leadnut_center.y, bc_screw_pulley_type],
                ]);
        }
    }
}

base_column_assembly();
