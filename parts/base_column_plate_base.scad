// parts/base_column_plate_base.scad - Shared base-column end-plate dimensions, the plate blank, and the shared cuts.
// The base column is the fixed J1 structure: flange-mount holders bolted to two end plates capture the lead screw
// (KFL08 flange bearing) and the two guide rods (FC8 flange couplers), spanning the carriage's vertical
// travel. It reuses the arm-carriage J1 axis frame so the moving carriage slides on the very same lead-screw and rod
// axes. No top-level render: this file is included, not run.
//
// 베이스 기둥(base column)의 단판(end plate) 공통 치수·블랭크·공유 음형(cut)을 정의한다.
// 기둥은 J1 고정 구조로, 두 단판에 플랜지 홀더를 볼트 체결해 리드스크류(KFL08 플랜지 베어링)와 가이드 로드 2개를
// (FC8 플랜지 커플러)로 위·아래에서 잡아 캐리지 행정을 가른다. 캐리지가 같은 리드스크류·로드 축을 타도록 암 캐리지의 J1 축 프레임을 공유한다.

include <arm_carriage_plate_base.scad>

// ── 독립 입력 치수(independent inputs) ────────────────────────────────────
bc_travel            = 120;  // J1 캐리지 수직 행정(vertical travel) — 외부 작업 영역(workspace)으로 정해지는 독립값
bc_end_margin        = 24;   // 행정 양 끝과 단판 사이 여유 — 단판 위 벨트 드라이브(belt drive) 스택 높이를 캐리지가 안 닿게 흡수(assembly assert로 검증)
bc_idler_arc_angle  = 130;   // J1 아이들러 공칭 각도(deg, 모터 기준) — 비대칭, 한쪽(+Y)에만
bc_idler_slot_sweep = 28;    // J1 아이들러 호 슬롯 각도 범위(deg) — 모터 중심 호를 따라 장력 조절

// ── 인터페이스 부품(interface vitamins) ───────────────────────────────────
bc_screw_support_type = KFL08;      // 리드스크류 플랜지 베어링 블록 — 보어 8mm가 T8 리드스크류에 맞고, 회전을 반경 지지한다
bc_rod_support_type   = FC8;        // 가이드 로드 플랜지 커플러 — 봉을 허브 멈춤나사로 죄어 플랜지에 수직으로 고정한다
bc_motor_type         = NEMA17_34;  // J1 리드스크류를 벨트로 구동하는 모터 — J2 모터(ac_motor_type)와 독립
bc_idler_pulley_type  = GT2x20_idler_5mm;  // J1 벨트 텐션 아이들러 — 5mm 보어 베어링 일체형, 축에서 자유 회전
bc_idler_screw_type   = M5_cap_screw;      // 아이들러 축 = 베어링 보어(5mm)에 맞춘 M5 볼트(슬롯에서 장력 조절)
bc_rod_diameter       = bearing_rod_dia(ac_linear_bearing_type);  // Ø8 가이드 로드(smooth rod) — LM8UU가 타는 매끈 봉
bc_rod_centers        = [ac_left_linear_bearing_center, ac_right_linear_bearing_center];  // J1 가이드 로드 2축 중심(좌·우) — 여러 곳에서 공유

// ── 단판 두께(end-plate thickness) — 캐리지와 같은 시트 두께를 공유한다 ──
bc_plate_thickness = ac_plate_thickness;

// ── 단판 외곽(end-plate outline) — 가장 멀리 뻗는 플랜지 홀더 외형을 품을 반경 ──
// 홀더 외접원이 축 중심에서 축중심거리만큼 떨어져 놓이므로, 단판 반경 = 축중심거리 + 홀더 외형반경(KFL은 kfl_radius, FC는 플랜지 반경). 셋(캐리지·KFL·FC) 중 최대에 여유를 더한다.
bc_plate_radius = max(ac_outer_radius,
                      ac_z_shaft_center_distance + kfl_radius(bc_screw_support_type),
                      ac_z_shaft_center_distance + fc_flange_diameter(bc_rod_support_type) / 2)
                  + component_margin / 2;

