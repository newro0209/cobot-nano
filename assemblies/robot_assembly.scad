// assemblies/robot_assembly.scad — 단일 통합 로봇 어셈블리(통짜).
// J1 베이스 컬럼(Z 이송) → J2 암 캐리지(어깨) → J3 상완(팔꿈치)를 하나의 robot_assembly()로 렌더한다.
// 구성: 변수(파생값) → 함수 → 진단(echo/assert) → 모듈 순으로 종류별 분리. joint별 robot_j1_/j2_/j3_,
// 공용은 robot_. 남은 bc_/ac_/ua_/j*_ 토큰은 parts/*.scad·config.scad가 정의하는 import 접근자다.

// NopSCADlib rod.scad는 include 시점에 global_defs로 show_threads를 해석하므로 include 전에 켠다.
$show_threads = true;

include <../parts/base_column_plate_base.scad>
include <../parts/arm_carriage_plate_base.scad>
include <../parts/upper_arm_plate_base.scad>

use <../parts/base_column_motor_plate.scad>
use <../parts/base_column_rod_plate.scad>
use <../parts/arm_carriage_bottom_plate.scad>
use <../parts/arm_carriage_top_plate.scad>
use <../parts/upper_arm_bottom_plate.scad>
use <../parts/upper_arm_top_plate.scad>
use <../parts/motor_seat.scad>
use <../vitamins/flange_bearing_blocks.scad>
use <../vitamins/flange_couplings.scad>

use <NopSCADlib/vitamins/ball_bearing.scad>
use <NopSCADlib/vitamins/belt.scad>
use <NopSCADlib/vitamins/leadnut.scad>
use <NopSCADlib/vitamins/linear_bearing.scad>
use <NopSCADlib/vitamins/nut.scad>
use <NopSCADlib/vitamins/pillar.scad>
use <NopSCADlib/vitamins/pulley.scad>
use <NopSCADlib/vitamins/screw.scad>
use <NopSCADlib/vitamins/shaft_coupling.scad>
use <NopSCADlib/vitamins/stepper_motor.scad>
use <NopSCADlib/vitamins/washer.scad>

// ============================================================
// 변수
// ============================================================

/* [Hardware visibility] */
show_fasteners = true;            // bolts, washers, nuts, standoffs/spacers.
show_motion_components = true;    // motors, belts, pulleys, bearings.
show_remaining_components = true; // rods, lead screws, couplings, leadnuts, and other vitamins.

/* [Preview] */
// 분해 간격(explode step) — 0이면 안착 스택. 키우면 각 관절 스택을 Z축으로 단계별로 벌린다(mm/단계).
robot_j1_exploded = 0; // [0:0.5:30]
robot_j2_exploded = 0; // [0:0.5:30]
robot_j3_exploded = 0; // [0:0.5:30]
// J2 모터 슬롯 위치 — 슬롯홀을 따라 모터를 옮겨 벨트 장력을 본다. 0=near(최소 장력), 1=far(최대 장력).
robot_j2_motor_slot_fraction = 0.5; // [0:0.01:1]
// J1 암-캐리지 높이 — 매달린 상완이 하부 베이스 판을 비키도록 충분히 높게 둔다.
robot_arm_carriage_z = 80; // [0:1:150]
// J2 어깨축 회전각.
robot_j2_angle = 0; // [-180:1:180]
// AC측 FC8 허브 하단과 상판 BB608 내륜 사이 축방향 여유. 0=직접 스택 접촉.
robot_j2_coupling_gap = 0; // [0:0.1:2]

/* [Hidden] */
// 아래는 위 입력에서 도출되는 파생값 — Customizer에 노출하지 않는다(함수는 hoist되므로 정의보다 먼저 참조해도 된다).

// 미리보기 색 — 상/하판·구동/종동 풀리·벨트.
robot_col_top_plate     = [0.18, 0.42, 0.62];
robot_col_bottom_plate  = [0.16, 0.30, 0.40];
robot_col_drive_pulley  = [0.85, 0.58, 0.18];
robot_col_driven_pulley = [0.78, 0.38, 0.18];
robot_col_belt          = [0.02, 0.02, 0.025];
robot_col_belt_tooth    = [0.18, 0.18, 0.18];

// ---- J1 베이스 컬럼 (Z 이송) ----
robot_j1_col_upper_rod_plate = [0.20, 0.36, 0.44];
robot_j1_col_lower_rod_plate = [0.14, 0.28, 0.34];
robot_j1_col_motor_plate     = [0.18, 0.42, 0.62];

robot_j1_ex_lower_kfl       = -3;
robot_j1_ex_lower_rod_plate = -2;
robot_j1_ex_rods            =  0;
robot_j1_ex_upper_kfl       =  1;
robot_j1_ex_upper_rod_plate =  2;
robot_j1_ex_gap             =  3;
robot_j1_ex_motor_plate     =  4;
robot_j1_ex_motor           =  5;

robot_j1_fc_seat_depth  = min(fc_flange_thickness(j1_flange_coupling_type),
                              bc_plate_thickness - seat_shoulder_thickness);
robot_j1_kfl_seat_depth = min(kfl_thickness(j1_flange_bearing_block_type),
                              bc_plate_thickness - seat_shoulder_thickness);
robot_j1_fc_top_seat_z     = bc_plate_thickness - robot_j1_fc_seat_depth;
robot_j1_fc_bottom_seat_z  = robot_j1_fc_seat_depth;
robot_j1_kfl_top_seat_z    = bc_plate_thickness - robot_j1_kfl_seat_depth;
robot_j1_kfl_bottom_seat_z = robot_j1_kfl_seat_depth;

