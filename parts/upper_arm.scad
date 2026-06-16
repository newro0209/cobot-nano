// plates/upper_arm.scad - Upper arm link profile with BB6201 bearing-seat plate preview.
// BB6201 proximal bearing seat and M8 distal shaft load path.
//
// 상완 링크(upper arm link) — 어깨 관절(shoulder joint)과 팔꿈치 관절(elbow joint) 사이의 절단 프로파일(cut profile).
// 근위 피벗(proximal pivot) — BB6201 베어링(bearing) 기반 어깨 축 지지.
// 원위 피벗(distal pivot) — M8 샤프트(shaft) 기반 팔꿈치 회전축(revolute axis).

include <../config.scad>
use <NopSCADLib/vitamins/ball_bearings.scad>
use <../plates/bearing_inner_race_boss.scad>

function upper_arm_length() = MAX_REACH * 0.55;
function upper_arm_plate_width() = 32;
function upper_arm_plate_thickness() = bb_width(BB608) + bearing_shoulder_thickness;

module ua_2d() {
    length            = upper_arm_length();
    width             = upper_arm_plate_width();
    half_width        = width / 2;

    proximal_race_span = bb_diameter(BB608) - bb_bore(BB608) - bb_rim(BB608) - bb_hub(BB608);  // 롤링 트랙(rolling track) 지름 구간 — 외륜·내륜 숄더 제외 후 남은 공간
    proximal_id        = bb_diameter(BB608) - proximal_race_span / 2;
    proximal_od        = max(bb_diameter(BB608) + half_width, half_width);
    distal_race_span   = bb_diameter(BB608)  - bb_bore(BB608)  - bb_rim(BB608)  - bb_hub(BB608);
    distal_id          = bb_diameter(BB608)  - distal_race_span / 2;
    distal_od          = max(bb_diameter(BB608)  + half_width, half_width);

    difference() {
        union() {
            hull() {
                circle(d = proximal_od);
                translate([length, 0]) circle(d = distal_od);
            }
        }

        // 경량화 컷아웃(lightening cutout) — 외곽 웹(web)과 질량 감소.
        offset(r = distal_id / 4) offset(r = -distal_id / 4)
        difference() {
            offset(r = -half_width / 2)
            hull() {
                circle(d = proximal_od);
                translate([length, 0]) circle(d = distal_od);
            }

            circle(d = proximal_od);
            translate([length, 0]) circle(d = distal_od);
        }

        // J2 어깨 축
        circle(d = proximal_id);
        // J3 팔꿈치 축
        translate([length, 0]) circle(d = distal_id + bearing_clearance);        
    }
}

module upper_arm_plate() {
    distal_pocket_z = upper_arm_plate_thickness() - bb_width(BB608);  // BB608 포켓 시작 z — 판재 상면에서 베어링 폭만큼 내려온 위치

    difference() {
        // 2D 상완 프로파일 압출 — BB6201 베어링 시트(bearing seat) 지지 여유.
        linear_extrude(upper_arm_plate_thickness())
            ua_2d();

        // 근위 베어링 시트 포켓(bearing seat pocket) — 외륜(outer race) 반경 구속.
        translate([0, 0, bearing_shoulder_thickness])
            cylinder(h = bb_width(BB608) + boolean_epsilon, d = bb_diameter(BB608) + bearing_clearance);

        // 원위 베어링 시트 포켓(bearing seat pocket)
        translate([upper_arm_length(), 0, distal_pocket_z])
            cylinder(h = bb_width(BB608) + boolean_epsilon, d = bb_diameter(BB608) + bearing_clearance);
    }
}

ua_j2_bearing_center_z = bearing_shoulder_thickness + bb_width(BB608) / 2;
ua_j3_bearing_center_z = upper_arm_plate_thickness() - bb_width(BB608) / 2;

upper_arm_plate();
// translate([0, 0, ua_bb6201_center_z]) ball_bearing(BB6201);
// translate([upper_arm_length(), 0, ua_bb608_center_z]) ball_bearing(BB608);