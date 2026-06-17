// assemblies/arm_carriage_assembly.scad - Renders the arm carriage (housing + plate) with all mounted vitamins for fit checks.
// Includes the shared plate-base datums so hardware placement and cut geometry use one coordinate source. The Z heights
// below are the real axial stack-up of bearings, pulleys, spacers and fasteners along each axis, checked by the asserts.
//
// 암 캐리지 조립체(arm carriage assembly) — 하우징·플레이트에 모터, 리드넛, 베어링, 풀리, 벨트, 체결구를 배치해 조립 간섭을 확인한다.
// 기본 판(base plate)의 기준 좌표를 그대로 include해 가공 형상과 같은 좌표계를 공유한다.
// 아래 Z 높이들은 각 축의 실제 축방향 스택업(axial stack-up)이며, 그 정합은 하단 assert로 검증한다.

show_hardware = true;
ac_exploded = 0; // [0:0.05:1]

// 라벨 표시 — 종류별 토글. show_labels가 전체 마스터, 아래 셋이 기능군별 on/off.
show_labels           = true;   // 라벨 전체 마스터
show_fastener_labels  = true;   // 볼트·너트·와셔·스탠드오프 등 체결구
show_structure_labels = true;   // 출력물(판·하우징·허브) + 개념상 링크·구동축/종동축/Z축
show_motion_labels    = true;   // 동적 기성품 — 모터·풀리·벨트·베어링·리드스크류

include <../parts/arm_carriage_plate_base.scad>
use <../parts/arm_carriage_plate.scad>
use <../parts/arm_carriage_housing.scad>
use <NopSCADlib/vitamins/belt.scad>
use <NopSCADlib/vitamins/pillar.scad>
use <NopSCADlib/vitamins/screw.scad>
use <NopSCADlib/vitamins/nut.scad>
use <NopSCADlib/vitamins/washer.scad>
use <NopSCADlib/vitamins/linear_bearing.scad>
use <annotations.scad>
use <../parts/j2_hub.scad>
use <NopSCADlib/vitamins/rod.scad>

ac_explode_distance = 24;
ac_bloom_gain       = 0.9;   // exploded bloom — 원점(0점)에서 거리비례로 부품을 밀어내는 배수(멀수록 더 벌어짐)

// 스페이서 높이(spacer height) — 베어링 내륜과 인접 면 사이 틈에서 와셔 두께를 뺀 나머지(음수면 0).
function spacer_height(gap, washer_type) = max(0, gap - washer_thickness(washer_type));

// ── 체결 부품(fasteners) ──────────────────────────────────────────────────
ac_standoff_screw_type          = M3_cap_screw;
// 표준 규격 길이(off-the-shelf): 판을 지나 F-F 스탠드오프 암나사에 무는 가장 긴 표준 캡스크류(바닥나지 않게 snap-down).
ac_standoff_top_screw_length    = screw_shorter_than(ac_plate_thickness + abs(pillar_top_thread(ac_standoff_type)));
ac_standoff_bottom_screw_length = screw_shorter_than(ac_plate_thickness + abs(pillar_bot_thread(ac_standoff_type)));
ac_driven_axis_shoulder_bolt_type = M6_shoulder_screw;  // 8mm 숄더가 BB608 내경에 끼워 J2 종동축 고정축(fixed pivot)이 된다
ac_driven_axis_washer_type      = screw_washer(ac_driven_axis_shoulder_bolt_type);
ac_driven_axis_locknut_type     = screw_nut(ac_driven_axis_shoulder_bolt_type);
ac_j2_idler_washer_type         = screw_washer(ac_j2_idler_screw_type);
ac_j2_idler_nut_type            = screw_nut(ac_j2_idler_screw_type);
ac_leadnut_screw_type           = leadnut_screw(ac_leadnut_type);
ac_leadnut_screw_nut_type       = screw_nut(ac_leadnut_screw_type);
// 표준 규격 길이(off-the-shelf): 너트까지 닿는 가장 짧은 표준 캡스크류(snap-up).
ac_leadnut_screw_length = screw_longer_than(ac_plate_thickness
                          + washer_thickness(screw_washer(ac_leadnut_screw_type))
                          + nut_thickness(ac_leadnut_screw_nut_type));

// ── J2 벨트 구동(belt drive) ──────────────────────────────────────────────
ac_motor_pulley_type = GT2x20um_pulley;
ac_j2_belt_type      = pulley_belt(ac_motor_pulley_type);

// ── 두 판의 Z 평면(plate / housing planes) ────────────────────────────────
ac_plate_z       = 0;
ac_plate_top_z   = ac_plate_z + ac_plate_thickness;
ac_housing_z     = ac_plate_z - ac_standoff_gap - ac_plate_thickness;
ac_housing_top_z = ac_housing_z + ac_plate_thickness;

