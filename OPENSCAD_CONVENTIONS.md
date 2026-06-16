---
name: openscad-conventions
description: 이 프로젝트에서 OpenSCAD 파라메트릭 모델을 설계, 구현, 수정, 리뷰할 때 적용하는 코딩 컨벤션.
version: 2.0-openscad
---

# OpenSCAD 코딩 컨벤션

> OpenSCAD는 선언형·함수형 CAD 언어다. 변수는 컴파일 시점에 확정되는 불변값이며, 재할당·반복 누적·예외 처리·객체지향 개념이 없다. 이 문서는 그 특성에 맞춰 작성되었다.

## 규칙 강도 표기

| 표기 | 의미 |
|------|------|
| **MUST** | 반드시 따른다. 위반은 잘못된 구현으로 간주한다. |
| **NEVER** | 어떤 경우에도 금지한다. |
| **SHOULD** | 기본으로 따른다. 위반 시 사유를 명시한다. |

## 충돌 시 우선순위

규칙이 충돌하면 위 항목이 항상 우선한다.

1. **현재 부품·요구의 정확한 충족** — 지금 필요 없는 파라미터·옵션은 만들지 않는다 (YAGNI)
2. **읽기 쉬움** — 한 번에 이해되지 않는 모델은 잘못된 설계다 (KISS)
3. **의미 보존** — 이름과 구조가 기계 부품의 의미를 드러내야 한다
4. **중복 제거** — 의미를 해치면 형상 중복을 허용한다 (DRY는 최하위)

---

## 1. 네이밍 [N]

### N-1 (MUST) 이름만으로 부품·치수의 역할을 추론할 수 있어야 한다

OpenSCAD 관례에 따라 모듈·함수·변수는 `snake_case`로 작성한다.

| ✅ 권장 | ❌ 금지 |
|---------|---------|
| `gt2_pulley`, `bearing_seat_608zz` | `part1`, `obj`, `thing` |
| `joint_actuator_housing` | `data`, `temp`, `stuff` |
| `belt_anchor_clamp` | `helper`, `util`, `make` |
| `shoulder_bolt_clearance` | `val`, `x1`, `do_it` |

### N-2 (MUST) CAD 표준 치수 약어만 허용한다

다음 한 글자 약어는 CAD·OpenSCAD 관례상 허용한다.

> `r`(반지름) · `d`(지름) · `h`(높이) · `w`(폭) · `t`(두께) · `od`/`id`(외경/내경) · `$fn`/`$fa`/`$fs`(해상도)

그 외 임의 단축어는 금지한다. 단, N-4의 부품 패밀리 접두사처럼 파일·타입 스키마가 정의한 짧은 도메인 prefix는 임의 단축어로 보지 않는다.

| ❌ 금지 | ✅ 권장 |
|---------|---------|
| `cfg`, `cnt`, `tol` | `configuration`, `count`, `clearance` |
| `brg`, `plt` | `bearing`, `pulley` |
| `dia` | `diameter` (또는 `d`) |

### N-3 (SHOULD) 짧은 이름보다 오해 없는 이름

`wall` → `mounting_wall_thickness`, `gap` → `axial_clearance`
단, 명확한 지역 변수(루프 인덱스 `i`, 각도 `a`)는 예외다.

### N-4 (MUST) 단일 프로젝트 설정값에는 반복 접두사를 붙이지 않는다

이 저장소처럼 단일 로봇을 모델링하는 프로젝트는 파일과 프로젝트가 이미 맥락을 제공하므로 설정 변수에 `design_`, `spec_`, `cobot_` 같은 반복 접두사를 붙이지 않는다. 공통 기준값은 `config.scad`에 두고, 특정 부품 패밀리의 기준값과 타입 배열은 해당 plural 파일에 둔다.

