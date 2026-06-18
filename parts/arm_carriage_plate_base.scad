// parts/arm_carriage_plate_base.scad - Shared blank for the arm-carriage plates (NopSCADlib printed-part style).
// Extends the column-carriage round blank with the shoulder-mount link (SHOULDER_MOUNT_LINK; a stadium-shaped arm)
// reaching out to the J2 shoulder axis, then cuts the guide-rod through-holes and the J2 shoulder-bolt bore.
// Top/bottom plates include this and add their own seats.
//
// 암 캐리지 판 공유 블랭크 — 컬럼 캐리지 둥근 블랭크에 J2 어깨축까지 뻗는 어깨 마운트 링크(shoulder mount link, 스타디움 형상)를 더하고,
// 가이드 로드 관통홀과 J2 숄더 볼트 보어를 깎는다. 상·하판은 이 파일을 include해 각자의 시트를 추가한다.

include <column_carriage_plate_base.scad>
use <../utils/placement.scad>

// 판 두께 — J2 종동 베어링 폭에 시트 단차(seat shoulder)를 더해, 베어링이 폭만큼 앉고도 뒤에 받침면이 남게 한다.
ac_thickness = max(bb_width(j2_driven_ball_bearing_type)) + seat_shoulder_thickness;

// J2 로브(lobe) 지름 — 어깨축에서 겹쳐 도는 종동 베어링과 종동 풀리 중 큰 쪽을 감싸야 하므로 둘의 큰 값으로 잡는다.
// component_margin은 부품 가장자리에서 판 가장자리까지 "반경 방향으로" 남길 살이다(center_distance가 부품-부품 간격에
// 주는 full margin과 일관). 지름 기준이므로 반경당 margin을 남기려면 2×component_margin을 더한다.
ac_j2_driven_axis_bounding_diameter = max(
    bb_diameter(j2_driven_ball_bearing_type),
    pulley_flange_dia(j2_driven_pulley_type)
) + 2 * component_margin;
// 구동 풀리 최대 외경 — 치형 외경(pulley_od)보다 플랜지(pulley_flange_dia)가 크므로, 마진이 플랜지에 남으려면 큰 쪽을 기준으로 잡는다.
ac_j2_drive_pulley_outer_dia = max(
    pulley_od(j2_drive_pulley_type),
    pulley_flange_dia(j2_drive_pulley_type)
);
ac_j2_motor_slot_bounding_diameter = max(
    ac_j2_driven_axis_bounding_diameter,
    NEMA_radius(j2_motor_type) * 2 + 2 * component_margin,
    ac_j2_drive_pulley_outer_dia + 2 * component_margin
);
ac_j2_drive_pulley_slot_bounding_diameter = ac_j2_drive_pulley_outer_dia + 2 * component_margin;

// J2 모터 슬롯 — 아이들러 없이 모터 전체를 −Y 방향으로 밀어 GT2 벨트 장력을 조절한다.
// 모터 중심은 명명 위치 대신 정규화 함수 하나로 표현한다: fraction 0=near, 1=far.
// near(0) 위치는 리드너트 플랜지와 모터 바디 사이가 component_margin만큼 남는 가장 안쪽 위치이고, far(1)가 최대 장력 위치다.
ac_j2_motor_slot_travel = 8;
function ac_j2_motor_center_at(fraction) =
    [0, -center_distance_for_bounding_diameters(
            leadnut_flange_dia(j1_leadnut_type),
            NEMA_width(j2_motor_type),
            component_margin)
        - ac_j2_motor_slot_travel * fraction];
ac_j2_motor_slot_vector = ac_j2_motor_center_at(1) - ac_j2_motor_center_at(0);

// 상/하판 간격과 LM8UU 시트 깊이 — 필러 길이를 기준으로 판 간격을 정하고, 베어링이 양쪽 판에 닿을 때만 시트를 판다.
ac_plate_gap = pillar_height(standoff_pillar_type);
ac_linear_bearing_seat_depth = max((bearing_length(j1_linear_bearing_type) - ac_plate_gap) / 2, 0);
ac_linear_bearing_axial_clearance = max(ac_plate_gap - bearing_length(j1_linear_bearing_type), 0);
ac_linear_bearing_capture_depth = 2.5;
ac_linear_bearing_boss_height = ac_linear_bearing_axial_clearance > eps ? ac_linear_bearing_capture_depth : 0;
ac_linear_bearing_retainer_lip_overlap = 0.6;
ac_linear_bearing_retainer_lip_height = min(ac_linear_bearing_axial_clearance / 2, 0.5);
assert(ac_linear_bearing_seat_depth <= ac_thickness, "LM 베어링 시트 깊이는 판 두께 이하여야 한다");
assert(2 * ac_linear_bearing_boss_height < ac_plate_gap,
       "상/하판 LM 베어링 캡처 칼라는 판 사이에서 서로 닿지 않아야 한다");

// 스탠드오프 볼트 서클(standoff bolt circle) — 모터 슬롯과 간섭하는 모터 쪽 인덱스를 제외할 수 있게 한다.
ac_standoff_count              = 8;
ac_standoff_bolt_circle_radius = cc_j1_guide_rod_distance_from_center - component_margin;
ac_standoff_start_angle        = 0;
ac_standoff_excluded_indices   = [2, 5, 6, 7]; // start_angle=0 기준 225°, 270°, 315° 위치 — 모터 슬롯 쪽 간섭 회피

function ac_index_in_list(index, indices) =
    len([for (i = indices) if (i == index) i]) > 0;

ac_standoff_active_indices = [
    for (i = [0 : ac_standoff_count - 1])
        if (!ac_index_in_list(i, ac_standoff_excluded_indices)) i
];

module ac_standoff_positions(indices = ac_standoff_active_indices) {
    for (i = indices)
        at_radial(i, ac_standoff_count, ac_standoff_bolt_circle_radius, ac_standoff_start_angle)
            children();
}

// 뒤쪽 슬롯 로브(slot lobe) — J2 driven 팔과 같은 방식으로 J1 기준 원부터 슬롯 far 위치까지 같은 폭으로 뻗는다.
// 슬롯 중간 위치는 far 위치로 가는 스타디움 팔 안에 포함되므로, 외곽은 항상 최대 슬롯 길이 기준으로 잡는다.
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
        for (center = cc_j1_guide_rod_centers)
            translate([center[0], center[1], -eps])
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

// 이 파일을 단독으로 열 때만 미리보기를 그린다. 상위 어셈블리가 include하면 hide_part_self_preview를 켜 유령 블랭크를 막는다.
if($preview && is_undef(hide_part_self_preview))
    ac_plate_base()
        ac_motor_slot_lobe();
