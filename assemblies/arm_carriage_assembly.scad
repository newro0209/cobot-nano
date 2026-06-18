// assemblies/arm_carriage_assembly.scad - Arm carriage stack preview.
// Places the top/bottom printed plates and the vitamins seated in their pockets:
// BB608 bearings on the J2 driven axis, one LM8UU linear bearing on each J1 guide rod,
// the J1 lead-nut in the top-plate underside seat, and the J2 motor / belt pulleys.
//
// 암 캐리지 조립체 — 상/하판과 각 포켓에 안착되는 부품을 함께 배치한다.
// J2 종동축 BB608, 각 J1 가이드 로드의 LM8UU 1개, 상판 아랫면 리드너트, J2 모터와 벨트 풀리를 포켓 방향에 맞춰 보여준다.

// 부품 블랭크 치수(ac_*, cc_*)만 쓰려고 include한다 — 이 플래그로 그 파일들의 단독 미리보기(유령 블랭크) 렌더를 막는다.
hide_part_self_preview = true;
include <../parts/arm_carriage_plate_base.scad>

use <../parts/arm_carriage_bottom_plate.scad>
use <../parts/arm_carriage_top_plate.scad>
use <../parts/motor_seat.scad>

use <NopSCADlib/vitamins/ball_bearing.scad>
use <NopSCADlib/vitamins/belt.scad>
use <NopSCADlib/vitamins/leadnut.scad>
use <NopSCADlib/vitamins/linear_bearing.scad>
use <NopSCADlib/vitamins/nut.scad>
use <NopSCADlib/vitamins/pillar.scad>
use <NopSCADlib/vitamins/pulley.scad>
use <NopSCADlib/vitamins/screw.scad>
use <NopSCADlib/vitamins/stepper_motor.scad>
use <NopSCADlib/vitamins/washer.scad>

/* [Preview] */
// 분해 간격(explode step) — 0이면 안착 스택. 키우면 부품을 Z축으로 단계별로 벌려 부품마다 따로 보기 쉽게 한다(mm/단계).
ac_exploded = 0; // [0:0.5:30]
show_hardware = true; // false = printed plates only.
show_belt = true;     // exploded view에서는 풀리와 어긋나지 않도록 자동으로 숨긴다.

// J2 모터 슬롯 위치 — 슬롯홀을 따라 모터를 옮겨 벨트 장력을 본다. 0=near(최소 장력), 1=far(최대 장력).
ac_j2_motor_slot_fraction = 0.5; // [0:0.01:1]
// 슬라이더가 가리키는 모터 중심 — 부품(슬롯 자체)은 고정이고, 이 좌표만 모터·구동 풀리·벨트 미리보기를 따라 움직인다.
ac_j2_motor_position = ac_j2_motor_center_at(ac_j2_motor_slot_fraction);

// Z 분해 레벨(explode level) — 안착 위치에 level×ac_exploded를 더해 스택 순서대로 벌린다. 음수=아래, 양수=위, 0=갭 중앙(고정).
// 갭 부품(필러·선형 베어링·종동 풀리)은 0으로 두면 판이 벌어지며 제자리에서 드러난다. 관통 체결류는 삽입축을 따라 멀리 빼 분리한다.
function ac_ez(level) = level * ac_exploded;
// 안착 베이스(base_z)에 분해 오프셋을 더해 자식을 놓는다 — 분해 배치 패턴을 한 곳으로 모은다.
module ac_place(base_z, level) {
    translate_z(base_z + ac_ez(level))
        children();
}
ac_ex_lock_nut       = -4;  // J2 락너트 — 하판 아래로 가장 멀리
ac_ex_bottom_screw   = -3;  // 하판 스탠드오프 볼트
ac_ex_bottom_bearing = -2;  // 하판 BB608 — 하판 포켓에서 아래로 빠짐
ac_ex_bottom_plate   = -1;
ac_ex_gap            =  0;   // 필러·선형 베어링·종동 풀리(갭 중앙 고정)
ac_ex_lead_nut       =  1;   // 리드너트 — 상판 아랫면 포켓에서 아래로 빠짐
ac_ex_leadnut_screw  =  1;   // 리드너트 플랜지 볼트(아래에서 삽입 → 너트와 같이 갭 쪽)
ac_ex_top_plate      =  2;
ac_ex_top_bearing    =  3;   // 상판 BB608 — 상판 포켓에서 위로 빠짐
ac_ex_drive_pulley   =  3;
ac_ex_top_screw      =  3;   // 상판 스탠드오프 볼트
ac_ex_leadnut_nut    =  3;   // 리드너트 플랜지 너트(상판 위)
ac_ex_fc_bottom      = -3;   // J2 하단 플랜지 커플링(하판 아래, 락너트 안쪽)
ac_ex_fc_top         =  4;   // J2 상단 플랜지 커플링(상판 위, 숄더 볼트 머리 안쪽)
ac_ex_motor          =  4;
ac_ex_shoulder_bolt  =  5;   // J2 숄더 볼트 — 위로 가장 멀리