단, NopSCADlib와 로컬 타입 배열의 접근자 함수는 T-2에 따라 `prefix_property(type)` 형식을 유지한다. 여러 파일이 같은 부품 패밀리의 공통 기준값을 include해 공유하는 경우에도 NopSCADlib처럼 짧고 안정적인 패밀리 prefix를 쓴다. 예를 들어 `arm_carriage_plate_base.scad`가 제공하는 전역 치수·좌표는 긴 `arm_carriage_*` 대신 `ac_*`를 사용한다.

```scad
// config.scad
sheet_thickness = 6;
main_bolt_diameter = 5;

// plates/links.scad
lower_link_length = 200;
upper_link_length = lower_link_length * upper_link_length_ratio;

// parts/arm_carriage_plate_base.scad
ac_leadnut_type = LSN8x2;
ac_motor_center = [0, 0];
ac_thickness = bb_width(ac_driven_axis_ball_bearing_type) + seat_shoulder_thickness;
```

---

## 2. 파일 구조와 책임 분리 [S]

### S-1 (MUST) 파일을 다음 순서로 구성한다

```text
1. 파라미터 블록   — 모든 설정 가능한 치수·공차를 상단에 모은다
2. 함수            — 순수 계산 (피치 지름, 좌표 생성 등)
3. 부품 모듈       — 출력·가공 단위가 되는 개별 부품
4. 어셈블리 모듈   — 부품을 조합해 배치 (시각화·간섭 확인용)
5. 렌더 선택부     — 무엇을 출력할지 고르는 진입점
```

### S-2 (MUST) 한 모듈 = 한 부품, 한 함수 = 한 계산

하나의 모듈은 하나의 출력·가공 단위(또는 하나의 기능적 형상)만 담당한다.

### S-3 (MUST) 매직 넘버를 금지한다 — 모든 치수는 명명된 파라미터로

특히 **공차·클리어런스**는 반드시 명명 변수로 분리한다. 프린터·가공 방식이 바뀌면 한 곳만 고치면 되도록 한다.

```text
// 제조 공차 (한 곳에서 관리)
fdm_clearance      = 0.2;   // PETG FDM 압출 공차(extrusion tolerance)
press_fit_interference = 0.05; // 608ZZ 베어링 압입 간섭(interference fit)
axial_clearance    = 0.3;   // 회전 허브-인접부 축방향 간격(axial gap)
```

### S-4 (NEVER) 미래 부품을 가정한 파라미터·옵션 선제작 금지

지금 만드는 부품에 필요 없는 분기·옵션 인자를 미리 넣지 않는다.

### S-5 (MUST) 형상 공통화 게이트 — 아래를 **모두** 만족할 때만 모듈로 추출한다

1. 동일 형상이 **3회 이상** 반복됨
2. 의미가 동일함 (우연히 모양만 같은 것은 중복이 아님)
3. 추출 후 이름이 더 명확해짐
4. 치수 변경 방향이 같다고 확신할 수 있음

하나라도 불충족 → 형상을 그대로 둔다. 볼트 구멍 하나를 성급히 모듈화하지 않는다.

### S-6 (MUST) `config.scad`와 plural 파일의 기준값 책임을 분리한다

`config.scad`에는 제조 공차, 렌더 해상도, 판재 두께, 체결 부품 선택, 베이스 vitamin, 기본 포즈처럼 여러 계층이 공유하는 기준값을 둔다. 특정 부품 패밀리의 치수, 비율, 타입 배열은 해당 plural 파일에 둔다. 예를 들어 링크 길이, 링크 폭, 링크 타입 배열, 커플러 오프셋은 `plates/links.scad`에서 관리한다. 판재 적층 수처럼 2D 프로파일이 아니라 3D 제작 방식에 속하는 값은 `fabrications/` 계층에 둔다.

```scad
// config.scad
clearance = 0.3;
$fn = 48;
sheet_thickness = 6;
main_bolt_diameter = 5;

// plates/links.scad
lower_link_length = 200;
upper_link_length = lower_link_length * upper_link_length_ratio;

// fabrications/link_stacks.scad
link_stack_layers = 2;
```

### S-7 (MUST) 연결된 치수는 비율로 파생한다

