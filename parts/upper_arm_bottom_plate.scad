// parts/upper_arm_bottom_plate.scad - UPPER_ARM bottom plate (NopSCADlib printed-part style).
// The Z-mirror of the top plate, sharing the same upper-arm blank. The lower face carries the proximal J2 FC8 flange
// seat that bolts to the AC-side J2 driven-axis hub, plus the lower J3 elbow-bearing seat.
// The motor mounts on the top plate and its 20T pulley reaches down into the gap.
//
// 상완 하판 — 상판과 같은 블랭크를 쓰는 Z 미러. 아랫면에는 AC J2 driven axis 위 FC8 허브에 체결되는 시트를 둔다.
// 하판은 하부 J3 팔꿈치 베어링 시트도 함께 깎는다.

include <upper_arm_plate_base.scad>
use <ball_bearing_seat.scad>
use <flange_coupling_seat.scad>

module upper_arm_bottom_plate() {
    difference() {
        ua_plate_base();

        // J3 종동 베어링 시트 — 상판(from_top=true)의 Z 미러: 아랫면으로 연다.
        translate(j3_elbow_axis_center)
            bb_bearing_seat_pocket(j3_driven_ball_bearing_type, part_thickness = ua_thickness, from_top = false);

        // 근위 J2 마운트 — AC J2 driven axis 위 FC8 허브 플랜지를 하판 아랫면에 묻고 볼트로 연결한다.
        translate(ua_j2_axis_center)
            fc_flange_coupling_seat_pocket(j2_driven_flange_coupling_type, part_thickness = ua_thickness, from_top = false);
    }
}

upper_arm_bottom_plate();
