// parts/arm_carriage_housing.scad - Provides the arm carriage housing geometry.
// Assembly render files place motors, leadnuts, bearings, and fasteners around this module.
//
// 암 캐리지 하우징(arm carriage housing)의 출력 형상을 제공한다.
// 하드웨어 배치(hardware placement)와 exploded view는 assemblies 계층에서 담당한다.

use <arm_carriage_plate.scad>

module arm_carriage_housing() {
    arm_carriage_plate();
}
