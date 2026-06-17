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
use <NopSCADlib/vitamins/screw.scad>
use <NopSCADlib/vitamins/nut.scad>
use <NopSCADlib/vitamins/washer.scad>

bc_explode_distance = 40;

// ── J1 벨트 드라이브(belt drive) — 모터를 상단 단판에 아래로 달고, 풀리·벨트를 단판 아래 같은 벨트면에 뒤집어 매단다 ──
bc_motor_pulley_type = GT2x20um_pulley;   // 모터 구동 풀리(GT2 20T)
bc_screw_pulley_type = GT2x20x8_pulley;   // 리드스크류 종동 풀리 — 보어 8mm가 스크류 8mm에 맞는다(모터 20T와 1:1)
bc_belt_type         = pulley_belt(bc_motor_pulley_type);
bc_drive_gap         = 3;   // 가장 높은 풀리 끝(허브)과 상단 단판 아랫면 사이 여유

// pulley()는 원점이 바닥, 벨트면이 원점 위로 |pulley_offset| 떨어져 있다 — 뒤집어 매달면 벨트면이 원점 아래로 |offset| 내려간다.
// 두 풀리 중 큰 오프셋에 여유를 더해 벨트면을 잡으면 두 풀리 모두 상단 단판 아래로 내려온다(허브 위끝이 단판 아래로 ≥ bc_drive_gap).
bc_belt_center_z         = bc_clear_height - bc_drive_gap - max(-pulley_offset(bc_screw_pulley_type), -pulley_offset(bc_motor_pulley_type), -pulley_offset(bc_idler_pulley_type));
bc_screw_pulley_origin_z = bc_belt_center_z - pulley_offset(bc_screw_pulley_type);
bc_motor_pulley_origin_z = bc_belt_center_z - pulley_offset(bc_motor_pulley_type);
bc_idler_pulley_origin_z = bc_belt_center_z - pulley_offset(bc_idler_pulley_type);
bc_drive_bottom_z        = min(bc_screw_pulley_origin_z - pulley_height(bc_screw_pulley_type),
                               bc_motor_pulley_origin_z - pulley_height(bc_motor_pulley_type),
                               bc_idler_pulley_origin_z - pulley_height(bc_idler_pulley_type));
bc_motor_seat_z          = bc_clear_height + ac_motor_recess_floor_z;   // NEMA 앞면(플랜지)이 상단 단판 리세스 바닥에 짚는 z

// ── 체결 길이(fastener lengths) ──
bc_idler_screw_length  = screw_longer_than(bc_top_face_z - (bc_idler_pulley_origin_z - pulley_height(bc_idler_pulley_type))
                                           + washer_thickness(screw_washer(bc_idler_screw_type))
                                           + nut_thickness(screw_nut(bc_idler_screw_type), nyloc = true));  // 슬롯·아이들러 관통 후 와셔+nyloc까지

// ── 색(part colours) — 출력물 단판은 블루, 풀리는 주황, 홀더/모터 등 vitamin은 내부 재질색 ──
bc_col_plate        = [0.20, 0.45, 0.78];
bc_col_screw_pulley = [0.88, 0.50, 0.12];
bc_col_motor_pulley = [0.92, 0.62, 0.28];
bc_col_idler        = [0.55, 0.56, 0.58];   // 아이들러(베어링 일체형) 강체

// ── 조립 정합 검증(fit asserts) ───────────────────────────────────────────
assert(bc_belt_type == pulley_belt(bc_screw_pulley_type),
       "모터 풀리와 리드스크류 풀리는 같은 벨트 타입이어야 한다");
assert(bc_end_margin >= bc_clear_height - bc_drive_bottom_z + clearance,
       "행정 끝 여유(bc_end_margin)는 상단 단판 아래 벨트 드라이브 깊이를 넘겨 캐리지와 안 닿게 해야 한다");
// 모터↔KFL 평면 검사는 제거: KFL은 접선(tangential) 배치라 모터엔 좁은 면(width)을 마주봐 외접원(kfl_radius)만 겹치는 false alarm — 실제 다이아몬드 외형은 비간섭.
// 아이들러는 회전 풀리(모터·리드스크류)와 component_margin 이상, 정지 KFL 외형(다이아몬드 플랜지)과는 최소 clearance 이상 떨어져야 한다.
assert(norm(bc_idler_centers[0] - ac_motor_center) >= pulley_extent(bc_idler_pulley_type) + pulley_extent(bc_motor_pulley_type) + component_margin,
       "J1 아이들러와 모터 풀리는 component_margin 이상 떨어져야 한다");
assert(norm(bc_idler_centers[0] - ac_leadnut_center) >= pulley_extent(bc_idler_pulley_type) + pulley_extent(bc_screw_pulley_type) + component_margin,
       "J1 아이들러와 리드스크류 풀리는 component_margin 이상 떨어져야 한다");
