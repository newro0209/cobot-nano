// parts/base_column_bottom_plate.scad - Lower end plate: motor recess plus shared axis bores and flange-holder bolts.
// The J1 drive motor mounts from below (body hangs into the pedestal, shaft up through the plate to its pulley); the
// lead screw and guide rods pass through clearance bores and are gripped by KFL08/SHF8 holders bolted to the faces.
//
// 베이스 기둥 하단 단판(lower end plate) — J1 구동 모터 리세스(recess) + 공유 축 보어·플랜지 홀더 볼트 홀.
// 모터는 아랫면으로 삽입해 바디가 베이스 페디스털(pedestal) 쪽으로 빠지고 샤프트는 판을 지나 위쪽 풀리로 올라간다.
// 리드스크류·가이드 로드는 관통 보어로 지나고, 판 면에 볼트 체결된 KFL08·SHF8 홀더가 잡는다.

include <base_column_plate_base.scad>

module base_column_bottom_plate() {
    difference() {
        base_column_plate_blank();

        base_column_axis_cuts();

        // ── J1 구동 모터(NEMA17) — 아랫면(z=0)에서 삽입 ──────────────────
        translate(ac_motor_center) {
            // 모터 바디 리세스(body recess) — 아랫면에서 NEMA 외형만큼 파, 위쪽에 플랜지가 짚을 시트 숄더를 남긴다.
            translate_z(-eps)
                linear_extrude(ac_motor_recess_depth + eps)
                    offset(delta = clearance)
                        NEMA_outline(ac_motor_type);

            // 센터링 보스·샤프트 관통(boss + shaft through-bore) — 보스 지름으로 끝까지 뚫어 샤프트가 판 위 풀리에 닿는다.
            translate_z(-eps)
                cylinder(h = bc_plate_thickness + 2 * eps, r = ac_motor_boss_recess_radius);

            // 모터 스크류 클리어런스 홀(screw clearance holes) — NEMA 홀 피치 기준 플랜지 체결 경로.
            NEMA_screw_positions(ac_motor_type)
                translate_z(-eps)
                    cylinder(h = bc_plate_thickness + 2 * eps, r = M3_clearance_radius);
        }
    }
}

base_column_bottom_plate();
