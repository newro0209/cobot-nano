// parts/column_carriage_plate_base.scad - Shared blank for the J1 carriage end plates (NopSCADlib printed-part style).
// Defines the round plate that carries the central J1 drive stack (motor / coupling / flange bearing) plus the three
// guide rods packed around it, and the rod-center placement. Concrete plates include this and add their own seats.
//
// J1 캐리지 단판(end plate) 공유 블랭크 — 중앙 J1 구동 스택(모터·커플링·플랜지 베어링)과 그 둘레의
// 가이드 로드 3개를 품는 둥근 판, 그리고 로드 중심 좌표를 정의한다. 실제 상·하판은 이 파일을 include해 시트·포켓을 더한다.

include <../config.scad>
use <../utils/plate.scad>
use <../utils/placement.scad>

// 중앙 J1 구동 스택(drive stack) 경계 지름 — 모터 바디·커플링·플랜지 베어링 블록 중 가장 큰 외형에 조립 여유를 더해
// 중앙부가 차지하는 원의 지름으로 삼는다. NEMA_radius*2 = 모터 바디 폭.
cc_j1_drive_axis_bounding_diameter = bounding_diameter_with_margin(max(NEMA_radius(j1_motor_type) * 2,
                                                sc_length(j1_shaft_coupling_type),
                                                kfl_length(j1_flange_bearing_block_type)), component_margin);
// 가이드 로드 1개 경계 지름 — LM8UU 직선 베어링과 FC8 플랜지 중 큰 쪽에 여유를 더한, 로드별 점유 원 지름.
// 주의: 캐리지 자체엔 로드에 LM8UU(15mm)만 타지만, 이 블랭크는 단판(end plate)과 공유한다 — 단판은 로드 끝을 FC8 플랜지(현 32mm)로
// 무므로 그쪽이 지배해 점유 원이 38mm로 커진다. 캐리지 단독 기준으론 과하지만, 단판과 외곽을 맞추려 일부러 둘의 큰 값으로 둔다.
cc_j1_guide_axis_bounding_diameter = bounding_diameter_with_margin(max(bearing_dia(j1_linear_bearing_type),
                                                fc_flange_diameter(j1_flange_coupling_type)), component_margin);
// 판 전체 경계 지름 — 중앙 스택 원과 가이드 로드 원이 외접해 늘어서므로 두 지름의 합으로 본다.
cc_j1_axis_bounding_diameter = cc_j1_drive_axis_bounding_diameter + cc_j1_guide_axis_bounding_diameter + component_margin;

// 가이드 로드를 중심에서 얼마나 띄울지 — 중앙 스택 원과 로드 원이 서로 닿지 않고 외접하는 거리(두 반지름의 합).
cc_j1_guide_rod_distance_from_center = center_distance_for_bounding_diameters(cc_j1_drive_axis_bounding_diameter, cc_j1_guide_axis_bounding_diameter);
// 가이드 로드 중심 좌표 — 첫 로드를 +Y(90°)에 두고 360/n 간격으로 등각 배치해 캐리지를 3점 지지한다.
cc_j1_guide_rod_centers = [
    for (i = [0:j1_guide_rod_count - 1])
    let(angle = 90 + i * 360 / j1_guide_rod_count)
        [
            cos(angle) * cc_j1_guide_rod_distance_from_center,
            sin(angle) * cc_j1_guide_rod_distance_from_center
        ]
];

cc_plate_diameter = cc_j1_axis_bounding_diameter;  // 둥근 판 외곽 = 축 전체 경계 지름

// 가이드 로드 배치(HOC) — 3개 J1 가이드 로드 중심마다 자식을 놓는다(2D 프로파일·3D 부품 공통).
module cc_at_guide_rods() {
    for (center = cc_j1_guide_rod_centers)
        translate(center)
            children();
}

// J1 캐리지 판 2D 프로파일 — 둥근 기준 판에 가이드 로드 로브를 더하고, 호출부가 넘긴 외곽(J2 로브 등)을 합친다.
module cc_plate_with_profile_2d(thickness) {
    round_plate_with_profile_2d(cc_plate_diameter / 2, thickness) {
        // 가이드 로드 로브(lobe) — 각 로드 중심에 점유 원을 둬, 판 외곽이 로드 둘레로 부풀어 베어링·커플링을 감싼다.
        cc_at_guide_rods()
            circle(d = cc_j1_guide_axis_bounding_diameter);

        children();
    }
}