// 조립체 색상 — 라벨 오버레이가 추가되면 같은 변수를 공유한다(A-3).
ac_col_top_plate      = [0.18, 0.42, 0.62];
ac_col_bottom_plate   = [0.16, 0.30, 0.40];
ac_col_drive_pulley   = [0.85, 0.58, 0.18];
ac_col_driven_pulley  = [0.78, 0.38, 0.18];
ac_col_belt           = [0.02, 0.02, 0.025];
ac_col_belt_tooth     = [0.18, 0.18, 0.18];

// 스택 높이 좌표 — 상판 윗면, 모터 페이스(상판 윗면에서 내려앉음), 모터 샤프트 끝.
ac_top_plate_z        = ac_thickness + ac_plate_gap;
ac_motor_face_local_z = ac_thickness - nema_motor_seat_face_inset(j2_motor_type, ac_thickness);
ac_motor_face_z       = ac_top_plate_z + ac_motor_face_local_z;
ac_motor_shaft_tip_z  = ac_motor_face_z - NEMA_shaft_length(j2_motor_type);

// 풀리 공통 평면 Z(belt center) — 구동·종동 풀리가 같은 높이에서 물려야 하므로, 두 풀리의 offset/height와
// 모터 샤프트 끝, 상/하판 안쪽 클리어런스를 모두 만족하는 가용 구간의 하한을 잡는다(상한 _max는 assert 검증용).
function ac_belt_center_z_min() =
    let(bottom_clear = ac_thickness + clearance / 2)
    max(bottom_clear - pulley_offset(j2_drive_pulley_type),
        bottom_clear - pulley_offset(j2_driven_pulley_type),
        ac_motor_shaft_tip_z - pulley_offset(j2_drive_pulley_type) + clearance / 2);
function ac_belt_center_z_max() =
    let(top_clear  = ac_top_plate_z - clearance / 2,
        drive_top  = pulley_offset(j2_drive_pulley_type) + pulley_height(j2_drive_pulley_type))
    min(top_clear - drive_top,
        top_clear - (pulley_offset(j2_driven_pulley_type) + pulley_height(j2_driven_pulley_type)),
        ac_motor_face_z - drive_top - clearance / 2);

ac_belt_center_z        = ac_belt_center_z_min() + eps;
ac_drive_pulley_local_z = ac_belt_center_z - ac_top_plate_z;
ac_drive_pulley_screw_z = ac_belt_center_z + pulley_offset(j2_drive_pulley_type) + pulley_screw_z(j2_drive_pulley_type);

// 체결 부품(fastener) 길이 — 판 두께·스택 높이에서 계산한다(하드코딩 금지).
ac_standoff_screw_length = screw_longer_than(ac_thickness + 6);   // 판 두께 지나 ff 필러에 ~6mm 체결
// J2 숄더 볼트 — 양끝 FC가 8mm 숄더를 물도록 판 스택 높이에 FC 높이를 위·아래(2×) + 머리 와셔를 더해, 나사산이 하단 FC 바깥면에서 시작.
ac_j2_shoulder_length = ac_top_plate_z + ac_thickness
                        + 2 * fc_height(j2_driven_flange_coupling_type)
                        + washer_thickness(screw_washer(j2_driven_shoulder_screw_type));

ac_timing_belt_type  = pulley_belt(j2_drive_pulley_type);
ac_timing_belt_pitch = belt_pitch(ac_timing_belt_type);