robot_j1_motor_face_local_z = robot_motor_face_local_z(j1_motor_type, bc_plate_thickness);
robot_j1_motor_face_z       = bc_motor_plate_z + robot_j1_motor_face_local_z;
robot_j1_motor_shaft_tip_z  = robot_j1_motor_face_z - NEMA_shaft_length(j1_motor_type);
robot_j1_fc_screw_type      = fc_screw(j1_flange_coupling_type);
robot_j1_fc_screw_length    = screw_length(robot_j1_fc_screw_type, bc_plate_thickness, 2, nut = true);
robot_j1_kfl_screw_type     = kfl_screw(j1_flange_bearing_block_type);
robot_j1_kfl_screw_length   = screw_length(robot_j1_kfl_screw_type, bc_plate_thickness, 2, nut = true);
robot_j1_motor_screw_type   = M3_cap_screw;
robot_j1_motor_screw_length = screw_longer_than(robot_j1_motor_face_local_z + 4);
robot_j1_shaft_coupling_center_local_z = bc_plate_thickness + bc_plate_gap / 2;
robot_j1_shaft_coupling_center_z       = bc_upper_rod_plate_z + robot_j1_shaft_coupling_center_local_z;
robot_j1_shaft_coupling_bottom_z       = robot_j1_shaft_coupling_center_z - sc_length(j1_shaft_coupling_type) / 2;
robot_j1_shaft_coupling_top_z          = robot_j1_shaft_coupling_center_z + sc_length(j1_shaft_coupling_type) / 2;

robot_j1_guide_rod_bottom_z  = robot_j1_fc_top_seat_z;
robot_j1_guide_rod_length    = smooth_rod_length(j1_guide_rod_type);
robot_j1_guide_rod_top_z     = robot_j1_guide_rod_bottom_z + robot_j1_guide_rod_length;
robot_j1_lead_screw_bottom_z = robot_j1_kfl_top_seat_z;
robot_j1_lead_screw_length   = lead_screw_length(j1_lead_screw_type);
robot_j1_lead_screw_top_z    = robot_j1_lead_screw_bottom_z + robot_j1_lead_screw_length;

// ---- J2 암 캐리지 (어깨) ----
// 슬라이더가 가리키는 모터 중심 — 부품(슬롯)은 고정이고, 이 좌표만 모터·구동 풀리·벨트 미리보기를 따라 움직인다.
robot_j2_motor_position = ac_j2_motor_center_at(robot_j2_motor_slot_fraction);

// Z 분해 레벨 — 안착 위치에 level×robot_j2_exploded를 더해 스택 순서대로 벌린다. 음수=아래, 양수=위, 0=갭 중앙(고정).
robot_j2_ex_lock_nut       = -4;  // J2 락너트 — 하판 아래로 가장 멀리
robot_j2_ex_bottom_screw   = -3;  // 하판 스탠드오프 볼트
robot_j2_ex_bottom_bearing = -2;  // 하판 BB608 — 하판 포켓에서 아래로 빠짐
robot_j2_ex_bottom_plate   = -1;
robot_j2_ex_gap            =  0;   // 필러·선형 베어링·종동 풀리(갭 중앙 고정)
robot_j2_ex_lead_nut       =  1;   // 리드너트 — 상판 아랫면 포켓에서 아래로 빠짐
robot_j2_ex_leadnut_screw  =  1;   // 리드너트 플랜지 볼트(아래에서 삽입)
robot_j2_ex_top_plate      =  2;
robot_j2_ex_top_bearing    =  3;   // 상판 BB608 — 상판 포켓에서 위로 빠짐
robot_j2_ex_drive_pulley   =  3;
robot_j2_ex_top_screw      =  3;   // 상판 스탠드오프 볼트
robot_j2_ex_leadnut_nut    =  3;   // 리드너트 플랜지 너트(상판 위)
robot_j2_ex_motor          =  4;

// 스택 높이 좌표 — 상판 윗면, 모터 페이스(상판 윗면에서 내려앉음), 모터 샤프트 끝.
robot_j2_top_plate_z        = ac_thickness + ac_plate_gap;
robot_j2_motor_face_local_z = robot_motor_face_local_z(j2_motor_type, ac_thickness);
robot_j2_motor_face_z       = robot_j2_top_plate_z + robot_j2_motor_face_local_z;
robot_j2_motor_shaft_tip_z  = robot_j2_motor_face_z - NEMA_shaft_length(j2_motor_type);

// 풀리 공통 평면 Z — 가용 구간의 하한을 잡는다(상한 _max는 assert 검증용).
robot_j2_belt_center_z_min = robot_belt_center_z_min(ac_thickness, robot_j2_motor_shaft_tip_z,
                                                     j2_drive_pulley_type, j2_driven_pulley_type);
robot_j2_belt_center_z_max = robot_belt_center_z_max(robot_j2_top_plate_z, robot_j2_motor_face_z,
                                                     j2_drive_pulley_type, j2_driven_pulley_type);
robot_j2_belt_center_z        = robot_j2_belt_center_z_min + eps;
robot_j2_drive_pulley_local_z = robot_drive_pulley_local_z(robot_j2_belt_center_z, robot_j2_top_plate_z);
robot_j2_drive_pulley_screw_z = robot_drive_pulley_screw_z(robot_j2_belt_center_z, j2_drive_pulley_type);

robot_j2_standoff_screw_length = screw_longer_than(ac_thickness + 6);   // 판 두께 지나 ff 필러에 ~6mm 체결

robot_j2_timing_belt_type  = pulley_belt(j2_drive_pulley_type);
robot_j2_timing_belt_pitch = belt_pitch(robot_j2_timing_belt_type);

// GT2 폐루프 표준 벨트 후보(BOM 참조) — near는 올림, far는 내림, current는 반올림한 피치 배수. robot_j2_belt_length() 함수로 도출.
robot_j2_timing_belt_standard_min = ceil (robot_j2_belt_length(0) / robot_j2_timing_belt_pitch) * robot_j2_timing_belt_pitch;
robot_j2_timing_belt_standard_max = floor(robot_j2_belt_length(1) / robot_j2_timing_belt_pitch) * robot_j2_timing_belt_pitch;
robot_j2_timing_belt_standard_mid = round(robot_j2_belt_length(robot_j2_motor_slot_fraction) / robot_j2_timing_belt_pitch) * robot_j2_timing_belt_pitch;

