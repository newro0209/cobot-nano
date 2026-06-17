// utils/plate.scad - Shared round-plate blank generator: a base disc unioned with caller-supplied 2D lobes,
// then morphologically closed so the concave junctions where lobes meet the disc are filleted, not sharp.
//
// 공유 둥근 판재 블랭크(round plate blank) 생성기 — 기준 원판에 호출부가 넘긴 2D 로브(lobe)를 union하고
// 모폴로지 닫힘(morphological close)으로 로브와 원판이 만나는 오목 모서리를 라운딩한다.

// 둥근 판 + 외곽 로브 프로파일 2D를 압출한다. rounding은 로브·원판 접합부의 필렛 반경.
module round_plate_with_profile_2d(radius, thickness, rounding = 2) {
    linear_extrude(thickness) {
        // offset(+r) 후 offset(-r) = 닫힘 연산(morphological close) — 원판과 로브가 만나는 안쪽 오목 모서리를
        // 반경 rounding으로 메워 응력 집중(stress riser)과 FDM에서 갈라지기 쉬운 날카로운 내각을 없앤다.
        offset(r = -rounding) offset(r = rounding) union() {
            circle(r = radius);
            children();
        }
    }
}
