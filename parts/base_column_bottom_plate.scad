// parts/base_column_bottom_plate.scad - Lower end plate: shared axis bores and flange-holder bolts (no motor).
// The lead screw and guide rods pass through clearance bores and are gripped by KFL08/FC8 holders bolted to the
// faces. The J1 drive motor lives on the upper plate, so this plate is a plain capture plate.
//
// 베이스 기둥 하단 단판(lower end plate) — 공유 축 보어·플랜지 홀더 볼트 홀만 둔다(모터 없음).
// 리드스크류·가이드 로드가 관통 보어로 지나고, 판 면에 볼트 체결된 KFL08·FC8 홀더가 잡는다. J1 구동 모터는 상단 단판에 있다.

include <base_column_plate_base.scad>

module base_column_bottom_plate() {
    difference() {
        base_column_plate_blank();
        base_column_axis_cuts();

        // 홀더 플랜지 리세스 — 바깥(아랫) 면에서 KFL·FC 플랜지를 가라앉힌다.
        base_column_holder_recesses(from_top = false);
    }
}

base_column_bottom_plate();