// ── J2 모터 스택(motor stack) — 모터를 뒤집어 플레이트 리세스에 앉히고, 그 아래로 풀리가 내려간다 ──
ac_motor_local_seated_z  = ac_motor_recess_floor_z - eps;
ac_motor_seated_z        = ac_plate_z + ac_motor_local_seated_z;
ac_motor_driven_stack_z  = ac_plate_thickness - ac_motor_local_seated_z;  // 안착면에서 풀리까지 내려가는 거리
ac_motor_pulley_origin_z = ac_motor_seated_z - ac_motor_driven_stack_z;
ac_motor_pulley_bottom_z = ac_motor_pulley_origin_z - pulley_height(ac_motor_pulley_type);
ac_j2_belt_center_z      = ac_motor_pulley_origin_z + pulley_offset(ac_motor_pulley_type);

// ── J2 종동축 스택(driven axis stack) — 상·하 베어링 사이에 풀리와 스페이서를 끼운다 ──
ac_housing_driven_axis_ball_bearing_seated_z = ac_housing_z + bb_width(ac_driven_axis_ball_bearing_type) / 2 - eps;
ac_plate_driven_axis_ball_bearing_seated_z   = ac_plate_top_z - bb_width(ac_driven_axis_ball_bearing_type) / 2 + eps;
ac_driven_axis_pulley_mount_z  = ac_j2_belt_center_z - pulley_offset(ac_driven_axis_pulley_type);
ac_driven_axis_pulley_top_z    = ac_driven_axis_pulley_mount_z;
ac_driven_axis_pulley_bottom_z = ac_driven_axis_pulley_mount_z - pulley_height(ac_driven_axis_pulley_type);
ac_plate_driven_axis_bearing_bottom_z = ac_plate_driven_axis_ball_bearing_seated_z - bb_width(ac_driven_axis_ball_bearing_type) / 2;
ac_housing_driven_axis_bearing_top_z  = ac_housing_driven_axis_ball_bearing_seated_z + bb_width(ac_driven_axis_ball_bearing_type) / 2;
ac_driven_axis_upper_gap = ac_plate_driven_axis_bearing_bottom_z - ac_driven_axis_pulley_top_z;
ac_driven_axis_lower_gap = ac_driven_axis_pulley_bottom_z - ac_housing_driven_axis_bearing_top_z;
ac_driven_axis_upper_spacer_height = spacer_height(ac_driven_axis_upper_gap, ac_driven_axis_washer_type);
ac_driven_axis_lower_spacer_height = spacer_height(ac_driven_axis_lower_gap, ac_driven_axis_washer_type);
ac_driven_axis_spacer_outer_radius = 6;
ac_driven_axis_spacer_inner_radius = screw_radius(ac_driven_axis_shoulder_bolt_type) + shaft_clearance / 2;
// 표준 규격 길이(off-the-shelf): 양끝 허브를 덮고 nyloc까지 닿는 가장 짧은 표준 길이(snap-up). 여분은 너트 아래로 빠진다.
ac_driven_axis_shoulder_bolt_length = screw_longer_than(ac_plate_top_z - ac_housing_z + 2 * j2_hub_height()
                                      + washer_thickness(ac_driven_axis_washer_type)
                                      + nut_thickness(ac_driven_axis_locknut_type, nyloc = true));

// ── J2 아이들러 스택(idler stack) — 대칭 2개 ───────────────────────────────
ac_j2_idler_pulley_mount_z  = ac_j2_belt_center_z - pulley_offset(ac_j2_idler_pulley_type);
ac_j2_idler_pulley_top_z    = ac_j2_idler_pulley_mount_z;
ac_j2_idler_pulley_bottom_z = ac_j2_idler_pulley_mount_z - pulley_height(ac_j2_idler_pulley_type);
ac_j2_idler_upper_gap = ac_plate_z - ac_j2_idler_pulley_top_z;
ac_j2_idler_lower_gap = ac_j2_idler_pulley_bottom_z - ac_housing_top_z;
ac_j2_idler_upper_spacer_height = spacer_height(ac_j2_idler_upper_gap, ac_j2_idler_washer_type);
ac_j2_idler_lower_spacer_height = spacer_height(ac_j2_idler_lower_gap, ac_j2_idler_washer_type);
ac_j2_idler_spacer_outer_radius = washer_diameter(ac_j2_idler_washer_type) / 2;
ac_j2_idler_spacer_inner_radius = screw_clearance_radius(ac_j2_idler_screw_type);
// 표준 규격 길이(off-the-shelf): nyloc까지 닿는 가장 짧은 표준 M5 길이(snap-up).
ac_j2_idler_screw_length = screw_longer_than(ac_plate_top_z - ac_housing_z
                           + washer_thickness(ac_j2_idler_washer_type)
                           + nut_thickness(ac_j2_idler_nut_type, nyloc = true));

// ── J1 선형 베어링 Z(linear bearing) ──────────────────────────────────────
ac_linear_bearing_center_z = ac_plate_z + ac_linear_bearing_recess_depth - bearing_length(ac_linear_bearing_type) / 2;
ac_linear_bearing_top_z    = ac_linear_bearing_center_z + bearing_length(ac_linear_bearing_type) / 2;
ac_linear_bearing_bottom_z = ac_linear_bearing_center_z - bearing_length(ac_linear_bearing_type) / 2;
ac_plate_linear_bearing_recess_floor_z   = ac_plate_z + ac_linear_bearing_recess_depth;
ac_housing_linear_bearing_recess_floor_z = ac_housing_top_z - ac_linear_bearing_recess_depth;

