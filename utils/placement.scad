// utils/placement.scad - Shared polar/radial placement helpers and bounding-diameter margin helpers.
// Higher-order modules that take children() so layout logic stays separate from the shapes being placed.
//
// 공유 배치(placement) 유틸 — 극좌표·원형 배열 고차 모듈과 마진 포함 경계 지름 함수 2종.
// 형상 정의와 배치 로직을 분리하도록 children()을 받는 고차 모듈로 둔다.

//! Center distance that leaves clearance between two bounding diameters.
// 두 경계원(bounding circle)이 서로 닿지 않는 최소 중심 거리(packing) — 두 반지름의 합에 여유를 더해 외접시킨다.
function center_distance_for_bounding_diameters(diameter_a, diameter_b, clearance = 0) =
    ((diameter_a + diameter_b) / 2) + clearance;

//! Outline diameter leaving full margin around one component edge (radial, so 2× on a diameter).
// 부품 경계원에 사방 마진을 남긴 외곽 지름(edge envelope) — 지름이라 반경 마진을 양쪽(2×)으로 더한다.
// center_distance_*가 부품-부품 간격(packing)을 주는 것과 달리, 이건 한 부품 둘레에 판 외곽까지의 살을 준다.
// 마진은 호출부에서 넘긴다(center_distance_*의 clearance처럼) — 이 util은 config 전역에 의존하지 않는다.
function bounding_diameter_with_margin(component_diameter, margin) =
    component_diameter + 2 * margin;

// 극좌표 배치(polar placement) — 자식 형상을 중심에서 radius만큼, angle 방향으로 옮긴다.
module at_polar(angle, radius) {
    translate([radius * cos(angle), radius * sin(angle)])
        children();
}

// 원형 배열(radial array) — count개를 등각으로 돌릴 때 index번째 위치에 자식을 놓는다(start_angle은 첫 항목 기준각).
module at_radial(index, count, radius, start_angle = 0) {
    at_polar(start_angle + index * 360 / count, radius)
        children();
}