// ---- J3 상완 (팔꿈치) ----
// 상/하판 간격 — J3 벨트 구동이 들어갈 표준 판 간격. 근위 J2 축은 AC 상단 FC8 허브와 맞물린다.
robot_j3_plate_gap   = pillar_height(standoff_pillar_type);
robot_j3_top_plate_z = ua_thickness + robot_j3_plate_gap;

robot_j3_ex_lock_nut       = -3;  // J3 락너트 — 하판 아래로 가장 멀리
robot_j3_ex_bottom_bearing = -2;  // 하판 BB608
robot_j3_ex_bottom_plate   = -1;
robot_j3_ex_gap            =  0;   // 종동 풀리·벨트(갭 중앙)
robot_j3_ex_top_plate      =  1;
robot_j3_ex_top_bearing    =  2;   // 상판 BB608
robot_j3_ex_drive_pulley   =  2;
robot_j3_ex_motor          =  3;
robot_j3_ex_shoulder_bolt  =  4;   // J3 숄더 볼트 — 위로 가장 멀리

robot_j3_motor_face_local_z = robot_motor_face_local_z(j3_motor_type, ua_thickness);
robot_j3_motor_face_z       = robot_j3_top_plate_z + robot_j3_motor_face_local_z;
robot_j3_motor_shaft_tip_z  = robot_j3_motor_face_z - NEMA_shaft_length(j3_motor_type);

robot_j3_belt_center_z_min = robot_belt_center_z_min(ua_thickness, robot_j3_motor_shaft_tip_z,
                                                     j3_drive_pulley_type, j3_driven_pulley_type);
robot_j3_belt_center_z_max = robot_belt_center_z_max(robot_j3_top_plate_z, robot_j3_motor_face_z,
                                                     j3_drive_pulley_type, j3_driven_pulley_type);
robot_j3_belt_center_z        = robot_j3_belt_center_z_min + eps;
robot_j3_drive_pulley_local_z = robot_drive_pulley_local_z(robot_j3_belt_center_z, robot_j3_top_plate_z);
robot_j3_drive_pulley_screw_z = robot_drive_pulley_screw_z(robot_j3_belt_center_z, j3_drive_pulley_type);

// J3 숄더 볼트 길이 — 숄더부가 상판 윗면에서 두 BB608을 지나 하판 아래 나사산까지 스택을 관통한다(J3엔 FC 없음).
robot_j3_shoulder_length = robot_j3_top_plate_z + ua_thickness
                         + washer_thickness(screw_washer(j3_driven_shoulder_screw_type));

// 벨트 진단 — 모터 고정이라 단일 경로. 표준 폐루프 후보 길이까지 echo로 노출한다.
robot_j3_timing_belt_type     = pulley_belt(j3_drive_pulley_type);
robot_j3_timing_belt_pitch    = belt_pitch(robot_j3_timing_belt_type);
robot_j3_timing_belt_path     = robot_two_pulley_belt_path(ua_j3_motor_center, j3_drive_pulley_type,
                                                           j3_elbow_axis_center, j3_driven_pulley_type);
robot_j3_timing_belt_distance = robot_two_pulley_distance(ua_j3_motor_center, j3_elbow_axis_center);
robot_j3_timing_belt_length   = belt_length(robot_j3_timing_belt_type, robot_j3_timing_belt_path);
robot_j3_timing_belt_standard = round(robot_j3_timing_belt_length / robot_j3_timing_belt_pitch) * robot_j3_timing_belt_pitch;

// ---- 로봇 프레임 배치 (관절 조립) ----
robot_arm_carriage_top_z = robot_arm_carriage_z + robot_j2_top_plate_z + ac_thickness;
robot_upper_arm_j2_mount_fc_seat_depth = min(fc_flange_thickness(j2_driven_flange_coupling_type),
                                             ua_thickness - seat_shoulder_thickness);
robot_upper_arm_lower_fc_below_plate = fc_height(j2_driven_flange_coupling_type)
                                     - robot_upper_arm_j2_mount_fc_seat_depth;
robot_j2_axis_hub_clearance = robot_j2_coupling_gap;
robot_upper_arm_z = robot_arm_carriage_top_z
                  + robot_j2_axis_hub_clearance
                  + robot_upper_arm_lower_fc_below_plate;
robot_j2_shoulder_length = ua_thickness
                         + fc_height(j2_driven_flange_coupling_type)
                         + robot_j2_top_plate_z
                         + ac_thickness
                         + washer_thickness(screw_washer(j2_driven_shoulder_screw_type));
robot_j2_hub_screw_type   = fc_screw(j2_driven_flange_coupling_type);
robot_j2_hub_screw_length = screw_length(robot_j2_hub_screw_type,
                                         ua_thickness + fc_flange_thickness(j2_driven_flange_coupling_type),
                                         2, nut = true);

// ============================================================
// 함수
// ============================================================

// 모터 페이스 로컬 Z — 모터를 판에 안착하면 페이스가 판 윗면에서 inset만큼 내려앉는다.
function robot_motor_face_local_z(motor_type, plate_thickness) =
    plate_thickness - nema_motor_seat_face_inset(motor_type, plate_thickness);

// 풀리 공통 평면 Z(belt center)의 가용 하한 — 두 풀리 offset, 모터 샤프트 끝, 하판 안쪽 클리어런스를 만족한다.
function robot_belt_center_z_min(part_thickness, motor_shaft_tip_z, drive_pulley_type, driven_pulley_type) =
    let(bottom_clear = part_thickness + clearance / 2)
    max(bottom_clear - pulley_offset(drive_pulley_type),
        bottom_clear - pulley_offset(driven_pulley_type),
        motor_shaft_tip_z - pulley_offset(drive_pulley_type) + clearance / 2);

