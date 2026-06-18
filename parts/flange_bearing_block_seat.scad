// parts/flange_bearing_block_seat.scad - KFL flange-bearing-block seat geometry cut into printed plates.
// Negative for difference(), parameterised by a local KFL type such as KFL08: a shallow diamond-flange recess,
// the lead-screw through-bore, and the flange mounting-screw clearance holes.
//
// KFL 플랜지 베어링 블록 시트 음형 — KFL08 다이아몬드 플랜지를 판에 살짝 묻기 위한 리세스,
// 리드스크류 관통 보어, 플랜지 고정 스크류 클리어런스 홀을 만든다.

include <../config.scad>

//! KFL 플랜지 베어링 블록 시트 음형. from_top=false면 바닥면, true면 윗면으로 열린다.
module kfl_flange_bearing_block_seat_pocket(type, part_thickness, from_top = false) {
    recess_depth = min(kfl_thickness(type), part_thickness - seat_shoulder_thickness);
    ear_diameter = kfl_length(type) - kfl_bolt_pitch(type);

    assert(recess_depth > 0, "KFL 시트 리세스 깊이는 0보다 커야 한다");
    assert(recess_depth <= part_thickness, "KFL 시트 리세스 깊이는 판 두께 이하여야 한다");
    assert(ear_diameter > 0, "KFL 볼트 이어 지름은 0보다 커야 한다");

    module flange_profile_2d() {
        hull() {
            circle(d = kfl_width(type) + clearance);
            for (x = [-1, 1])
                translate([x * kfl_bolt_pitch(type) / 2, 0])
                    circle(d = ear_diameter + clearance);
        }
    }

    module pocket() {
        // 다이아몬드 플랜지 리세스 — KFL 플랜지를 판 표면 안으로 묻어 위치를 잡는다.
        translate_z(-eps)
            linear_extrude(height = recess_depth + eps)
                flange_profile_2d();

        // 리드스크류 관통 보어.
        translate_z(-eps)
            cylinder(d = kfl_bore(type) + shaft_clearance, h = part_thickness + eps * 2);

        // 플랜지 고정 스크류 홀.
        kfl_screw_positions(type)
            translate_z(-eps)
                cylinder(r = screw_clearance_radius(kfl_screw(type)), h = part_thickness + eps * 2);
    }

    if (from_top)
        translate_z(part_thickness) mirror([0, 0, 1]) pocket();
    else
        pocket();
}

if ($preview) {
    difference() {
        cylinder(d = kfl_length(KFL08) + 10, h = 8);
        kfl_flange_bearing_block_seat_pocket(KFL08, part_thickness = 8, from_top = true);
    }
}
