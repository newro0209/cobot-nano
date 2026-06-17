// parts/base_column_top_plate.scad - Upper end plate: shared axis bores and flange-holder bolts (no motor).
// Mirror of the bottom plate without the drive: the lead screw and guide rods pass through clearance bores and are
// gripped by KFL08/SHF8 holders bolted to the top face, capturing the three J1 axes against the lower plate.
//
// 베이스 기둥 상단 단판(upper end plate) — 공유 축 보어·플랜지 홀더 볼트 홀만 둔다(모터 없음).
// 드라이브 없는 하단 단판의 대칭으로, 리드스크류·가이드 로드가 관통 보어로 지나고 윗면에 볼트 체결된 KFL08·SHF8 홀더가 세 J1 축을 잡는다.

include <base_column_plate_base.scad>

module base_column_top_plate() {
    difference() {
        base_column_plate_blank();
        base_column_axis_cuts();
    }
}

base_column_top_plate();