직접 mm 값을 두는 대상은 기준 링크 길이, 판재 두께, 볼트 지름처럼 외부 제약이나 설계 의사결정으로 독립적으로 정해지는 값으로 제한한다. lazy-susan처럼 외부 부품을 선택하는 타입도 독립 기준으로 볼 수 있다. 그 기준에 연결된 길이·간격·폭은 별도 mm 값으로 다시 쓰지 않고 비율이나 함수로 계산한다.

```scad
// plates/links.scad
lower_link_length = 200;
upper_link_length_ratio = 1.2;
link_width_ratio = 0.15;

upper_link_length = lower_link_length * upper_link_length_ratio;
link_width = lower_link_length * link_width_ratio;

// config.scad
base_bearing = BB6808;
base_diameter_ratio = 1.6;
base_diameter = bb_diameter(base_bearing) * base_diameter_ratio;
```

### S-8 (NEVER) 로봇 전체 설계를 타입 배열/접근자 레이어로 감싸지 않는다

타입 배열과 `prefix_property(type)` 접근자는 NopSCADlib식 vitamin 데이터처럼 독립 부품의 스키마가 명확할 때 사용한다. 로봇 전체 어셈블리의 임시 설계값을 배열 하나와 수십 개의 접근자 함수로 감싸지 않는다.

### S-9 (MUST) 2D 프로파일, 제작 부품, 조립체 계층을 분리한다

2D 절단 기반 프로젝트는 아래 계층을 분리한다.

```text
plates/        DXF 원천인 2D 프로파일만 정의
fabrications/  2D 프로파일을 두께·적층·간격으로 3D 제작 부품화
assemblies/    제작 부품과 vitamins를 배치해 기능 조립체 구성
```

`plates/`에는 `linear_extrude()`, 색상, 판재 적층, 샌드위치 간격을 넣지 않는다. `assemblies/`는 `plates/`를 직접 배치하지 않고 `fabrications/`와 `vitamins/`만 배치한다.

### S-10 (MUST) 같은 스키마의 2D 프로파일 변형은 타입 배열로 통합한다

같은 기계적 의미와 스키마를 가진 2D 프로파일이 여러 개 필요하면 개별 파일과 개별 모듈을 늘리지 않는다. 단일 프로파일 파일에 타입 배열 스키마, `prefix_property(type)` 접근자, `prefix_2d(type)` 모듈을 두고, 타입 인스턴스는 같은 폴더의 plural 파일에서 정의한다.

```scad
function link_length(type) = type[1];

module link_2d(type) {
    // 피벗 구멍(pivot hole)은 회전 조인트(revolute joint)가 축 기준으로 움직일 조립 여유(clearance)를 만든다.
    // ...
}

// plates/links.scad
//                name          length             width       bolt_diameter       profile_width_ratio
lower_link_type = ["lower_link", lower_link_length, link_width, main_bolt_diameter, 1.0];
upper_link_type = ["upper_link", upper_link_length, link_width, main_bolt_diameter, 1.0];
```

단, 우연히 모양만 같고 설계 변경 방향이나 기계적 의미가 다르면 S-5에 따라 공통화하지 않는다.

---

## 3. 타입 배열과 접근자 함수 [T]

NopSCADlib는 객체처럼 보이는 부품 데이터를 배열로 표현한다. 배열의 0번 요소는 대체로 이름이나 코드이고, 이후 요소는 치수와 속성이다.

```scad
BB608 = ["608", 8, 22, 7, "black", 1.4, 2.0, 0, 0];
```

### T-1 (MUST) 타입 배열은 기존 인덱스 방식으로 정의한다

배열 인덱스는 타입 정의부와 접근자 함수 내부에만 둔다. 호출부에 `type[2]` 같은 직접 접근을 노출하지 않는다.

### T-2 (MUST) 접근자 함수는 `prefix_property(type)` 형식을 따른다

접근자 함수는 짧고 안정적인 접두사를 사용한다. 기존 파일에서 쓰는 접두사가 있으면 바꾸지 않는다.

