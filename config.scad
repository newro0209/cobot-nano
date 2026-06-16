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
include <NopSCADlib/vitamins/pillars.scad>
include <NopSCADlib/vitamins/stepper_motors.scad>
include <vitamins/screws.scad>   // 로컬 M6_shoulder_screw (+ NopSCADlib screw 패밀리)
include <vitamins/pulleys.scad>  // 로컬 GT2x60x8_pulley (+ NopSCADlib pulley 패밀리)

// 제조 공차(manufacturing allowance) — 가공/프린트 방식이 바뀌면 여기 한 곳만 고친다.
clearance         = 0.1;  // 부품 간 일반 끼움 간격(general fit) — 간섭(interference) 방지
bearing_clearance = 0.1;  // 베어링 시트(bearing seat)와 베어링 사이 — 조립 편차·윤활유 수용
shaft_clearance   = 0.5;  // 샤프트 관통홀(shaft through-hole) — 오차·회전축 조립 편차 흡수

// 공유 형상 기준값(shared geometry)
seat_shoulder_thickness = 2;   // 포켓·리세스 바닥에 남기는 축방향 지지 단차(seat shoulder)
component_margin        = 12;  // 조립 부품 간 최소 간격 — 조립 편차·시각적 명확성 확보

$fn = 56;  // 곡면 분할(facets) — vitamin·제작 형상 미리보기에 충분한 해상도
