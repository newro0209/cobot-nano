// assemblies/arm_carriage_assembly.scad - Renders the arm carriage (housing + plate) with all mounted vitamins for fit checks.
// Includes the shared plate-base datums so hardware placement and cut geometry use one coordinate source. The Z heights
// below are the real axial stack-up of bearings, pulleys, spacers and fasteners along each axis, checked by the asserts.
//
// 암 캐리지 조립체(arm carriage assembly) — 하우징·플레이트에 모터, 리드넛, 베어링, 풀리, 벨트, 체결구를 배치해 조립 간섭을 확인한다.
// 기본 판(base plate)의 기준 좌표를 그대로 include해 가공 형상과 같은 좌표계를 공유한다.
// 아래 Z 높이들은 각 축의 실제 축방향 스택업(axial stack-up)이며, 그 정합은 하단 assert로 검증한다.

show_hardware = true;
ac_exploded = 0; // [0:0.05:1]

include <../parts/arm_carriage_plate_base.scad>
use <../parts/arm_carriage_plate.scad>
use <../parts/arm_carriage_housing.scad>
use <NopSCADlib/vitamins/belt.scad>
use <NopSCADlib/vitamins/pillar.scad>
use <NopSCADlib/vitamins/screw.scad>
use <NopSCADlib/vitamins/nut.scad>
use <NopSCADlib/vitamins/washer.scad>
use <NopSCADlib/vitamins/linear_bearing.scad>

ac_explode_distance = 24;

// 스페이서 높이(spacer height) — 베어링 내륜과 인접 면 사이 틈에서 와셔 두께를 뺀 나머지(음수면 0).
function spacer_height(gap, washer_type) = max(0, gap - washer_thickness(washer_type));

// ── 체결 부품(fasteners) ──────────────────────────────────────────────────
ac_standoff_screw_type          = M3_cap_screw;
ac_standoff_top_screw_length    = ac_plate_thickness + abs(pillar_top_thread(ac_standoff_type));
ac_standoff_bottom_screw_length = ac_plate_thickness + abs(pillar_bot_thread(ac_standoff_type));
ac_driven_axis_shoulder_bolt_type = M6_shoulder_screw;  // 8mm 숄더가 BB608 내경에 끼워 J2 종동축 고정축(fixed pivot)이 된다
ac_driven_axis_washer_type      = screw_washer(ac_driven_axis_shoulder_bolt_type);
ac_driven_axis_locknut_type     = screw_nut(ac_driven_axis_shoulder_bolt_type);
ac_j2_idler_washer_type         = screw_washer(ac_j2_idler_screw_type);
ac_j2_idler_nut_type            = screw_nut(ac_j2_idler_screw_type);
ac_leadnut_screw_type           = leadnut_screw(ac_leadnut_type);
ac_leadnut_screw_nut_type       = screw_nut(ac_leadnut_screw_type);
ac_leadnut_screw_length = ac_plate_thickness
                          + washer_thickness(screw_washer(ac_leadnut_screw_type))
                          + nut_thickness(ac_leadnut_screw_nut_type);

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
ac_driven_axis_shoulder_bolt_length = ac_plate_top_z - ac_housing_z
                                      + washer_thickness(ac_driven_axis_washer_type)
                                      + nut_thickness(ac_driven_axis_locknut_type, nyloc = true);

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
ac_j2_idler_screw_length = ac_plate_top_z - ac_housing_z
                           + washer_thickness(ac_j2_idler_washer_type)
                           + nut_thickness(ac_j2_idler_nut_type, nyloc = true);

// ── J1 선형 베어링 Z(linear bearing) ──────────────────────────────────────
ac_linear_bearing_center_z = ac_plate_z + ac_linear_bearing_recess_depth - bearing_length(ac_linear_bearing_type) / 2;
ac_linear_bearing_top_z    = ac_linear_bearing_center_z + bearing_length(ac_linear_bearing_type) / 2;
ac_linear_bearing_bottom_z = ac_linear_bearing_center_z - bearing_length(ac_linear_bearing_type) / 2;
ac_plate_linear_bearing_recess_floor_z   = ac_plate_z + ac_linear_bearing_recess_depth;
ac_housing_linear_bearing_recess_floor_z = ac_housing_top_z - ac_linear_bearing_recess_depth;

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

