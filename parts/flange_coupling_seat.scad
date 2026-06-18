// parts/flange_coupling_seat.scad - Flange-coupling seat geometry cut into printed plates.
// Negative for difference(), parameterised by a local flange-coupling type such as FC8: a shallow circular flange
// recess, the shaft through-bore, and the flange mounting-screw clearance holes.
//
// 플랜지 커플링 시트 음형 — FC8 같은 플랜지 커플링을 판에 살짝 묻기 위한 원형 플랜지 리세스,
// 샤프트 관통 보어, 플랜지 고정 스크류 클리어런스 홀을 만든다.

include <../config.scad>

//! 플랜지 커플링 시트(flange-coupling seat) 음형. from_top=false면 바닥면, true면 윗면으로 열린다.
module fc_flange_coupling_seat_pocket(type, part_thickness, from_top = false) {
    recess_depth = min(fc_flange_thickness(type), part_thickness - seat_shoulder_thickness);

    assert(recess_depth > 0, "FC 시트 리세스 깊이는 0보다 커야 한다");
    assert(recess_depth <= part_thickness, "FC 시트 리세스 깊이는 판 두께 이하여야 한다");

    module pocket() {
        // 플랜지 리세스 — 플랜지 원판을 판 표면 안으로 묻어 위치를 잡는다.
        translate_z(-eps)
            cylinder(d = fc_flange_diameter(type) + clearance, h = recess_depth + eps);

        // 샤프트 관통 보어 — 가이드 로드가 판과 커플링을 통과한다.
        translate_z(-eps)
            cylinder(d = fc_bore(type) + shaft_clearance, h = part_thickness + eps * 2);

        // 플랜지 고정 스크류 홀.
        fc_screw_positions(type)
            translate_z(-eps)
                cylinder(r = screw_clearance_radius(fc_screw(type)), h = part_thickness + eps * 2);
    }

    if (from_top)
        translate_z(part_thickness) mirror([0, 0, 1]) pocket();
    else
        pocket();
}

if ($preview) {
    difference() {
        cylinder(d = fc_flange_diameter(FC8) + 8, h = 8);
        fc_flange_coupling_seat_pocket(FC8, part_thickness = 8, from_top = true);
    }
}