// 풀리 공통 평면 Z의 가용 상한(assert 검증용) — 두 풀리 높이, 모터 페이스, 상판 안쪽 클리어런스를 만족한다.
function robot_belt_center_z_max(top_plate_z, motor_face_z, drive_pulley_type, driven_pulley_type) =
    let(top_clear = top_plate_z - clearance / 2,
        drive_top = pulley_offset(drive_pulley_type) + pulley_height(drive_pulley_type))
    min(top_clear - drive_top,
        top_clear - (pulley_offset(driven_pulley_type) + pulley_height(driven_pulley_type)),
        motor_face_z - drive_top - clearance / 2);

function robot_drive_pulley_local_z(belt_center_z, top_plate_z) = belt_center_z - top_plate_z;
function robot_drive_pulley_screw_z(belt_center_z, drive_pulley_type) =
    belt_center_z + pulley_offset(drive_pulley_type) + pulley_screw_z(drive_pulley_type);

function robot_two_pulley_belt_path(drive_center, drive_pulley_type, driven_center, driven_pulley_type) =
    [[drive_center[0], drive_center[1], drive_pulley_type],
     [driven_center[0], driven_center[1], driven_pulley_type]];

function robot_two_pulley_distance(drive_center, driven_center) = norm(drive_center - driven_center);

// J2 모터 슬롯 fraction(0=near~1=far)에서의 벨트 경로·중심거리·길이 — 병렬 변수 대신 함수로 도출한다.
function robot_j2_belt_path(fraction) =
    robot_two_pulley_belt_path(ac_j2_motor_center_at(fraction), j2_drive_pulley_type,
                               j2_driven_axis_center, j2_driven_pulley_type);
function robot_j2_belt_distance(fraction) = robot_two_pulley_distance(ac_j2_motor_center_at(fraction), j2_driven_axis_center);
function robot_j2_belt_length(fraction)   = belt_length(robot_j2_timing_belt_type, robot_j2_belt_path(fraction));

// ============================================================
// 진단 (echo / assert)
// ============================================================

// ---- J1 ----
echo(str("Base column plate thickness / motor standoff gap / column span = ",
         bc_plate_thickness, " / ", bc_plate_gap, " / ", bc_column_span, " mm"));
echo(str("Base column J1 coupling length = ", sc_length(j1_shaft_coupling_type), " mm"));
echo(str("Base column J1 coupling Z range = ",
         robot_j1_shaft_coupling_bottom_z, " .. ", robot_j1_shaft_coupling_top_z, " mm"));
echo(str("Base column guide rod / lead screw length = ",
         robot_j1_guide_rod_length, " / ", robot_j1_lead_screw_length, " mm"));

assert(NEMA_thread_d(j1_motor_type) == screw_radius(robot_j1_motor_screw_type) * 2,
       "J1 NEMA 모터 고정 스크류 지름은 모터 탭 지름과 같아야 한다");
assert(abs(robot_j1_guide_rod_top_z - (bc_motor_plate_z + robot_j1_fc_top_seat_z + fc_height(j1_flange_coupling_type))) <= eps,
       "J1 가이드 로드 길이는 하부 FC8부터 모터 판 위 FC8 허브 끝까지 닿아야 한다");
assert(abs(robot_j1_lead_screw_top_z - robot_j1_shaft_coupling_center_z) <= eps,
       "J1 리드스크류 길이는 하부 KFL08부터 샤프트 커플러 중심까지 닿아야 한다");

// ---- J2 ----
echo(str("J2 belt pulley center distance min/current/max = ",
         robot_j2_belt_distance(0), " / ", robot_j2_belt_distance(robot_j2_motor_slot_fraction), " / ", robot_j2_belt_distance(1), " mm"));
echo(str("J2 timing belt length min/current/max = ",
         robot_j2_belt_length(0), " / ", robot_j2_belt_length(robot_j2_motor_slot_fraction), " / ", robot_j2_belt_length(1), " mm"));
echo(str("J2 GT2 closed-loop belt usable standard range = ",
         robot_j2_timing_belt_standard_min, " .. ", robot_j2_timing_belt_standard_max, " mm, nominal ", robot_j2_timing_belt_standard_mid, " mm"));

robot_drive_stack_assertions("J2", j2_motor_type, j2_drive_pulley_type, j2_driven_pulley_type,
                             robot_j2_timing_belt_type, robot_j2_belt_center_z, robot_j2_belt_center_z_max,
                             robot_j2_drive_pulley_screw_z, robot_j2_motor_shaft_tip_z, ac_thickness, robot_j2_top_plate_z);

// ---- J3 ----
echo(str("J3 belt pulley center distance = ", robot_j3_timing_belt_distance, " mm"));
echo(str("J3 timing belt length / nearest standard = ", robot_j3_timing_belt_length, " / ", robot_j3_timing_belt_standard, " mm"));

robot_drive_stack_assertions("J3", j3_motor_type, j3_drive_pulley_type, j3_driven_pulley_type,
                             robot_j3_timing_belt_type, robot_j3_belt_center_z, robot_j3_belt_center_z_max,
                             robot_j3_drive_pulley_screw_z, robot_j3_motor_shaft_tip_z, ua_thickness, robot_j3_top_plate_z);

// ---- 로봇 프레임 ----
echo(str("Robot arm-carriage Z = ", robot_arm_carriage_z, " mm"));
echo(str("Robot arm-carriage top Z = ", robot_arm_carriage_top_z, " mm"));
echo(str("Robot upper-arm base Z = ", robot_upper_arm_z, " mm"));
echo(str("Robot J2 FC8-to-bearing gap = ", robot_j2_coupling_gap, " mm"));