// fraction(0=near~1=far)에서의 벨트 경로·중심거리·길이 — min/current/max 병렬 변수 대신 함수로 도출한다(P-4).
function ac_belt_path(fraction) =
    let(m = ac_j2_motor_center_at(fraction))
    [[m.x, m.y, j2_drive_pulley_type],
     [j2_driven_axis_center.x, j2_driven_axis_center.y, j2_driven_pulley_type]];
function ac_belt_distance(fraction) = norm(ac_j2_motor_center_at(fraction) - j2_driven_axis_center);
function ac_belt_length(fraction)   = belt_length(ac_timing_belt_type, ac_belt_path(fraction));

// GT2 폐루프 표준 벨트 후보(BOM 참조) — near는 올림, far는 내림, current는 반올림한 피치 배수.
ac_timing_belt_standard_min = ceil (ac_belt_length(0) / ac_timing_belt_pitch) * ac_timing_belt_pitch;
ac_timing_belt_standard_max = floor(ac_belt_length(1) / ac_timing_belt_pitch) * ac_timing_belt_pitch;
ac_timing_belt_standard_mid = round(ac_belt_length(ac_j2_motor_slot_fraction) / ac_timing_belt_pitch) * ac_timing_belt_pitch;

echo(str("J2 belt pulley center distance min/current/max = ",
         ac_belt_distance(0), " / ", ac_belt_distance(ac_j2_motor_slot_fraction), " / ", ac_belt_distance(1), " mm"));
echo(str("J2 timing belt length min/current/max = ",
         ac_belt_length(0), " / ", ac_belt_length(ac_j2_motor_slot_fraction), " / ", ac_belt_length(1), " mm"));
echo(str("J2 GT2 closed-loop belt usable standard range = ",
         ac_timing_belt_standard_min, " .. ", ac_timing_belt_standard_max, " mm, nominal ", ac_timing_belt_standard_mid, " mm"));

assert(ac_timing_belt_type == pulley_belt(j2_driven_pulley_type),
       "J2 구동 풀리와 종동 풀리는 같은 벨트 타입이어야 한다");
assert(!is_list(NEMA_shaft_length(j2_motor_type)), "J2 모터 샤프트 길이는 숫자여야 한다");
assert(ac_belt_center_z < ac_belt_center_z_max(),
       "모터 샤프트와 상/하판 사이에 공통 풀리 높이를 잡을 공간이 있어야 한다");
assert(ac_drive_pulley_screw_z > ac_motor_shaft_tip_z,
       "J2 구동 풀리 세트스크류 위치는 모터 샤프트 끝보다 위에 있어야 한다");
assert(ac_belt_center_z + min(
           pulley_offset(j2_drive_pulley_type),
           pulley_offset(j2_driven_pulley_type)
       ) > ac_thickness + clearance / 2,
       "풀리는 하판 윗면과 간섭하지 않아야 한다");
assert(ac_belt_center_z + max(
           pulley_height(j2_drive_pulley_type) + pulley_offset(j2_drive_pulley_type),
           pulley_height(j2_driven_pulley_type) + pulley_offset(j2_driven_pulley_type)
       ) < ac_top_plate_z - clearance / 2,
       "풀리는 상판 아랫면과 간섭하지 않아야 한다");

// 부품별 분해를 위해 안착 부품을 한 부품당 한 모듈로 둔다(좌표는 각 판 베이스 기준 로컬, 호출부에서 판 프레임+분해 오프셋을 씌운다).
module ac_bottom_driven_bearing() {
    // 하판 J2 BB608 — 하판 아랫면 포켓(from_top=false)에 안착, 베어링 외측면은 하판 바닥면과 flush.
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1], bb_width(j2_driven_ball_bearing_type) / 2])
        ball_bearing(j2_driven_ball_bearing_type);
}

module ac_top_driven_bearing() {
    // 상판 J2 BB608 — 상판 윗면 포켓(from_top=true)에 안착, 베어링 외측면은 상판 윗면과 flush.
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1], ac_thickness - bb_width(j2_driven_ball_bearing_type) / 2])
        ball_bearing(j2_driven_ball_bearing_type);
}

module ac_top_lead_nut() {
    // 상판 J1 리드너트 — 아랫면 포켓(from_top=false)에 플랜지를 맞춰 안착.
    translate(j1_axis_center)
        leadnut(j1_leadnut_type);
}

