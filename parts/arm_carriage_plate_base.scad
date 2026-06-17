// parts/arm_carriage_plate_base.scad - Shared arm-carriage dimensions and the base plate blank (2D outline + through-cuts).
// Interface centers and recess sizes are materialised as shared values so the plate, housing, and assembly files all
// reference one mechanical datum instead of re-deriving coordinates. No top-level render: this file is included, not run.
//
// 암 캐리지 판(arm carriage plate)의 공통 치수와 기본 판 블랭크(base plate blank, 외곽 + 관통 절단)를 정의한다.
// 인터페이스 중심(interface center)과 리세스 치수를 값으로 공유해 plate·housing·assembly가 같은 기준 좌표를 쓰게 한다.

include <../config.scad>

// ── 인터페이스 부품(interface vitamins) ───────────────────────────────────
ac_leadnut_type                  = LSN8x2;
ac_linear_bearing_type           = LM8UU;
ac_motor_type                    = NEMA17_47;          // J2(어깨 관절, shoulder joint)를 벨트로 구동하는 모터
ac_driven_axis_ball_bearing_type = BB608;              // J2 종동축(driven axis)을 상하로 지지
ac_driven_axis_pulley_type       = GT2x60x8_pulley;    // 벨트가 도는 J2 종동 풀리
ac_j2_idler_pulley_type          = GT2x20_idler_5mm;   // 5mm 보어 베어링 일체형(integral bearing) GT2 20T 아이들러 — 축에서 자유 회전
ac_j2_idler_screw_type           = M5_cap_screw;       // 아이들러 축 = 베어링 보어(5mm)에 맞춘 M5 볼트(슬롯에서 장력 조절)
ac_standoff_type = ["M3x20_ff_hex_pillar", "hex", 3, 20, 5 / cos(30), 5 / cos(30), 6, 6, "silver", silver, -8, -8, true];

// ── 독립 입력 치수(independent inputs) ────────────────────────────────────
ac_j2_linear_link_length = 100;  // 모터축 ↔ J2 종동축 피벗 거리
ac_j2_idler_slot_travel  = 24;   // 아이들러 벨트 장력 조절 이동량(slot travel)
ac_j2_idler_center_x = 50; // [38:1:62]   현재 아이들러 X (슬롯 범위 안)
ac_j2_idler_center_y = 13; // [9:1:22]    아이들러 대칭 Y 오프셋

// ── 판 두께(plate thickness) ──────────────────────────────────────────────
// 외륜(outer race)이 다 들어가게 베어링 폭(width)을 받고, 그 위에 시트 숄더(seat shoulder)를 한 단 남긴다.
ac_plate_thickness = bb_width(ac_driven_axis_ball_bearing_type) + seat_shoulder_thickness;
ac_standoff_gap    = pillar_height(ac_standoff_type);  // 두 판 사이 간격 = 스탠드오프 길이
assert(ac_plate_thickness >= 2 * seat_shoulder_thickness,
       "ac_plate_thickness는 중첩 리세스의 2단 시트 숄더 이상이어야 한다");

// ── J1 리드넛(leadnut) — 플랜지·섕크 리세스와 체결 홀 ─────────────────────
ac_leadnut_flange_radius          = leadnut_flange_dia(ac_leadnut_type) / 2;
ac_leadnut_flange_thickness       = leadnut_flange_t(ac_leadnut_type);
ac_leadnut_flange_recess_radius   = ac_leadnut_flange_radius + clearance / 2;
ac_leadnut_flange_recess_depth    = ac_leadnut_flange_thickness;          // 플랜지(flange)가 판 안으로 안착하는 깊이
ac_leadnut_shank_recess_radius    = leadnut_od(ac_leadnut_type) / 2 + clearance / 2;
ac_leadnut_shank_recess_depth     = leadnut_flange_offset(ac_leadnut_type); // 플랜지 위 원통 섕크(shank) 길이
ac_leadnut_screw_clearance_radius = leadnut_hole_dia(ac_leadnut_type) / 2;

