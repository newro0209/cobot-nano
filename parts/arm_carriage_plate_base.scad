// parts/arm_carriage_plate_base.scad - Shared blank for the arm-carriage plates (NopSCADlib printed-part style).
// Extends the column-carriage round blank with a stadium arm reaching out to the J2 shoulder axis, then cuts the
// guide-rod through-holes and the J2 shoulder-bolt bore. Top/bottom plates include this and add their own seats.
//
// 암 캐리지 판 공유 블랭크 — 컬럼 캐리지 둥근 블랭크에 J2 어깨축까지 뻗는 스타디움(stadium) 팔을 더하고,
// 가이드 로드 관통홀과 J2 숄더 볼트 보어를 깎는다. 상·하판은 이 파일을 include해 각자의 시트를 추가한다.

include <column_carriage_plate_base.scad>
use <../utils/placement.scad>

// 판 두께 — J2 종동 베어링 폭에 시트 단차(seat shoulder)를 더해, 베어링이 폭만큼 앉고도 뒤에 받침면이 남게 한다.
ac_thickness = max(bb_width(j2_driven_ball_bearing_type)) + seat_shoulder_thickness;

// J2 로브(lobe) 지름 — 어깨축에서 겹쳐 도는 종동 베어링과 종동 풀리 중 큰 쪽을 감싸야 하므로 둘의 큰 값으로 잡는다.
ac_j2_driven_axis_bounding_diameter = max(
    bb_diameter(j2_driven_ball_bearing_type),
    pulley_extent(j2_driven_pulley_type) * 2
) + component_margin;

// J2 모터 중심 — 리드너트 뒤(−Y, J2 어깨축 반대편)에 모터를 단다. 모터의 평평한 면(NEMA_width/2)이 리드너트를 향하므로,
// 리드너트 플랜지와 모터 바디 사이가 component_margin만큼 떨어지는 중심 거리를 NEMA_width로 잡는다.
ac_j2_motor_center = [0, -center_distance_for_bounding_diameters(
                            leadnut_flange_dia(j1_leadnut_type),
                            NEMA_width(j2_motor_type),
                            component_margin)];

// J2 벨트 아이들러 — 리드너트(J1 중심) 좌우(±X)에 한 쌍. 슬롯 안쪽 끝을 리드너트 플랜지 바로 옆(clearance만큼 띄움)에 두고,
// 거기서 바깥(±X)으로 ac_idler_slot_travel만큼 밀어 GT2 벨트 텐션을 조정한다.
ac_idler_center_distance = center_distance_for_bounding_diameters(
                               leadnut_flange_dia(j1_leadnut_type),
                               pulley_od(j2_idler_pulley_type),
                               clearance);
ac_idler_slot_travel = 10;   // 아이들러 X 위치 조정 범위(슬롯 가동 길이) — 벨트 텐션

// 상/하판 간격과 LM8UU 시트 깊이 — 필러 길이를 기준으로 판 간격을 정하고, 베어링이 양쪽 판에 닿을 때만 시트를 판다.
ac_plate_gap = pillar_height(standoff_pillar_type);
ac_linear_bearing_seat_depth = max((bearing_length(j1_linear_bearing_type) - ac_plate_gap) / 2, 0);
ac_linear_bearing_axial_clearance = max(ac_plate_gap - bearing_length(j1_linear_bearing_type), 0);
ac_linear_bearing_boss_height = ac_linear_bearing_axial_clearance / 2;
assert(ac_linear_bearing_seat_depth <= ac_thickness, "LM 베어링 시트 깊이는 판 두께 이하여야 한다");

// 스탠드오프 볼트 서클 배치 — 주석 다시 달것
ac_standoff_count              = 4;
ac_standoff_bolt_circle_radius = cc_j1_guide_rod_distance_from_center - component_margin;
ac_standoff_start_angle        = 45;

module ac_standoff_positions() {
    for (i = [0 : ac_standoff_count - 1])
        at_radial(i, ac_standoff_count, ac_standoff_bolt_circle_radius, ac_standoff_start_angle)
            children();
}

// 뒤쪽(−Y) 로브는 판마다 다르므로(상판=모터 풋프린트, 하판=20T 풀리 풋프린트) ac_plate_base 안에 박지 않고
// children()로 받는다. 호출 판이 ac_j2_motor_center 자리에 둘 2D 프로파일을 넘기고, 여기서 J1 중심과 한 몸으로 잇는다.
module ac_plate_base() {
    difference() {
        cc_plate_with_profile_2d(ac_thickness) {
            // 스타디움 팔(stadium arm) — J1 중심 원과 J2 어깨축 원을 hull로 이어, 판이 두 축을 잇는 외팔보로 뻗는다.
            hull() {
                circle(d = ac_j2_driven_axis_bounding_diameter);
                translate(j2_driven_axis_center) circle(d = ac_j2_driven_axis_bounding_diameter);
            }

            // 뒤쪽(−Y) 로브 — 호출 판이 넘긴 2D 프로파일. J1 중심 원과 hull로 이어 외팔보를 −Y로 잇는다.
            hull() {
                circle(d = ac_j2_driven_axis_bounding_diameter);
                children();
            }
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

if($preview)
    ac_plate_base()
        translate(ac_j2_motor_center) circle(d = ac_j2_driven_axis_bounding_diameter);
