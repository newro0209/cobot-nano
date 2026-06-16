# BOM

이 문서는 현재 `assemblies/arm_carriage_assembly.scad` 기준의 수동 BOM입니다.
수치는 CAD 변수에서 파생되며(`eps`·공차 포함), 실제 구매 전에는 OpenSCAD 콘솔 출력이나 실측 조립으로 최종 확인합니다.

## Arm Carriage Assembly

| 분류 | 품목 | 사양 / CAD 기준 | 수량 | 비고 |
|------|------|------------------|------|------|
| 제작품 | Arm carriage plate | `parts/arm_carriage_plate.scad`, 두께 9mm | 1 | 상부 플레이트 |
| 제작품 | Arm carriage housing | `parts/arm_carriage_housing.scad`, 두께 9mm | 1 | 하부 플레이트 |
| 모터 | Stepper motor | `NEMA17_40` | 1 | J2 구동 모터 |
| 풀리 | Motor pulley | `GT2x20um_pulley` | 1 | 6mm GT2 벨트 |
| 풀리 | Driven pulley | `GT2x60x8_pulley` (60T, 8mm bore) | 1 | 6mm GT2 벨트 |
| 풀리 | Idler pulley | `GT2x20_toothed_idler` | 2 | 대칭 조절 슬롯 장착 |
| 벨트 | Timing belt | `GT2x6` | 1 | 길이는 `belt()` 경로에서 산출 |
| 베어링 | Ball bearing | `BB608` (8×22×7) | 2 | J2 종동축 상하 지지 |
| 베어링 | Linear bearing | `LM8UU` | 2 | J1 가이드 로드 좌우 |
| 리드넛 | Leadnut | `LSN8x2` | 2 | 플레이트 1개, 하우징 1개 |
| 스탠드오프 | Female-female hex pillar | `M3x20_ff_hex_pillar` (길이 20mm) | 4 | 두 판 사이 간격 유지 |
| 스크류 | Standoff screw set | M3 cap + washer/star washer, 길이 **17mm** | 8 | 상하 4개씩 |
| 스크류 | Motor screw set | M3 cap + washer/star washer | 4 | NEMA17 체결(NopSCADlib 기본 길이) |
| 스크류 | Leadnut screw set | M3 cap + washer/star washer + nut, 길이 **11.9mm** | 4 | 리드넛 2개 기준 |
| 스크류 | Idler screw | M4 cap, 길이 **43.8mm** | 2 | 슬롯 조절 축 |
| 너트 | Idler locknut | M4 nyloc nut | 2 | 아이들러 위치 고정 |
| 와셔 | Idler washer | M4 washer | 8 | 아이들러 상하 스택 |
| 스페이서 | Idler spacer | ID 4.4 / OD 9mm, 높이 상 **7.22** · 하 **2.68mm** | 4 | 아이들러 상하 각 1개 |
| 스크류 | Driven axis shoulder bolt | `M6_shoulder_screw` (8mm shoulder), 길이 **47.6mm** | 1 | J2 종동축 고정축 |
| 너트 | Driven axis locknut | M6 nyloc nut | 1 | 하우징 하부 체결 |
| 와셔 | Driven axis washer | M8 washer | 4 | 숄더 볼트 스택 |
| 스페이서 | Driven axis spacer | ID 8.5 / OD 12mm, 높이 상 **0.17** · 하 **3.64mm** | 2 | 풀리와 베어링 내륜 사이 |

## 주요 치수 (CAD 파생, mm)

| 항목 | 값 | 출처 변수 |
|------|----|-----------|
| 판 두께 (각 1장) | 9 | `ac_plate_thickness` = `bb_width(BB608)` + `seat_shoulder_thickness` |
| 두 판 사이 간격 | 20 | `ac_standoff_gap` = `pillar_height(M3x20_ff_hex_pillar)` |
| 캐리지 외곽 디스크 지름 | 133.6 | `ac_outer_radius`*2 + `component_margin` |
| J2 링크 길이 (모터축↔종동축) | 100 | `ac_j2_linear_link_length` |
| 아이들러 중심 / 슬롯 이동 | x=50, y=±13 / 24 | `ac_j2_idler_center_x/y`, `ac_j2_idler_slot_travel` |

> 스페이서 높이(0.17 / 3.64 / 7.22 / 2.68)는 `eps` 항을 포함한 CAD 파생값이라 소수점 둘째 자리에서 반올림했습니다. 구매·가공 전 콘솔 echo로 재확인하세요.

## Notes

- 아이들러 위치는 `ac_j2_idler_center_x`로 조절하고, 슬롯 이동 범위는 `ac_j2_idler_slot_travel`로 관리합니다.
- 스탠드오프는 `ac_j2_belt_xy_keepout` 밖에 있어야 하며, 이 조건은 `arm_carriage_plate_base.scad`의 assert로 검증합니다.
- `GT2x60x8_pulley`는 `vitamins/pulleys.scad`, `M6_shoulder_screw`는 `vitamins/screws.scad`에 정의된 로컬 vitamin 타입입니다(NopSCADlib 패밀리를 미러링).