// ── 기둥 유효 높이(column clear height) — 두 단판의 안쪽 면 사이 ──────────
// 캐리지 스택(상판 + 스탠드오프 갭 + 하판)이 행정 전체를 오르내릴 공간에 양 끝 여유를 더한다.
bc_carriage_height = 2 * ac_plate_thickness + ac_standoff_gap;
bc_clear_height    = bc_travel + bc_carriage_height + 2 * bc_end_margin;

assert(kfl_bore(bc_screw_support_type) == leadnut_bore(ac_leadnut_type),
       "KFL 보어는 리드스크류 보어(leadnut_bore)와 같아야 한다");
assert(fc_bore(bc_rod_support_type) == bc_rod_diameter,
       "플랜지 커플러 보어는 가이드 로드 지름과 같아야 한다");

// 상단 단판 윗면(top-plate face) — 상단 플랜지 홀더가 앉고, 결합 조립의 J1 축 스팬 기준이 되는 z. (공유 리드스크류·로드 드로잉은 결합 조립이 소유한다.)
bc_top_face_z = bc_clear_height + bc_plate_thickness;

// ── 홀더 플랜지 리세스(holder flange recess) — KFL·FC 플랜지를 단판 바깥 면에 가라앉혀 위치 고정·낮은 프로파일 ──
bc_screw_support_recess_depth = kfl_thickness(bc_screw_support_type);   // KFL 플랜지가 가라앉는 깊이
bc_rod_support_recess_depth   = fc_flange_thickness(bc_rod_support_type); // FC 플랜지가 가라앉는 깊이
assert(bc_plate_thickness > max(bc_screw_support_recess_depth, bc_rod_support_recess_depth) + seat_shoulder_thickness,
       "홀더 플랜지 리세스 뒤에 시트 숄더가 남을 만큼 단판이 두꺼워야 한다");

// ── J1 벨트 아이들러(idler) — 모터 중심 호(arc) 위 단일 아이들러(비대칭, 한쪽) ──
// 호 반경이 모터에서 일정하므로 슬롯 어디서나 모터 풀리와 component_margin 이격을 유지한다(모터쪽으로 가까워지지 않는다).
bc_idler_arc_radius  = 2 * pulley_extent(bc_idler_pulley_type) + component_margin + clearance;  // 모터 풀리도 같은 20T라 아이들러 extent 2배(+clearance로 부동소수 경계 회피) — plate_base는 모터 풀리 타입을 참조하지 않는다
bc_idler_slot_radius = max(screw_clearance_radius(bc_idler_screw_type),
                           pulley_bore(bc_idler_pulley_type) / 2 + shaft_clearance / 2);
bc_idler_center  = ac_motor_center + bc_idler_arc_radius * [cos(bc_idler_arc_angle), sin(bc_idler_arc_angle)];
bc_idler_centers = [bc_idler_center];   // 결합 조립·슬롯·체결에서 공유(단일 요소 리스트)

// 플랜지 홀더 접선 배치 각도(tangential angle) — 홀더 장축을 반경에 수직으로 둬 모서리를 판 안에 들이고 볼트열을 펼친다.
function bc_tangential_angle(center) = atan2(center.y, center.x) + 90;

// 한 축 중심에 홀더를 접선 방향으로 정렬해 자식(children)을 놓는다(z=0 평면; 호출부가 z·뒤집기를 더한다).
module bc_at_support(center) {
    translate([center.x, center.y])
        rotate(bc_tangential_angle(center))
            children();
}

// 베이스 기둥 단판 블랭크(plate blank) — 세 J1 축과 플랜지 홀더를 담는 원형 판.
module base_column_plate_blank() {
    linear_extrude(bc_plate_thickness)
        circle(r = bc_plate_radius);
}

