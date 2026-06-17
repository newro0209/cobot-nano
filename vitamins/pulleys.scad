// vitamins/pulleys.scad - Local pulley types that extend NopSCADlib's pulley family.
// Mirrors NopSCADlib's family-per-file layout: include the library family for the shared schema and
// accessors (pulley_extent, pulley_bore, pulley_offset, ...), then append the project-specific type rows.
//
// NopSCADlib pulley 패밀리(family)를 그대로 쓰되, 라이브러리에 없는 프로젝트 전용 풀리 타입만 추가한다.
// 라이브러리를 직접 수정할 수 없으므로 동일 패밀리 파일을 미러링한다 — 경로가 달라 가림(shadow) 충돌은 없다.

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>
include <NopSCADlib/vitamins/pulleys.scad>

// J2 종동축(driven axis) 풀리 — 60T GT2, 보어(bore) 8mm를 BB608 내경/숄더 볼트에 맞춘다.
// 치형 외경(teeth OD)은 60T 2GT 표준값 37.69mm 근처이고, 플랜지 외경은 일반 BF형 제품의 약 42mm를 따른다.
//                   code               type  teeth od     belt   width hub_dia hub_l bore flange_d flange_t screw_l screw_z screw          screws
GT2x60x8_pulley = ["GT2x60x8_pulley", "GT2", 60,   37.69, GT2x6, 7,    25,     9,    8,   42,      1.0,     6,      4.5,    M4_grub_screw, 2];

// J1 리드스크류 종동 풀리 — 20T GT2, 보어(bore) 8mm를 T8 리드스크류에 맞춘다(모터 20T와 1:1 직결, 감속 없음).
//                   code               type  teeth od     belt   width hub_dia hub_l bore flange_d flange_t screw_l screw_z screw          screws
GT2x20x8_pulley = ["GT2x20x8_pulley", "GT2", 20,   12.22, GT2x6, 7,     18,      7,    8,   18,    1.0, 6,   3.75, M3_grub_screw, 2];
