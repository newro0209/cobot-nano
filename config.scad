// config.scad - Holds project-wide configuration and non-link assembly targets.
// Link family dimensions live in plates/links.scad so the typed link instances stay next to their 2D profile schema.
//
// 프로젝트 공통 구성(project-wide configuration)과 링크 외 조립 기준값(non-link assembly target)을 관리한다.
// 링크 패밀리(link family)의 치수와 타입 배열(type array)은 2D 프로파일 스키마(profile schema) 옆의 `plates/links.scad`에서 관리한다.

include <NopSCADlib/core.scad>
include <NopSCADlib/global_defs.scad>
include <NopSCADlib/vitamins/ball_bearings.scad>
include <NopSCADlib/vitamins/linear_bearings.scad>
include <NopSCADlib/vitamins/leadnuts.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>
include <NopSCADlib/vitamins/screws.scad>
include <NopSCADlib/vitamins/pulleys.scad>

clearance = 0.1; // 일반적인 간섭(interference)을 방지하기 위한 기본 여유(margin) — 부품 간의 간격을 유지한다.
bearing_clearance = 0.1; // 베어링 시트 포켓(bearing seat pocket)과 베어링 사이의 여유(clearance)는 조립 편차와 윤활유(lubricant)를 수용한다.
shaft_clearance = 0.5;   // 샤프트 관통홀(shaft through-hole)은 오차와 회전축 조립 편차를 흡수하도록 더 큰 여유를 둔다.
boolean_epsilon = 0.01;  // 부울 연산(boolean operation)에서 작은 간격(small gap)을 허용해 불필요한 정점(vertex)과 면(face)이 생기는 것을 방지한다.
explode_distance = 0.1; // 조립 exploded view에서 부품 간의 간격.
seat_shoulder_thickness = 2; // 시트 숄더(seat shoulder) — 포켓·리세스 바닥에 남기는 축방향 지지 두께.
plate_thickness = 6; // 링크 플레이트 두께(link plate thickness) — 베어링 시트 포켓과 외륜 숄더를 포함하도록 충분히 두껍게 한다.
component_margin = 6; // 조립에서 부품 간의 최소 간격 — 조립 편차와 시각적 명확성을 위해 충분히 크게 한다.

$fn = 56;

// 독립 기준값(independent target)은 외부 제약이나 설계 의사결정으로 직접 정해지는 값이다.
MAX_REACH = 280;
BB6805 = ["6805", 25, 37, 7, "black", 1.5, 1.6, 0, 0];

// J2 어깨 축(shoulder axis) 고정 숄더 볼트(shoulder bolt) — NopSCADlib screw 스키마로 정의한 로컬 타입.
// 숄더 지름(shoulder diameter) 8mm를 BB608 보어(8mm)에 맞춰 고정축(fixed axis)으로 쓴다. 나사산은 ISO 7379대로 M6 (숄더보다 작아야 함).
//                     code          desc          head    ds  dk   k    socket_depth socket_af max_thread washer     nut     tap_radius     clearance_r thread_d
M6_shoulder_screw = ["M6_shoulder", "M6 shoulder", hs_cap, 8,  13,  5.5, 3,           4,        9.5,       M8_washer, M6_nut, M6_tap_radius, 4.0,        6];

// GT2x60: NopSCADlib에 없는 로컬 타입. od = 2*(60*2/(2*PI) - belt_pitch_offset(GT2x6)) = 37.7mm.
// 보어(bore) 12mm = BB6201 내경(bore)에 맞춰 어깨 축(shoulder shaft)에 직접 압입 가능.
GT2x60_pulley = ["GT2x60_pulley", "GT2", 60, 37.7, GT2x6, 7, 18, 8, 5, 41, 1.0, 6, 3.5, M3_grub_screw, 2];
