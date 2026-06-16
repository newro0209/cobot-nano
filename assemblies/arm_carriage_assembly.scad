// assemblies/arm_carriage_assembly.scad - Renders the arm carriage housing with mounted vitamins for fit checks.
// The assembly includes the shared plate base datums so hardware placement and cut geometry use one coordinate source.
//
// 암 캐리지 조립체(arm carriage assembly)에 모터, 리드넛, 베어링을 배치해 조립 간섭을 확인한다.
// 하드웨어 배치(hardware placement)는 기본 판(base plate)의 기준 좌표를 그대로 include해 같은 좌표계를 공유한다.

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
ac_standoff_screw_type = M3_cap_screw;
ac_standoff_top_screw_length = ac_thickness + abs(pillar_top_thread(ac_standoff_type));
ac_standoff_bottom_screw_length = ac_thickness + abs(pillar_bot_thread(ac_standoff_type));
ac_driven_axis_stripper_bolt_type = M6_shoulder_screw;
ac_driven_axis_washer_type = screw_washer(ac_driven_axis_stripper_bolt_type);
ac_driven_axis_locknut_type = screw_nut(ac_driven_axis_stripper_bolt_type);
ac_j2_idler_washer_type = screw_washer(ac_j2_idler_screw_type);
ac_j2_idler_nut_type = screw_nut(ac_j2_idler_screw_type);
ac_plate_z = 0;
ac_plate_top_z = ac_plate_z + ac_thickness;
ac_housing_z = ac_plate_z - ac_standoff_gap - ac_thickness;
ac_housing_top_z = ac_housing_z + ac_thickness;
ac_motor_pulley_type = GT2x20um_pulley;
ac_j2_belt_type = pulley_belt(ac_motor_pulley_type);
ac_motor_local_seated_z = ac_motor_recess_floor_z - boolean_epsilon;
ac_motor_mount_z = ac_plate_z + ac_motor_recess_floor_z;
ac_motor_seated_z = ac_plate_z + ac_motor_local_seated_z;
ac_motor_driven_stack_z = ac_thickness - ac_motor_local_seated_z;
ac_motor_pulley_origin_z = ac_motor_seated_z - ac_motor_driven_stack_z;
ac_j2_belt_center_z = ac_motor_pulley_origin_z + pulley_offset(ac_motor_pulley_type);
ac_plate_leadnut_mount_z = ac_plate_z;
ac_plate_leadnut_seated_z = ac_plate_leadnut_mount_z + boolean_epsilon;
ac_housing_leadnut_mount_z = ac_housing_z;
ac_housing_leadnut_seated_z = ac_housing_leadnut_mount_z + boolean_epsilon;
ac_leadnut_screw_type = leadnut_screw(ac_leadnut_type);
ac_leadnut_screw_nut_type = screw_nut(ac_leadnut_screw_type);
ac_leadnut_screw_length = ac_thickness
                         + washer_thickness(screw_washer(ac_leadnut_screw_type))
                         + nut_thickness(ac_leadnut_screw_nut_type);
ac_housing_driven_axis_ball_bearing_seated_z = ac_housing_z + bb_width(ac_driven_axis_ball_bearing_type) / 2 - boolean_epsilon;
ac_plate_driven_axis_ball_bearing_seated_z = ac_plate_top_z - bb_width(ac_driven_axis_ball_bearing_type) / 2 + boolean_epsilon;
ac_driven_axis_pulley_mount_z = ac_j2_belt_center_z - pulley_offset(ac_driven_axis_pulley_type);
ac_j2_idler_pulley_mount_z = ac_j2_belt_center_z - pulley_offset(ac_j2_idler_pulley_type);
ac_driven_axis_stripper_bolt_length = ac_plate_top_z - ac_housing_z
                                      + washer_thickness(ac_driven_axis_washer_type)
                                      + nut_thickness(ac_driven_axis_locknut_type, nyloc = true);
ac_j2_idler_screw_length = ac_plate_top_z - ac_housing_z
                           + washer_thickness(ac_j2_idler_washer_type)
                           + nut_thickness(ac_j2_idler_nut_type, nyloc = true);
