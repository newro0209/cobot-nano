// parts/base_column_top_plate.scad - Upper end plate: J1 drive motor recess plus shared axis bores and holder bolts.
// The J1 motor mounts on the top face pointing down (like the carriage's J2 motor): its body sits above the plate,
// the shaft drops through to a pulley below, and the lead screw / guide rods pass through and are gripped by KFL08/FC8.
//
// 베이스 기둥 상단 단판(upper end plate) — J1 구동 모터 리세스(recess) + 공유 축 보어·플랜지 홀더 볼트 홀.
// 모터는 윗면에서 아래로 삽입(캐리지 J2 모터처럼) — 바디는 판 위로 서고 샤프트는 판을 지나 아래 풀리로 내려간다.
// 리드스크류·가이드 로드는 관통 보어로 지나고 KFL08·FC8 홀더가 잡는다.

include <base_column_plate_base.scad>

module base_column_top_plate() {
    difference() {
        base_column_plate_blank();

        base_column_axis_cuts();

        // ── J1 구동 모터 2단 시트(motor seat) — 윗면에서 삽입하는 뒤집힌 모터용 음형(공유 모듈) ──
        translate(ac_motor_center)
            nema_motor_seat(bc_motor_type, bc_plate_thickness);

        // ── 홀더 플랜지 리세스 — 바깥(윗) 면에서 KFL·FC 플랜지를 가라앉힌다 ──
        base_column_holder_recesses(from_top = true);

        // ── J1 아이들러 조절 슬롯 — 대칭 2슬롯, 축 볼트가 미끄러져 벨트 장력 조절 ──
        base_column_idler_slots();
    }
}

base_column_top_plate();
