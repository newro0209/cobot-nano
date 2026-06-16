// assemblies/annotations.scad - Preview-only callout labels: a leader line plus camera-facing billboard text.
// Colour is passed in fully resolved (so the caller can spread tone-on-tone shades within a colour family); the
// emphasis flag only thickens the leader and bolds the text for important elements (axes, links). Labels are
// $preview-only and never affect STL or cut geometry.
//
// 프리뷰 전용 호출 라벨(callout) — 지시선(leader line)과 카메라를 향하는 빌보드 텍스트(billboard text).
// 색은 호출부에서 최종값으로 받아(한 계열 안에서 톤온톤 농담을 부여), emphasis는 색이 아니라 지시선 굵기·볼드만 바꾼다.
// $preview에서만 그려져 STL·조립 형상에는 영향을 주지 않는다.

include <NopSCADlib/core.scad>

function lerp3(a, b, t) = a + (b - a) * t;

// 한 색 계열 안에서 톤(tone: 0=진함 .. 1=옅음)으로 농담을 만든다 — 톤온톤. 같은 그룹 부품끼리 겹치지 않게 한다.
function label_shade(base, tone) = lerp3(base * 0.70, base + ([1, 1, 1] - base) * 0.62, tone);

// 빌보드 텍스트(billboard text) — 뷰포트 회전 $vpr만큼 돌려 어느 각도에서 보든 카메라 정면. 강조는 볼드 글꼴.
module billboard_text(string, size, bold = false) {
    rotate($vpr)
        linear_extrude(0.1)
            text(string, size = size,
                 font = bold ? "Liberation Sans:style=Bold" : "Liberation Sans",
                 halign = "center", valign = "center");
}

// 부품 호출 라벨(part callout) — target(부품 점)에서 lead만큼 떨어진 곳에 텍스트를 두고 지시선으로 잇는다.
// colour는 이미 톤이 적용된 최종 색. emphasis=true(축·링크)면 굵은 지시선 + 큰 볼드 텍스트 + 큰 점 마커.
module part_label(string, target, lead, colour = [0, 0, 0], emphasis = false) {
    line_d    = emphasis ? 1.0 : 0.35;   // 지시선 굵기
    text_size = emphasis ? 3.4 : 2.4;
    dot_d     = emphasis ? 2.0 : 1.1;    // 부품 점 마커 지름
    tip = target + lead;
    if ($preview)
        color(colour) {
            // 지시선(leader line) — 부품 점에서 텍스트로 가늘어지는 선.
            hull() {
                translate(target) sphere(d = line_d * 1.8, $fn = 16);
                translate(tip)    sphere(d = line_d, $fn = 12);
            }
            translate(target) sphere(d = dot_d, $fn = 20);   // 부품 점 마커(dot)
            translate(tip) billboard_text(string, text_size, emphasis);
        }
}
