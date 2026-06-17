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

// 대비 테두리 색(contrast outline) — 글자색 명도로 흑/백을 골라 어떤 대상색에서도 글자가 읽히게 한다.
// 회색 계열은 RGB 보색이 다시 회색이라 대비가 안 나므로, 명도(luminance) 기준 흑/백을 쓴다.
function contrast_outline(colour) =
    (colour[0] * 0.299 + colour[1] * 0.587 + colour[2] * 0.114) > 0.5 ? [0.05, 0.05, 0.06] : [1, 1, 1];

// 빌보드 텍스트(billboard text) — 뷰포트 회전 $vpr만큼 돌려 어느 각도에서 보든 카메라를 향한다. 강조는 볼드 글꼴.
// halign으로 글자가 지시선 끝점에서 바깥으로 뻗게 한다(좌측 열=right, 우측 열=left).
// colour는 대상 부품과 같은 색, outline>0이면 그 뒤에 대비 테두리를 깔아 가독성을 올린다.
module billboard_text(string, size, bold = false, halign = "center", colour = [0, 0, 0], outline = 0) {
    font = bold ? "Liberation Sans:style=Bold" : "Liberation Sans";
    rotate($vpr) {
        if (outline > 0)
            color(contrast_outline(colour))
                translate([0, 0, -0.05])
                    linear_extrude(0.1)
                        offset(delta = outline)
                            text(string, size = size, font = font, halign = halign, valign = "center");
        color(colour)
            linear_extrude(0.12)
                text(string, size = size, font = font, halign = halign, valign = "center");
    }
}

// ── 화면 기준축(screen basis) — 빌보드와 같은 원리로 뷰포트 회전 $vpr에서 월드 좌표의 화면 우/상/법선 축을 만든다.
// R = rotate($vpr) = Rz(c)·Ry(b)·Rx(a)의 열벡터: x̂열=화면 오른쪽, ŷ열=화면 위, ẑ열=카메라를 향하는 법선.
// 라벨을 화면 평면에 펼쳐 부품에 가리지 않게 배치할 때 쓴다.
function _vpr()  = is_undef($vpr) ? [55, 0, 25] : $vpr;
function screen_right()  = let(v = _vpr(), a = v[0], b = v[1], c = v[2],
    cb = cos(b), sb = sin(b), cc = cos(c), sc = sin(c)) [cc * cb, sc * cb, -sb];
function screen_up()     = let(v = _vpr(), a = v[0], b = v[1], c = v[2],
    ca = cos(a), sa = sin(a), cb = cos(b), sb = sin(b), cc = cos(c), sc = sin(c))
    [cc * sb * sa - sc * ca, sc * sb * sa + cc * ca, cb * sa];
function screen_normal() = let(v = _vpr(), a = v[0], b = v[1], c = v[2],
    ca = cos(a), sa = sin(a), cb = cos(b), sb = sin(b), cc = cos(c), sc = sin(c))
    [cc * sb * ca + sc * sa, sc * sb * ca - cc * sa, cb * ca];

// 호출 라벨(callout) — 한 부품의 모든 인스턴스 점(points)에서 화면 가장자리 정착점(anchor)으로 지시선을 긋고 텍스트를 한 번 단다.
// 같은 부품이 여러 개면(스탠드오프·베어링 등) 점마다 지시선·점을 그려, 설명서처럼 모든 인스턴스를 빠짐없이 가리킨다.
// 지시선은 양끝 두께가 같고 끝마다 점(dot)을 찍는다. 텍스트는 anchor 너머 바깥(side)으로 정렬해 부품에서 멀어지게 둔다. $preview 전용.
module one_callout(string, points, anchor, side, colour = [0, 0, 0], emphasis = false, gap = 4) {
    line_d  = emphasis ? 0.9 : 0.45;   // 지시선 굵기(양끝 동일)
    dot_d   = emphasis ? 2.4 : 1.5;    // 끝점 점(dot) 지름
    tsize   = emphasis ? 3.4 : 2.4;
    outline = emphasis ? 0.22 : 0.15;  // 대비 테두리 폭
    // 지시선·점은 대상과 같은 색(colour)으로 그려, 라벨이 어느 부품을 가리키는지 색으로도 잇는다.
    color(colour) {
        for (p = points) {
            // 지시선 — 부품 인스턴스 점에서 정착점까지 균일 두께로 잇는다.
            hull() {
                translate(p)      sphere(d = line_d, $fn = 12);
                translate(anchor) sphere(d = line_d, $fn = 12);
            }
            translate(p) sphere(d = dot_d, $fn = 20);   // 부품 끝 점(인스턴스마다)
        }
        translate(anchor) sphere(d = dot_d * 0.75, $fn = 16);   // 라벨 끝 점(공유)
    }
    translate(anchor + screen_right() * side * gap)
        billboard_text(string, tsize, emphasis, halign = side > 0 ? "left" : "right",
                       colour = colour, outline = outline);
}