module ac_j2_motor() {
    // J2 스텝모터 — 상판 윗면 시트(from_top=true)에 모터 전면을 맞추고, 축은 판 아래쪽 풀리로 내려간다. 슬롯 위치는 슬라이더가 정한다.
    translate([ac_j2_motor_position[0], ac_j2_motor_position[1], ac_motor_face_local_z])
        rotate([180, 0, 0])
            NEMA(j2_motor_type);
}

module ac_j2_drive_pulley() {
    // J2 구동 풀리 — 모터 샤프트에 물린 부품이므로 모터와 같은 top 그룹 좌표를 따른다.
    translate([ac_j2_motor_position[0], ac_j2_motor_position[1], ac_drive_pulley_local_z])
        pulley_assembly(j2_drive_pulley_type, ac_col_drive_pulley);
}

module ac_shared_linear_bearings() {
    // LM8UU — 필러 간격 중앙에 두며, 시트 깊이가 있으면 상/하판 시트가 양끝을 물고 없으면 축방향 여유를 둔다.
    cc_at_guide_rods()
        translate_z(ac_thickness + ac_plate_gap / 2)
            linear_bearing(j1_linear_bearing_type);
}

module ac_standoffs() {
    ac_standoff_positions()
        translate_z(ac_thickness)
            pillar(standoff_pillar_type);
}

// 스탠드오프 볼트 — ff 필러는 양끝이 암나사라 위·아래 판에서 각각 볼트로 죈다(볼트는 자기 판 그룹에 두어 분해 시 함께 움직인다).
module ac_standoff_top_fasteners() {
    // 상판 윗면(상판 그룹 로컬 z=ac_thickness)에서 와셔를 깔고 필러 상단 암나사로 내려가 죈다.
    ac_standoff_positions()
        translate_z(ac_thickness)
            screw_and_washer(standoff_screw_type, ac_standoff_screw_length);
}

module ac_standoff_bottom_fasteners() {
    // 하판 아랫면(하판 그룹 로컬 z=0)에서 뒤집어 필러 하단 암나사로 올라가 죈다.
    ac_standoff_positions()
        rotate([180, 0, 0])
            screw_and_washer(standoff_screw_type, ac_standoff_screw_length);
}

// J2 종동축 숄더 볼트 — 상단 플랜지 커플링 윗면에서 와셔를 깔고(머리가 상단 FC를 축방향으로 리테인), 숄더부가 두 BB608
// 보어와 상/하 FC 허브를 채우며 스택을 관통해 내려간다(상판 그룹).
module ac_j2_driven_shoulder_bolt() {
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1],
               ac_thickness + fc_height(j2_driven_flange_coupling_type)])
        screw_and_washer(j2_driven_shoulder_screw_type, ac_j2_shoulder_length);
}

// J2 종동축 락너트 — 하단 플랜지 커플링 아랫면으로 빠져나온 나사산에 와셔+나일록 너트로 스택을 축방향 고정한다(하판 그룹).
module ac_j2_driven_lock_nut() {
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1],
               -fc_height(j2_driven_flange_coupling_type)])
        rotate([180, 0, 0])
            nut_and_washer(screw_nut(j2_driven_shoulder_screw_type), true);
}

// J2 종동축 플랜지 커플링 — 숄더 봉(8mm)을 허브로 죄고 플랜지로 상/하 암 링크를 무는 마운트. 축(숄더 볼트+락너트)은 그대로 두고
// 그 바깥에 덧댄다. 플랜지(베이스)를 판 바깥면에 붙이고 허브를 바깥으로 내며, 머리/락너트가 허브 끝을 리테인한다(각 판 그룹 로컬).
module ac_j2_driven_flange_coupling_top() {
    fc = j2_driven_flange_coupling_type;
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1], ac_thickness])
        FC(fc);
}

module ac_j2_driven_flange_coupling_bottom() {
    fc = j2_driven_flange_coupling_type;
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1], 0])
        rotate([180, 0, 0])
            FC(fc);
}

