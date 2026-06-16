// parts/arm_carriage_plate_base.scad - Defines shared arm carriage dimensions and the base plate blank.
// Interface centers are materialized as shared values so downstream plate and housing files use the same mechanical datum.
//
// 암 캐리지 판(arm carriage plate)의 공통 치수와 기본 판 형상(base plate blank)을 정의한다.
// 인터페이스 중심(interface center)은 값으로 공유해 플레이트(plate)와 하우징(housing)의 기준 좌표가 어긋나지 않게 한다.

include <../config.scad>

ac_leadnut_type = LSN8x2;
ac_linear_bearing_type = LM8UU;
ac_shoulder_motor_type = NEMA17_40;
ac_driven_axis_ball_bearing_type = BB608;
ac_driven_axis_pulley_type = GT2x60x8_pulley;
ac_j2_idler_pulley_type = GT2x20_toothed_idler;
ac_standoff_type = ["M3x20_ff_hex_pillar", "hex", 3, 20, 5 / cos(30), 5 / cos(30), 6, 6, "silver", silver, -8, -8, true];
ac_standoff_gap = pillar_height(ac_standoff_type);

ac_j2_linear_link_length = 100;
ac_j2_idler_slot_center_x = ac_j2_linear_link_length / 2;
ac_j2_idler_slot_travel = 24;
ac_j2_idler_center_x = 50; // [38:1:62]
ac_j2_idler_center_y = 13; // [9:1:22]
ac_thickness = bb_width(ac_driven_axis_ball_bearing_type) + seat_shoulder_thickness;

ac_leadnut_bore = leadnut_bore(ac_leadnut_type);
ac_leadnut_od = leadnut_od(ac_leadnut_type);
ac_leadnut_flange_radius = leadnut_flange_dia(ac_leadnut_type) / 2;
ac_leadnut_flange_offset = leadnut_flange_offset(ac_leadnut_type);
ac_leadnut_flange_thickness = leadnut_flange_t(ac_leadnut_type);
ac_leadnut_flange_recess_radius = ac_leadnut_flange_radius + clearance / 2;
ac_leadnut_flange_recess_depth = ac_leadnut_flange_thickness;
ac_leadnut_shank_recess_radius = ac_leadnut_od / 2 + clearance / 2;
ac_leadnut_shank_recess_depth = ac_leadnut_flange_offset;
ac_leadnut_screw_clearance_radius = leadnut_hole_dia(ac_leadnut_type) / 2;

ac_linear_bearing_bore = bearing_rod_dia(ac_linear_bearing_type);
ac_linear_bearing_radius = bearing_dia(ac_linear_bearing_type) / 2;
ac_linear_bearing_recess_radius = ac_linear_bearing_radius + bearing_clearance / 2;
ac_linear_bearing_recess_depth = (bearing_length(ac_linear_bearing_type) - ac_standoff_gap) / 2;

ac_motor_radius = NEMA_radius(ac_shoulder_motor_type);
ac_motor_shaft_clearance_radius = NEMA_shaft_dia(ac_shoulder_motor_type) / 2 + shaft_clearance / 2;
ac_motor_recess_floor_z = seat_shoulder_thickness * 2;
ac_motor_recess_depth = ac_thickness - ac_motor_recess_floor_z;
ac_motor_boss_recess_radius = NEMA_big_hole(ac_shoulder_motor_type);
ac_motor_boss_recess_floor_z = seat_shoulder_thickness;
ac_motor_boss_recess_depth = ac_thickness - ac_motor_boss_recess_floor_z;

assert(ac_thickness >= 2 * seat_shoulder_thickness,
       "ac_thickness는 중첩 리세스의 2단 시트 숄더 이상이어야 한다");
assert(ac_linear_bearing_recess_depth >= 0,
       "스탠드오프 갭은 선형 베어링 길이보다 길 수 없다");
assert(ac_linear_bearing_recess_depth <= ac_thickness - seat_shoulder_thickness,
       "선형 베어링 리세스는 시트 숄더를 남겨야 한다");

