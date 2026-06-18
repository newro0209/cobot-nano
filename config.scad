// config.scad - Project-wide shared values for the cobot-nano arm carriage subsystem.
// Holds manufacturing allowances, render resolution, and shared geometry constants, and pulls in the
// NopSCADlib vitamin families plus the project-local vitamin extensions (vitamins/screws, vitamins/pulleys).
//
// 프로젝트 공통값 — 제조 공차(manufacturing allowance), 렌더 해상도, 공유 형상 기준값을 둔다.
// NopSCADlib vitamin 패밀리와 프로젝트 로컬 vitamin 확장(vitamins/screws, vitamins/pulleys)을 함께 가져온다.
// 작은 fudge 값(coincident-face 방지)은 NopSCADlib 전역 `eps`(=1/128)를 그대로 쓴다 — 별도 정의하지 않는다.

include <NopSCADlib/core.scad>
include <NopSCADlib/global_defs.scad>
include <NopSCADlib/vitamins/ball_bearings.scad>
include <NopSCADlib/vitamins/linear_bearings.scad>
include <NopSCADlib/vitamins/leadnuts.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>
include <NopSCADlib/vitamins/shaft_couplings.scad>
include <vitamins/pillars.scad>               // 로컬 M3x25_ff_hex_pillar (+ NopSCADlib pillar 패밀리)
include <vitamins/screws.scad>                // 로컬 M6_shoulder_screw (+ NopSCADlib screw 패밀리)
include <vitamins/pulleys.scad>               // 로컬 GT2x60x8_pulley (+ NopSCADlib pulley 패밀리)
include <vitamins/rods.scad>                  // 로컬 J1_guide_rod / T8x2_lead_screw (+ NopSCADlib rod 모듈)
include <vitamins/flange_couplings.scad>      // 로컬 FC8 플랜지 커플링 (NopSCADlib 미수록)
include <vitamins/flange_bearing_blocks.scad> // 로컬 KFL08 플랜지 베어링 블록 (NopSCADlib 미수록)

// 제조 공차(manufacturing allowance) — 가공/프린트 방식이 바뀌면 여기 한 곳만 고친다.
clearance           = 0.1;  // 부품 간 일반 끼움 간격(general fit) — 간섭(interference) 방지
bearing_clearance   = 0.1;  // 베어링 시트(bearing seat)와 베어링 사이 — 조립 편차·윤활유 수용
shaft_clearance     = 0.5;  // 샤프트 관통홀(shaft through-hole) — 오차·회전축 조립 편차 흡수
min_printed_feature = 0.8;  // FDM 최소 인쇄 두께(≈2 레이어) — 이보다 얇은 부싱/스페이서는 인쇄 대신 와셔로 흡수해 생략

// 공유 형상 기준값(shared geometry)
seat_shoulder_thickness = 2;   // 포켓·리세스 바닥에 남기는 축방향 지지 단차(seat shoulder)
component_margin        = 6;  // 조립 부품 간 최소 간격 — 조립 편차·시각적 명확성 확보

// J1 축 중심 좌표
j1_axis_center = [0, 0];

// ── J1 축(Z 병진, prismatic joint) — 리드스크류로 캐리지를 수직 이송한다 ──
// 모터를 강성 커플링(rigid coupling)으로 리드스크류에 직결하고, 캐리지에 고정된 리드너트(lead nut)가
// 스크류 회전을 직선 이송으로 바꾼다. 가이드 로드(guide rod) 3개가 LM8UU로 캐리지를 직선 안내하고,
// 로드 양끝은 플랜지 커플링으로 단판(end plate)에 수직 고정된다.
j1_motor_type                = NEMA17_34;     // Z 이송 구동 모터
j1_shaft_coupling_type       = SC_5x8_rigid;  // 모터 5mm 축 ↔ 리드스크류 8mm 축 강성 직결
j1_lead_screw_type           = T8x2_lead_screw; // T8x2 리드스크류 — NopSCADlib leadscrew() 렌더 사양
j1_leadnut_type              = LSN8x2;         // T8x2 리드너트 — 회전을 병진으로 변환(리드 2mm/rev)
j1_flange_bearing_block_type = KFL08;          // 리드스크류 회전을 받는 플랜지 베어링 블록
j1_linear_bearing_type       = LM8UU;          // 가이드 로드 직선 베어링
j1_guide_rod_type            = J1_guide_rod;   // LM8UU와 FC8이 공유하는 8mm smooth guide rod
j1_flange_coupling_type      = FC8;            // 가이드 로드 끝을 단판에 수직 고정하는 커플링
// 가이드 로드는 LM8UU가 타는 봉이자 FC8이 무는 봉 — 한 봉을 공유하므로 두 부품의 호칭 지름이 같아야 한다.
assert(smooth_rod_diameter(j1_guide_rod_type) == bearing_rod_dia(j1_linear_bearing_type),
       "J1 가이드 로드 지름은 LM8UU 가이드 베어링 지름과 같아야 한다");