// ── J1 선형 베어링(LM8UU) ─────────────────────────────────────────────────
ac_linear_bearing_radius        = bearing_dia(ac_linear_bearing_type) / 2;
ac_linear_bearing_recess_radius = ac_linear_bearing_radius + bearing_clearance / 2;
// 두 판이 베어링을 절반씩 감싸므로 (전체 길이 − 스탠드오프 갭)/2 만 한쪽 판의 리세스 깊이가 된다.
ac_linear_bearing_recess_depth  = (bearing_length(ac_linear_bearing_type) - ac_standoff_gap) / 2;
assert(ac_linear_bearing_recess_depth >= 0, "스탠드오프 갭은 선형 베어링 길이보다 길 수 없다");
assert(ac_linear_bearing_recess_depth <= ac_plate_thickness - seat_shoulder_thickness,
       "선형 베어링 리세스는 시트 숄더를 남겨야 한다");

// ── J2 모터(NEMA17) 리세스 — 2단 시트 숄더로 바디·센터링 보스를 받는다 ────
ac_motor_radius              = NEMA_radius(ac_motor_type);
ac_motor_recess_floor_z      = seat_shoulder_thickness * 2;   // 바디 리세스 바닥(위에서 2단 숄더) — 모터 플랜지 안착 z 기준
ac_motor_boss_recess_floor_z = seat_shoulder_thickness;       // 보스 리세스 바닥(가장 깊은 단도 1단 숄더)

// NEMA 모터 2단 시트 음형(motor seat pocket) — 윗면에서 삽입하는(뒤집힌) 모터용. difference() 안에서 모터 중심에 두고 쓴다.
// 바디 리세스(2단 숄더) + 센터링 보스 리세스(1단 숄더) + 샤프트 관통 보어 + 스크류 클리어런스 홀. 리세스 깊이는 판 두께에서 잡는다.
module nema_motor_seat(type, thickness = ac_plate_thickness) {
    // 모터 스크류 클리어런스 홀(screw clearance holes) — NEMA 홀 피치 기준 플랜지 체결 경로(관통).
    NEMA_screw_positions(type)
        translate_z(-eps)
            cylinder(h = thickness + 2 * eps, r = M3_clearance_radius);

    // 바디 리세스(body recess) — 윗면에서 2단 시트 숄더를 남기는 플랜지 안착면.
    translate_z(ac_motor_recess_floor_z)
        linear_extrude(thickness - ac_motor_recess_floor_z + eps)
            offset(delta = clearance)
                NEMA_outline(type);

    // 센터링 보스 리세스(centering boss recess) — 가장 깊은 단도 바닥에 1단 숄더를 남기는 동축 공간.
    translate_z(ac_motor_boss_recess_floor_z)
        cylinder(h = thickness - ac_motor_boss_recess_floor_z + eps, r = NEMA_big_hole(type));

    // 샤프트 관통 보어(shaft through-bore) — 뒤집힌 모터 축이 보스 시트 숄더를 지나 판 아래 풀리로 내려간다.
    translate_z(-eps)
        cylinder(h = thickness + 2 * eps, r = NEMA_shaft_dia(type) / 2 + shaft_clearance / 2);
}

// ── J2 종동축·아이들러(driven axis & idler) ───────────────────────────────
ac_driven_axis_pulley_radius = pulley_extent(ac_driven_axis_pulley_type);
ac_j2_idler_slot_center_x = ac_j2_linear_link_length / 2;
ac_j2_idler_slot_min_x    = ac_j2_idler_slot_center_x - ac_j2_idler_slot_travel / 2;
ac_j2_idler_slot_max_x    = ac_j2_idler_slot_center_x + ac_j2_idler_slot_travel / 2;
ac_j2_idler_slot_radius   = max(screw_clearance_radius(ac_j2_idler_screw_type),
                                pulley_bore(ac_j2_idler_pulley_type) / 2 + shaft_clearance / 2);