```scad
function bb_name(type)     = type[0]; //! Part code without shield type suffix
function bb_bore(type)     = type[1]; //! Internal diameter
function bb_diameter(type) = type[2]; //! External diameter
```

파생값도 접근자 함수로 표현한다. 원본 배열에 중복 저장해서 불일치를 만들지 않는다.

```scad
function gridfinity_bin_size_mm(type) =
    gridfinity_bin_size(type) * gridfinity_pitch();
```

### T-3 (SHOULD) 생성자 함수는 필요한 경우에만 둔다

복잡한 printed part처럼 사용자가 타입 배열을 직접 만들 가능성이 높으면 생성자 함수를 둘 수 있다. 생성자 이름은 대상 타입명과 같게 두는 기존 패턴을 우선한다.

```scad
function knob(name = "knob", top_d = 12, bot_d = 15, height = 18, shaft_length, ...) =
[
    name, top_d, bot_d, height, ...
];
```

### T-4 (MUST) 배열 스키마 주석을 유지한다

타입 목록 파일에는 열 의미를 알려주는 정렬 주석을 유지한다. 새 필드를 추가하면 주석, 접근자 함수, 타입 목록, 테스트를 함께 갱신한다.

```scad
//          name     id od   w    color
BB608    = ["608",   8, 22,  7,   "black"];
```

---

## 4. 모듈과 함수 [M]

### M-1 (MUST) 역할을 분리한다 — 모듈은 형상, 함수는 값

- **module**: 지오메트리를 생성한다. 값을 반환하지 않는다.
- **function**: 값을 계산해 반환한다. 형상을 만들지 않는다.

```text
// 함수: 값 계산
function gt2_pitch_diameter(teeth, pitch = 2) = teeth * pitch / PI;

// 모듈: 형상 생성
module gt2_pulley(teeth, bore_diameter, height) {
  assert(teeth > 0, "치아 수(teeth)는 양수여야 합니다");
  // ...
}
```

### M-2 (MUST) 명명 인자와 기본값을 사용한다 — 불리언·위치 인자 나열 금지

호출부에서 각 숫자의 의미가 드러나야 한다.

```text
❌ belt_anchor(12, 3, 5, true, false)
✅ belt_anchor(clamp_width = 12,
               bolt_diameter = 3,
               wall = 5,
               dual_end = true)
```

### M-3 (SHOULD) 반복·배치는 `children()`을 받는 고차 모듈로 분리한다

배치 로직과 형상 정의를 섞지 않는다.

```text
module radial_array(count, radius) {
  for (i = [0 : count - 1])
    rotate([0, 0, i * 360 / count])
      translate([radius, 0, 0])
        children();
}

radial_array(count = 6, radius = 20) bolt_hole(d = 3);
```

### M-4 (SHOULD) 불리언 연산 중첩을 평평하게 유지한다

`difference`/`union`이 3단계 이상 깊어지면 의미 있는 중간 모듈로 분리한다.

---

## 5. 선언적·파라메트릭 설계 [P]

### P-1 (MUST) 명령형 누적 대신 리스트 컴프리헨션으로 표현한다

OpenSCAD에는 가변 상태가 없다. 반복 데이터는 선언적으로 생성한다.

```text
// 섹터 기반 구동 요소의 둘레 좌표
tooth_points = [ for (a = [0 : tooth_angle : 360 - tooth_angle])
                   [cos(a) * pitch_r, sin(a) * pitch_r] ];
```

### P-2 (MUST) 함수 내 지역 바인딩은 `let()`으로 명시한다

```text
function planetary_output_speed(input_rpm, ratio) =
  let (output = input_rpm / ratio)
  output;
```

### P-3 (SHOULD) 2D 스케치 후 압출하는 선언적 패턴을 우선한다

`linear_extrude`, `rotate_extrude`로 단면을 먼저 정의하면 의도가 분명해지고 수정이 쉽다. 3D 프리미티브를 즉흥적으로 깎는 방식보다 우선한다.

### P-4 (MUST) 파생 치수는 저장하지 말고 함수로 계산한다

