// parts/ball_bearing_seat.scad - Ball-bearing seat geometry cut into / added to sheet plates (NopSCADlib printed-part style).
// These are fabricated features parameterised by a NopSCADlib ball-bearing type, not bought vitamins, so they live
// under parts/. The pocket is a negative for difference(); the boss is a positive spacer.
//
// 베어링을 앉히기 위해 판재에 깎거나(음형) 덧대는(양형) 제작 형상이다. 구입 부품(vitamin)이 아니라 가공 형상이라 parts/에 둔다.
// 베어링 치수는 NopSCADlib ball-bearing 타입(BB608 등)에서 접근자(bb_*)로 읽어 하드코딩을 피한다.

include <../config.scad>

//! 베어링 닫힌 면(closed face)의 반경 방향 띠 폭 — 보어 쪽과 외경 쪽 림(rim) 사이에 남는 면.
//! 외륜 림(outer-race rim)을 절반쯤 무는 단차 지름을 잡는 기준으로 쓴다.
function bb_bearing_shield_thickness(type) = bb_diameter(type) - bb_bore(type) - bb_rim(type) - bb_hub(type);

//! 베어링 시트(bearing seat) 음형(negative) — 원점에서 만드는 동축 단차 구멍(coaxial stepped bore). difference() 피연산자.
//! 외륜(outer race)을 베어링 폭만큼 앉히는 카운터보어 + 외륜 림을 무는 더 좁은 관통 보어로 이루어진다.
//! from_top=false면 바닥면, true면 윗면으로 열린다(판 중립면 기준 대칭).
module bb_bearing_seat_pocket(type, part_thickness, from_top = false) {
    diameter = bb_diameter(type);
    bore = bb_bore(type);
    hub = bb_hub(type);
    width = bb_width(type);

    // 안착 깊이(seat depth)는 베어링 폭(width)이므로, 관통 보어가 그보다 얕으면 시트 단차가 성립하지 않는다.
    assert(part_thickness >= width, "part_thickness는 베어링 폭(bb_width) 이상이어야 한다");

    // 림 무는 단차 지름(rim-grip diameter) — 보어+허브에 닫힌 면 띠의 절반을 더해 외륜 림만 축방향으로 지지한다.
    rim_grip_diameter = bore + hub + bb_bearing_shield_thickness(type) / 2;

    // 바닥면 기준 음형 — 외륜 카운터보어가 바닥면에 열린다.
    // from_top이면 이 음형을 판 중립면 기준으로 뒤집어 윗면으로 연다(모든 시트 모듈이 쓰는 동일 패턴).
    module pocket() {
        // 관통 보어(through bore) — 부품 전체 깊이를 림 무는 지름으로 관통한다.
        translate_z(-eps)
            cylinder(h = part_thickness + eps * 2, d = rim_grip_diameter + shaft_clearance);

        // 안착 카운터보어(counterbore) — 외륜을 베어링 폭만큼 앉히는 자리.
        translate_z(-eps)
            cylinder(h = width + eps, d = diameter + bearing_clearance);
    }

    if (from_top)
        translate_z(part_thickness) mirror([0, 0, 1]) pocket();
    else
        pocket();
}

//! 내륜 보스(inner-race boss) 양형(positive) — 인접 부품과 내륜(inner race) 사이를 띄우는 동축 링 스페이서.
//! 내륜 외경(inner-race outside diameter)까지만 닿아 외륜·실드를 건드리지 않고 회전 간섭을 막는다.
module bb_bearing_inner_race_boss(type, height = seat_shoulder_thickness) {
    id = bb_bore(type) + shaft_clearance;
    od = id + bb_hub(type) + bearing_clearance;

    linear_extrude(height)
        difference() {
            circle(d = od);
            circle(d = id);
        }
}

// 미리보기(preview) — 내륜 보스(양형)와, 시험 블록에 깎은 시트 포켓(음형)을 나란히 보여준다.
if ($preview) {
    bb_bearing_inner_race_boss(BB608);
    translate([30, 0, 0])
        difference() {
            cylinder(h = 10, d = bb_diameter(BB608) + 6);
            bb_bearing_seat_pocket(BB608, part_thickness = 10);
        }
}
