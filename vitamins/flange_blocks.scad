// vitamins/flange_blocks.scad - Local flange-mount bearing-block family (KFL), not present in NopSCADlib.
// A KFL flange block bolts flat onto a plate and carries a self-aligning insert ball bearing whose axis is
// PERPENDICULAR to the flange, so a vertical lead screw runs through it and rotates. NopSCADlib only ships KP pillow
// blocks (axis parallel to base), so this local family mirrors NopSCADlib's family-per-file vitamin style.
//
// 로컬 플랜지 베어링 블록(KFL) 패밀리 — NopSCADlib에 없어 새로 둔다.
// KFL 블록은 다이아몬드(2볼트) 아연 다이캐스트 플랜지가 판에 평면 체결되고, 자동조심(self-aligning) 인서트 볼 베어링 축이
// 플랜지에 수직이라 수직 리드스크류가 관통해 회전한다. NopSCADlib는 KP 필로블록(축이 베이스와 평행)만 제공해 로컬로 미러링한다.
// 치수는 KFL08 제품 도면 기준(docs/images/kfl08_reference.png) — a=48, b=27, e=37, s=5, Z=11.5, l=8.5, n=3.5, g=4.5, bore 8.

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>
include <NopSCADlib/vitamins/ball_bearings.scad>

//                   code      bore  length  width  flange_t  bolt_pitch  bolt_hole_d  bolt_screw     housing_d  height  collar_h  bearing
KFL08    = ["KFL08",  8,    48,     27,    4.5,      37,         5,           M4_cap_screw,  26,        11.5,   3.5,      BB608];

flange_blocks = [KFL08];

function kfl_bore(type)             = type[1];  //! Shaft bore diameter
function kfl_length(type)           = type[2];  //! Flange overall length a (across the bolt ears)
function kfl_width(type)            = type[3];  //! Flange width b (across the housing)
function kfl_thickness(type)        = type[4];  //! Flange ear plate thickness g
function kfl_bolt_pitch(type)       = type[5];  //! Distance e between the two mounting holes
function kfl_bolt_hole_diameter(type) = type[6]; //! Mounting hole diameter s
function kfl_screw(type)            = type[7];  //! Mounting screw type
function kfl_housing_diameter(type) = type[8];  //! Bearing housing diameter
function kfl_height(type)           = type[9];  //! Total height Z, flange face to housing front
function kfl_collar_height(type)    = type[10]; //! Inner-race collar height n (carries the set screws)
function kfl_bearing(type)          = type[11]; //! Reference ball-bearing type (bore/OD basis)

module kfl_screw_positions(type) { //! Place children at the two mounting-hole centres on the flange face
    for (x = [-1, 1])
        translate([x * kfl_bolt_pitch(type) / 2, 0, 0])
            children();
}

// 모서리를 깎은 링 단면(chamfered ring) — rotate_extrude로 돌려 외/내륜의 살짝 둥근(배럴) 외형을 만든다.
module kfl_chamfered_ring(id, od, h, chamfer = 0.8) {
    rotate_extrude(convexity = 4)
        polygon([
            [id / 2, 0], [od / 2 - chamfer, 0], [od / 2, chamfer],
            [od / 2, h - chamfer], [od / 2 - chamfer, h], [id / 2, h],
        ]);
}

module flange_bearing(type) { //! Draw a KFL flange bearing block, flange in XY (z = 0 face mounts down), bore up the Z axis
    vitamin(str("flange_bearing(", type[0], "): KFL", kfl_bore(type),
                " flange bearing block, ", bb_name(kfl_bearing(type)), "-class insert"));

    bore      = kfl_bore(type);
    length    = kfl_length(type);
    width     = kfl_width(type);
    t         = kfl_thickness(type);
    pitch     = kfl_bolt_pitch(type);
    hole_d    = kfl_bolt_hole_diameter(type);
    housing_d = kfl_housing_diameter(type);
    Z         = kfl_height(type);
    ear_d     = length - pitch;            // 볼트 이어(ear) 지름 — 전체 길이에서 볼트 피치를 뺀 로브 폭
    seat_d    = housing_d - 6;             // 베어링 외륜 시트(outer-race seat) 지름
    race_w    = 8.5;                        // 외륜 폭 l
    race_z    = (Z - race_w) / 2 + 0.5;    // 외륜 축방향 위치(앞쪽으로 약간 치우침)
    inner_od  = seat_d - 4;                // 내륜 외경

    // ── 아연 다이캐스트 플랜지 + 하우징(zinc die-cast flange + housing) ──
    color(grey(82))
        difference() {
            union() {
                // 다이아몬드 플랜지(diamond flange) — 가운데 하우징 원과 양끝 볼트 이어를 hull로 잇는 2볼트 로브 형상.
                linear_extrude(t)
                    hull() {
                        circle(d = width);
                        for (x = [-1, 1])
                            translate([x * pitch / 2, 0])
                                circle(d = ear_d);
                    }
                // 베어링 하우징 보스(bearing housing boss) — 인서트 베어링을 품는 중앙 원통.
                cylinder(d = housing_d, h = Z);
            }

            // 베어링 외륜 시트(outer-race seat) — 외륜이 앉는 관통 보어. 구면 자동조심을 단순화한 원통 시트.
            translate_z(-eps)
                cylinder(d = seat_d, h = Z + 2 * eps);

            // 마운팅 볼트 홀(mounting holes) — 도면 s=5 관통 홀.
            kfl_screw_positions(type)
                translate_z(-eps)
                    cylinder(d = hole_d, h = t + 2 * eps);
        }

    // ── 인서트 볼 베어링(insert ball bearing) — 외륜·실드·내륜+칼라·세트 스크류 ──
    // 외륜(outer race) — 시트에 앉는 강체 링, 모서리를 깎아 구면 자동조심 외형을 흉내낸다.
    color(grey(50))
        translate_z(race_z)
            kfl_chamfered_ring(inner_od - 1, seat_d, race_w);

    // 실드(shield) — 외륜 앞면의 검은 고무 실(seal).
    color(grey(18))
        translate_z(race_z + race_w - 0.6)
            kfl_chamfered_ring(bore + 1.5, seat_d - 1, 0.6, chamfer = 0.2);

    // 내륜 + 칼라(inner race + collar) — 보어로 축을 받고, 칼라가 앞으로 돌출해 세트 스크류로 축에 고정된다.
    color(grey(58))
        difference() {
            union() {
                translate_z(race_z)
                    cylinder(d = inner_od, h = race_w);
                // 칼라(collar) — 앞면으로 n 만큼 돌출.
                translate_z(race_z + race_w - eps)
                    cylinder(d = inner_od - 2, h = kfl_collar_height(type));
            }
            translate_z(-eps)
                cylinder(d = bore, h = Z + 2 * eps);
        }

    // 세트 스크류(set screws) — 칼라에서 축을 반경으로 죄는 2개의 멈춤나사.
    color(grey(28))
        translate_z(race_z + race_w + kfl_collar_height(type) / 2)
            for (a = [40, 160])
                rotate(a)
                    translate([(inner_od - 2) / 2 - 1, 0, 0])
                        rotate([0, 90, 0])
                            cylinder(d = 2.6, h = 1.5);
}