// J1 Z축 샤프트(lead screw + 가이드 샤프트) — 카메라가 타고 오르내리는 고정 가이드. 상단을 상판 위로 빼고 베이스 방향(아래)으로 연장한다.
ac_j1_shaft_length   = 160;
ac_j1_shaft_center_z = ac_plate_top_z + 20 - ac_j1_shaft_length / 2;

// ── 조립 정합 검증(fit asserts) ───────────────────────────────────────────
assert(ac_j2_belt_type == pulley_belt(ac_driven_axis_pulley_type),
       "J2 구동 풀리와 종동 풀리는 같은 벨트 타입이어야 한다");
assert(ac_j2_belt_type == pulley_belt(ac_j2_idler_pulley_type),
       "J2 아이들러 풀리는 구동 풀리와 같은 벨트 타입이어야 한다");
assert(abs(ac_linear_bearing_top_z - ac_plate_linear_bearing_recess_floor_z) <= eps,
       "선형 베어링 상단은 플레이트 하부 리세스 바닥에 맞아야 한다");
assert(abs(ac_linear_bearing_bottom_z - ac_housing_linear_bearing_recess_floor_z) <= eps,
       "선형 베어링 하단은 하우징 상부 리세스 바닥에 맞아야 한다");
assert(ac_housing_top_z <= min(ac_motor_pulley_bottom_z, ac_driven_axis_pulley_bottom_z, ac_j2_idler_pulley_bottom_z) - clearance,
       "하우징 윗면은 J2 풀리 아래로 clearance 이상 떨어져야 한다");
assert(ac_driven_axis_upper_gap >= washer_thickness(ac_driven_axis_washer_type),
       "J2 종동축 상부 베어링과 풀리 사이에는 와셔 공간이 필요하다");
assert(ac_driven_axis_lower_gap >= washer_thickness(ac_driven_axis_washer_type),
       "J2 종동축 하부 베어링과 풀리 사이에는 와셔 공간이 필요하다");
assert(ac_j2_idler_upper_gap >= washer_thickness(ac_j2_idler_washer_type),
       "J2 아이들러 상부에는 와셔 공간이 필요하다");
assert(ac_j2_idler_lower_gap >= washer_thickness(ac_j2_idler_washer_type),
       "J2 아이들러 하부에는 와셔 공간이 필요하다");

// ── 부품 렌더 색(part colours) ─────────────────────────────────────────────
// 라벨이 대상과 같은 색을 쓰도록 색을 한 곳에서 정의해 그리기·라벨이 공유한다(label_colour는 파일 하단 정의, 함수라 순서 무관).
// 내가 색을 지정하는 출력물·풀리는 기능색(label_colour) + 톤. NopSCADlib 기성품은 내부 고정색이라 재질색으로 근사한다.
ac_col_plate          = label_shade(label_colour("printed"), 0.00);   // 상판 = J2 링크(가장 진한 블루)
ac_col_hub            = label_shade(label_colour("printed"), 0.25);
ac_col_housing        = label_shade(label_colour("printed"), 0.45);
ac_col_driven_bushing = label_shade(label_colour("printed"), 0.70);
ac_col_idler_bushing  = label_shade(label_colour("printed"), 0.85);
ac_col_motor_pulley   = label_shade(label_colour("transmission"), 0.20);
ac_col_driven_pulley  = label_shade(label_colour("transmission"), 0.50);
ac_col_idler_pulley   = label_shade(label_colour("transmission"), 0.80);
ac_col_steel   = [0.70, 0.72, 0.75];   // 스테인리스/크롬 — 체결구·리드스크류·리니어 샤프트
ac_col_bearing = [0.40, 0.41, 0.43];   // 볼·리니어 베어링(흑색 실드 + 강체)
ac_col_motor   = [0.32, 0.32, 0.34];   // 스테퍼 모터 바디
ac_col_belt    = [0.16, 0.16, 0.16];   // GT2 고무 벨트
ac_col_leadnut = [0.62, 0.63, 0.65];   // 리드넛
ac_col_concept = label_shade(label_colour("printed"), 0.00);   // 관절/축/링크 개념 라벨 = 구조 블루

// 라벨 점의 현재 위치 — 부품과 똑같은 변환을 적용해 exploded에서도 라벨이 부품을 따라간다.
// bloom이면 원점에서 거리비례로 밀고(at_xy와 동일), ez만큼 Z로 분해(explode와 동일)한다.
function label_point(target, bloom, ez, e) =
    (bloom ? target * (1 + ac_bloom_gain * e) : target) + [0, 0, ez * e];

// 평면 좌표 p와 높이 z로 자식(children)을 배치한다. exploded 시 원점(0점)에서 거리비례로 밀어내 멀수록 더 벌어진다.
module at_xy(p, z = 0) {
    explode = is_undef($explode) ? 0 : $explode;
    translate([p.x, p.y, z] * (1 + ac_bloom_gain * explode))
        children();
}

