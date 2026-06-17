// vitamins/pillars.scad - Local pillar types that extend NopSCADlib's pillar family.
// Mirrors NopSCADlib's family-per-file layout: include the library family for the shared schema and
// accessors (pillar_od, pillar_height, pillar_top_thread, pillar_bot_thread, ...), then append project rows.
//
// NopSCADlib pillar 패밀리(family)를 그대로 쓰되, 라이브러리에 없는 프로젝트 전용 필러 타입만 추가한다.
// 라이브러리를 직접 수정할 수 없으므로 동일 패밀리 파일을 미러링한다 — 경로가 달라 가림(shadow) 충돌은 없다.

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/pillars.scad>

// 두 판 사이 스탠드오프(standoff) — 양끝 암나사(female-female) M3x20 육각 필러.
// NopSCADlib M3x20_hex_pillar는 수-암(top −8, bot +8)이라 한쪽이 수나사 스터드다. 두 판을 위·아래 스크류로 죄려면 양끝 암나사가 필요해 bot도 −8로 둔다.
//                       code                  style  M  len top_af      bot_af      tl bl colour     colour2 top_thr bot_thr wafer
M3x20_ff_hex_pillar = ["M3x20_ff_hex_pillar", "hex", 3, 20, 5 / cos(30), 5 / cos(30), 6, 6, "silver",  silver, -8,     -8,     true];
