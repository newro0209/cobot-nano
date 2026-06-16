// parts/j2_hub.scad - Upper-arm mounting hub on the J2 (shoulder) axis (NopSCADlib printed-part style).
// The hub clamps to the rotating J2 output around the shoulder bolt and presents an M3 bolt circle for the upper arm.
// One hub above the top plate and one below the housing let the upper arm connect on either or both faces.
//
// J2(어깨 관절, shoulder joint) 축의 상완 장착 허브 — 숄더 볼트 둘레에서 J2 회전 출력(driven output)에 물려 돌고, 상완(upper arm)용 M3 볼트원(bolt circle)을 낸다.
// 상판 위와 하우징 아래에 하나씩 달아, 상완을 위·아래 어느 면에서든 연결할 수 있게 한다.

include <../config.scad>

j2_hub_bore_diameter            = bb_bore(BB608) + shaft_clearance;  // 숄더 볼트 8mm 축이 지나는 중심 보어
j2_hub_arm_screw                = M3_cap_screw;                      // 상완 체결 스크류
j2_hub_arm_screw_count          = 4;
j2_hub_arm_bolt_circle_diameter = 24;                               // 상완 볼트원 지름
j2_hub_diameter                 = 34;                               // 허브 외경 — 볼트원 + 머리/벽 여유
j2_hub_thickness                = 6;

assert(j2_hub_arm_bolt_circle_diameter + 2 * screw_clearance_radius(j2_hub_arm_screw) < j2_hub_diameter,
       "상완 볼트원은 허브 외경 안에 들어와야 한다");
assert(j2_hub_arm_bolt_circle_diameter > j2_hub_bore_diameter,
       "상완 볼트원은 중심 보어보다 커야 한다");

module j2_hub() {
    linear_extrude(j2_hub_thickness)
        difference() {
            circle(d = j2_hub_diameter);
            circle(d = j2_hub_bore_diameter);   // 중심 보어 — 숄더 볼트 축

            // 상완 볼트원(bolt circle) — M3 클리어런스 홀을 등각으로 배치.
            for (i = [0 : j2_hub_arm_screw_count - 1])
                rotate(i * 360 / j2_hub_arm_screw_count)
                    translate([j2_hub_arm_bolt_circle_diameter / 2, 0])
                        circle(r = screw_clearance_radius(j2_hub_arm_screw));
        }
}

j2_hub();
