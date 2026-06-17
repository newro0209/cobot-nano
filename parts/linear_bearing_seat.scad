// parts/linear_bearing_seat.scad - Linear-bearing seat geometry cut into printed plates (NopSCADlib printed-part style).
// Negative for difference(), parameterised by a NopSCADlib linear-bearing type: a blind counterbore at the bearing OD
// that seats an LMxUU bush, leaving a shoulder at the far face so the bearing cannot push through.
// from_top selects which face the bearing seats into, so the top plate and the mirrored bottom plate can share it.
//
// 선형(직선) 베어링을 판재에 앉히기 위해 깎는 음형(negative) 제작 형상이다. 구입 부품(vitamin)이 아니라 가공 형상이라 parts/에 둔다.
// 치수는 NopSCADlib linear-bearing 타입(LM8UU 등)에서 접근자(bearing_*)로 읽어 하드코딩을 피한다.
// 가이드 로드 관통홀은 판 블랭크가 이미 뚫으므로, 여기서는 그 위에 베어링 외경 시트(막힌 카운터보어)만 덧깎는다.
// from_top으로 베어링이 앉는 면을 골라, 상판과 반대로 앉히는 하판이 같은 모듈을 공유한다.

include <../config.scad>

//! 선형 베어링 시트(linear-bearing seat) 음형(negative) — 원점에서 베어링 외경으로 깎는 카운터보어. difference() 피연산자.
//! seat_depth가 지정되면 그 깊이만 얕게 파고, 생략하면 기존처럼 part_thickness - shoulder 깊이로 판다.
//! from_top=false면 바닥면, true면 윗면으로 열린다(판 중립면 기준 대칭).
module linear_bearing_seat_pocket(type, part_thickness, seat_depth = undef, shoulder = seat_shoulder_thickness, from_top = false) {
    depth = is_undef(seat_depth) ? part_thickness - shoulder : seat_depth;

    assert(depth > 0, "seat_depth는 0보다 커야 한다");
    assert(depth <= part_thickness, "seat_depth는 part_thickness 이하여야 한다");

    // 바닥면 기준 음형 — 베어링 외경 시트가 바닥면에 열리고 단차는 윗면에 남는다.
    // from_top이면 이 음형을 판 중립면 기준으로 뒤집어 윗면으로 연다(모든 시트 모듈이 쓰는 동일 패턴).
    module pocket() {
        translate_z(-eps)
            cylinder(d = bearing_dia(type) + bearing_clearance, h = depth + eps);
    }

    if (from_top)
        translate_z(part_thickness) mirror([0, 0, 1]) pocket();
    else
        pocket();
}

//! 선형 베어링 시트(linear-bearing seat) 양형(positive) — 리세스와 반대로 판 안쪽으로 솟은 외곽 칼라.
//! 베어링 OD 안쪽은 비워 두고, OD보다 큰 바깥 림만 돌출시켜 베어링 외경을 감싼다.
module linear_bearing_seat_boss(type, part_thickness, height, wall = min_printed_feature, from_top = false) {
    collar_id = bearing_dia(type) + bearing_clearance;
    collar_od = collar_id + 2 * wall;

    assert(height > 0, "height는 0보다 커야 한다");
    assert(wall > 0, "wall은 0보다 커야 한다");
    assert(collar_od > collar_id, "linear bearing boss collar OD는 ID보다 커야 한다");

    module boss() {
        linear_extrude(height = height + eps)
            difference() {
                circle(d = collar_od);
                circle(d = collar_id);
            }
    }

    if (from_top)
        translate_z(part_thickness - eps) boss();
    else
        translate_z(-height) boss();
}

// 미리보기(preview) — 시험 블록 양쪽에 깎은 선형 베어링 시트(음형): 왼쪽 바닥 열림, 오른쪽 윗면 열림.
if ($preview) {
    difference() {
        cylinder(h = 10, d = bearing_dia(LM8UU) + 6);
        linear_bearing_seat_pocket(LM8UU, part_thickness = 10);
    }
    translate([bearing_dia(LM8UU) + 16, 0, 0])
        difference() {
            cylinder(h = 10, d = bearing_dia(LM8UU) + 6);
            linear_bearing_seat_pocket(LM8UU, part_thickness = 10, from_top = true);
        }
}