피치 지름, 중심 거리처럼 다른 값에서 계산되는 치수는 별도 변수로 중복 정의하지 않고 함수로 도출한다. 원본 치수와 파생 치수가 어긋나는 것을 방지한다.

---

## 6. 검증과 해상도 [V]

### V-1 (MUST) 기하학적 전제는 `assert()`로 강제한다

벽 두께가 음수가 되거나 구멍이 외경보다 큰 경우처럼 물리적으로 불가능한 입력을 컴파일 시점에 차단한다.

```text
module bearing_seat(outer_diameter, wall) {
  assert(wall > 0, "벽 두께(wall)는 0보다 커야 합니다");
  assert(outer_diameter > 0, "외경(outer diameter)은 양수여야 합니다");
  // ...
}
```

### V-2 (SHOULD) 디버깅 값은 `echo()`로 노출한다

조립 간섭이나 계산된 중심 거리 같은 핵심 수치를 콘솔로 확인할 수 있게 한다.

```text
echo(belt_center_distance = gt2_center_distance(driver_teeth, driven_teeth));
```

### V-3 (MUST) 해상도를 의도적으로 관리한다

- 전역 기본은 `$fa`/`$fs`로 설정한다.
- 특정 부품에만 높은 해상도가 필요하면 해당 모듈에서 `$fn`을 지역 지정한다.
- 모든 형상에 무분별하게 큰 `$fn`을 박지 않는다. 미리보기·렌더 시간이 폭증한다.

---

## 7. 주석 [C]

### C-1 (MUST) 주석은 "왜"만 설명한다

치수의 출처나 비자명한 제약의 이유를 적는다. 코드가 명백히 보여주는 것은 반복하지 않는다.

```text
❌ // 원기둥을 만듭니다.
✅ // 6810ZZ 외경 65mm + 압입 간섭 0.05mm 기준
   bearing_bore = 65 - press_fit_interference;
```

### C-2 (MUST) 주석과 문서는 한국어로 작성한다. 기계 용어는 한국어(영어) 병기한다

예: `// 숄더 볼트(shoulder bolt)가 고정축 역할을 하므로 베어링 내경에 맞춘다`

### C-3 (MUST) 파일 최상단 주석은 영어 설명 뒤 한국어 요약을 붙인다

파일 최상단 주석은 먼저 영어 문단으로 파일의 역할과 계층을 설명하고, 바로 뒤에 한국어 요약을 붙인다. 영어 설명은 외부 라이브러리·툴과 함께 읽히는 파일 헤더 역할을 하고, 한국어 요약은 프로젝트 내부 의사결정을 빠르게 확인하기 위한 것이다.

```scad
// fabrications/link_stacks.scad - Builds 3D sandwich links from 2D cut profiles.
// The layer spacing represents the physical plate stack used to increase bending stiffness without machining depth.
//
// 2D 절단 프로파일을 판재 적층(plate stack)으로 3D 제작 부품화한다.
// 절삭 깊이 없이 굽힘 강성(bending stiffness)을 높이기 위해 판재 사이 간격을 실제 조립 구조로 표현한다.
```

### C-4 (MUST) 모듈 내부 주석은 한국어로 쓰고, 기계 원리를 설명한다

모듈 내부 주석은 한국어를 사용한다. 기계공학과 관련된 전문 용어는 반드시 `한국어(영어)` 형식으로 병기하고, 단순 명칭만 적지 말고 그 구조가 어떤 원리로 쓰이는지 설명한다.

```scad
// 평행사변형 링크(parallelogram linkage)가 하부 링크와 같은 각도로 회전해 말단판(end plate)의 수평 자세를 유지한다.
translate([0, coupler_offset, 0])
    rotate(lower_angle)
        link_stack(coupler_link_type, sheet_thickness, stack_layers);
```

### C-5 (SHOULD) 리팩터링 주석은 절보다 구(phrase)를 우선한다

