// parts/base_column_rod_plate.scad - Guide-rod / lead-screw support plate for the fixed base column.
// The same printed part can be used at the upper and lower ends: it anchors the three guide rods with FC8 flange
// couplings and supports the J1 lead screw with a KFL08 flange bearing block.
//
// BASE_COLUMN 로드/리드스크류 지지 판 — 상부와 하부에 같은 부품을 쓰며, 가이드 로드 3개는 FC8 플랜지 커플링으로 잡고,
// 리드스크류는 중앙 KFL08 플랜지 베어링 블록으로 받는다.

include <base_column_plate_base.scad>
use <flange_bearing_block_seat.scad>
use <flange_coupling_seat.scad>

module base_column_rod_plate(seat_from_top = true) {
    difference() {
        bc_plate_base();

        // 중앙 리드스크류 KFL08 시트 — 상/하부 support에서 필요한 면만 열리도록 호출부가 고른다.
        kfl_flange_bearing_block_seat_pocket(j1_flange_bearing_block_type,
                                             part_thickness = bc_plate_thickness,
                                             from_top = seat_from_top);

        // 3개 가이드 로드 FC8 시트.
        cc_at_guide_rods()
            fc_flange_coupling_seat_pocket(j1_flange_coupling_type,
                                           part_thickness = bc_plate_thickness,
                                           from_top = seat_from_top);
    }
}

base_column_rod_plate();