// 점 무리의 무게중심(centroid) — 한 라벨의 여러 인스턴스 점을 대표하는 한 점을 구해 화면 좌표 산정 기준으로 쓴다.
// [1,1,..]·(N×3 행렬) = 좌표 합이라는 성질로 평균을 낸다(OpenSCAD 벡터·행렬 곱).
function centroid(points) = ([for (p = points) 1] * points) / len(points);

// 호출 라벨 자동 배치(callout field) — 고정 lead 없이 뷰포트($vpr)와 부품 좌표로 라벨을 화면 좌/우 두 열에 균등 분배한다.
// 각 라벨의 대표점(인스턴스 무게중심) 화면좌표(u,v)를 구해 u부호로 좌/우 열을 정하고, 열 안에서 v로 정렬해 균등 간격으로 실루엣 밖에 둔다.
// items = [[텍스트, 부품 점 리스트, 색, 강조], ...]. center = 화면투영 기준점.
// min_halfw = 열 가로 오프셋 하한(정지 실루엣 반경). exploded로 부품이 퍼지면 실측 |u| 최대로 키워 항상 부품 바깥에 둔다.
// row_spacing = 열 안 행 간격. 열을 데이터 세로 중심(vmid)에 두고 개수만큼 위아래로 키워, 한쪽에 몰려도 겹치지 않게 한다.
module callout_field(items, center, min_halfw, pad = 10, front = 8, row_spacing = 4.6) {
    n = len(items);
    if ($preview && n > 0) {
        sr = screen_right();
        su = screen_up();
        sn = screen_normal();
        reps = [for (it = items) centroid(it[1])];       // 라벨별 대표점
        us = [for (r = reps) (r - center) * sr];   // 화면 가로 좌표
        vs = [for (r = reps) (r - center) * su];   // 화면 세로 좌표
        halfw = max(min_halfw, max([for (u = us) abs(u)]) + pad);   // 부품이 퍼져도 열은 그 바깥
        vmid  = (max(vs) + min(vs)) / 2;   // 데이터 세로 중심 — 각 열을 이 중심에 맞춰 펼친다
        sides = [for (u = us) u >= 0 ? 1 : -1];
        for (i = [0 : n - 1])
            let(side  = sides[i],
                col   = [for (j = [0 : n - 1]) if (sides[j] == side) j],   // 같은 열 항목
                m     = len(col),
                // 열 안 세로 순위(0=맨 위). 같은 v(동일 좌표 라벨)는 인덱스로 동점 처리해 슬롯이 겹치지 않게 한다.
                rank  = len([for (j = col) if (vs[j] > vs[i]) 1])
                      + len([for (j = col) if (vs[j] == vs[i] && j < i) 1]),
                // vmid 중심에서 row_spacing 균등 — 위(+)에서 아래(-)로. 개수가 늘면 열이 그만큼 길어진다.
                vv    = vmid + ((m - 1) / 2 - rank) * row_spacing,
                anchor = center + sr * side * halfw + su * vv + sn * front)
                one_callout(items[i][0], items[i][1], anchor, side,
                            colour = items[i][2], emphasis = items[i][3]);
    }
}

// 스택 순서 체인(stack sequence) — 한 축의 조립 순서를 "A -> B -> ... -> Z"로 표현한다.
// items = [[이름, 축 위 부품 z], ...]를 위→아래 순서대로. 축 옆 열에 번호로 늘어놓고, 각 부품 점으로 지시선을 긋고,
// 항목 사이를 세로 척추선(spine)으로 이어 조립 순서를 한눈에 보여준다. $preview 전용.
module stack_sequence(items, axis_xy, label_x, top_z, bottom_z, colour = [0.1, 0.1, 0.12]) {
    n = len(items);
    function row_z(i) = lerp3(top_z, bottom_z, n <= 1 ? 0 : i / (n - 1));
    spine_x = label_x - 13;
    if ($preview)
        color(colour) {
            // 척추선(spine) — 열 왼쪽을 세로로 관통하는 순서 체인.
            hull() {
                translate([spine_x, axis_xy.y, row_z(0)])     sphere(d = 0.9, $fn = 12);
                translate([spine_x, axis_xy.y, row_z(n - 1)]) sphere(d = 0.9, $fn = 12);
            }
            // 맨 아래 화살촉 — 순서 방향(아래로).
            translate([spine_x, axis_xy.y, row_z(n - 1)])
                rotate([90, 0, 0]) cylinder(h = 2.4, d1 = 2.6, d2 = 0, $fn = 16);

            for (i = [0 : n - 1]) {
                label = [label_x, axis_xy.y, row_z(i)];
                part  = [axis_xy.x, axis_xy.y, items[i][1]];   // 축 위 실제 부품 점
                // 부품 점 → 번호 라벨 지시선(균일 두께).
                hull() {
                    translate(part)  sphere(d = 0.5, $fn = 12);
                    translate(label) sphere(d = 0.5, $fn = 12);
                }
                translate(part) sphere(d = 1.0, $fn = 16);
                // 척추선 → 번호 라벨 가지(branch).
                translate([spine_x, axis_xy.y, row_z(i)]) sphere(d = 1.0, $fn = 12);
                translate(label) billboard_text(str(i + 1, ".  ", items[i][0]), 2.7);
            }
        }
}