assert(robot_arm_carriage_top_z < bc_upper_rod_plate_z - clearance,
       "J1 carriage preview position is too high for the base column span");

// ============================================================
// 모듈
// ============================================================

// ---- 공용 헬퍼 ----

// 안착 Z에 level×exploded를 더해 스택을 벌린다.
module robot_place_exploded(base_z, level, exploded) {
    translate_z(base_z + level * exploded)
        children();
}

// 부품 배치 — 축 중심·계산된 Z에 vitamin을 놓는다.
module robot_bottom_bearing_at(center, bearing_type) {
    translate([center[0], center[1], bb_width(bearing_type) / 2])
        ball_bearing(bearing_type);
}

module robot_top_bearing_at(center, bearing_type, part_thickness) {
    translate([center[0], center[1], part_thickness - bb_width(bearing_type) / 2])
        ball_bearing(bearing_type);
}

module robot_downward_stepper_at(center, face_z, motor_type) {
    translate([center[0], center[1], face_z])
        rotate([180, 0, 0])
            NEMA(motor_type);
}

module robot_pulley_at(center, z, pulley_type, col) {
    translate([center[0], center[1], z])
        pulley_assembly(pulley_type, col);
}

module robot_timing_belt_at(z, belt_type, path, belt_colour, tooth_colour) {
    translate_z(z)
        belt(belt_type, path, belt_colour = belt_colour, tooth_colour = tooth_colour);
}

module robot_shoulder_bolt_at(center, z, screw_type, length) {
    translate([center[0], center[1], z])
        screw_and_washer(screw_type, length);
}

module robot_lock_nut_at(center, screw_type) {
    translate([center[0], center[1], 0])
        rotate([180, 0, 0])
            nut_and_washer(screw_nut(screw_type), true);
}

// 판 관통 볼트+너트 한 쌍 — 한 면에서 머리+와셔로 죄고, plate_thickness 떨어진 반대 면에서 너트+와셔로 받는다.
// screw_from_top=true: 머리는 윗면(z=plate_thickness)·너트는 아랫면(z=0). false면 위아래가 반대.
module robot_through_plate_fasteners(plate_thickness, screw, length, screw_from_top = true) {
    if (screw_from_top) {
        translate_z(plate_thickness) screw_and_washer(screw, length);
        rotate([180, 0, 0])          nut_and_washer(screw_nut(screw), false);
    } else {
        rotate([180, 0, 0])          screw_and_washer(screw, length);
        translate_z(plate_thickness) nut_and_washer(screw_nut(screw), false);
    }
}

// 스탠드오프 필러 — 판 윗면(z=thickness)에 세운다. <positions>() 아래에서 호출한다.
module robot_standoff_pillar(thickness, pillar_type) {
    translate_z(thickness) pillar(pillar_type);
}

// 스탠드오프 볼트 — from_top이면 판 윗면(z=thickness)에서 머리+와셔, 아니면 뒤집어 아래(z=0)에서. <positions>() 아래에서 호출한다.
module robot_standoff_fastener(thickness, screw_length, from_top) {
    if (from_top) translate_z(thickness) screw_and_washer(standoff_screw_type, screw_length);
    else          rotate([180, 0, 0])    screw_and_washer(standoff_screw_type, screw_length);
}

// 시트 Z에 vitamin 안착 — flip이면 허브가 반대로 향하게 뒤집어, 상/하판 양쪽에서 같은 부품을 쓴다.
module robot_seated_at(z, flip = false) {
    translate_z(z) {
        if (flip) rotate([180, 0, 0]) children();
        else children();
    }
}

// 구동 스택(모터+구동 풀리 ↔ 종동 풀리) 정합 검증 — J2·J3가 공유한다.
module robot_drive_stack_assertions(axis_label, motor_type, drive_pulley_type, driven_pulley_type, belt_type,
                                    belt_center_z, belt_center_z_max, drive_pulley_screw_z, motor_shaft_tip_z,
                                    part_thickness, top_plate_z) {
    assert(belt_type == pulley_belt(driven_pulley_type),
           str(axis_label, " 구동 풀리와 종동 풀리는 같은 벨트 타입이어야 한다"));
    assert(!is_list(NEMA_shaft_length(motor_type)),
           str(axis_label, " 모터 샤프트 길이는 숫자여야 한다"));
    assert(belt_center_z < belt_center_z_max,
           str(axis_label, " 모터 샤프트와 상/하판 사이에 공통 풀리 높이를 잡을 공간이 있어야 한다"));
    assert(drive_pulley_screw_z > motor_shaft_tip_z,
           str(axis_label, " 구동 풀리 세트스크류 위치는 모터 샤프트 끝보다 위에 있어야 한다"));
    assert(belt_center_z + min(pulley_offset(drive_pulley_type), pulley_offset(driven_pulley_type))
           > part_thickness + clearance / 2,
           str(axis_label, " 풀리는 하판 윗면과 간섭하지 않아야 한다"));
    assert(belt_center_z + max(pulley_height(drive_pulley_type) + pulley_offset(drive_pulley_type),
                               pulley_height(driven_pulley_type) + pulley_offset(driven_pulley_type))
           < top_plate_z - clearance / 2,
           str(axis_label, " 풀리는 상판 아랫면과 간섭하지 않아야 한다"));
}

// ---- J1 베이스 컬럼 ----

// KFL08 플랜지 베어링 블록 — 시트 Z에 안착. flip이면 판 아랫면에 매달림(상부 판), 아니면 윗면에서 받침(하부 판).
module robot_j1_flange_bearing_block(seat_z, flip = false) {
    robot_seated_at(seat_z, flip)
        kfl_flange_bearing_block(j1_flange_bearing_block_type);
}

