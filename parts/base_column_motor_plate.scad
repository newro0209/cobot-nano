// parts/base_column_motor_plate.scad - Upper top plate of the fixed base column.
// Holds the J1 motor on the centre axis so its shaft points down to the lead screw through j1_shaft_coupling_type.
// The three guide rods pass through and are extended upward through FC8 couplings seated on the motor plate.
//
// BASE_COLUMN 모터 판 — 중앙 NEMA 모터를 잡아 모터축이 아래쪽 샤프트 커플링을 통해 리드스크류와 직결되게 한다.

include <base_column_plate_base.scad>
use <flange_coupling_seat.scad>
use <motor_seat.scad>

module base_column_motor_plate() {
    difference() {
        bc_plate_base();

        // 중앙 J1 모터 시트 — 모터는 윗면에 앉고 축은 아래쪽 커플링으로 내려간다.
        translate(j1_axis_center)
            nema_motor_seat_pocket(j1_motor_type, part_thickness = bc_plate_thickness, from_top = true);

        // 모터 판도 FC8로 가이드 로드를 잡아, 로드를 상부로 더 뻗힌다.
        cc_at_guide_rods()
            fc_flange_coupling_seat_pocket(j1_flange_coupling_type,
                                           part_thickness = bc_plate_thickness,
                                           from_top = true);
    }
}

base_column_motor_plate();