ac_driven_axis_pulley_radius = pulley_extent(ac_driven_axis_pulley_type);
ac_driven_axis_shaft_clearance_radius = pulley_bore(ac_driven_axis_pulley_type) / 2 + shaft_clearance / 2;
ac_j2_idler_screw_type = M4_cap_screw;
ac_j2_idler_slot_radius = max(screw_clearance_radius(ac_j2_idler_screw_type),
                              pulley_bore(ac_j2_idler_pulley_type) / 2 + shaft_clearance / 2);
ac_j2_idler_slot_min_x = ac_j2_idler_slot_center_x - ac_j2_idler_slot_travel / 2;
ac_j2_idler_slot_max_x = ac_j2_idler_slot_center_x + ac_j2_idler_slot_travel / 2;

assert(ac_j2_idler_center_x >= ac_j2_idler_slot_min_x
       && ac_j2_idler_center_x <= ac_j2_idler_slot_max_x,
       "J2 아이들러 중심 X는 슬롯 이동 범위 안에 있어야 한다");
assert(ac_j2_idler_center_y >= pulley_extent(ac_j2_idler_pulley_type) + clearance,
       "J2 대칭 아이들러는 서로 닿지 않을 만큼 Y 오프셋이 필요하다");

ac_z_shaft_radius = max(ac_leadnut_flange_radius, ac_linear_bearing_radius);
ac_z_shaft_center_distance = ac_motor_radius + ac_z_shaft_radius + component_margin;
ac_outer_radius = ac_z_shaft_center_distance + ac_z_shaft_radius;

ac_motor_center = [0, 0];
ac_driven_axis_center = [ac_j2_linear_link_length, 0];
ac_j2_linear_link_radius = ac_driven_axis_pulley_radius + component_margin / 2;
ac_j2_upper_idler_center = [ac_j2_idler_center_x, ac_j2_idler_center_y];
ac_j2_lower_idler_center = [ac_j2_idler_center_x, -ac_j2_idler_center_y];
ac_j2_idler_centers = [ac_j2_upper_idler_center, ac_j2_lower_idler_center];
ac_standoff_screw_clearance_radius = M3_clearance_radius;
ac_standoff_body_radius = pillar_od(ac_standoff_type) / 2;
ac_j2_belt_xy_keepout = belt_width(pulley_belt(ac_j2_idler_pulley_type)) / 2
                        + ac_standoff_body_radius
                        + component_margin;
ac_standoff_j1_outer_x = -ac_z_shaft_center_distance + ac_z_shaft_radius + component_margin / 2;
ac_standoff_j1_y = ac_motor_radius - ac_standoff_body_radius - clearance;
ac_standoff_belt_side_x = ac_j2_idler_slot_center_x - component_margin / 2;
ac_standoff_belt_side_y = ac_j2_idler_center_y + ac_j2_belt_xy_keepout + component_margin / 2;
ac_standoff_centers = [
    [ac_standoff_j1_outer_x, ac_standoff_j1_y],
    [ac_standoff_j1_outer_x, -ac_standoff_j1_y],
    [ac_standoff_belt_side_x, ac_standoff_belt_side_y],
    [ac_standoff_belt_side_x, -ac_standoff_belt_side_y]
];
ac_leadnut_center = [-ac_z_shaft_center_distance, 0];
ac_left_linear_bearing_center = [
    ac_z_shaft_center_distance * cos(60),
    ac_z_shaft_center_distance * sin(60)
];
ac_right_linear_bearing_center = [
    ac_z_shaft_center_distance * cos(-60),
    ac_z_shaft_center_distance * sin(-60)
];

