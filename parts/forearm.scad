// plates/forearm.scad - Forearm link profile with horn pin and bearing-seat plate preview.
// BB608 proximal bearing seat, 5mm wrist-side shaft, and 5mm horn-pin load path.
//
// 전완 링크(forearm link) — 팔꿈치 관절(elbow joint)과 손목 관절(wrist joint) 사이의 절단 프로파일(cut profile).
// 근위 피벗(proximal pivot) — BB608 베어링(bearing) 기반 팔꿈치 축 지지.
// 원위 피벗(distal pivot)과 혼 핀(horn pin) — 5mm 샤프트(shaft) 기반 손목 축 및 구동 하중(actuation load) 전달.
include <../config.scad>
use <NopSCADLib/vitamins/ball_bearings.scad>
use <upper_arm.scad>
use <../plates/bearing_inner_race_boss.scad>

function forearm_length() = MAX_REACH - upper_arm_length();
function forearm_plate_width() = 24;
function forearm_plate_thickness() = plate_thickness;
function forearm_plate_distal_pivot_diameter() = 5; // M5 손목 샤프트(wrist shaft) — 공칭 지름(nominal diameter, 호칭 치수).
function forearm_plate_horn_pin_diameter() = 5; // M5 혼 핀(horn pin) — 공칭 지름(nominal diameter, 호칭 치수).
function forearm_plate_proximal_boss_engagement() = 2; // 보스(boss)가 BB608 내륜(inner race)에 확실히 안착하도록 추가하는 축방향 여유(axial engagement margin)
function forearm_plate_proximal_boss_height() = upper_arm_plate_thickness() - bb_width(BB608) + forearm_plate_proximal_boss_engagement();

module fa_2d() {
    length            = forearm_length();
    width             = forearm_plate_width();
    half_width        = width / 2;

    horn_angle        = 180;
    horn_length       = upper_arm_length() - length;
    horn_position     = [horn_length * cos(horn_angle), horn_length * sin(horn_angle)];
    horn_pin_id       = forearm_plate_horn_pin_diameter();
    horn_pin_od       = max(horn_pin_id + half_width, half_width);

    proximal_id       = bb_bore(BB608);
    proximal_od       = max(bb_bore(BB608) + half_width, half_width);
    distal_id         = forearm_plate_distal_pivot_diameter();
    distal_od         = max(distal_id + half_width, half_width);

    difference() {
        union() {
            hull() {
                translate(horn_position) circle(d = horn_pin_od);
                circle(d = proximal_od);
                translate([length, 0]) circle(d = distal_od);
            }
        }

        // 경량화 컷아웃(lightening cutout) — 팔꿈치-손목 웹(web)과 말단 질량 감소.
        offset(r = distal_id / 2) offset(r = -distal_id / 2)
        difference() {
            offset(r = -half_width / 2)
            hull() {
                circle(d = proximal_od);
                translate([length, 0]) circle(d = distal_od);
            }

            circle(d = proximal_od);
            translate([length, 0]) circle(d = distal_od);
        }

        // J3 팔꿈치 축
        // 근위 피벗 구멍
        circle(d = proximal_id);

        // J4 손목 축
        // 원위 피벗 구멍(distal pivot hole) — 손목 샤프트(wrist shaft) 회전 조인트(revolute joint) 여유(clearance).
        translate([length, 0]) circle(d = distal_id + shaft_clearance);

        // 혼 핀 구멍(horn pin hole) — 핀 조인트(pin joint) 전단 하중(shear load) 전달 위치.
        translate(horn_position) circle(d = horn_pin_id + shaft_clearance);
    }
}

module forearm_plate() {
    // 2D 전완 프로파일 압출 — BB608 베어링 시트(bearing seat) 지지 여유.
    linear_extrude(forearm_plate_thickness())
        fa_2d();
    // 근위 피벗 보스
    translate([0, 0, forearm_plate_thickness()]) bearing_inner_race_boss(BB608, forearm_plate_proximal_boss_height());
}

forearm_plate();