// J2 종동축 프린트 부싱(printed bushing) — 숄더 볼트 둘레, 풀리와 베어링 내륜 사이 동축 링.
module ac_axis_spacer(height) {
    if (height >= min_printed_feature)   // 인쇄 가능한 두께만 부싱으로 출력, 더 얇으면 와셔가 흡수
        color(ac_col_driven_bushing)   // 3D 프린트 출력물(블루 톤온톤)
            difference() {
                cylinder(h = height, r = ac_driven_axis_spacer_outer_radius);
                translate_z(-eps)
                    cylinder(h = height + eps * 2, r = ac_driven_axis_spacer_inner_radius);
            }
}

// J2 아이들러 프린트 부싱(printed bushing) — 와셔 외경 둘레, 풀리와 판 사이 동축 링.
module ac_idler_spacer(height) {
    if (height >= min_printed_feature)   // 인쇄 가능한 두께만 부싱으로 출력, 더 얇으면 와셔가 흡수
        color(ac_col_idler_bushing)   // 3D 프린트 출력물(블루 톤온톤)
            difference() {
                cylinder(h = height, r = ac_j2_idler_spacer_outer_radius);
                translate_z(-eps)
                    cylinder(h = height + eps * 2, r = ac_j2_idler_spacer_inner_radius);
            }
}

