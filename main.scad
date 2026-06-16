// main.scad - Renders the full cobot-nano assembly and exposes pose variables for OpenSCAD animation.
// The base, arm, and gripper assemblies are composed here so kinematic pose changes can be inspected as one mechanism.
//
// 전체 cobot-nano 조립체를 렌더링하고 OpenSCAD 애니메이션용 자세 변수를 제공한다.
// 베이스(base), 팔(arm), 그리퍼(gripper)를 한 곳에서 합성해 기구학적 자세 변화를 확인한다.

include <config.scad>
include <plates/links.scad>
use <assemblies/base_asm.scad>
use <assemblies/arm_asm.scad>
use <assemblies/gripper_asm.scad>

// 설계 기본 자세를 OpenSCAD 시간 변수(time variable) `$t`로 대체하면 작동 범위를 스윕(sweep)할 수 있다.
pose_base_angle  = base_angle;
pose_lower_angle = lower_angle;
pose_upper_angle = upper_angle;
// pose_base_angle  = 360 * $t;
// pose_lower_angle = 30 + 40 * sin(360 * $t);
// pose_upper_angle = 90 + 30 * cos(360 * $t);

base_asm(base_angle = pose_base_angle);

// 팔 조립체(arm assembly)는 회전 상판(rotating deck) 위에 올라가므로 베이스 회전과 같은 기준 좌표계(reference frame)를 공유한다.
translate([0, 0, arm_mount_z])
rotate(pose_base_angle)
{
    arm_asm(lower_angle = pose_lower_angle,
            upper_angle = pose_upper_angle);

    // 순기구학(forward kinematics)으로 손목(wrist) 위치를 계산해 4절 링크(four-bar linkage)의 말단을 따라간다.
    wx = wrist_x(pose_lower_angle, pose_upper_angle);
    wz = wrist_z(pose_lower_angle, pose_upper_angle);
    translate([wx, 0, wz]) gripper_asm();
}