기존 주석을 정리할 때는 긴 문장형 절보다 `대상 용어(English term) — 역할/이유` 형태의 짧은 구를 우선한다. 코드 바로 옆에서는 동사형 설명을 반복하지 말고, 기계적 역할과 제약이 빠르게 스캔되도록 쓴다. 내용은 가능한 한 단순화하고, `공칭 지름(nominal diameter, 호칭 치수)`처럼 오해될 수 있는 전문어는 괄호 안에 영어와 짧은 해석을 함께 붙인다.

```scad
// 외륜 숄더(outer-race shoulder) — 내륜 외경(inner-race outside diameter) 바깥에서만 남는 축방향 지지 단차.
circle(d = inner_race_outside_diameter + bearing_clearance);
```

단, 파일 헤더처럼 독립 문맥이 필요한 주석이나 복잡한 설계 의사결정은 C-1에 따라 짧은 문장으로 이유를 설명할 수 있다.

### C-6 (SHOULD) 후속 가공 부위는 `[CNC-LATER]` 태그로 표기한다

FDM 프로토타입 후 절삭 가공할 구조적 임계부를 주석으로 명시해 추후 검색·교체가 쉽도록 한다.

```text
// [CNC-LATER] 고하중 피벗(high-load pivot) 베어링 시트, 프린트 후 보링 가공
```

---

## 8. 외부 라이브러리 [L]

### L-1 (MUST) `use`와 `include`를 구분해 쓴다

- `use <lib.scad>`: 모듈·함수만 가져온다 (최상위 형상 실행 안 함). **기본값**.
- `include <lib.scad>`: 파일 전체를 펼친다. 최상위 형상이 함께 실행되므로 신중히 쓴다.

### L-2 (MUST) 부품을 만들기 전에 NopSCADlib 존재 여부를 먼저 확인한다

기성품, 체결 부품, 모터, 베어링, 풀리처럼 vitamin 성격의 부품은 직접 모델링하거나 치수를 하드코딩하기 전에 `NopSCADlib/vitamins`에 같은 부품이 있는지 확인한다.

- 있으면 NopSCADlib의 타입 배열, 접근자 함수, 모듈을 그대로 사용한다.
- 없으면 프로젝트 `vitamins/`에 NopSCADlib의 단수/복수 파일 패턴으로 로컬 vitamin을 만든다.
- 확인 없이 로컬 모델, 래퍼, 임의 치수 상수를 만들지 않는다.

### L-3 (MUST) 라이브러리 부품 치수는 접근자로 읽는다

NopSCADlib가 제공하는 타입 배열의 치수는 숫자로 복사하지 않는다. 호출부와 제작 파트는 라이브러리 접근자를 통해 값을 읽는다.

```scad
// 금지: NEMA17 값 복사
NEMA17_HOLE = 31;
NEMA17_BORE = 23;

// 권장: NopSCADlib 접근자 사용
hole_pitch = NEMA_hole_pitch(NEMA17_40);
boss_clearance_r = NEMA_big_hole(NEMA17_40);
body_width = NEMA_width(NEMA17_40);
```

로컬 vitamin도 같은 원칙을 따른다. 예를 들어 lazy-susan의 외경과 장착 홀 피치는 `ls_diameter(type)`, `ls_bolt_circle_diameter(type)`처럼 접근자로 읽는다.

### L-4 (MUST) 라이브러리 도입 게이트 — 모두 만족할 때만 도입한다

1. 직접 구현보다 유지 비용이 낮음 (예: BOSL2의 나사산·기어)
2. 유지보수 상태가 안정적
3. 모델 핵심 복잡도를 실제로 줄임
4. 기존 코드·치수 체계와 충돌하지 않음

### L-5 (NEVER) 라이브러리가 이미 제공하는 vitamin을 의미 없이 래핑하지 않는다

NopSCADlib처럼 타입 배열, 접근자 함수, 모듈을 이미 제공하는 부품은 원래 파일과 이름을 그대로 사용한다. 프로젝트 파일은 라이브러리에 없는 부품을 추가하거나, 실제로 다른 인터페이스·의미를 제공할 때만 만든다.