module arm_carriage_assembly() {
    let($explode = ac_exploded) {
        // 파츠 색도 라벨과 같은 기능별 톤온톤 — 3D 프린트 출력물은 블루 계열, 부품마다 다른 톤(링크인 상판이 가장 진함).
        color(ac_col_housing) translate_z(ac_housing_z) arm_carriage_housing();
        color(ac_col_plate)   translate_z(ac_plate_z)   arm_carriage_plate();

        // J2 상완 허브(upper-arm hub) — 상판 위·하우징 아래로 상완을 연결. 내륜 보스만큼 띄워 회전 내륜에 물려 돈다.
        color(ac_col_hub) {
            at_xy(ac_driven_axis_center, ac_plate_top_z + j2_hub_boss_height()) j2_hub();
            at_xy(ac_driven_axis_center, ac_housing_z - j2_hub_boss_height()) rotate([180, 0, 0]) j2_hub();
        }

        if (show_hardware) {
            // ── 판 사이 스탠드오프(hex standoffs)와 상·하 체결 스크류 ──────────
            for (standoff_center = ac_standoff_centers)
                at_xy(standoff_center, ac_housing_top_z)
                    pillar(ac_standoff_type);

            explode([0, 0, ac_explode_distance])
                for (standoff_center = ac_standoff_centers)
                    at_xy(standoff_center, ac_plate_top_z + eps)
                        screw_and_washer(ac_standoff_screw_type, ac_standoff_top_screw_length, true);

            explode([0, 0, -ac_explode_distance])
                for (standoff_center = ac_standoff_centers)
                    at_xy(standoff_center, ac_housing_z - eps)
                        rotate([180, 0, 0])
                            screw_and_washer(ac_standoff_screw_type, ac_standoff_bottom_screw_length, true);

            // ── J2 구동 모터(drive motor)와 모터 풀리 ────────────────────────
            explode([0, 0, ac_explode_distance])
                at_xy(ac_motor_center, ac_motor_seated_z)
                    rotate([180, 0, 0])
                        // 모터 플랜지(motor flange)가 리세스 바닥에 안착하는 좌표.
                        NEMA(ac_motor_type);

            explode([0, 0, -ac_explode_distance])
                at_xy(ac_motor_center, ac_motor_seated_z)
                    rotate([180, 0, 0])
                        translate_z(ac_motor_driven_stack_z) {
                            // 샤프트 방향으로 내려가는 스크류·풀리 스택 — 풀리 간섭 검증.
                            NEMA_screws(ac_motor_type, M3_cap_screw);
                            pulley(ac_motor_pulley_type, colour = ac_col_motor_pulley);
                        }

            if (ac_exploded == 0)
                // J2 타이밍 벨트(timing belt) — 모터·아이들러·종동 풀리를 같은 벨트 중심 높이에 둔다.
                translate_z(ac_j2_belt_center_z)
                    belt(ac_j2_belt_type, [
                        [ac_motor_center.x,          ac_motor_center.y,          ac_motor_pulley_type],
                        [ac_j2_upper_idler_center.x, ac_j2_upper_idler_center.y, ac_j2_idler_pulley_type],
                        [ac_driven_axis_center.x,    ac_driven_axis_center.y,    ac_driven_axis_pulley_type],
                        [ac_j2_lower_idler_center.x, ac_j2_lower_idler_center.y, ac_j2_idler_pulley_type],
                    ]);

            // ── J1 리드넛(leadnut) — 플레이트·하우징 하부 장착 ───────────────
            explode([0, 0, -ac_explode_distance])
                at_xy(ac_leadnut_center, ac_plate_z + eps) {
                    leadnut(ac_leadnut_type);
                    leadnut_screw_positions(ac_leadnut_type)
                        translate_z(-ac_leadnut_flange_thickness - eps)
                            rotate([180, 0, 0])
                                screw_and_washer(ac_leadnut_screw_type, ac_leadnut_screw_length, true);
                }

            explode([0, 0, ac_explode_distance])
                at_xy(ac_leadnut_center, ac_plate_top_z + eps)
                    leadnut_screw_positions(ac_leadnut_type)
                        translate_z(-ac_leadnut_flange_thickness)
                            nut(ac_leadnut_screw_nut_type);

            explode([0, 0, -ac_explode_distance])
                at_xy(ac_leadnut_center, ac_housing_z + eps) {
                    leadnut(ac_leadnut_type);
                    leadnut_screw_positions(ac_leadnut_type)
                        translate_z(-ac_leadnut_flange_thickness - eps)
                            rotate([180, 0, 0])
                                screw_and_washer(ac_leadnut_screw_type, ac_leadnut_screw_length, true);
                }

            explode([0, 0, -ac_explode_distance])
                at_xy(ac_leadnut_center, ac_housing_top_z + eps)
                    leadnut_screw_positions(ac_leadnut_type)
                        translate_z(-ac_leadnut_flange_thickness)
                            nut(ac_leadnut_screw_nut_type);

            // ── J1 선형 베어링(LM8UU) — 두 판 사이 양쪽 리세스 바닥에 맞춤 ────
            explode([0, 0, -ac_explode_distance])
                for (bearing_center = [ac_left_linear_bearing_center, ac_right_linear_bearing_center])
                    at_xy(bearing_center, ac_linear_bearing_center_z)
                        linear_bearing(ac_linear_bearing_type);

            // ── J1 Z축 샤프트(lead screw + 가이드 샤프트) — 고정 가이드. explode에서 bloom하지 않고 기준으로 남는다.
            // T8 트라페조이드 리드 스크류(trapezoidal lead screw, Tr8x2) — 리드넛 LSN8x2가 타고 Z 병진. lead·start는 리드넛에서 읽는다.
            translate([ac_leadnut_center.x, ac_leadnut_center.y, ac_j1_shaft_center_z])
                leadscrew(leadnut_bore(ac_leadnut_type), ac_j1_shaft_length,
                          leadnut_lead(ac_leadnut_type),
                          leadnut_lead(ac_leadnut_type) / leadnut_pitch(ac_leadnut_type));
            // Ø8 리니어 샤프트(linear shaft, smooth rod) — LM8UU 볼 부싱(ball bushing)이 직선 안내된다. 프로파일 레일이 아니다.
            for (shaft_center = [ac_left_linear_bearing_center, ac_right_linear_bearing_center])
                translate([shaft_center.x, shaft_center.y, ac_j1_shaft_center_z])
                    rod(bearing_rod_dia(ac_linear_bearing_type), ac_j1_shaft_length);

            // ── J2 종동축 스택(driven axis stack) ────────────────────────────
            // 하·상 종동축 베어링.
            explode([0, 0, -ac_explode_distance])
                at_xy(ac_driven_axis_center, ac_housing_driven_axis_ball_bearing_seated_z)
                    ball_bearing(ac_driven_axis_ball_bearing_type);
            explode([0, 0, ac_explode_distance])
                at_xy(ac_driven_axis_center, ac_plate_driven_axis_ball_bearing_seated_z)
                    ball_bearing(ac_driven_axis_ball_bearing_type);

            // 숄더 볼트(shoulder bolt) — 상·하 허브·베어링·풀리·스페이서 스택을 같은 8mm 숄더 축에 묶는다. 머리는 상부 허브 위에 앉는다.
            explode([0, 0, ac_explode_distance])
                at_xy(ac_driven_axis_center, ac_plate_top_z + j2_hub_height() + eps)
                    screw_and_washer(ac_driven_axis_shoulder_bolt_type, ac_driven_axis_shoulder_bolt_length);

            // 종동 풀리(driven pulley) — GT2 60T, 8mm 보어.
            explode([0, 0, -ac_explode_distance * 2])
                at_xy(ac_driven_axis_center, ac_driven_axis_pulley_mount_z)
                    rotate([180, 0, 0])
                        pulley(ac_driven_axis_pulley_type, colour = ac_col_driven_pulley);

            // 상부 스페이서/와셔 — 상부 베어링 내륜과 풀리 사이 간격을 채운다.
            at_xy(ac_driven_axis_center, ac_driven_axis_pulley_top_z) {
                ac_axis_spacer(ac_driven_axis_upper_spacer_height);
                translate_z(ac_driven_axis_upper_spacer_height)
                    washer(ac_driven_axis_washer_type);
            }

            // 하부 와셔/스페이서 — 하부 베어링 내륜과 풀리 사이 간격을 채운다.
            at_xy(ac_driven_axis_center, ac_housing_driven_axis_bearing_top_z) {
                washer(ac_driven_axis_washer_type);
                translate_z(washer_thickness(ac_driven_axis_washer_type))
                    ac_axis_spacer(ac_driven_axis_lower_spacer_height);
            }

            // 락너트(locknut) — 하우징 바닥면에서 숄더 볼트를 잠근다.
            explode([0, 0, -ac_explode_distance])
                at_xy(ac_driven_axis_center, ac_housing_z - j2_hub_height() - washer_thickness(ac_driven_axis_washer_type))
                    washer(ac_driven_axis_washer_type);
            // nyloc 칼라가 아래(바깥)를 향하도록 뒤집어 베어링 면이 와셔에 닿게 한다.
            explode([0, 0, -ac_explode_distance])
                at_xy(ac_driven_axis_center, ac_housing_z - j2_hub_height() - washer_thickness(ac_driven_axis_washer_type))
                    rotate([180, 0, 0])
                        nut(ac_driven_axis_locknut_type, nyloc = true);

            // ── J2 아이들러(idler) — 대칭 2개, 슬롯 조절 + 하우징 하부 락너트 ──
            for (idler_center = ac_j2_idler_centers) {
                // 조절 볼트(adjustment bolt) — 슬롯에서 축 위치를 옮긴 뒤 하우징 하부 락너트로 고정.
                explode([0, 0, ac_explode_distance])
                    at_xy(idler_center, ac_plate_top_z + eps)
                        screw_and_washer(ac_j2_idler_screw_type, ac_j2_idler_screw_length);

                // 상부 스페이서 — 플레이트와 풀리 베어링 내륜 사이를 채워 클램프 하중을 전달.
                at_xy(idler_center, ac_j2_idler_pulley_top_z) {
                    washer(ac_j2_idler_washer_type);
                    translate_z(washer_thickness(ac_j2_idler_washer_type))
                        ac_idler_spacer(ac_j2_idler_upper_spacer_height);
                }

                // 아이들러 풀리 — 구동축과 종동축 사이에서 대칭 벨트 경로를 만든다.
                explode([0, 0, -ac_explode_distance * 2])
                    at_xy(idler_center, ac_j2_idler_pulley_mount_z)
                        rotate([180, 0, 0])
                            pulley(ac_j2_idler_pulley_type, colour = ac_col_idler_pulley);

                // 하부 스페이서 — 하우징과 풀리 베어링 내륜 사이를 지지.
                at_xy(idler_center, ac_housing_top_z) {
                    ac_idler_spacer(ac_j2_idler_lower_spacer_height);
                    translate_z(ac_j2_idler_lower_spacer_height)
                        washer(ac_j2_idler_washer_type);
                }

                // 락너트(locknut) — 슬롯 조정 후 축 볼트를 풀림 없이 잠근다.
                explode([0, 0, -ac_explode_distance])
                    at_xy(idler_center, ac_housing_z - washer_thickness(ac_j2_idler_washer_type))
                        washer(ac_j2_idler_washer_type);
                // nyloc 칼라가 아래(바깥)를 향하도록 뒤집어 베어링 면이 와셔에 닿게 한다.
                explode([0, 0, -ac_explode_distance])
                    at_xy(idler_center, ac_housing_z - washer_thickness(ac_j2_idler_washer_type))
                        rotate([180, 0, 0])
                            nut(ac_j2_idler_nut_type, nyloc = true);
            }
        }
    }
}

