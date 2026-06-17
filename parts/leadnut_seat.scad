// parts/leadnut_seat.scad - Lead-nut seat geometry cut into printed plates (NopSCADlib printed-part style).
// Negative for difference(), parameterised by a NopSCADlib leadnut type: a lead-screw clearance bore, a flange
// recess + body recess that countersink the nut into the plate, and the flange mounting-screw clearance holes.
// from_top selects which face the nut seats into, so the top plate and the mirrored bottom plate can share it.
//
// 리드너트를 판재에 묻기 위해 깎는 음형(negative) 제작 형상이다. 구입 부품(vitamin)이 아니라 가공 형상이라 parts/에 둔다.
// 치수는 NopSCADlib leadnut 타입(LSN8x2 등)에서 접근자(leadnut_*)로 읽어 하드코딩을 피한다.
// 리드스크류 관통 보어 + 플랜지·몸통 리세스(너트를 판에 묻음) + 플랜지 고정 스크류 클리어런스 홀로 이루어진다.
// from_top으로 너트가 묻히는 면을 골라, 상판과 반대로 묻히는 하판이 같은 모듈을 공유한다.

include <../config.scad>

//! 리드너트 시트(lead-nut seat) 음형(negative) — 원점에서 만드는 동축 리세스 + 관통 홀. difference() 피연산자.
//! 가장 깊은 본체 리세스는 바닥에 seat_shoulder_thickness만 남겨 너트를 축방향으로 받치고(back-stop), 리드스크류는 그 shoulder를 자유 관통하며, 플랜지 스크류로 죈다.
//! from_top=false면 바닥면, true면 윗면으로 열린다(판 중립면 기준 대칭).
module leadnut_seat_pocket(type, part_thickness, from_top = false) {
    bore       = leadnut_bore(type);
    flange_dia = leadnut_flange_dia(type);
    flange_t   = leadnut_flange_t(type);
    od         = leadnut_od(type);
    hole_dia   = leadnut_hole_dia(type);

    // 가장 깊은 본체 리세스가 바닥에 seat_shoulder_thickness만 남기려면, 플랜지 두께보다 더 깊이 들어갈 여유가 있어야 한다.
    assert(part_thickness - seat_shoulder_thickness > flange_t,
           "part_thickness는 리드너트 플랜지 두께 + seat_shoulder_thickness보다 커야 한다");

    // 바닥면 기준 음형 — 플랜지가 z=0 면에 묻히고 몸통이 그 위로 솟는다. from_top이면 이 음형을 판 중립면 기준으로
    // 뒤집어 윗면으로 연다(비대칭 스택을 면마다 다시 쓰지 않고 mirror로 일관되게 뒤집는다).
    module pocket() {
        // 리드스크류 관통 보어(lead-screw clearance bore) — T8 스크류가 판을 자유 관통하도록 너트 보어에 여유를 더한다.
        translate_z(-eps)
            cylinder(d = bore + shaft_clearance, h = part_thickness + eps * 2);

        // 플랜지 리세스(flange recess) — 너트 플랜지 디스크가 바닥면에 평면으로 묻히는 카운터보어.
        translate_z(-eps)
            cylinder(d = flange_dia + bearing_clearance, h = flange_t + eps * 2);

        // 본체 리세스(body recess, 가장 깊은 리세스) — 플랜지 아래 너트 몸통(od)을 받아, 바닥에 seat_shoulder_thickness만
        // 남기고 판 깊이 판다. 남은 shoulder는 리드스크류 보어만 관통해 너트의 축방향 받침(back-stop)이 된다.
        translate_z(flange_t)
            cylinder(d = od + bearing_clearance, h = part_thickness - seat_shoulder_thickness - flange_t + eps);

        // 플랜지 고정 스크류 홀(flange screw holes) — 플랜지 볼트 위치에서 판을 지나 너트를 죄는 클리어런스 홀.
        leadnut_screw_positions(type)
            translate_z(-flange_t - eps)
                cylinder(d = hole_dia + shaft_clearance, h = part_thickness + eps * 2);
    }

    if (from_top)
        translate_z(part_thickness) mirror([0, 0, 1]) pocket();
    else
        pocket();
}

// 미리보기(preview) — 시험 블록 양쪽에 깎은 리드너트 시트(음형): 왼쪽 바닥 열림, 오른쪽 윗면 열림.
if ($preview) {
    difference() {
        cylinder(h = 10, d = leadnut_flange_dia(LSN8x2) + 6);
        leadnut_seat_pocket(LSN8x2, part_thickness = 10);
    }
    translate([leadnut_flange_dia(LSN8x2) + 16, 0, 0])
        difference() {
            cylinder(h = 10, d = leadnut_flange_dia(LSN8x2) + 6);
            leadnut_seat_pocket(LSN8x2, part_thickness = 10, from_top = true);
        }
}
