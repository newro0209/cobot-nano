include <../config.scad>

function bb_closure_thickness(type) = bb_diameter(type) - bb_bore(type) - bb_rim(type) - bb_hub(type);

//! 베어링 시트(bearing seat) 음형(negative) — 원점(origin)에서 생성하는 동축 단차 구멍(coaxial stepped bore), difference() 피연산자로 사용
//! — 베어링 폭(width)만큼 깊은 외경 안착 카운터보어(counterbore) + 외륜 림(outer-race rim)을 잡으며 호스트 판(host plate)을 관통하는 단차 구멍(stepped bore)
module bb_seat_pocket(type, bore_depth, from_top = false) {
    diameter = bb_diameter(type);
    bore = bb_bore(type);
    hub = bb_hub(type);
    width = bb_width(type);
    closure = bb_closure_thickness(type); // 측판 두께

    // 안착 깊이(seat depth)는 베어링 폭(width)이므로 관통 보어 깊이(bore_depth)가 그보다 얕으면 시트 단차가 성립하지 않음
    assert(bore_depth >= width, "bore_depth는 베어링 폭(bb_width) 이상이어야 한다");

    // 외륜 림(outer-race rim) — 샤프트 구멍보다 외륜 림두께(hub) + 측판 두께(closure) 절반만큼 더 뚫어 림을 잡는 단차 지름(stepped bore diameter)
    rim_grip_diameter = bore + hub + closure / 2;

    // 관통 보어(through bore) — 부품 전체 깊이를 외륜 림(outer-race rim) 잡는 단차 지름으로 관통
    translate([0, 0, -boolean_epsilon])
        cylinder(h = bore_depth + boolean_epsilon * 2, d = rim_grip_diameter + shaft_clearance);

    // 안착 카운터보어(counterbore) — from_top이면 윗면(top face), 아니면 바닥면(bottom face)으로 열림. 베어링 삽입 면 선택.
    seat_z = from_top ? bore_depth - width : -boolean_epsilon;
    translate([0, 0, seat_z])
        cylinder(h = width + boolean_epsilon, d = diameter + bearing_clearance);
}

bb_seat_pocket(BB608, bore_depth = 10);