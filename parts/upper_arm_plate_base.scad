// parts/upper_arm_plate_base.scad - Shared blank for the UPPER_ARM plates (NopSCADlib printed-part style).
// A two-plate sandwich link mounted above the arm carriage on the J2 (shoulder) driven axis. The proximal end clamps
// to the same J2 axis through the AC-side upper FC8 hub, the J3 motor sits coaxially at that J2 axis, and the distal
// pivot carries the J3 (elbow) BB608 bearing. The top/bottom plates include this and add their own seats.
//
// 상완(UPPER_ARM) 판 공유 블랭크 — 암 캐리지 위에서 같은 J2(어깨) 종동축에 올라타 J3(팔꿈치)까지 뻗는 두 판 샌드위치 링크.
// 근위는 AC 상단 FC8 축 허브로 J2 축에 물리고, J3 모터는 그 J2 축에 동축 배치되며,
// 원위 피벗(distal pivot)은 J3 BB608 베어링을 품는다. 상·하판이 이 파일을 include해 시트를 더한다.

include <../config.scad>
use <../utils/placement.scad>

// 판 두께 — J3 종동 베어링 폭에 시트 단차(seat shoulder)를 더해, 베어링이 폭만큼 앉고도 뒤에 받침면이 남게 한다.
ua_thickness = bb_width(j3_driven_ball_bearing_type) + seat_shoulder_thickness;

// 근위(J2) 마운트 중심 — 상완 로컬 원점. 원위(J3)는 config의 j3_elbow_axis_center(+Y).
ua_j2_axis_center = [0, 0];

// 근위 J2 마운트 로브 지름 — J2 플랜지 커플링(FC8)을 무는 마운트라 플랜지 외경을 envelope로 감싼다.
ua_j2_mount_bounding_diameter =
    bounding_diameter_with_margin(max(bb_diameter(j2_driven_ball_bearing_type),
                                      fc_flange_diameter(j2_driven_flange_coupling_type),
                                      pulley_flange_dia(j2_driven_pulley_type)), component_margin);
// 원위 J3 종동축 로브 지름 — 팔꿈치 베어링과 60T 종동 풀리 중 큰 쪽을 envelope로 감싼다.
ua_j3_driven_axis_bounding_diameter =
    bounding_diameter_with_margin(max(bb_diameter(j3_driven_ball_bearing_type),
                                      pulley_flange_dia(j3_driven_pulley_type)), component_margin);
// J3 모터 로브 지름 — 모터 바디 폭을 envelope로 감싸 시트 풋프린트를 판 안에 담는다.
ua_j3_motor_bounding_diameter =
    bounding_diameter_with_margin(NEMA_radius(j3_motor_type) * 2, component_margin);
// J3 구동 풀리 최대 외경 — 치형 외경(pulley_od)보다 플랜지가 크면 큰 쪽.
ua_j3_drive_pulley_outer_dia = max(pulley_od(j3_drive_pulley_type), pulley_flange_dia(j3_drive_pulley_type));

// J3 모터 중심 — AC J2 driven axis와 같은 축이다. 모터축의 20T 풀리가 여기서 원위 J3 60T 풀리를 구동한다.
ua_j3_motor_center = ua_j2_axis_center;

// J3 벨트 중심 거리(모터→팔꿈치) — 구동(20T)·종동(60T) 풀리가 겹치지 않을 최소 중심 거리보다 커야 한다.
ua_j3_belt_center_distance = j3_elbow_axis_center[1] - ua_j3_motor_center[1];
assert(ua_j3_belt_center_distance >
       center_distance_for_bounding_diameters(ua_j3_drive_pulley_outer_dia,
                                              pulley_flange_dia(j3_driven_pulley_type), clearance),
       "J3 구동(20T)·종동(60T) 풀리가 겹친다 — upper_arm_length를 키워라");
echo(str("J3 belt center distance (motor -> elbow) = ", ua_j3_belt_center_distance, " mm"));

// 상완 판 2D 프로파일 HOC — 링크 몸체(근위 J2 마운트/모터·원위 J3 원의 hull)에 호출부가 넘긴 2D 로브를 union하고,
// 모폴로지 닫힘(offset +r 후 -r)으로 로브 접합부의 오목 모서리를 라운딩한 뒤 압출한다(cc_plate_with_profile_2d와 같은 형태).
// 기본 링크 몸체는 볼록 hull이라 닫힘은 무연산이고, 호출부가 로브를 더해 생기는 오목 모서리만 필렛된다.
module ua_plate_with_profile_2d(thickness, rounding = 4) {
    linear_extrude(thickness)
        offset(r = -rounding) offset(r = rounding)
            union() {
                hull() {
                    translate(ua_j2_axis_center)     circle(d = ua_j2_mount_bounding_diameter);
                    translate(ua_j3_motor_center)    circle(d = ua_j3_motor_bounding_diameter);
                    translate(j3_elbow_axis_center)  circle(d = ua_j3_driven_axis_bounding_diameter);
                }
                children();
            }
}

// 상완 판 공유 블랭크 — 링크 프로파일을 압출하고 팔꿈치 피벗 보어를 뚫는다. 상·하판이 각자의 시트를 덧깎는다.
module ua_plate_base() {
    difference() {
        ua_plate_with_profile_2d(ua_thickness);

        // J3 팔꿈치 피벗 보어 — 피벗 볼트가 판을 관통하도록 BB608 내경(bb_bore)으로 뚫는다(상·하판 공통).
        translate([j3_elbow_axis_center[0], j3_elbow_axis_center[1], -eps])
            cylinder(d = bb_bore(j3_driven_ball_bearing_type), h = ua_thickness + eps * 2);
    }
}