ac_linear_bearing_center_z = ac_plate_z + ac_linear_bearing_recess_depth - bearing_length(ac_linear_bearing_type) / 2;
ac_linear_bearing_top_z = ac_linear_bearing_center_z + bearing_length(ac_linear_bearing_type) / 2;
ac_linear_bearing_bottom_z = ac_linear_bearing_center_z - bearing_length(ac_linear_bearing_type) / 2;
ac_plate_linear_bearing_recess_floor_z = ac_plate_z + ac_linear_bearing_recess_depth;
ac_housing_linear_bearing_recess_floor_z = ac_housing_top_z - ac_linear_bearing_recess_depth;
ac_motor_pulley_bottom_z = ac_motor_pulley_origin_z - pulley_height(ac_motor_pulley_type);
ac_driven_axis_pulley_bottom_z = ac_driven_axis_pulley_mount_z - pulley_height(ac_driven_axis_pulley_type);
ac_j2_idler_pulley_bottom_z = ac_j2_idler_pulley_mount_z - pulley_height(ac_j2_idler_pulley_type);
ac_j2_idler_pulley_top_z = ac_j2_idler_pulley_mount_z;
ac_j2_idler_upper_gap = ac_plate_z - ac_j2_idler_pulley_top_z;
ac_j2_idler_lower_gap = ac_j2_idler_pulley_bottom_z - ac_housing_top_z;
ac_j2_idler_upper_spacer_height = max(0, ac_j2_idler_upper_gap - washer_thickness(ac_j2_idler_washer_type));
ac_j2_idler_lower_spacer_height = max(0, ac_j2_idler_lower_gap - washer_thickness(ac_j2_idler_washer_type));
ac_j2_idler_spacer_outer_radius = washer_diameter(ac_j2_idler_washer_type) / 2;
ac_j2_idler_spacer_inner_radius = screw_clearance_radius(ac_j2_idler_screw_type);
ac_driven_axis_pulley_top_z = ac_driven_axis_pulley_mount_z;
ac_plate_driven_axis_bearing_bottom_z = ac_plate_driven_axis_ball_bearing_seated_z - bb_width(ac_driven_axis_ball_bearing_type) / 2;
ac_housing_driven_axis_bearing_top_z = ac_housing_driven_axis_ball_bearing_seated_z + bb_width(ac_driven_axis_ball_bearing_type) / 2;
ac_driven_axis_upper_gap = ac_plate_driven_axis_bearing_bottom_z - ac_driven_axis_pulley_top_z;
ac_driven_axis_lower_gap = ac_driven_axis_pulley_bottom_z - ac_housing_driven_axis_bearing_top_z;
ac_driven_axis_upper_spacer_height = max(0, ac_driven_axis_upper_gap - washer_thickness(ac_driven_axis_washer_type));
ac_driven_axis_lower_spacer_height = max(0, ac_driven_axis_lower_gap - washer_thickness(ac_driven_axis_washer_type));
ac_driven_axis_spacer_outer_radius = 6;
ac_driven_axis_spacer_inner_radius = screw_radius(ac_driven_axis_stripper_bolt_type) + shaft_clearance / 2;

assert(ac_j2_belt_type == pulley_belt(ac_driven_axis_pulley_type),
       "J2 구동 풀리와 종동 풀리는 같은 벨트 타입이어야 한다");
assert(ac_j2_belt_type == pulley_belt(ac_j2_idler_pulley_type),
       "J2 아이들러 풀리는 구동 풀리와 같은 벨트 타입이어야 한다");
assert(abs(ac_linear_bearing_top_z - ac_plate_linear_bearing_recess_floor_z) <= boolean_epsilon,
       "선형 베어링 상단은 플레이트 하부 리세스 바닥에 맞아야 한다");