arm_carriage_assembly();

// 기능 기준색(base hue) — 출력물·풀리 색의 바탕이며, ac_col_* 가 여기에 톤을 입혀 실제 렌더 색을 만든다.
function label_colour(group) =
    group == "printed"      ? [0.15, 0.42, 0.82] :  // 파랑 — 출력물(판·하우징·허브·부싱)을 한 계열로 묶는다.
    group == "transmission" ? [0.88, 0.50, 0.12] :  // 주황 — 동력 전달 풀리를 한 계열로 묶는다.
                              [0, 0, 0];

// 표시 토글 — 라벨 데이터에 명시한 category로 직접 켜고 끈다(분류는 각 라벨에서 손으로 지정한다).
function label_visible(category) =
    category == "fastener"  ? show_fastener_labels  :
    category == "structure" ? show_structure_labels :
                              show_motion_labels;

// 부품 라벨 데이터 — [텍스트, 점 리스트, category, 강조, bloom, ez, 색].
//   점 리스트 : 같은 부품의 모든 인스턴스 좌표. 여러 개면 점마다 지시선을 그어 설명서처럼 전부 가리킨다.
//   category  : 표시 토글 분류 — structure(구조·관절·축·링크) / motion(동적 기성품) / fastener(체결구·부싱).
//   강조      : 관절·축·링크 같은 개념 요소면 true로 둬 굵은 지시선·볼드로 강조한다.
//   bloom·ez  : 부품이 받는 변환(bloom=at_xy 거리비례 분해, ez=explode Z거리)을 라벨 점에도 적용해 exploded에서 따라가게 한다.
//   색        : 대상 부품을 그린 색(ac_col_*)과 같게 줘 라벨이 어느 부품인지 색으로도 잇는다.
ac_part_labels = [
    // ── 운동 체인 개념(kinematic concepts) — 관절·축·링크를 빠짐없이 단다. 개념이라 분해하지 않는다. ──
    ["J1 — Z prismatic joint",       [[ac_leadnut_center.x, ac_leadnut_center.y, ac_plate_top_z + 26]], "structure", true, false, 0, ac_col_concept],
    ["J2 — shoulder revolute joint", [[ac_driven_axis_center.x, 0, ac_plate_top_z + 22]],               "structure", true, false, 0, ac_col_concept],
    ["J2 idler axis",                [[ac_j2_upper_idler_center.x, ac_j2_upper_idler_center.y, ac_plate_top_z + 18]], "structure", true, false, 0, ac_col_concept],

    // ── 구조 출력물(printed structure) — 링크·프레임이라 structure로 둔다. ──
    ["Carriage plate (J2 link)",   [[-24, 30, ac_plate_top_z]],   "structure", true,  false, 0, ac_col_plate],
    ["Housing (J1 carriage)",      [[-32, -22, ac_housing_z]],    "structure", false, false, 0, ac_col_housing],
    ["J2 hub (upper-arm link) x2", [[ac_driven_axis_center.x, 0, ac_plate_top_z + 3], [ac_driven_axis_center.x, 0, ac_housing_z - 3]], "structure", true, true, 0, ac_col_hub],
    ["8mm linear shaft x2",        [for (c = [ac_left_linear_bearing_center, ac_right_linear_bearing_center]) [c.x, c.y, ac_plate_top_z + 16]], "structure", false, false, 0, ac_col_steel],

    // ── 동적 기성품(dynamic vitamins) — 회전·이동하는 기성품(모터·풀리·벨트·베어링·이송나사)이라 motion으로 둔다. ──
    ["NEMA17 motor",          [[0, 0, ac_plate_top_z + 32]], "motion", false, true,  ac_explode_distance,      ac_col_motor],
    ["GT2x20 motor pulley",   [[0, -8, ac_j2_belt_center_z]], "motion", false, true, -ac_explode_distance,     ac_col_motor_pulley],
    ["GT2 belt",              [[ac_j2_idler_slot_center_x, ac_j2_belt_xy_keepout + 8, ac_j2_belt_center_z]], "motion", false, false, 0, ac_col_belt],
    ["GT2x60 driven pulley",  [[ac_driven_axis_center.x, -8, ac_driven_axis_pulley_mount_z]], "motion", false, true, -2 * ac_explode_distance, ac_col_driven_pulley],
    ["GT2x20 idler (5mm bearing) x2", [for (c = ac_j2_idler_centers) [c.x, c.y, ac_j2_idler_pulley_mount_z]], "motion", false, true, -2 * ac_explode_distance, ac_col_idler_pulley],
    ["BB608 (upper)",         [[ac_driven_axis_center.x + 11, 0, ac_plate_driven_axis_ball_bearing_seated_z]], "motion", false, true,  ac_explode_distance, ac_col_bearing],
    ["BB608 (lower)",         [[ac_driven_axis_center.x + 11, 0, ac_housing_driven_axis_ball_bearing_seated_z]], "motion", false, true, -ac_explode_distance, ac_col_bearing],
    ["LM8UU x2",              [for (c = [ac_left_linear_bearing_center, ac_right_linear_bearing_center]) [c.x, c.y, ac_linear_bearing_center_z]], "motion", false, true, -ac_explode_distance, ac_col_bearing],
    ["T8x2 lead screw",       [[ac_leadnut_center.x, ac_leadnut_center.y, ac_plate_top_z + 16]], "motion", false, false, 0, ac_col_steel],

    // ── 체결구(fasteners) — 모든 인스턴스에 지시선을 달아 설명서처럼 전부 가리킨다. 부싱(출력 스페이서)도 체결 보조라 여기 둔다. ──
    [str("M3x20 hex standoff x", len(ac_standoff_centers)),     [for (c = ac_standoff_centers) [c.x, c.y, (ac_plate_z + ac_housing_top_z) / 2]], "fastener", false, true, 0, ac_col_steel],
    [str("M3x16 screw + star washer (top) x", len(ac_standoff_centers)), [for (c = ac_standoff_centers) [c.x, c.y, ac_plate_top_z + 4]], "fastener", false, true,  ac_explode_distance, ac_col_steel],
    [str("M3x16 screw + star washer (bot) x", len(ac_standoff_centers)), [for (c = ac_standoff_centers) [c.x, c.y, ac_housing_z - 4]],    "fastener", false, true, -ac_explode_distance, ac_col_steel],
    ["M3 cap screw (motor) x4",            [for (x = NEMA_holes(ac_motor_type)) for (y = NEMA_holes(ac_motor_type)) [x, y, ac_plate_top_z]], "fastener", false, true, -ac_explode_distance, ac_col_steel],
    ["M3 screw + washer (leadnut) x8",     [for (z = [ac_plate_z - 1, ac_housing_z + 1]) for (i = [0 : leadnut_holes(ac_leadnut_type) - 1]) let(a = i * 360 / leadnut_holes(ac_leadnut_type), r = leadnut_hole_pitch(ac_leadnut_type)) [ac_leadnut_center.x + r * cos(a), ac_leadnut_center.y + r * sin(a), z]], "fastener", false, true, -ac_explode_distance, ac_col_steel],
    ["M3 nut (leadnut) x8",                [for (z = [ac_plate_top_z + 1, ac_housing_top_z + 1]) for (i = [0 : leadnut_holes(ac_leadnut_type) - 1]) let(a = i * 360 / leadnut_holes(ac_leadnut_type), r = leadnut_hole_pitch(ac_leadnut_type)) [ac_leadnut_center.x + r * cos(a), ac_leadnut_center.y + r * sin(a), z]], "fastener", false, true, 0, ac_col_steel],
    ["M6 shoulder bolt (J2 pivot)",        [[ac_driven_axis_center.x, 0, ac_plate_top_z + 4]], "fastener", false, true, ac_explode_distance, ac_col_steel],
    ["M8 washer (under bolt head)",        [[ac_driven_axis_center.x, 0, ac_plate_top_z + 1.5]], "fastener", false, true, ac_explode_distance, ac_col_steel],
    ["M8 washer (upper bearing)",          [[ac_driven_axis_center.x + 4, 0, ac_driven_axis_pulley_top_z + ac_driven_axis_upper_spacer_height + 0.5]], "fastener", false, true, 0, ac_col_steel],
    ["M8 washer (lower bearing)",          [[ac_driven_axis_center.x + 4, 0, ac_housing_driven_axis_bearing_top_z + 0.5]], "fastener", false, true, 0, ac_col_steel],
    ["M8 washer (under nut)",              [[ac_driven_axis_center.x, 0, ac_housing_z - 0.5]], "fastener", false, true, -ac_explode_distance, ac_col_steel],
    ["M6 nyloc nut",                       [[ac_driven_axis_center.x, 0, ac_housing_z - 5]], "fastener", false, true, -ac_explode_distance, ac_col_steel],
    ["Driven bushing",                     [[ac_driven_axis_center.x, 0, ac_housing_driven_axis_bearing_top_z + 2]], "fastener", false, true, 0, ac_col_driven_bushing],
    ["M5 screw + washer (idler axle) x2",  [for (c = ac_j2_idler_centers) [c.x, c.y, ac_plate_top_z + 3]], "fastener", false, true, ac_explode_distance, ac_col_steel],
    ["M5 washer (idler upper) x2",         [for (c = ac_j2_idler_centers) [c.x + 3, c.y, ac_j2_idler_pulley_top_z + 0.5]], "fastener", false, true, 0, ac_col_steel],
    ["M5 washer (idler lower) x2",         [for (c = ac_j2_idler_centers) [c.x + 3, c.y, ac_housing_top_z + 0.5]], "fastener", false, true, 0, ac_col_steel],
    ["M5 washer (under nut) x2",           [for (c = ac_j2_idler_centers) [c.x, c.y, ac_housing_z - 0.5]], "fastener", false, true, -ac_explode_distance, ac_col_steel],
    ["M5 nyloc nut (idler) x2",            [for (c = ac_j2_idler_centers) [c.x, c.y, ac_housing_z - 5]], "fastener", false, true, -ac_explode_distance, ac_col_steel],
    ["Idler bushing x2",                   [for (c = ac_j2_idler_centers) [c.x, c.y, ac_j2_idler_pulley_top_z + 1]], "fastener", false, true, 0, ac_col_idler_bushing],
];