// FC8 가이드-로드 커플링 — 세 로드 위치마다 시트 Z에 안착. flip이면 허브가 아래로(상부 판에서 로드를 내려잡음).
module robot_j1_guide_rod_couplings(seat_z, flip = false) {
    cc_at_guide_rods()
        robot_seated_at(seat_z, flip)
            FC(j1_flange_coupling_type);
}

// FC8 가이드-로드 커플링 플랜지 — 세 로드 위치마다 판을 관통해 볼트+너트로 죈다.
module robot_j1_fc_fasteners(screw_from_top) {
    cc_at_guide_rods()
        fc_screw_positions(j1_flange_coupling_type)
            robot_through_plate_fasteners(bc_plate_thickness, robot_j1_fc_screw_type, robot_j1_fc_screw_length, screw_from_top);
}

// KFL08 플랜지 베어링 블록 — 판을 관통해 볼트+너트로 죈다.
module robot_j1_kfl_fasteners(screw_from_top) {
    kfl_screw_positions(j1_flange_bearing_block_type)
        robot_through_plate_fasteners(bc_plate_thickness, robot_j1_kfl_screw_type, robot_j1_kfl_screw_length, screw_from_top);
}

module robot_j1_motor_fasteners() {
    translate(j1_axis_center)
        NEMA_screw_positions(j1_motor_type)
            rotate([180, 0, 0])
                screw_and_washer(robot_j1_motor_screw_type, robot_j1_motor_screw_length);
}

module robot_j1_motor() {
    robot_downward_stepper_at(j1_axis_center, robot_j1_motor_face_z, j1_motor_type);
}

module robot_j1_shaft_coupling() {
    // SC_5x8_rigid의 작은 보어(5mm)가 위쪽 모터축, 큰 보어(8mm)가 아래쪽 리드스크류를 향하도록 뒤집는다.
    translate_z(robot_j1_shaft_coupling_center_local_z)
        rotate([180, 0, 0])
            shaft_coupling(j1_shaft_coupling_type);
}

module robot_j1_rods() {
    cc_at_guide_rods()
        translate_z(robot_j1_guide_rod_bottom_z)
            rod(smooth_rod_diameter(j1_guide_rod_type), robot_j1_guide_rod_length, center = false);

    translate_z(robot_j1_lead_screw_bottom_z)
        leadscrew(lead_screw_diameter(j1_lead_screw_type),
                  robot_j1_lead_screw_length,
                  lead_screw_lead(j1_lead_screw_type),
                  lead_screw_starts(j1_lead_screw_type),
                  center = false);
}

// ---- J2 암 캐리지 ----

module robot_j2_top_lead_nut() {
    // 상판 J1 리드너트 — 아랫면 포켓(from_top=false)에 플랜지를 맞춰 안착.
    translate(j1_axis_center)
        leadnut(j1_leadnut_type);
}

module robot_j2_shared_linear_bearings() {
    // LM8UU — 필러 간격 중앙에 두며, 시트 깊이가 있으면 상/하판 시트가 양끝을 물고 없으면 축방향 여유를 둔다.
    cc_at_guide_rods()
        translate_z(ac_thickness + ac_plate_gap / 2)
            linear_bearing(j1_linear_bearing_type);
}

// J2 종동축 위 FC8 축 허브 — 허브 하단이 상판 BB608 내륜 높이에 닿고, 플랜지 윗면은 상완 하판 포켓에 맞물린다.
module robot_j2_driven_axis_hub(hub_clearance = 0) {
    fc = j2_driven_flange_coupling_type;
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1],
               ac_thickness + hub_clearance + fc_height(fc)])
        rotate([180, 0, 0])
            FC(fc);
}

// J1 리드너트 플랜지 고정 — 플랜지가 상판 아랫면(z=0)에 묻혀, 아랫면에서 머리+와셔로 죄고 윗면 와셔+너트로 고정한다.
// 분해 시 볼트(아래)·너트(위)가 반대로 빠지게 두 모듈로 나눈다. leadnut_screw_positions는 z=flange_t 기준이라 판 바닥(z=0)으로 되돌린다.
module robot_j2_leadnut_flange_positions() {
    translate(j1_axis_center)
        leadnut_screw_positions(j1_leadnut_type)
            translate_z(-leadnut_flange_t(j1_leadnut_type))
                children();
}

module robot_j2_leadnut_flange_screws() {
    screw  = leadnut_screw(j1_leadnut_type);
    length = screw_length(screw, ac_thickness, 2, nut = true);
    robot_j2_leadnut_flange_positions()
        rotate([180, 0, 0])
            screw_and_washer(screw, length);   // 플랜지 노출면(아랫면)에서 머리+와셔로 죄고 위로 관통
}

module robot_j2_leadnut_flange_nuts() {
    robot_j2_leadnut_flange_positions()
        translate_z(ac_thickness)
            nut_and_washer(screw_nut(leadnut_screw(j1_leadnut_type)), false);  // 상판 윗면에서 와셔+너트로 고정
}

// ---- 로봇 프레임 ----

module robot_at_j2_axis() {
    translate(j2_driven_axis_center)
        rotate([0, 0, robot_j2_angle])
            translate(-j2_driven_axis_center)
                children();
}

module robot_place_j2_axis_hub() {
    translate_z(robot_arm_carriage_z + robot_j2_top_plate_z)
        robot_at_j2_axis()
            robot_j2_driven_axis_hub(hub_clearance = robot_j2_axis_hub_clearance);
}

// J2 어깨 축 중심·각도로 상완 프레임 배치 — 상완 스택과 허브 체결이 공유한다.
module robot_at_upper_arm() {
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1], robot_upper_arm_z])
        rotate([0, 0, robot_j2_angle])
            children();
}

module robot_j2_hub_to_upper_arm_fasteners() {
    robot_at_upper_arm()
        fc_screw_positions(j2_driven_flange_coupling_type)
            robot_through_plate_fasteners(ua_thickness, robot_j2_hub_screw_type, robot_j2_hub_screw_length);
}

