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
// 바깥 지름(outer diameter) = 2*(60*2/(2*PI) - belt_pitch_offset(GT2x6)) ≈ 37.7mm (피치원에서 벨트 두께만큼 안쪽).
//                   code               type  teeth od    belt   bore_r flange_d hub_h bore body_d sc_w sc_z sc_r screw          flanges
GT2x60x8_pulley = ["GT2x60x8_pulley", "GT2", 60,   37.7, GT2x6, 7,     18,      8,    8,   41,    1.0, 6,   3.5, M3_grub_screw, 2];

// J2 아이들러 — 5mm 보어 베어링 일체형(integral bearing) GT2 20T 토스트 아이들러. 보어(bore)=베어링 내경 5mm, M5 축에 끼워 자유 회전한다.
// NopSCADlib GT2x20_toothed_idler(보어 4mm)를 미러링하되 보어만 5mm로 둔다(screws=0 → idler, 내장 베어링).
//                     code               type  teeth od     belt   r1   flange_d f1 bore w_etc...
GT2x20_idler_5mm = ["GT2x20_idler_5mm", "GT2", 20,   12.22, GT2x6, 6.5, 18,      0, 5,   18.0,  1.0, 0,   0,   false,         0];
