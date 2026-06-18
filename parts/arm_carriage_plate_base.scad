// parts/arm_carriage_plate_base.scad - Shared blank for the arm-carriage plates (NopSCADlib printed-part style).
// Extends the column-carriage round blank with the shoulder-mount link (SHOULDER_MOUNT_LINK; a stadium-shaped arm)
// reaching out to the J2 shoulder axis, then cuts the guide-rod through-holes and the J2 shoulder-bolt bore.
// Top/bottom plates include this and add their own seats.
//
// 암 캐리지 판 공유 블랭크 — 컬럼 캐리지 둥근 블랭크에 J2 어깨축까지 뻗는 어깨 마운트 링크(shoulder mount link, 스타디움 형상)를 더하고,
// 가이드 로드 관통홀과 J2 숄더 볼트 보어를 깎는다. 상·하판은 이 파일을 include해 각자의 시트를 추가한다.

include <column_carriage_plate_base.scad>
use <../utils/placement.scad>
use <linear_bearing_seat.scad>

// 판 두께 — J2 종동 베어링 폭에 시트 단차(seat shoulder)를 더해, 베어링이 폭만큼 앉고도 뒤에 받침면이 남게 한다.
ac_thickness = max(bb_width(j2_driven_ball_bearing_type)) + seat_shoulder_thickness;

// J2 종동축 로브 지름 — 어깨축에서 겹쳐 도는 종동 베어링·종동 풀리 중 큰 쪽을 envelope로 감싼다(반경 마진 근거는 함수 정의 참고).
ac_j2_driven_axis_bounding_diameter =
    bounding_diameter_with_margin(max(NEMA_radius(j3_motor_type) * 2,
                                      bb_diameter(j2_driven_ball_bearing_type),
                                      fc_flange_diameter(j2_driven_flange_coupling_type),
                                      pulley_flange_dia(j2_driven_pulley_type)), component_margin);
// 구동 풀리 최대 외경 — 치형 외경(pulley_od)보다 플랜지(pulley_flange_dia)가 크므로 큰 쪽으로 잡는다.
ac_j2_drive_pulley_outer_dia = max(pulley_od(j2_drive_pulley_type),
                                   pulley_flange_dia(j2_drive_pulley_type));
ac_j2_drive_pulley_slot_bounding_diameter = bounding_diameter_with_margin(ac_j2_drive_pulley_outer_dia, component_margin);
// 모터 슬롯 로브 지름 — 종동축·모터 바디·구동 풀리 슬롯 중 가장 큰 envelope.
ac_j2_motor_slot_bounding_diameter = max(ac_j2_driven_axis_bounding_diameter,
                                         bounding_diameter_with_margin(NEMA_radius(j2_motor_type) * 2, component_margin),
                                         ac_j2_drive_pulley_slot_bounding_diameter);

// J2 모터 슬롯 — 모터 전체를 −Y로 밀어 GT2 벨트 장력을 조절한다(아이들러 없음). fraction 0=near(최소 장력)~1=far(최대).
// near(0)은 리드너트 플랜지와 모터 바디가 component_margin만큼 떨어진 안쪽 끝.
ac_j2_motor_slot_travel = 8;
function ac_j2_motor_center_at(fraction) =
    [0, -center_distance_for_bounding_diameters(
            leadnut_flange_dia(j1_leadnut_type),
            NEMA_width(j2_motor_type),
            component_margin)
        - ac_j2_motor_slot_travel * fraction];
ac_j2_motor_slot_vector = ac_j2_motor_center_at(1) - ac_j2_motor_center_at(0);

// 상/하판 간격과 LM8UU 캡처 — 필러 길이로 판 간격을 정한다. 간격이 베어링보다 길면 외곽 칼라(양형)로, 짧으면 시트(음형)로 양끝을 잡는다(배타적).
ac_plate_gap = pillar_height(standoff_pillar_type);
ac_linear_bearing_seat_depth = max((bearing_length(j1_linear_bearing_type) - ac_plate_gap) / 2, 0);
ac_linear_bearing_axial_clearance = max(ac_plate_gap - bearing_length(j1_linear_bearing_type), 0);
ac_linear_bearing_capture_depth = 2.5;   // 칼라(양형) 높이 = 축방향 캡처 깊이
assert(ac_linear_bearing_seat_depth <= ac_thickness, "LM 베어링 시트 깊이는 판 두께 이하여야 한다");
assert(ac_linear_bearing_axial_clearance <= eps || 2 * ac_linear_bearing_capture_depth < ac_plate_gap,
       "상/하판 LM 베어링 캡처 칼라는 판 사이에서 서로 닿지 않아야 한다");