assert(abs(ac_linear_bearing_bottom_z - ac_housing_linear_bearing_recess_floor_z) <= boolean_epsilon,
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

module ac_axis_spacer(height) {
    if (height > boolean_epsilon)
        color(grey(80))
            difference() {
                cylinder(h = height, r = ac_driven_axis_spacer_outer_radius);
                translate([0, 0, -boolean_epsilon])
                    cylinder(h = height + boolean_epsilon * 2,
                             r = ac_driven_axis_spacer_inner_radius);
            }
}

module ac_idler_spacer(height) {
    if (height > boolean_epsilon)
        color(grey(80))
            difference() {
                cylinder(h = height, r = ac_j2_idler_spacer_outer_radius);
                translate([0, 0, -boolean_epsilon])
                    cylinder(h = height + boolean_epsilon * 2,
                             r = ac_j2_idler_spacer_inner_radius);
            }
}

module arm_carriage_assembly() {
    let($explode = ac_exploded) {
        translate([0, 0, ac_housing_z])
            arm_carriage_housing();
        translate([0, 0, ac_plate_z])
            arm_carriage_plate();

        if (show_hardware) {
            // 판 사이 스탠드오프(hex standoffs) — 하우징 윗면과 플레이트 아랫면 사이 갭을 유지한다.
            for (standoff_center = ac_standoff_centers)
                translate([standoff_center.x, standoff_center.y, ac_housing_top_z])
                    pillar(ac_standoff_type);

            // 스탠드오프 상부 체결 스크류(standoff top screws) — 플레이트 윗면에서 암나사 스탠드오프로 내려간다.
            explode([0, 0, ac_explode_distance])
            for (standoff_center = ac_standoff_centers)
                translate([standoff_center.x, standoff_center.y, ac_plate_top_z + boolean_epsilon])
                    screw_and_washer(ac_standoff_screw_type, ac_standoff_top_screw_length, true);

            // 스탠드오프 하부 체결 스크류(standoff bottom screws) — 하우징 바닥면에서 암나사 스탠드오프로 올라간다.
            explode([0, 0, -ac_explode_distance])
            for (standoff_center = ac_standoff_centers)
                translate([standoff_center.x, standoff_center.y, ac_housing_z - boolean_epsilon])
                    rotate([180, 0, 0])
                        screw_and_washer(ac_standoff_screw_type, ac_standoff_bottom_screw_length, true);

            explode([0, 0, ac_explode_distance])
            translate([ac_motor_center.x, ac_motor_center.y, ac_motor_seated_z])
                rotate([180, 0, 0]) {
                    // J2 구동 모터(drive motor) — 모터 플랜지(motor flange)가 리세스 바닥에 안착하는 좌표.
                    NEMA(ac_shoulder_motor_type);
                }

            explode([0, 0, -ac_explode_distance])
            translate([ac_motor_center.x, ac_motor_center.y, ac_motor_seated_z])
                rotate([180, 0, 0])
                    translate([0, 0, ac_motor_driven_stack_z]) {
                        // J2 축 하부 스택(lower drive stack) — 샤프트 방향으로 내려가는 스크류와 풀리 간섭 검증.
                        NEMA_screws(ac_shoulder_motor_type, M3_cap_screw);
                        pulley(ac_motor_pulley_type);
                    }

            if (ac_exploded == 0)
                // J2 타이밍 벨트(timing belt) — 모터 풀리와 종동축 풀리의 벨트 중심 높이를 같은 평면에 둔다.
                translate([0, 0, ac_j2_belt_center_z])
                    belt(ac_j2_belt_type, [
                        [ac_motor_center.x, ac_motor_center.y, ac_motor_pulley_type],
                        [ac_j2_upper_idler_center.x, ac_j2_upper_idler_center.y, ac_j2_idler_pulley_type],
                        [ac_driven_axis_center.x, ac_driven_axis_center.y, ac_driven_axis_pulley_type],
                        [ac_j2_lower_idler_center.x, ac_j2_lower_idler_center.y, ac_j2_idler_pulley_type]
                    ]);

            // J1 플레이트 리드넛 하부 장착(bottom-mounted plate leadnut) — 플랜지를 플레이트 하부 리세스에 안착시킨다.
            explode([0, 0, -ac_explode_distance])
            translate([ac_leadnut_center.x, ac_leadnut_center.y, ac_plate_leadnut_seated_z]) {
                leadnut(ac_leadnut_type);
                leadnut_screw_positions(ac_leadnut_type)
                    translate([0, 0, -ac_leadnut_flange_thickness - boolean_epsilon])
                        rotate([180, 0, 0])
                            screw_and_washer(ac_leadnut_screw_type, ac_leadnut_screw_length, true);
            }

            // J1 플레이트 리드넛 스크류 너트(plate leadnut screw nuts) — 플레이트 윗면에서 리드넛 체결 스크류를 잠근다.
            explode([0, 0, ac_explode_distance])
            translate([ac_leadnut_center.x, ac_leadnut_center.y, ac_plate_top_z + boolean_epsilon])
                leadnut_screw_positions(ac_leadnut_type)
                    translate([0, 0, -ac_leadnut_flange_thickness])
                        nut(ac_leadnut_screw_nut_type);

            // J1 하우징 리드넛 하부 장착(bottom-mounted housing leadnut) — 플랜지를 하우징 하부 리세스에 안착시킨다.
            explode([0, 0, -ac_explode_distance])
            translate([ac_leadnut_center.x, ac_leadnut_center.y, ac_housing_leadnut_seated_z]) {
                leadnut(ac_leadnut_type);
                leadnut_screw_positions(ac_leadnut_type)
                    translate([0, 0, -ac_leadnut_flange_thickness - boolean_epsilon])
                        rotate([180, 0, 0])
                            screw_and_washer(ac_leadnut_screw_type, ac_leadnut_screw_length, true);
            }

            // J1 하우징 리드넛 스크류 너트(housing leadnut screw nuts) — 하우징 윗면에서 리드넛 체결 스크류를 잠근다.
            explode([0, 0, -ac_explode_distance])
            translate([ac_leadnut_center.x, ac_leadnut_center.y, ac_housing_top_z + boolean_epsilon])
                leadnut_screw_positions(ac_leadnut_type)
                    translate([0, 0, -ac_leadnut_flange_thickness])
                        nut(ac_leadnut_screw_nut_type);

            // J1 선형 베어링(linear bearings) — 플레이트와 하우징 사이에서 양쪽 리세스 바닥에 맞춘다.
            explode([0, 0, -ac_explode_distance])
            for (bearing_center = [ac_left_linear_bearing_center, ac_right_linear_bearing_center])
                translate([bearing_center.x, bearing_center.y, ac_linear_bearing_center_z])
                    linear_bearing(ac_linear_bearing_type);

            // J2 하부 종동축 베어링(lower driven axis bearing) — 하우징 바닥면 베어링 시트와 같은 축방향 중심.
            explode([0, 0, -ac_explode_distance])
            translate([ac_driven_axis_center.x, ac_driven_axis_center.y, ac_housing_driven_axis_ball_bearing_seated_z])
                ball_bearing(ac_driven_axis_ball_bearing_type);

            // J2 상부 종동축 베어링(upper driven axis bearing) — 플레이트 윗면 베어링 시트와 같은 축방향 중심.
            explode([0, 0, ac_explode_distance])
            translate([ac_driven_axis_center.x, ac_driven_axis_center.y, ac_plate_driven_axis_ball_bearing_seated_z])
                ball_bearing(ac_driven_axis_ball_bearing_type);

            // J2 종동축 스트리퍼 볼트(stripper bolt) — 상하 베어링, 풀리, 스페이서 스택을 같은 8mm 숄더 축에 묶는다.
            explode([0, 0, ac_explode_distance])
            translate([ac_driven_axis_center.x, ac_driven_axis_center.y, ac_plate_top_z + boolean_epsilon])
                screw_and_washer(ac_driven_axis_stripper_bolt_type, ac_driven_axis_stripper_bolt_length);

            // J2 종동축 풀리(driven axis pulley) — GT2 60T, 8mm 보어(bore), 6mm 벨트(belt)용.
            explode([0, 0, -ac_explode_distance * 2])
            translate([ac_driven_axis_center.x, ac_driven_axis_center.y, ac_driven_axis_pulley_mount_z])
                rotate([180, 0, 0])
                    pulley(ac_driven_axis_pulley_type);

            // J2 종동축 상부 스페이서/와셔(upper spacer and washer) — 상부 베어링 내륜과 풀리 사이 간격을 채운다.
            translate([ac_driven_axis_center.x, ac_driven_axis_center.y, ac_driven_axis_pulley_top_z]) {
                ac_axis_spacer(ac_driven_axis_upper_spacer_height);
                translate_z(ac_driven_axis_upper_spacer_height)
                    washer(ac_driven_axis_washer_type);
            }

            // J2 종동축 하부 와셔/스페이서(lower washer and spacer) — 하부 베어링 내륜과 풀리 사이 간격을 채운다.
            translate([ac_driven_axis_center.x, ac_driven_axis_center.y, ac_housing_driven_axis_bearing_top_z]) {
                washer(ac_driven_axis_washer_type);
                translate_z(washer_thickness(ac_driven_axis_washer_type))
                    ac_axis_spacer(ac_driven_axis_lower_spacer_height);
            }

            // J2 종동축 락너트(locknut) — 하우징 바닥면에서 스트리퍼 볼트를 잠근다.
            explode([0, 0, -ac_explode_distance])
            translate([ac_driven_axis_center.x, ac_driven_axis_center.y, ac_housing_z - washer_thickness(ac_driven_axis_washer_type)])
                washer(ac_driven_axis_washer_type);
            explode([0, 0, -ac_explode_distance])
            translate([ac_driven_axis_center.x, ac_driven_axis_center.y,
                       ac_housing_z - washer_thickness(ac_driven_axis_washer_type) - nut_thickness(ac_driven_axis_locknut_type, nyloc = true)])
                nut(ac_driven_axis_locknut_type, nyloc = true);

            for (idler_center = ac_j2_idler_centers) {
                // J2 아이들러 조절 볼트(idler adjustment bolt) — 슬롯 안에서 축 위치를 옮긴 뒤 하우징 하부 락너트로 고정한다.
                explode([0, 0, ac_explode_distance])
                translate([idler_center.x, idler_center.y, ac_plate_top_z + boolean_epsilon])
                    screw_and_washer(ac_j2_idler_screw_type, ac_j2_idler_screw_length);

                // J2 아이들러 상부 스페이서(upper idler spacer) — 플레이트와 풀리 베어링 내륜 사이를 채워 클램프 하중을 전달한다.
                translate([idler_center.x, idler_center.y, ac_j2_idler_pulley_top_z]) {
                    washer(ac_j2_idler_washer_type);
                    translate_z(washer_thickness(ac_j2_idler_washer_type))
                        ac_idler_spacer(ac_j2_idler_upper_spacer_height);
                }

                // J2 아이들러 풀리(idler pulley) — 구동축과 종동축 사이에서 대칭 벨트 경로를 만든다.
                explode([0, 0, -ac_explode_distance * 2])
                translate([idler_center.x, idler_center.y, ac_j2_idler_pulley_mount_z])
                    rotate([180, 0, 0])
                        pulley(ac_j2_idler_pulley_type);

                // J2 아이들러 하부 스페이서(lower idler spacer) — 하우징과 풀리 베어링 내륜 사이를 지지한다.
                translate([idler_center.x, idler_center.y, ac_housing_top_z]) {
                    ac_idler_spacer(ac_j2_idler_lower_spacer_height);
                    translate_z(ac_j2_idler_lower_spacer_height)
                        washer(ac_j2_idler_washer_type);
                }

                // J2 아이들러 락너트(idler locknut) — 슬롯 조정 후 축 볼트를 풀림 없이 잠근다.
                explode([0, 0, -ac_explode_distance])
                translate([idler_center.x, idler_center.y, ac_housing_z - washer_thickness(ac_j2_idler_washer_type)])
                    washer(ac_j2_idler_washer_type);
                explode([0, 0, -ac_explode_distance])
                translate([idler_center.x, idler_center.y,
                           ac_housing_z - washer_thickness(ac_j2_idler_washer_type) - nut_thickness(ac_j2_idler_nut_type, nyloc = true)])
                    nut(ac_j2_idler_nut_type, nyloc = true);
            }
        }
    }
}

arm_carriage_assembly();