assert(smooth_rod_diameter(j1_guide_rod_type) == fc_bore(j1_flange_coupling_type),
       "J1 가이드 로드 지름은 FC 플랜지 커플링 보어와 같아야 한다");
assert(lead_screw_diameter(j1_lead_screw_type) == leadnut_bore(j1_leadnut_type),
       "J1 리드스크류 지름은 리드너트 보어와 같아야 한다");
assert(lead_screw_diameter(j1_lead_screw_type) == kfl_bore(j1_flange_bearing_block_type),
       "J1 리드스크류 지름은 KFL08 베어링 보어와 같아야 한다");
assert(lead_screw_lead(j1_lead_screw_type) == leadnut_lead(j1_leadnut_type),
       "J1 리드스크류 리드는 리드너트 리드와 같아야 한다");
assert(lead_screw_starts(j1_lead_screw_type) == leadnut_lead(j1_leadnut_type) / leadnut_pitch(j1_leadnut_type),
       "J1 리드스크류 starts는 리드너트 lead/pitch와 같아야 한다");
assert(lead_screw_length(j1_lead_screw_type) < smooth_rod_length(j1_guide_rod_type),
       "J1 리드스크류는 가이드 로드보다 짧아야 한다");
j1_guide_rod_diameter = smooth_rod_diameter(j1_guide_rod_type);
j1_guide_rod_count    = 3;  // 캐리지 3점 지지 — 단일 봉의 비틀림(yaw)·기울어짐(pitch)을 억제

// ── J2 축(어깨 회전, revolute joint) — GT2 타이밍벨트로 상완을 수평 회전한다 ──
// 모터 20T 구동 풀리 → GT2 벨트 → 60T 종동 풀리로 3:1 감속, 종동축은 BB608로 캐리지에 회전 지지된다.
j2_motor_type               = NEMA17_47;       // 어깨 회전 구동 모터(상완 하중 대응 긴 바디)
j2_drive_pulley_type        = GT2x20um_pulley;  // 모터축 20T 구동 풀리(NopSCADlib 기본)
j2_driven_ball_bearing_type = BB608;            // 종동축(어깨 피벗) 회전 지지 베어링
j2_driven_pulley_type       = GT2x60x8_pulley;  // 60T 종동 풀리 — 20:60 = 3:1 감속
j2_driven_shoulder_screw_type = M6_shoulder_screw;  // 어깨 피벗 고정 — 숄더부가 BB608 보어를 채우고 끝 나사산에 락너트가 물린다
j2_driven_flange_coupling_type = FC8;          // 어깨축 상/하단 링크 마운트 — 허브가 숄더 봉을 죄고 플랜지가 상/하 암 링크를 무다

// J1(중심축)에서 J2(어깨축)까지 수평 거리 — 캐리지 판이 두 축을 잇는 길이(기준 치수).
shoulder_mount_link_length = 80;

// J2 어깨축 중심 — J1 원점에서 +Y로 링크 길이만큼 떨어진 좌표.
j2_driven_axis_center = [0, shoulder_mount_link_length];

// 캐리지 스탠드오프 — 위·아래 캐리지 판을 잇는 M3 양끝 암나사 필러와 체결 볼트를 고른다.
// (볼트 서클 배치값은 형상 종속이라 arm_carriage_plate_base.scad의 ac_standoff_*에 둔다.)
standoff_pillar_type = M3x25_ff_hex_pillar;
standoff_screw_type = M3_cap_screw;

$fn = 56;  // 곡면 분할(facets) — vitamin·제작 형상 미리보기에 충분한 해상도
