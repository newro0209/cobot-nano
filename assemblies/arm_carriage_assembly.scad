// assemblies/arm_carriage_assembly.scad - Renders the arm carriage housing with mounted vitamins for fit checks.
// The assembly includes the shared plate base datums so hardware placement and cut geometry use one coordinate source.
//
// 암 캐리지 조립체(arm carriage assembly)에 모터, 리드넛, 베어링을 배치해 조립 간섭을 확인한다.
// 하드웨어 배치(hardware placement)는 기본 판(base plate)의 기준 좌표를 그대로 include해 같은 좌표계를 공유한다.

show_hardware = true;
ac_exploded = 0; // [0:0.05:1]

include <../parts/arm_carriage_plate_base.scad>
use <../parts/arm_carriage_housing.scad>
use <NopSCADlib/vitamins/screw.scad>

ac_explode_distance = 24;
ac_motor_mount_z = ac_motor_recess_floor_z;
ac_motor_driven_stack_z = ac_thickness - ac_motor_mount_z;
ac_leadnut_mount_z = -ac_leadnut_flange_thickness;
ac_leadnut_screw_length = ac_thickness + ac_leadnut_flange_thickness;
ac_shoulder_bearing_center_z = ac_thickness - bb_width(ac_shoulder_joint_bearing_type) / 2;

module arm_carriage_assembly() {
    let($explode = ac_exploded) {
        arm_carriage_housing();

        if (show_hardware) {
            explode([0, 0, ac_explode_distance])
            translate([ac_motor_center.x, ac_motor_center.y, ac_motor_mount_z])
                rotate([180, 0, 0]) {
                    // J2 구동 모터(drive motor) — 모터 플랜지(motor flange)가 리세스 바닥에 안착하는 좌표.
                    NEMA(ac_shoulder_motor_type);
                }

            explode([0, 0, -ac_explode_distance])
            translate([ac_motor_center.x, ac_motor_center.y, ac_motor_mount_z])
                rotate([180, 0, 0])
                    translate([0, 0, ac_motor_driven_stack_z]) {
                        // J2 축 하부 스택(lower drive stack) — 샤프트 방향으로 내려가는 스크류와 풀리 간섭 검증.
                        NEMA_screws(ac_shoulder_motor_type, M3_cap_screw);
                        pulley(GT2x20um_pulley);
                    }

            // J1 리드넛 하부 장착(bottom-mounted leadnut) — 플랜지 상면을 캐리지 하단에 맞춘다.
            explode([0, 0, -ac_explode_distance])
            translate([ac_leadnut_center.x, ac_leadnut_center.y, ac_leadnut_mount_z]) {
                leadnut(ac_leadnut_type);
                leadnut_screw_positions(ac_leadnut_type)
                    rotate([180, 0, 0])
                        screw_and_washer(leadnut_screw(ac_leadnut_type), ac_leadnut_screw_length, true);
            }

            // J2 종동 베어링(driven bearing) — 윗면 기준 베어링 시트와 같은 축방향 중심.
            explode([0, 0, ac_explode_distance])
            translate([ac_shoulder_bearing_center.x, ac_shoulder_bearing_center.y, ac_shoulder_bearing_center_z])
                ball_bearing(ac_shoulder_joint_bearing_type);
        }
    }
}

arm_carriage_assembly();
