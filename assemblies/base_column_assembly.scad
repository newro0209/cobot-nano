// assemblies/base_column_assembly.scad - Renders the fixed J1 base column for fit checks.
// Flange holders bolted to two end plates capture the rotating lead screw (KFL08 flange bearing top and bottom) and
// the two fixed guide rods (FC8 flange couplers), spanning the carriage's vertical travel. A central NEMA17
// hangs under the lower plate and turns the lead screw through a GT2 belt (motor pulley -> lead-screw pulley).
//
// 고정 J1 베이스 기둥(base column) 조립체 — 두 단판에 볼트 체결된 플랜지 홀더가 회전 리드스크류(상·하 KFL08 플랜지 베어링)와
// 고정 가이드 로드 2개(FC8 플랜지 커플러)를 잡아 캐리지 행정을 가른다.
// 중앙 NEMA17이 하단 단판 아래에 매달려 GT2 벨트(모터 풀리 → 리드스크류 풀리)로 리드스크류를 돌린다.

bc_exploded = 0; // [0:0.05:1]

include <../parts/base_column_plate_base.scad>
use <../parts/base_column_bottom_plate.scad>
use <../parts/base_column_top_plate.scad>
use <NopSCADlib/vitamins/rod.scad>
use <NopSCADlib/vitamins/belt.scad>

bc_explode_distance = 40;

// ── J1 벨트 드라이브(belt drive) — 모터·리드스크류 풀리를 하단 단판 위 같은 벨트면에 둔다 ──
bc_motor_pulley_type = GT2x20um_pulley;   // 모터 구동 풀리(GT2 20T)
bc_screw_pulley_type = GT2x60x8_pulley;   // 리드스크류 종동 풀리 — 보어 8mm가 스크류 8mm에 맞는다(3:1 감속)
bc_belt_type         = pulley_belt(bc_motor_pulley_type);
bc_drive_gap         = 3;   // 가장 낮은 풀리 끝과 단판 윗면 사이 여유

// pulley()는 원점이 바닥, 벨트면이 원점 위로 |pulley_offset| 떨어져 있다 — 두 풀리 중 큰 오프셋에 여유를 더해 벨트면을 잡으면
// 두 풀리 모두 단판 위로 올라온다(translate_z(belt_center + pulley_offset)이 각 원점, 모두 ≥ bc_drive_gap).
bc_belt_center_z         = bc_drive_gap + max(-pulley_offset(bc_screw_pulley_type), -pulley_offset(bc_motor_pulley_type));
bc_screw_pulley_origin_z = bc_belt_center_z + pulley_offset(bc_screw_pulley_type);
bc_motor_pulley_origin_z = bc_belt_center_z + pulley_offset(bc_motor_pulley_type);
bc_drive_top_z           = max(bc_screw_pulley_origin_z + pulley_height(bc_screw_pulley_type),
                               bc_motor_pulley_origin_z + pulley_height(bc_motor_pulley_type));
bc_motor_face_z          = -bc_plate_thickness + ac_motor_recess_depth;   // NEMA 앞면(플랜지)이 리세스 바닥에 짚는 z

// ── 리드스크류·로드 Z 스팬(span) — 위·아래 플랜지 홀더를 관통한다 ─────────
bc_top_face_z     = bc_clear_height + bc_plate_thickness;   // 상단 단판 윗면(상단 홀더가 앉는 면)
bc_screw_bottom_z = -bc_plate_thickness - kfl_height(bc_screw_support_type);
bc_screw_top_z    = bc_top_face_z + kfl_height(bc_screw_support_type);
bc_screw_length   = bc_screw_top_z - bc_screw_bottom_z;
bc_screw_center_z = (bc_screw_top_z + bc_screw_bottom_z) / 2;
bc_rod_bottom_z   = -bc_plate_thickness - fc_height(bc_rod_support_type);
bc_rod_top_z      = bc_top_face_z + fc_height(bc_rod_support_type);
bc_rod_length     = bc_rod_top_z - bc_rod_bottom_z;
bc_rod_center_z   = (bc_rod_top_z + bc_rod_bottom_z) / 2;