assert(ac_j2_idler_center_x >= ac_j2_idler_slot_min_x && ac_j2_idler_center_x <= ac_j2_idler_slot_max_x,
       "J2 아이들러 중심 X는 슬롯 이동 범위 안에 있어야 한다");
assert(ac_j2_idler_center_y >= pulley_extent(ac_j2_idler_pulley_type) + clearance,
       "J2 대칭 아이들러는 서로 닿지 않을 만큼 Y 오프셋이 필요하다");

// ── J1 Z축 3점 풋프린트(lead screw + 가이드 로드 2) 와 캐리지 외곽 ────────
// 가장 큰 J1 인터페이스 반경(리드넛 플랜지 vs 선형 베어링)으로 세 축의 배치 반경을 잡는다.
ac_z_shaft_radius          = max(ac_leadnut_flange_radius, ac_linear_bearing_radius);
ac_z_shaft_center_distance = ac_motor_radius + ac_z_shaft_radius + component_margin;
ac_outer_radius            = ac_z_shaft_center_distance + ac_z_shaft_radius;

// ── 평면 좌표(planar centers) ─────────────────────────────────────────────
ac_motor_center       = [0, 0];
ac_driven_axis_center = [ac_j2_linear_link_length, 0];
ac_leadnut_center     = [-ac_z_shaft_center_distance, 0];
// 리드넛은 −X, 두 가이드 로드는 ±60°로 벌려 J1 3점 지지를 이룬다.
ac_left_linear_bearing_center  = ac_z_shaft_center_distance * [cos(60),  sin(60)];
ac_right_linear_bearing_center = ac_z_shaft_center_distance * [cos(-60), sin(-60)];
ac_j2_linear_link_radius = ac_driven_axis_pulley_radius + component_margin / 2;
ac_j2_upper_idler_center = [ac_j2_idler_center_x,  ac_j2_idler_center_y];
ac_j2_lower_idler_center = [ac_j2_idler_center_x, -ac_j2_idler_center_y];
ac_j2_idler_centers = [ac_j2_upper_idler_center, ac_j2_lower_idler_center];

// ── 스탠드오프(hex standoff) 볼트서클 배치 ─────────────────────────────────
ac_standoff_body_radius            = pillar_od(ac_standoff_type) / 2;
ac_standoff_screw_clearance_radius = M3_clearance_radius;
// 벨트 슬롯 양옆에서 벨트가 차지하는 XY 폭 — 벨트 폭 절반 + 스탠드오프 몸통 + 여유.
ac_j2_belt_xy_keepout = belt_width(pulley_belt(ac_j2_idler_pulley_type)) / 2
                        + ac_standoff_body_radius + component_margin;

// J2 벨트 경로(belt path)가 차지하는 |y| 한계 — 구동축·아이들러·종동축을 잇는 사다리꼴을 x로 보간한다.
// ramp_up_x~ramp_down_x 사이는 아이들러 높이로 평평하고, 그 바깥은 모터(x=0)·종동축(x=link_length)으로 선형 감소한다.
function j2_belt_envelope_y(x, ramp_up_x, ramp_down_x) =
    (x <= ramp_up_x   ? ac_j2_idler_center_y * x / ramp_up_x
     : x >= ramp_down_x ? ac_j2_idler_center_y * (ac_j2_linear_link_length - x)
                          / (ac_j2_linear_link_length - ramp_down_x)
     : ac_j2_idler_center_y) + ac_j2_belt_xy_keepout;