// 평면 좌표 p와 높이 z로 자식(children)을 배치한다 — [c.x, c.y, z] 반복을 줄인다.
module at_xy(p, z = 0) {
    translate([p.x, p.y, z])
        children();
}

// J2 종동축 스페이서(driven axis spacer) — 숄더 볼트 둘레, 풀리와 베어링 내륜 사이 동축 링.
module ac_axis_spacer(height) {
    if (height > eps)
        color(grey(80))
            difference() {
                cylinder(h = height, r = ac_driven_axis_spacer_outer_radius);
                translate_z(-eps)
                    cylinder(h = height + eps * 2, r = ac_driven_axis_spacer_inner_radius);
            }
}

// J2 아이들러 스페이서(idler spacer) — 와셔 외경 둘레, 풀리와 판 사이 동축 링.
module ac_idler_spacer(height) {
    if (height > eps)
        color(grey(80))
            difference() {
                cylinder(h = height, r = ac_j2_idler_spacer_outer_radius);
                translate_z(-eps)
                    cylinder(h = height + eps * 2, r = ac_j2_idler_spacer_inner_radius);
            }
}

module arm_carriage_assembly() {
    let($explode = ac_exploded) {
        translate_z(ac_housing_z) arm_carriage_housing();
        translate_z(ac_plate_z)   arm_carriage_plate();

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
                            pulley(ac_motor_pulley_type);
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

            // ── J2 종동축 스택(driven axis stack) ────────────────────────────
            // 하·상 종동축 베어링.
            explode([0, 0, -ac_explode_distance])
                at_xy(ac_driven_axis_center, ac_housing_driven_axis_ball_bearing_seated_z)
                    ball_bearing(ac_driven_axis_ball_bearing_type);
            explode([0, 0, ac_explode_distance])
                at_xy(ac_driven_axis_center, ac_plate_driven_axis_ball_bearing_seated_z)
                    ball_bearing(ac_driven_axis_ball_bearing_type);

            // 숄더 볼트(shoulder bolt) — 상·하 베어링·풀리·스페이서 스택을 같은 8mm 숄더 축에 묶는다.
            explode([0, 0, ac_explode_distance])
                at_xy(ac_driven_axis_center, ac_plate_top_z + eps)
                    screw_and_washer(ac_driven_axis_shoulder_bolt_type, ac_driven_axis_shoulder_bolt_length);

            // 종동 풀리(driven pulley) — GT2 60T, 8mm 보어.
            explode([0, 0, -ac_explode_distance * 2])
                at_xy(ac_driven_axis_center, ac_driven_axis_pulley_mount_z)
                    rotate([180, 0, 0])
                        pulley(ac_driven_axis_pulley_type);

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
                at_xy(ac_driven_axis_center, ac_housing_z - washer_thickness(ac_driven_axis_washer_type))
                    washer(ac_driven_axis_washer_type);
            explode([0, 0, -ac_explode_distance])
                at_xy(ac_driven_axis_center,
                      ac_housing_z - washer_thickness(ac_driven_axis_washer_type) - nut_thickness(ac_driven_axis_locknut_type, nyloc = true))
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
                            pulley(ac_j2_idler_pulley_type);

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
                explode([0, 0, -ac_explode_distance])
                    at_xy(idler_center,
                          ac_housing_z - washer_thickness(ac_j2_idler_washer_type) - nut_thickness(ac_j2_idler_nut_type, nyloc = true))
                        nut(ac_j2_idler_nut_type, nyloc = true);
            }
        }
    }
}

arm_carriage_assembly();