// 화면투영 기준점(라벨 열의 중심). 열 가로 오프셋 하한은 정지 실루엣 디스크 반경 밖에 둔다 — callout_field가 exploded 확산에 맞춰 더 키운다.
ac_label_center = [0, 0, (ac_plate_top_z + ac_housing_z) / 2];
ac_label_min_halfw = ac_outer_radius + 14;

// 표시 토글(show_*)로 보일 라벨만 추리고, 각 인스턴스 점을 부품과 같은 변환(label_point)으로 옮겨 exploded에서도 부품을 따라가게 한다.
if (show_labels)
    let(e = ac_exploded,
        items = [for (spec = ac_part_labels)
            if (label_visible(spec[2]))
                [spec[0], [for (p = spec[1]) label_point(p, spec[4], spec[5], e)], spec[6], spec[3]]])
        callout_field(items, ac_label_center, ac_label_min_halfw);

// J2 축 조립 순서 체인(stack sequence) — 숄더 볼트(맨 위) → ... → 너트(맨 아래)까지 끼우는 순서.
// 자동 callout 라벨과 겹치는 포커스 오버레이라 기본 off. J2 조립 순서만 볼 때 켠다(callout은 끄고 보길 권장).
show_j2_stack = false;
ac_j2_stack = [
    ["M6 shoulder bolt", ac_plate_top_z + 6],
    ["M8 washer",        ac_plate_top_z + 1],
    ["BB608 (upper)",    ac_plate_driven_axis_ball_bearing_seated_z],
    ["spacer + washer",  ac_driven_axis_pulley_top_z + 2],
    ["GT2x60 pulley",    ac_driven_axis_pulley_mount_z],
    ["washer + spacer",  ac_housing_driven_axis_bearing_top_z + 2],
    ["BB608 (lower)",    ac_housing_driven_axis_ball_bearing_seated_z],
    ["M8 washer",        ac_housing_z - 1],
    ["M6 nyloc nut",     ac_housing_z - 6],
];
if (show_j2_stack)
    stack_sequence(ac_j2_stack, ac_driven_axis_center,
                   label_x = ac_driven_axis_center.x + 42,
                   top_z = ac_plate_top_z + 24, bottom_z = ac_housing_z - 12);