// 두 단판이 공유하는 음형(cut) — 세 J1 축 관통 보어와 플랜지 홀더 마운팅 볼트 홀. difference() 안에서 쓴다.
module base_column_axis_cuts() {
    // 리드스크류 관통 보어(through bore) — 스크류가 자유롭게 지난다.
    translate(ac_leadnut_center)
        translate_z(-eps)
            cylinder(d = leadnut_bore(ac_leadnut_type) + shaft_clearance, h = bc_plate_thickness + 2 * eps);

    // 가이드 로드 관통 보어 — 봉이 단판을 지나 플랜지 커플러에 물린다.
    for (rod_center = bc_rod_centers)
        translate(rod_center)
            translate_z(-eps)
                cylinder(d = bc_rod_diameter + shaft_clearance, h = bc_plate_thickness + 2 * eps);

    // KFL 마운팅 볼트 홀(mounting holes) — 리드스크류 플랜지 베어링을 판에 무는 도면 s=5 관통 홀.
    bc_at_support(ac_leadnut_center)
        kfl_screw_positions(bc_screw_support_type)
            translate_z(-eps)
                cylinder(d = kfl_bolt_hole_diameter(bc_screw_support_type), h = bc_plate_thickness + 2 * eps);

    // 플랜지 커플러 마운팅 볼트 홀 — 각 가이드 로드 커플러를 판에 무는 볼트원 관통 홀.
    for (rod_center = bc_rod_centers)
        bc_at_support(rod_center)
            fc_screw_positions(bc_rod_support_type)
                translate_z(-eps)
                    cylinder(r = screw_clearance_radius(fc_screw(bc_rod_support_type)), h = bc_plate_thickness + 2 * eps);
}

// 홀더 플랜지 리세스 음형 — KFL 다이아몬드 + FC 원형 플랜지를 단판 바깥 면에서 가라앉힌다(from_top=true 윗면, false 아랫면). difference() 안에서 쓴다.
module base_column_holder_recesses(from_top) {
    // KFL 플랜지(다이아몬드) 리세스 — 다이아몬드 윤곽이 회전 잠금(anti-rotation)도 겸한다.
    bc_at_support(ac_leadnut_center)
        translate_z(from_top ? bc_plate_thickness - bc_screw_support_recess_depth : -eps)
            linear_extrude(bc_screw_support_recess_depth + eps)
                offset(delta = clearance)
                    hull() {
                        circle(d = kfl_width(bc_screw_support_type));
                        for (x = [-1, 1])
                            translate([x * kfl_bolt_pitch(bc_screw_support_type) / 2, 0])
                                circle(d = kfl_length(bc_screw_support_type) - kfl_bolt_pitch(bc_screw_support_type));
                    }

    // FC 플랜지(원형) 리세스.
    for (rod_center = bc_rod_centers)
        translate(rod_center)
            translate_z(from_top ? bc_plate_thickness - bc_rod_support_recess_depth : -eps)
                cylinder(h = bc_rod_support_recess_depth + eps, d = fc_flange_diameter(bc_rod_support_type) + clearance);
}

// J1 아이들러 조절 슬롯 음형 — 모터를 중심으로 휘어진 호(arc) 슬롯 1개. 축 볼트가 호를 따라 미끄러져(모터에서 일정 거리) 벨트 장력을 맞춘다. difference() 안에서 쓴다.
module base_column_idler_slots() {
    steps = 16;
    a0 = bc_idler_arc_angle - bc_idler_slot_sweep / 2;
    a1 = bc_idler_arc_angle + bc_idler_slot_sweep / 2;
    for (i = [0 : steps - 1])
        hull()
            for (a = [a0 + (a1 - a0) * i / steps, a0 + (a1 - a0) * (i + 1) / steps])
                translate(ac_motor_center + bc_idler_arc_radius * [cos(a), sin(a)])
                    translate_z(-eps)
                        cylinder(r = bc_idler_slot_radius, h = bc_plate_thickness + 2 * eps);
}