// ── 색(part colours) — 출력물 단판은 블루, 풀리는 주황, 홀더/모터 등 vitamin은 내부 재질색 ──
bc_col_plate        = [0.20, 0.45, 0.78];
bc_col_screw_pulley = [0.88, 0.50, 0.12];
bc_col_motor_pulley = [0.92, 0.62, 0.28];

// ── 조립 정합 검증(fit asserts) ───────────────────────────────────────────
assert(bc_belt_type == pulley_belt(bc_screw_pulley_type),
       "모터 풀리와 리드스크류 풀리는 같은 벨트 타입이어야 한다");
assert(bc_end_margin >= bc_drive_top_z + clearance,
       "행정 끝 여유(bc_end_margin)는 단판 위 벨트 드라이브 높이를 넘겨 캐리지와 안 닿게 해야 한다");
assert(norm(ac_leadnut_center - ac_motor_center) >= NEMA_radius(ac_motor_type) + kfl_housing_diameter(bc_screw_support_type) / 2 + clearance,
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

module base_column_assembly() {
    let($explode = bc_exploded) {
        // ── 단판(end plates) — 하단은 드라이브, 상단은 홀더만 ──
        color(bc_col_plate) translate_z(-bc_plate_thickness) base_column_bottom_plate();
        explode([0, 0, bc_explode_distance * 2])
            color(bc_col_plate) translate_z(bc_clear_height) base_column_top_plate();

        // ── 리드스크류 플랜지 베어링(KFL08) — 상·하 단판 바깥 면, 하우징이 바깥을 향한다 ──
        bc_place_support_ends(ac_leadnut_center)
            flange_bearing(bc_screw_support_type);

        // ── 가이드 로드(Ø8 smooth rod)와 끝단 플랜지 커플러(FC8) — 로드마다 상·하 커플러로 물고 봉이 두 단판을 잇는다 ──
        for (rod_center = bc_rod_centers) {
            bc_place_support_ends(rod_center)
                flange_coupler(bc_rod_support_type);
            translate([rod_center.x, rod_center.y, bc_rod_center_z])
                rod(bc_rod_diameter, bc_rod_length);
        }

        // ── J1 리드스크류(T8x2 trapezoidal lead screw) — 상·하 KFL 베어링에 지지되어 회전, 리드넛이 타고 Z 병진 ──
        translate([ac_leadnut_center.x, ac_leadnut_center.y, bc_screw_center_z])
            leadscrew(leadnut_bore(ac_leadnut_type), bc_screw_length,
                      leadnut_lead(ac_leadnut_type),
                      leadnut_lead(ac_leadnut_type) / leadnut_pitch(ac_leadnut_type));

        // ── J1 구동 모터(NEMA17) — 하단 단판 아래에 매달려 샤프트가 판 위로 올라온다 ──
        explode([0, 0, -bc_explode_distance * 2])
            translate([ac_motor_center.x, ac_motor_center.y, bc_motor_face_z]) {
                NEMA(ac_motor_type);
                NEMA_screws(ac_motor_type, M3_cap_screw);
            }

        // ── 벨트 드라이브 풀리 — 모터(중앙)·리드스크류(−X)를 같은 벨트면에 두고 GT2 벨트로 잇는다 ──
        explode([0, 0, -bc_explode_distance])
            translate([ac_motor_center.x, ac_motor_center.y, bc_motor_pulley_origin_z])
                pulley(bc_motor_pulley_type, colour = bc_col_motor_pulley);
        explode([0, 0, -bc_explode_distance])
            translate([ac_leadnut_center.x, ac_leadnut_center.y, bc_screw_pulley_origin_z])
                pulley(bc_screw_pulley_type, colour = bc_col_screw_pulley);

        if (bc_exploded == 0)
            translate_z(bc_belt_center_z)
                belt(bc_belt_type, [
                    [ac_motor_center.x,   ac_motor_center.y,   bc_motor_pulley_type],
                    [ac_leadnut_center.x, ac_leadnut_center.y, bc_screw_pulley_type],
                ]);
    }
}

base_column_assembly();
