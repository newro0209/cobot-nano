// vitamins/screws.scad - Local screw types that extend NopSCADlib's screw family.
// Mirrors NopSCADlib's family-per-file layout: include the library family for the shared schema and
// accessors (screw_washer, screw_nut, screw_radius, ...), then append the project-specific type rows.
//
// NopSCADlib screw 패밀리(family)를 그대로 쓰되, 라이브러리에 없는 프로젝트 전용 스크류 타입만 추가한다.
// 라이브러리를 직접 수정할 수 없으므로 동일 패밀리 파일을 미러링한다 — 경로가 달라 가림(shadow) 충돌은 없다.

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

// J2 종동축(driven axis) 고정용 숄더 볼트(shoulder bolt) — 숄더부가 BB608 보어(8mm)에 끼워져 회전축(fixed pivot)을 이룬다.
// 숄더 지름(shoulder diameter) 8mm > 나사산 M6: 숄더가 베어링 내경을 지지하고 나사산은 그보다 작아야 락너트가 들어간다(ISO 7379).
//                     code           desc           head    shoulder_d head_d head_h socket_d socket_af thread_len washer     nut     tap_radius     clearance_r thread_d
M6_shoulder_screw = ["M6_shoulder", "M6 shoulder", hs_cap, 8,         13,    5.5,   3,       4,        9.5,       M8_washer, M6_nut, M6_tap_radius, 4.0,        6];
