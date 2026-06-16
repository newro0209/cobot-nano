include <../config.scad>
use <../plates/upper_arm.scad>

e = 0;
module elbow_assembly() {
    upper_arm_plate();

    // // J3 팔꿈치 관절 축 체결 — M8 캡 스크류(cap screw) + 와셔(washer) × 2 + 나일록 너트(nyloc nut)
    // // 볼트 헤드 +y, 나일록 너트 -y. rotate([-90,0,0])으로 NopSCADlib z축을 조립체 y축에 정렬
    // translate([upper_arm_length(), 0, 0]) {
    //     // 헤드 측 와셔(head-side washer)
    //     translate([0, elbow_half_span, 0])
    //         rotate([-90, 0, 0])
    //             washer(M8_washer);

    //     // M8 캡 스크류 — 헤드 +y
    //     translate([0, elbow_half_span + washer_thickness(M8_washer), 0])
    //         rotate([-90, 0, 0])
    //             screw(M8_cap_screw, elbow_bolt_length);

    //     // 너트 측 와셔(nut-side washer)
    //     translate([0, -(elbow_half_span + washer_thickness(M8_washer)), 0])
    //         rotate([-90, 0, 0])
    //             washer(M8_washer);

    //     // M8 나일록 너트(nyloc nut) — 축방향 하중(axial load)에서 자동 풀림 방지(self-locking)
    //     translate([0, -(elbow_half_span + washer_thickness(M8_washer) + nut_thickness(M8_nut, true)), 0])
    //         rotate([-90, 0, 0])
    //             nut(M8_nut, nyloc = true);
    // }
}

elbow_assembly();