// 스탠드오프 볼트 서클(standoff bolt circle) — 8등분 중 모터·풀리 로브(−Y) 간섭 위치를 뺀 자리에만 둔다.
ac_standoff_count              = 8;
ac_standoff_active_indices     = [0, 1, 3, 4]; // 0/45/135/180° 사용, 90/225/270/315°(−Y 로브 쪽) 제외
ac_standoff_bolt_circle_radius = cc_j1_guide_rod_distance_from_center - component_margin;
ac_standoff_start_angle        = 0;

module ac_standoff_positions(indices = ac_standoff_active_indices) {
    for (i = indices)
        at_radial(i, ac_standoff_count, ac_standoff_bolt_circle_radius, ac_standoff_start_angle)
            children();
}

// 뒤쪽 슬롯 로브(slot lobe) — J1 기준 원부터 슬롯 far 위치까지 같은 폭으로 hull해, 모터 가동 전 구간을 덮는다.
module ac_rear_slot_lobe_to(center, diameter) {
    hull() {
        circle(d = diameter);
        translate(center) circle(d = diameter);
    }
}

module ac_motor_slot_lobe() {
    ac_rear_slot_lobe_to(ac_j2_motor_center_at(1), diameter = ac_j2_motor_slot_bounding_diameter);
}

module ac_drive_pulley_slot_lobe() {
    ac_rear_slot_lobe_to(ac_j2_motor_center_at(1), diameter = ac_j2_drive_pulley_slot_bounding_diameter);
}

// LM8UU 캡처(HOC, 양형) — 간격이 베어링보다 길면 가이드 로드마다 외곽 칼라로 끝면을 잡는다(union 측). 간격 없으면 비운다.
module ac_linear_bearing_bosses(from_top) {
    lip_overlap = 0.6;  // 끝단 걸림턱이 베어링 OD를 무는 반경 깊이
    if (ac_linear_bearing_axial_clearance > eps)
        cc_at_guide_rods()
            linear_bearing_seat_boss(j1_linear_bearing_type, part_thickness = ac_thickness,
                                     height = ac_linear_bearing_capture_depth, lip_overlap = lip_overlap,
                                     lip_height = min(ac_linear_bearing_axial_clearance / 2, 0.5),
                                     from_top = from_top);
}

// LM8UU 캡처(HOC, 음형) — 간격이 베어링보다 짧을 때만 가이드 로드마다 시트 깊이만큼 카운터보어(difference 측).
module ac_linear_bearing_seats(from_top) {
    if (ac_linear_bearing_seat_depth > eps)
        cc_at_guide_rods()
            linear_bearing_seat_pocket(j1_linear_bearing_type, part_thickness = ac_thickness,
                                       seat_depth = ac_linear_bearing_seat_depth, from_top = from_top);
}

// 뒤쪽(−Y) 로브는 판마다 다르므로(상판=모터 슬롯 풋프린트, 하판=20T 풀리 슬롯 풋프린트) ac_plate_base 안에 박지 않고
// children()로 받는다. 호출 판이 이미 J1 기준 원과 연결된 2D 로브를 넘긴다.
module ac_plate_base() {
    difference() {
        cc_plate_with_profile_2d(ac_thickness) {
            // 어깨 마운트 링크(shoulder mount link) — J1 중심 원과 J2 어깨축 원을 hull로 이어(스타디움 형상), 판이 두 축을 잇는 외팔보로 뻗는다.
            hull() {
                circle(d = ac_j2_driven_axis_bounding_diameter);
                translate(j2_driven_axis_center) circle(d = ac_j2_driven_axis_bounding_diameter);
            }

            // 뒤쪽(−Y) 로브 — 호출 판이 만든 슬롯 로브를 그대로 더한다.
            children();
        }

        // 가이드 로드 관통홀 — 봉이 판을 지나도록 로드 지름으로 뚫는다(상판은 여기에 LM8UU 시트를 덧깎는다).
        cc_at_guide_rods()
            translate_z(-eps)
                cylinder(d = j1_guide_rod_diameter, h = ac_thickness + eps * 2);

        // J2 숄더 볼트 보어 — 어깨 피벗 볼트가 판을 관통하도록 베어링 내경(bb_bore)으로 뚫는다.
        translate([j2_driven_axis_center[0], j2_driven_axis_center[1], -eps])
            cylinder(d = bb_bore(j2_driven_ball_bearing_type), h = ac_thickness + eps * 2);

        // 스탠드오프 볼트 서클(standoff bolt circle) — 두 판을 잇는 M3 필러용 볼트 클리어런스 홀(양 판 공통이라 블랭크에 둔다).
        ac_standoff_positions()
            translate_z(-eps)
                cylinder(r = screw_clearance_radius(standoff_screw_type), h = ac_thickness + eps * 2);
    }
}
