// assemblies/column_carriage_assembly.scad - J1 Z stage: the fixed base column plus the riding arm carriage.
// Combines the two sub-assemblies on one J1 axis and is the single owner of the shared lead screw + guide rods that
// span the column — the base column captures them in its KFL/FC holders and the carriage rides them, so neither
// sub-assembly draws them alone. cc_carriage_travel slides the carriage 0..1 along the travel.
//
// J1 Z 스테이지(stage) 조립 — 고정 베이스 기둥 + 그 위를 타는 암 캐리지를 한 J1 축에 결합한다.
// 기둥을 관통하는 공유 리드스크류·가이드 로드를 여기서만 그린다(기둥이 KFL·FC 홀더로 잡고 캐리지가 타므로 두 서브 조립은 봉을 그리지 않는다).
// cc_carriage_travel(0..1)로 캐리지를 행정 위·아래로 옮긴다.

cc_carriage_travel = 0.5; // [0:0.05:1]
cc_animate_carriage = false;   // [false:true]
show_hardware = true;          // 기성품 하드웨어 표시 — false면 출력물(단판·허브 등)만, 두 서브 조립·공유 봉에 전달

cc_carriage_travel_effective = cc_animate_carriage ? (sin($t * 360) / 2) + 0.5 : cc_carriage_travel;

include <../parts/base_column_plate_base.scad>   // bc_*/ac_* 기준값(축 중심·높이·홀더 타입)
use <base_column_assembly.scad>
use <arm_carriage_assembly.scad>
use <NopSCADlib/vitamins/rod.scad>

// 캐리지 리프트(lift) — 기둥 내부 좌표(하단 단판 윗면 z=0)에서 캐리지 하단을 행정 위치로 올린다.
// 행정 0 = 아래 끝(여유 bc_end_margin), 1 = 위 끝. 캐리지 하단(local) = −(스탠드오프 갭 + 판 두께).
cc_carriage_lift = bc_end_margin + bc_travel * cc_carriage_travel_effective + ac_standoff_gap + ac_plate_thickness;

// ── 공유 J1 축 스팬(shaft span) — 두 단판의 KFL·FC 홀더를 관통한다 ──
bc_screw_bottom_z = -bc_plate_thickness - kfl_height(bc_screw_support_type);
bc_screw_top_z    = bc_top_face_z + kfl_height(bc_screw_support_type);
bc_screw_length   = bc_screw_top_z - bc_screw_bottom_z;
bc_screw_center_z = (bc_screw_top_z + bc_screw_bottom_z) / 2;
bc_rod_bottom_z   = -bc_plate_thickness - fc_height(bc_rod_support_type);
bc_rod_top_z      = bc_top_face_z + fc_height(bc_rod_support_type);
bc_rod_length     = bc_rod_top_z - bc_rod_bottom_z;
bc_rod_center_z   = (bc_rod_top_z + bc_rod_bottom_z) / 2;

// 공유 J1 축 하드웨어 — 회전 리드스크류(T8x2) + 고정 가이드 로드 2개. 기둥이 잡고 캐리지가 타므로 결합 조립에서 한 번만 그린다.
module bc_j1_shafts() {
    translate([ac_leadnut_center.x, ac_leadnut_center.y, bc_screw_center_z])
        leadscrew(leadnut_bore(ac_leadnut_type), bc_screw_length,
                  leadnut_lead(ac_leadnut_type),
                  leadnut_lead(ac_leadnut_type) / leadnut_pitch(ac_leadnut_type));
    for (rod_center = bc_rod_centers)
        translate([rod_center.x, rod_center.y, bc_rod_center_z])
            rod(bc_rod_diameter, bc_rod_length);
}

module column_carriage_assembly() {
    // 고정 베이스 기둥(단판·KFL·FC·모터·벨트).
    base_column_assembly(show_hardware = show_hardware);

    // 공유 J1 축 — 리드스크류·가이드 로드(하드웨어)가 기둥을 관통한다.
    if (show_hardware)
        bc_j1_shafts();

    // 암 캐리지 — 행정 위치로 올린다.
    translate_z(cc_carriage_lift)
        arm_carriage_assembly(show_hardware = show_hardware);
}

column_carriage_assembly();
