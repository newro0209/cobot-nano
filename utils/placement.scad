// utils/placement.scad - Shared polar/radial placement helpers and a center-distance helper.
// Higher-order modules that take children() so layout logic stays separate from the shapes being placed.
//
// 공유 배치(placement) 유틸 — 극좌표·원형 배열 모듈과 중심 거리 계산 함수.
// 형상 정의와 배치 로직을 분리하도록 children()을 받는 고차 모듈로 둔다.

//! Center distance that leaves clearance between two bounding diameters.
// 두 경계원(bounding circle)이 서로 닿지 않는 최소 중심 거리 — 두 반지름의 합에 여유를 더해, 외접하도록 떨어뜨린다.
function center_distance_for_bounding_diameters(diameter_a, diameter_b, clearance = 0) =
    ((diameter_a + diameter_b) / 2) + clearance;

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