module robot_j2_driven_shoulder_bolt() {
    robot_shoulder_bolt_at(j2_driven_axis_center, robot_upper_arm_z + ua_thickness,
                           j2_driven_shoulder_screw_type, robot_j2_shoulder_length);
}

// ---- 통합 어셈블리 ----

module robot_assembly() {
    // ── J1 베이스 컬럼: 하부 판·로드·상부 판·스탠드오프·모터 판 ──
    // 하부 지지 판: 리드스크류 하단과 가이드 로드 하단을 잡는다.
    robot_place_exploded(0, robot_j1_ex_lower_rod_plate, robot_j1_exploded)
        color(robot_j1_col_lower_rod_plate)
            base_column_rod_plate();

    if (show_motion_components)
        robot_place_exploded(0, robot_j1_ex_lower_kfl, robot_j1_exploded) robot_j1_flange_bearing_block(robot_j1_kfl_top_seat_z);

    if (show_remaining_components)
        robot_place_exploded(0, robot_j1_ex_lower_rod_plate, robot_j1_exploded) robot_j1_guide_rod_couplings(robot_j1_fc_top_seat_z);

    if (show_fasteners)
        robot_place_exploded(0, robot_j1_ex_lower_rod_plate, robot_j1_exploded) {
            robot_j1_fc_fasteners(screw_from_top = true);
            robot_j1_kfl_fasteners(screw_from_top = true);
        }

    if (show_remaining_components)
        robot_place_exploded(0, robot_j1_ex_rods, robot_j1_exploded) robot_j1_rods();

    // 상부 지지 판: 리드스크류·가이드 로드 상단을 잡고, 모터 판과 스탠드오프로 맞물린다.
    robot_place_exploded(bc_upper_rod_plate_z, robot_j1_ex_upper_rod_plate, robot_j1_exploded)
        color(robot_j1_col_upper_rod_plate)
            base_column_rod_plate(seat_from_top = false);

    if (show_motion_components)
        robot_place_exploded(bc_upper_rod_plate_z, robot_j1_ex_upper_kfl, robot_j1_exploded) robot_j1_flange_bearing_block(robot_j1_kfl_bottom_seat_z, flip = true);

    if (show_remaining_components)
        robot_place_exploded(bc_upper_rod_plate_z, robot_j1_ex_upper_rod_plate, robot_j1_exploded) robot_j1_guide_rod_couplings(robot_j1_fc_bottom_seat_z, flip = true);

    if (show_fasteners)
        robot_place_exploded(bc_upper_rod_plate_z, robot_j1_ex_upper_rod_plate, robot_j1_exploded) {
            robot_j1_fc_fasteners(screw_from_top = false);
            robot_j1_kfl_fasteners(screw_from_top = false);
        }

    if (show_fasteners || show_remaining_components)
        robot_place_exploded(bc_upper_rod_plate_z, robot_j1_ex_gap, robot_j1_exploded) {
            if (show_fasteners) bc_standoff_positions() robot_standoff_pillar(bc_plate_thickness, bc_standoff_pillar_type);
            if (show_remaining_components) robot_j1_shaft_coupling();
        }

    if (show_fasteners)
        robot_place_exploded(bc_upper_rod_plate_z, robot_j1_ex_upper_rod_plate, robot_j1_exploded)
            bc_standoff_positions() robot_standoff_fastener(bc_plate_thickness, bc_standoff_screw_length, from_top = false);

    // 모터 판: 모터는 윗면에 체결되어 축이 아래 커플링으로 내려간다.
    robot_place_exploded(bc_motor_plate_z, robot_j1_ex_motor_plate, robot_j1_exploded)
        color(robot_j1_col_motor_plate)
            base_column_motor_plate();

    if (show_fasteners)
        robot_place_exploded(bc_motor_plate_z, robot_j1_ex_motor_plate, robot_j1_exploded)
            bc_standoff_positions() robot_standoff_fastener(bc_plate_thickness, bc_standoff_screw_length, from_top = true);

    if (show_remaining_components)
        robot_place_exploded(bc_motor_plate_z, robot_j1_ex_motor_plate, robot_j1_exploded) robot_j1_guide_rod_couplings(robot_j1_fc_top_seat_z);

    if (show_fasteners)
        robot_place_exploded(bc_motor_plate_z, robot_j1_ex_motor_plate, robot_j1_exploded) {
            robot_j1_fc_fasteners(screw_from_top = true);
            robot_j1_motor_fasteners();
        }

    if (show_motion_components)
        robot_place_exploded(0, robot_j1_ex_motor, robot_j1_exploded) robot_j1_motor();