assert(norm(bc_idler_centers[0] - ac_leadnut_center) >= pulley_extent(bc_idler_pulley_type) + kfl_radius(bc_screw_support_type) + clearance,
       "J1 아이들러는 리드스크류 KFL 외형(다이아몬드 플랜지)과 겹치면 안 된다");

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

// 단판 관통 볼트(through bolt) — 바깥 면(outer_z)에 머리+와셔, 안쪽 면(inner_z)에 와셔+너트. 현재 좌표(XY)에 수직으로 박는다.
module bc_through_bolt(outer_z, inner_z, screw) {
    down   = inner_z < outer_z;   // 바깥이 위면 샤프트는 −z로 내려간다
    nut_t  = screw_nut(screw);
    wash   = screw_washer(screw);
    length = screw_longer_than(abs(inner_z - outer_z) + 2 * washer_thickness(wash) + nut_thickness(nut_t));
    se     = down ? 1 : -1;       // 바깥 면이 위면 머리는 +z로(바깥으로) 분해
    explode([0, 0,  se * bc_explode_distance * 1.5])
        translate_z(outer_z) rotate([down ? 0 : 180, 0, 0]) screw_and_washer(screw, length);
    explode([0, 0, -se * bc_explode_distance])
        translate_z(inner_z) rotate([down ? 180 : 0, 0, 0]) {
            washer(wash);
            translate_z(washer_thickness(wash)) nut(nut_t);
        }
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

        // ── 벨트 드라이브 풀리 — 상단 단판 아래에 뒤집어 매단다. 모터·리드스크류·대칭 아이들러 2개를 같은 벨트면에 둔다 ──
        explode([0, 0, bc_explode_distance])
            translate([ac_motor_center.x, ac_motor_center.y, bc_motor_pulley_origin_z])
                rotate([180, 0, 0]) pulley(bc_motor_pulley_type, colour = bc_col_motor_pulley);
        explode([0, 0, bc_explode_distance])
            translate([ac_leadnut_center.x, ac_leadnut_center.y, bc_screw_pulley_origin_z])
                rotate([180, 0, 0]) pulley(bc_screw_pulley_type, colour = bc_col_screw_pulley);
        for (idler_center = bc_idler_centers)
            explode([0, 0, bc_explode_distance])
                translate([idler_center.x, idler_center.y, bc_idler_pulley_origin_z])
                    rotate([180, 0, 0]) pulley(bc_idler_pulley_type, colour = bc_col_idler);

        // J1 타이밍 벨트 — 모터 → 아이들러(한쪽) → 리드스크류 삼각 루프. 아이들러가 한쪽에서 장력을 잡는다.
        if (bc_exploded == 0)
            translate_z(bc_belt_center_z)
                belt(bc_belt_type, [
                    [ac_motor_center.x,     ac_motor_center.y,     bc_motor_pulley_type],
                    [bc_idler_centers[0].x, bc_idler_centers[0].y, bc_idler_pulley_type],
                    [ac_leadnut_center.x,   ac_leadnut_center.y,   bc_screw_pulley_type],
                ]);

        // ── 체결 부품(fasteners) — 홀더 관통 볼트(머리+와셔 / 와셔+너트) + 아이들러 축 볼트 ──
        // KFL08 마운팅 볼트 (상·하 단판, 2볼트). 바깥 면에 머리, 안쪽 면(기둥 내부)에 너트.
        bc_at_support(ac_leadnut_center)
            kfl_screw_positions(bc_screw_support_type) {
                bc_through_bolt(bc_top_face_z, bc_clear_height, kfl_screw(bc_screw_support_type));
                bc_through_bolt(-bc_plate_thickness, 0, kfl_screw(bc_screw_support_type));
            }

        // FC8 마운팅 볼트 (로드마다 상·하, 볼트원 4볼트).
        for (rod_center = bc_rod_centers)
            bc_at_support(rod_center)
                fc_screw_positions(bc_rod_support_type) {
                    bc_through_bolt(bc_top_face_z, bc_clear_height, fc_screw(bc_rod_support_type));
                    bc_through_bolt(-bc_plate_thickness, 0, fc_screw(bc_rod_support_type));
                }

        // 아이들러 축 볼트(M5) — 상단 단판 호 슬롯을 지나 머리+와셔(위), 아이들러 아래에서 와셔+nyloc로 잠근다.
        for (idler_center = bc_idler_centers) {
            explode([0, 0, bc_explode_distance * 1.5])
                translate([idler_center.x, idler_center.y, bc_top_face_z])
                    screw_and_washer(bc_idler_screw_type, bc_idler_screw_length);
            explode([0, 0, -bc_explode_distance])
                translate([idler_center.x, idler_center.y, bc_idler_pulley_origin_z - pulley_height(bc_idler_pulley_type)])
                    rotate([180, 0, 0]) {
                        washer(screw_washer(bc_idler_screw_type));
                        translate_z(washer_thickness(screw_washer(bc_idler_screw_type)))
                            nut(screw_nut(bc_idler_screw_type), nyloc = true);
                    }
        }
        }
    }
}

base_column_assembly();