// 스탠드오프 자리 적합(keepout) — 회전·고정 부품(모터·리드넛·LM8UU·종동축 풀리)과 J2 벨트 경로를 모두 비켜나면 참.
function ac_standoff_clear(c) =
       norm(c - ac_motor_center)               >= ac_motor_radius + ac_standoff_body_radius + clearance
    && norm(c - ac_leadnut_center)             >= ac_leadnut_flange_recess_radius + ac_standoff_body_radius + clearance
    && norm(c - ac_left_linear_bearing_center)  >= ac_linear_bearing_recess_radius + ac_standoff_body_radius + clearance
    && norm(c - ac_right_linear_bearing_center) >= ac_linear_bearing_recess_radius + ac_standoff_body_radius + clearance
    && norm(c - ac_driven_axis_center)         >= ac_driven_axis_pulley_radius + ac_standoff_body_radius + clearance
    && (c.x < ac_motor_center.x || c.x > ac_driven_axis_center.x
        || (abs(c.y) >= j2_belt_envelope_y(c.x, ac_j2_idler_slot_min_x, ac_j2_idler_slot_max_x)
         && abs(c.y) >= j2_belt_envelope_y(c.x, ac_j2_idler_center_x, ac_j2_idler_center_x)));

// 스탠드오프 볼트서클(bolt circle) — 캐리지 디스크 가장자리 안쪽 한 반경에 등각 후보를 두고,
// 회전·고정 부품과 벨트 경로를 침범하는 후보(특히 +x 링크/벨트 통로, −x 리드넛)는 걸러 빈 둘레만 메운다.
ac_standoff_bolt_circle_radius = ac_outer_radius + 1;
ac_standoff_candidate_count    = 10;   // 36° 등각 후보 — 키프아웃을 통과하는 점만 실제 스탠드오프가 된다
ac_standoff_centers = [
    for (i = [0 : ac_standoff_candidate_count - 1])
        let(a = i * 360 / ac_standoff_candidate_count,
            c = ac_standoff_bolt_circle_radius * [cos(a), sin(a)])
        if (ac_standoff_clear(c)) c
];

assert(len(ac_standoff_centers) >= 4,
       "스탠드오프 볼트서클에서 키프아웃을 통과하는 점이 4개 이상이어야 한다 — 반경·후보 수를 조정하라");

module arm_carriage_plate_base() {
    linear_extrude(height = ac_plate_thickness)
        difference() {
            union() {
                // 캐리지 외곽 디스크(carriage outer disc) — 모터와 J1 3점 풋프린트가 한 판에 들어가는 원형 경계.
                circle(d = ac_outer_radius * 2 + component_margin);

                // J2 선형 링크(linear link) — 모터축과 종동축을 잇는, 종동 풀리 풋프린트 폭의 직선 링크.
                hull() {
                    translate(ac_motor_center)       circle(r = ac_j2_linear_link_radius);
                    translate(ac_driven_axis_center) circle(r = ac_j2_linear_link_radius);
                }
            }

            // J1 Z축 관통 보어(through bore) — 리드스크류·가이드 로드가 자유롭게 지난다.
            translate(ac_leadnut_center)              circle(d = leadnut_bore(ac_leadnut_type) + shaft_clearance);
            translate(ac_left_linear_bearing_center)  circle(d = bearing_rod_dia(ac_linear_bearing_type) + shaft_clearance);
            translate(ac_right_linear_bearing_center) circle(d = bearing_rod_dia(ac_linear_bearing_type) + shaft_clearance);

            // J2 종동축 관통 보어(driven axis bore) — 풀리 보어(pulley bore) 기준 축 경로.
            translate(ac_driven_axis_center)
                circle(r = pulley_bore(ac_driven_axis_pulley_type) / 2 + shaft_clearance / 2);

            // J2 아이들러 조절 슬롯(idler slots) — 대칭 아이들러 축 볼트가 벨트 장력 조절을 위해 X로 미끄러진다.
            for (idler_center = ac_j2_idler_centers)
                hull() {
                    translate([ac_j2_idler_slot_min_x, idler_center.y]) circle(r = ac_j2_idler_slot_radius);
                    translate([ac_j2_idler_slot_max_x, idler_center.y]) circle(r = ac_j2_idler_slot_radius);
                }
        }
}
