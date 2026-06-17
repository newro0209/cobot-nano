// vitamins/flange_couplers.scad - Local flange shaft-coupler family, not present in NopSCADlib.
// A flange coupler clamps onto a round shaft through a central hub (grub screw) and presents a round flange with a
// bolt circle, so bolting the flange flat onto a plate fixes the shaft PERPENDICULAR to it. Used here to anchor the
// guide-rod ends to the column end plates. Mirrors NopSCADlib's family-per-file vitamin style.
//
// 로컬 플랜지 샤프트 커플러(flange coupler) 패밀리 — NopSCADlib에 없어 새로 둔다.
// 플랜지 커플러는 중앙 허브(hub)로 매끈 봉을 멈춤나사(grub screw)로 죄고, 볼트원(bolt circle)이 있는 원형 플랜지를 낸다.
// 플랜지를 판에 평면 체결하면 봉이 판에 수직으로 고정된다 — 여기선 가이드 로드 끝을 단판에 고정한다.
// 치수는 일반 8mm 플랜지 커플러 공칭값(nominal) — 실제 구매 전 공급사 도면으로 확인한다.

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

//                code    bore  flange_d  flange_t  bolt_circle  bolt_count  bolt_screw     hub_d  hub_h  grub_screw
FC8      = ["FC8",   8,    22,       5,        16,          4,          M4_cap_screw,  13,    8,     M4_grub_screw];

flange_couplers = [FC8];

function fc_bore(type)           = type[1]; //! Shaft bore diameter
function fc_flange_diameter(type)= type[2]; //! Flange outer diameter
function fc_flange_thickness(type)= type[3]; //! Flange plate thickness
function fc_bolt_circle(type)    = type[4]; //! Mounting bolt-circle diameter
function fc_bolt_count(type)     = type[5]; //! Number of mounting holes
function fc_screw(type)          = type[6]; //! Mounting screw type
function fc_hub_diameter(type)   = type[7]; //! Clamp hub diameter
function fc_hub_height(type)     = type[8]; //! Clamp hub height above the flange
function fc_grub_screw(type)     = type[9]; //! Hub grub screw type
function fc_height(type)         = fc_flange_thickness(type) + fc_hub_height(type); //! Total height, flange face to hub top

module fc_screw_positions(type) { //! Place children at the mounting holes around the bolt circle, on the flange face
    for (i = [0 : fc_bolt_count(type) - 1])
        rotate(i * 360 / fc_bolt_count(type))
            translate([fc_bolt_circle(type) / 2, 0, 0])
                children();
}

module flange_coupler(type) { //! Draw a flange shaft coupler, flange in XY (z = 0 face mounts down), bore up the Z axis
    vitamin(str("flange_coupler(", type[0], "): ", fc_bore(type), "mm flange shaft coupler"));

    bore = fc_bore(type);
    fd   = fc_flange_diameter(type);
    ft   = fc_flange_thickness(type);
    hd   = fc_hub_diameter(type);
    hh   = fc_hub_height(type);

    color(grey(80))
        difference() {
            union() {
                // 플랜지 디스크(flange disc) — 볼트원으로 판에 평면 체결되는 원형 베이스.
                linear_extrude(ft)
                    circle(d = fd);

                // 클램프 허브(clamp hub) — 봉을 멈춤나사로 죄어 축방향·반경 위치를 고정한다.
                translate_z(ft - eps)
                    cylinder(d = hd, h = hh + eps);
            }

            // 봉 보어(shaft bore) — 축이 플랜지에 수직으로 관통한다.
            translate_z(-eps)
                cylinder(d = bore, h = fc_height(type) + 2 * eps);

            // 마운팅 볼트 홀(mounting holes) — 볼트원 위 관통 홀로 플랜지를 판에 무다.
            fc_screw_positions(type)
                translate_z(-eps)
                    cylinder(r = screw_clearance_radius(fc_screw(type)), h = ft + 2 * eps);

            // 허브 멈춤나사 홀(grub screw hole) — 허브 옆에서 봉을 반경으로 죈다.
            translate_z(ft + hh / 2)
                rotate([0, 90, 0])
                    cylinder(r = screw_clearance_radius(fc_grub_screw(type)), h = hd / 2 + eps);
        }
}