---

## 작업 절차

부품 추가·수정 시 아래 순서를 따른다.

1. 만들 부품을 **한 문장**으로 정의한다 (예: "608ZZ 2개를 지지하는 J2 팔꿈치 베어링 하우징")
2. 해당 부품이나 인접 vitamin이 NopSCADlib에 있는지 먼저 확인한다 (L-2)
3. NopSCADlib에 있으면 원본 타입·모듈·접근자로 인터페이스 치수를 읽는다 (L-3)
4. 인접 부품과의 인터페이스 치수·공차를 먼저 파라미터로 정리한다
5. 파생 치수를 함수로 분리한다
6. 2D 단면 → 압출 가능한지 먼저 검토한다
7. `plates/`에는 2D 프로파일만 두고, 압출·적층은 `fabrications/`로 분리한다 (S-9)
8. 같은 스키마의 반복 2D 프로파일이면 타입 배열과 접근자 함수로 통합한다 (S-10, T-1, T-2)
9. 이름을 확정한 뒤 모듈을 구현한다
10. 반복 형상은 즉시 모듈화하지 말고 S-5 게이트를 검사한다
11. `assert()`로 기하 전제를 건다
12. 더 단순하게 줄일 수 있는지 마지막으로 검토한다

---

## 셀프 리뷰 체크리스트

제출 전 **모든** 항목을 통과해야 한다.

- [ ] 이름만 보고 부품·치수 역할을 이해할 수 있는가? (N-1)
- [ ] 공통 기준값은 `config.scad`, 특정 부품 패밀리 값과 타입 배열은 plural 파일에 있으며 반복 접두사를 쓰지 않는가? (N-4, S-6)
- [ ] 매직 넘버 없이 공차·치수가 명명 파라미터로 분리됐는가? (S-3)
- [ ] vitamin 성격의 부품을 만들기 전에 NopSCADlib 존재 여부를 확인했는가? (L-2)
- [ ] NopSCADlib 제공 부품의 치수를 숫자로 복사하지 않고 접근자로 읽는가? (L-3)
- [ ] 2D 프로파일, 제작 부품, 조립체 계층이 `plates/`, `fabrications/`, `assemblies/`로 분리됐는가? (S-9)
- [ ] 타입 배열을 직접 인덱싱하지 않고 접근자 함수로만 읽는가? (T-1, T-2)
- [ ] 같은 스키마의 반복 2D 프로파일을 개별 파일로 늘리지 않고 타입 배열로 통합했는가? (S-10)
- [ ] 타입 배열의 주석, 접근자 함수, 타입 목록, 테스트가 함께 갱신됐는가? (T-4)
- [ ] 한 모듈이 한 부품, 한 함수가 한 계산만 하는가? (S-2, M-1)
- [ ] 지금 부품에 불필요한 옵션을 미리 만들지 않았는가? (S-4)
- [ ] 형상 추출이 의미를 해치지 않았는가? (S-5)
- [ ] 호출부가 명명 인자로 읽히는가? (M-2)
- [ ] 파생 치수를 중복 저장하지 않고 함수로 도출했는가? (P-4)
- [ ] 물리적으로 불가능한 입력을 `assert()`로 막았는가? (V-1)
- [ ] 해상도(`$fn`/`$fa`/`$fs`)를 의도적으로 관리했는가? (V-3)
- [ ] 파일 최상단 주석이 영어 설명 뒤 한국어 요약 형식인가? (C-3)
- [ ] 모듈 내부 주석이 한국어이며 기계 용어를 한국어(영어)로 병기하고 원리를 설명하는가? (C-4)
- [ ] 불리언 연산 중첩이 평평하게 읽히는가? (M-4)

하나라도 실패하면 해당 규칙 ID 기준으로 수정한 뒤 재검사한다.

---

## 최종 판단 기준

이 문서와 충돌하는 모델보다, 이 문서에 맞춰 **단순하고 명확하게 다시 작성한 파라메트릭 모델**을 우선한다.