for (standoff_center = ac_standoff_centers) {
    assert(norm(standoff_center - ac_motor_center)
           >= ac_motor_radius + ac_standoff_body_radius + clearance,
           "스탠드오프는 J2 모터 바디 리세스와 겹치면 안 된다");
    assert(norm(standoff_center - ac_leadnut_center)
           >= ac_leadnut_flange_recess_radius + ac_standoff_body_radius + clearance,
           "스탠드오프는 J1 리드넛 플랜지 리세스와 겹치면 안 된다");
    assert(norm(standoff_center - ac_left_linear_bearing_center)
           >= ac_linear_bearing_recess_radius + ac_standoff_body_radius + clearance,
           "스탠드오프는 좌측 LM8UU 리세스와 겹치면 안 된다");
    assert(norm(standoff_center - ac_right_linear_bearing_center)
           >= ac_linear_bearing_recess_radius + ac_standoff_body_radius + clearance,
           "스탠드오프는 우측 LM8UU 리세스와 겹치면 안 된다");
    assert(norm(standoff_center - ac_driven_axis_center)
           >= ac_driven_axis_pulley_radius + ac_standoff_body_radius + clearance,
           "스탠드오프는 J2 종동축 풀리 풋프린트와 겹치면 안 된다");
    if (standoff_center.x >= ac_motor_center.x && standoff_center.x <= ac_driven_axis_center.x)
        assert(abs(standoff_center.y)
               >= (standoff_center.x <= ac_j2_idler_slot_min_x
                   ? ac_j2_idler_center_y * standoff_center.x / ac_j2_idler_slot_min_x
                   : standoff_center.x >= ac_j2_idler_slot_max_x
                   ? ac_j2_idler_center_y
                     * (ac_j2_linear_link_length - standoff_center.x)
                     / (ac_j2_linear_link_length - ac_j2_idler_slot_max_x)
                   : ac_j2_idler_center_y)
                  + ac_j2_belt_xy_keepout,
               "스탠드오프는 J2 벨트 슬롯 전체 범위의 XY 킵아웃(keepout) 밖에 있어야 한다");
    if (standoff_center.x >= ac_motor_center.x && standoff_center.x <= ac_driven_axis_center.x)
        assert(abs(standoff_center.y)
               >= (standoff_center.x <= ac_j2_idler_center_x
                   ? ac_j2_idler_center_y * standoff_center.x / ac_j2_idler_center_x
                   : ac_j2_idler_center_y
                     * (ac_j2_linear_link_length - standoff_center.x)
                     / (ac_j2_linear_link_length - ac_j2_idler_center_x))
                  + ac_j2_belt_xy_keepout,
               "스탠드오프는 현재 J2 벨트 경로의 XY 킵아웃(keepout) 밖에 있어야 한다");
}

module arm_carriage_plate_base() {
    linear_extrude(height = ac_thickness)
    difference() {
        union() {
            // 캐리지 외곽 디스크(carriage outer disc) — 모터와 3점 Z축 풋프린트(footprint)가 한 판 안에 남는 원형 경계.
            circle(d = ac_outer_radius * 2 + component_margin);

            // J2 선형 링크(linear link) — 종동축(driven axis) 풀리 풋프린트(footprint) 기준 폭을 유지하는 직선 링크.
            hull() {
                translate(ac_motor_center)
                    circle(r = ac_j2_linear_link_radius);
                translate(ac_driven_axis_center)
                    circle(r = ac_j2_linear_link_radius);
            }
        }

        // J1 Z축 클리어런스 보어(clearance bore) — 리드스크류(lead screw)와 가이드 로드(guide rod)의 자유 이동 공간.
        translate(ac_leadnut_center)
            circle(d = ac_leadnut_bore + shaft_clearance);
        translate(ac_left_linear_bearing_center)
            circle(d = ac_linear_bearing_bore + shaft_clearance);
        translate(ac_right_linear_bearing_center)
            circle(d = ac_linear_bearing_bore + shaft_clearance);

        // J2 종동축 클리어런스 보어(driven axis clearance bore) — 풀리 보어(pulley bore) 기준 축 경로.
        translate(ac_driven_axis_center)
            circle(r = ac_driven_axis_shaft_clearance_radius);

        // J2 아이들러 조절 슬롯(idler adjustment slots) — 대칭 아이들러 축 볼트가 벨트 장력 조절을 위해 X 방향으로 미끄러진다.
        for (idler_center = ac_j2_idler_centers)
            hull() {
                translate([ac_j2_idler_slot_min_x, idler_center.y])
                    circle(r = ac_j2_idler_slot_radius);
                translate([ac_j2_idler_slot_max_x, idler_center.y])
                    circle(r = ac_j2_idler_slot_radius);
            }
    }
}
