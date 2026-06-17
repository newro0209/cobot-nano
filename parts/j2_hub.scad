// parts/j2_hub.scad - Upper-arm mounting hub on the J2 (shoulder) axis (NopSCADlib printed-part style).
// The hub clamps to the rotating J2 output around the shoulder bolt and presents an M3 bolt circle for the upper arm.
// An inner-race boss stands the hub body off the bearing so it grips only the spinning inner race, clear of the
// stationary shield and outer race. One hub above the top plate and one below the housing serve either face.
//
// J2(어깨 관절, shoulder joint) 축의 상완 장착 허브 — 숄더 볼트 둘레에서 J2 회전 출력(driven output)에 물려 돌고, 상완(upper arm)용 M3 볼트원(bolt circle)을 낸다.
// 내륜 보스(inner-race boss)가 허브 몸체를 베어링에서 띄워, 정지한 실드·외륜을 건드리지 않고 회전 내륜만 짚게 한다. 상완을 위·아래 어느 면에서든 연결한다.

include <../config.scad>

j2_hub_bore_diameter            = bb_bore(BB608) + shaft_clearance;  // 숄더 볼트 8mm 축이 지나는 중심 보어
j2_hub_arm_screw                = M3_cap_screw;                      // 상완 체결 스크류
j2_hub_arm_screw_count          = 4;
j2_hub_arm_bolt_circle_diameter = 24;                               // 상완 볼트원 지름
j2_hub_diameter                 = 34;                               // 허브 외경 — 볼트원 + 머리/벽 여유
j2_hub_thickness                = 6;
j2_hub_boss_diameter            = bb_bore(BB608) + 4;               // 내륜(inner race) 외경 근사 — 보스가 회전 내륜만 짚는다

// 내륜 보스 높이(inner-race boss height) — 허브 몸체를 베어링 실드/외륜 위로 띄워 회전 허브가 정지부에 안 닿게 한다(접근자: 조립부가 이만큼 허브를 벌린다).
function j2_hub_boss_height() = 3;

// 허브 전체 높이(boss + disc) — 숄더 볼트 스택이 양끝 허브를 덮도록 조립부가 이만큼 머리·너트를 바깥으로 민다.
function j2_hub_height() = j2_hub_boss_height() + j2_hub_thickness;

assert(j2_hub_arm_bolt_circle_diameter + 2 * screw_clearance_radius(j2_hub_arm_screw) < j2_hub_diameter,
       "상완 볼트원은 허브 외경 안에 들어와야 한다");
assert(j2_hub_arm_bolt_circle_diameter > j2_hub_boss_diameter,
       "상완 볼트원은 내륜 보스 바깥에 있어야 한다");
assert(j2_hub_boss_diameter > j2_hub_bore_diameter,
       "내륜 보스 외경은 중심 보어보다 커야 한다");

module j2_hub() {
    difference() {
        union() {
            // 허브 디스크(hub disc) — 상완 볼트원을 내는 본체.
            cylinder(d = j2_hub_diameter, h = j2_hub_thickness);

            // 내륜 보스(inner-race boss) — 베어링 쪽(−z)으로 돌출해 회전 내륜만 짚고, 허브 몸체를 실드·외륜 위로 띄운다.
            translate_z(-j2_hub_boss_height())
                cylinder(d = j2_hub_boss_diameter, h = j2_hub_boss_height() + eps);
        }

        // 중심 보어(center bore) — 숄더 볼트(shoulder bolt) 축이 보스·디스크를 함께 관통한다.
        translate_z(-j2_hub_boss_height() - eps)
            cylinder(d = j2_hub_bore_diameter, h = j2_hub_boss_height() + j2_hub_thickness + 2 * eps);

        // 상완 볼트원(bolt circle) — 디스크에 M3 클리어런스 홀을 등각으로 배치.
        for (i = [0 : j2_hub_arm_screw_count - 1])
            rotate([0, 0, i * 360 / j2_hub_arm_screw_count])
                translate([j2_hub_arm_bolt_circle_diameter / 2, 0, -eps])
                    cylinder(r = screw_clearance_radius(j2_hub_arm_screw), h = j2_hub_thickness + 2 * eps);
    }
}

j2_hub();