// J1 리드너트 플랜지 고정 — 플랜지가 상판 아랫면(z=0)에 묻혀, 아랫면에서 머리+와셔로 죄고 판을 관통해 윗면 와셔+너트로 고정한다.
// 분해 시 볼트(아래)·너트(위)가 반대로 빠지게 두 모듈로 나눈다. leadnut_screw_positions는 z=flange_t 기준이라 판 바닥(z=0)으로 되돌린다.
module ac_j1_leadnut_flange_positions() {
    translate(j1_axis_center)
        leadnut_screw_positions(j1_leadnut_type)
            translate_z(-leadnut_flange_t(j1_leadnut_type))
                children();
}

module ac_j1_leadnut_flange_screws() {
    screw  = leadnut_screw(j1_leadnut_type);
    length = screw_length(screw, ac_thickness, 2, nut = true);
    ac_j1_leadnut_flange_positions()
        rotate([180, 0, 0])
            screw_and_washer(screw, length);   // 플랜지 노출면(아랫면)에서 머리+와셔로 죄고 위로 관통
}

module ac_j1_leadnut_flange_nuts() {
    ac_j1_leadnut_flange_positions()
        translate_z(ac_thickness)
            nut_and_washer(screw_nut(leadnut_screw(j1_leadnut_type)), false);  // 상판 윗면에서 와셔+너트로 고정
}

module ac_shared_pulleys() {
    // J2 종동 풀리 — BB608로 지지되는 어깨축의 회전 출력 풀리.
    translate([j2_driven_axis_center[0], j2_driven_axis_center[1], ac_belt_center_z])
        pulley_assembly(j2_driven_pulley_type, ac_col_driven_pulley);
}

module ac_timing_belt() {
    translate_z(ac_belt_center_z)
        belt(ac_timing_belt_type,
             ac_belt_path(ac_j2_motor_slot_fraction),
             belt_colour = ac_col_belt,
             tooth_colour = ac_col_belt_tooth);
}

module arm_carriage_assembly() {
    // ── 하판 밴드(하판 베이스 z=0 기준) — 안착면 아래로 단계별 분해 ──
    ac_place(0, ac_ex_bottom_plate)
        color(ac_col_bottom_plate)
            arm_carriage_bottom_plate();

    if (show_hardware) {
        ac_place(0, ac_ex_bottom_bearing) ac_bottom_driven_bearing();
        ac_place(0, ac_ex_bottom_screw)   ac_standoff_bottom_fasteners();
        ac_place(0, ac_ex_lock_nut)       ac_j2_driven_lock_nut();
        ac_place(0, ac_ex_fc_bottom)      ac_j2_driven_flange_coupling_bottom();

        // ── 갭(중앙) — 분해해도 자리 유지, 판이 벌어지며 드러난다 ──
        ac_place(0, ac_ex_gap) {
            ac_standoffs();
            ac_shared_linear_bearings();
            ac_shared_pulleys();
        }
        if (show_belt && ac_exploded == 0)
            ac_timing_belt();
    }

    // ── 상판 밴드(상판 베이스 z=ac_top_plate_z 기준) — 안착면 위로 단계별 분해 ──
    ac_place(ac_top_plate_z, ac_ex_top_plate)
        color(ac_col_top_plate)
            arm_carriage_top_plate();

    if (show_hardware) {
        ac_place(ac_top_plate_z, ac_ex_top_bearing)   ac_top_driven_bearing();
        ac_place(ac_top_plate_z, ac_ex_lead_nut)      ac_top_lead_nut();
        ac_place(ac_top_plate_z, ac_ex_motor)         ac_j2_motor();
        ac_place(ac_top_plate_z, ac_ex_drive_pulley)  ac_j2_drive_pulley();
        ac_place(ac_top_plate_z, ac_ex_top_screw)     ac_standoff_top_fasteners();
        ac_place(ac_top_plate_z, ac_ex_shoulder_bolt) ac_j2_driven_shoulder_bolt();
        ac_place(ac_top_plate_z, ac_ex_fc_top)        ac_j2_driven_flange_coupling_top();
        ac_place(ac_top_plate_z, ac_ex_leadnut_screw) ac_j1_leadnut_flange_screws();
        ac_place(ac_top_plate_z, ac_ex_leadnut_nut)   ac_j1_leadnut_flange_nuts();
    }
}

arm_carriage_assembly();