    // ── J2 암 캐리지: base column 위 robot_arm_carriage_z 높이의 어깨 스택 ──
    translate_z(robot_arm_carriage_z) {
        // 하판 밴드
        robot_place_exploded(0, robot_j2_ex_bottom_plate, robot_j2_exploded)
            color(robot_col_bottom_plate)
                arm_carriage_bottom_plate();

        if (show_motion_components)
            robot_place_exploded(0, robot_j2_ex_bottom_bearing, robot_j2_exploded)
                robot_bottom_bearing_at(j2_driven_axis_center, j2_driven_ball_bearing_type);

        if (show_fasteners) {
            robot_place_exploded(0, robot_j2_ex_bottom_screw, robot_j2_exploded)
                ac_standoff_positions() robot_standoff_fastener(ac_thickness, robot_j2_standoff_screw_length, from_top = false);
            robot_place_exploded(0, robot_j2_ex_lock_nut, robot_j2_exploded)
                robot_lock_nut_at(j2_driven_axis_center, j2_driven_shoulder_screw_type);
        }

        if (show_fasteners || show_motion_components) {
            // 갭(중앙) — 분해해도 자리 유지, 판이 벌어지며 드러난다
            robot_place_exploded(0, robot_j2_ex_gap, robot_j2_exploded) {
                if (show_fasteners) ac_standoff_positions() robot_standoff_pillar(ac_thickness, standoff_pillar_type);
                if (show_motion_components) {
                    robot_j2_shared_linear_bearings();
                    robot_pulley_at(j2_driven_axis_center, robot_j2_belt_center_z,
                                    j2_driven_pulley_type, robot_col_driven_pulley);
                }
            }
            if (show_motion_components && robot_j2_exploded == 0)
                robot_timing_belt_at(robot_j2_belt_center_z, robot_j2_timing_belt_type,
                                     robot_j2_belt_path(robot_j2_motor_slot_fraction), robot_col_belt, robot_col_belt_tooth);
        }

        // 상판 밴드
        robot_place_exploded(robot_j2_top_plate_z, robot_j2_ex_top_plate, robot_j2_exploded)
            color(robot_col_top_plate)
                arm_carriage_top_plate();

        if (show_motion_components) {
            robot_place_exploded(robot_j2_top_plate_z, robot_j2_ex_top_bearing, robot_j2_exploded)
                robot_top_bearing_at(j2_driven_axis_center, j2_driven_ball_bearing_type, ac_thickness);
            robot_place_exploded(robot_j2_top_plate_z, robot_j2_ex_motor, robot_j2_exploded)
                robot_downward_stepper_at(robot_j2_motor_position, robot_j2_motor_face_local_z, j2_motor_type);
            robot_place_exploded(robot_j2_top_plate_z, robot_j2_ex_drive_pulley, robot_j2_exploded)
                robot_pulley_at(robot_j2_motor_position, robot_j2_drive_pulley_local_z, j2_drive_pulley_type, robot_col_drive_pulley);
        }

        if (show_remaining_components)
            robot_place_exploded(robot_j2_top_plate_z, robot_j2_ex_lead_nut, robot_j2_exploded) robot_j2_top_lead_nut();

        if (show_fasteners) {
            robot_place_exploded(robot_j2_top_plate_z, robot_j2_ex_top_screw, robot_j2_exploded)
                ac_standoff_positions() robot_standoff_fastener(ac_thickness, robot_j2_standoff_screw_length, from_top = true);
            robot_place_exploded(robot_j2_top_plate_z, robot_j2_ex_leadnut_screw, robot_j2_exploded) robot_j2_leadnut_flange_screws();
            robot_place_exploded(robot_j2_top_plate_z, robot_j2_ex_leadnut_nut, robot_j2_exploded) robot_j2_leadnut_flange_nuts();
        }
    }

    // J2 종동축 위 FC8 허브 (어깨축 ↔ 상완 하판) — 로봇 프레임에서 배치
    if (show_remaining_components)
        robot_place_j2_axis_hub();

    // ── J3 상완: J2 어깨축 중심·각도로 매달린 팔꿈치 스택 ──
    robot_at_upper_arm() {
        // 하판 밴드
        robot_place_exploded(0, robot_j3_ex_bottom_plate, robot_j3_exploded)
            color(robot_col_bottom_plate)
                upper_arm_bottom_plate();

        if (show_motion_components)
            robot_place_exploded(0, robot_j3_ex_bottom_bearing, robot_j3_exploded)
                robot_bottom_bearing_at(j3_elbow_axis_center, j3_driven_ball_bearing_type);

        if (show_fasteners)
            robot_place_exploded(0, robot_j3_ex_lock_nut, robot_j3_exploded)
                robot_lock_nut_at(j3_elbow_axis_center, j3_driven_shoulder_screw_type);

        if (show_motion_components) {
            // 갭(중앙)
            robot_place_exploded(0, robot_j3_ex_gap, robot_j3_exploded)
                robot_pulley_at(j3_elbow_axis_center, robot_j3_belt_center_z, j3_driven_pulley_type, robot_col_driven_pulley);
            if (robot_j3_exploded == 0)
                robot_timing_belt_at(robot_j3_belt_center_z, robot_j3_timing_belt_type,
                                     robot_j3_timing_belt_path, robot_col_belt, robot_col_belt_tooth);
        }

        // 상판 밴드
        robot_place_exploded(robot_j3_top_plate_z, robot_j3_ex_top_plate, robot_j3_exploded)
            color(robot_col_top_plate)
                upper_arm_top_plate();

        if (show_motion_components) {
            robot_place_exploded(robot_j3_top_plate_z, robot_j3_ex_top_bearing, robot_j3_exploded)
                robot_top_bearing_at(j3_elbow_axis_center, j3_driven_ball_bearing_type, ua_thickness);
            robot_place_exploded(robot_j3_top_plate_z, robot_j3_ex_motor, robot_j3_exploded)
                robot_downward_stepper_at(ua_j3_motor_center, robot_j3_motor_face_local_z, j3_motor_type);
            robot_place_exploded(robot_j3_top_plate_z, robot_j3_ex_drive_pulley, robot_j3_exploded)
                robot_pulley_at(ua_j3_motor_center, robot_j3_drive_pulley_local_z, j3_drive_pulley_type, robot_col_drive_pulley);
        }

        if (show_fasteners)
            robot_place_exploded(robot_j3_top_plate_z, robot_j3_ex_shoulder_bolt, robot_j3_exploded)
                robot_shoulder_bolt_at(j3_elbow_axis_center, ua_thickness, j3_driven_shoulder_screw_type, robot_j3_shoulder_length);
    }

    // J2 어깨축 관통 체결 (로봇 프레임) — 허브-상완 볼트, 어깨 숄더 볼트
    if (show_fasteners) {
        robot_j2_hub_to_upper_arm_fasteners();
        robot_j2_driven_shoulder_bolt();
    }
}

robot_assembly();
