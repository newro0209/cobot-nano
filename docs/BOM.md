# BOM

이 문서는 현재 `assemblies/arm_carriage_assembly.scad` 기준의 수동 BOM입니다.
수치는 CAD 변수에서 파생되며(`eps`·공차 포함), 실제 구매 전에는 OpenSCAD 콘솔 출력이나 실측 조립으로 최종 확인합니다.

## Arm Carriage Assembly

| 분류 | 품목 | 사양 / CAD 기준 | 수량 | 비고 |
|------|------|------------------|------|------|
| 제작품 | Arm carriage top plate | `parts/arm_carriage_top_plate.scad`, 두께 9mm | 1 | 상부 플레이트 |
| 제작품 | Arm carriage bottom plate | `parts/arm_carriage_bottom_plate.scad`, 두께 9mm | 1 | 하부 플레이트 |
| 모터 | Stepper motor | `NEMA17_47` | 1 | J2 구동 모터 |
| 풀리 | Motor pulley | `GT2x20um_pulley` | 1 | 6mm GT2 벨트 |
| 풀리 | Driven pulley | `GT2x60x8_pulley` (60T, 8mm bore) | 1 | 6mm GT2 벨트 |
| 벨트 | Timing belt | `GT2x6` | 1 | 2풀리 경로, 모터 슬롯 기준 322..340mm 표준 후보 |
| 베어링 | Ball bearing | `BB608` (8×22×7) | 2 | J2 종동축 상하 지지 |
| 베어링 | Linear bearing | `LM8UU` | 3 | J1 가이드 로드 3점 지지 |
| 리드넛 | Leadnut | `LSN8x2` | 1 | 상판 아랫면 시트 |
| 스탠드오프 | Female-female hex pillar | `M3x25_ff_hex_pillar` (길이 25mm) | 5 | 8점 볼트 서클 중 모터 슬롯 쪽 `[5,6,7]` 제외 |
| 스크류 | Standoff screw set | M3 cap + washer/star washer | 8 | 상하 4개씩 |
| 스크류 | Motor screw set | M3 cap + washer/star washer | 4 | NEMA17 Y축 슬롯 체결 |
| 스크류 | Leadnut screw set | M3 cap + washer/star washer + nut, 길이 **12mm** | 4 | 리드넛 2개 기준 |
| 스크류 | Driven axis shoulder bolt | `M6_shoulder_screw` (8mm shoulder), 길이 **50mm** | 1 | J2 종동축 고정축 |
| 너트 | Driven axis locknut | M6 nyloc nut | 1 | 하우징 하부 체결 |
| 와셔 | Driven axis washer | M8 washer | 4 | 숄더 볼트 스택 |
| 부싱 | Driven axis bushing (printed) | ID 8.5 / OD 12mm, 높이 하 **3.64mm** (상 0.17mm는 와셔로 흡수, 생략) | 1 | 풀리와 베어링 내륜 사이, 3D 프린트 |

## 주요 치수 (CAD 파생, mm)

| 항목 | 값 | 출처 변수 |
|------|----|-----------|
| 판 두께 (각 1장) | 9 | `ac_thickness` = `bb_width(BB608)` + `seat_shoulder_thickness` |
| 두 판 사이 간격 | 25 | `ac_plate_gap` = `pillar_height(standoff_pillar_type)` |
| J1 중심축↔J2 어깨축 거리 | 80 | `shoulder_mount_link_length` |
| J2 모터 슬롯 이동 | 10 | `ac_j2_motor_slot_travel` |
| J2 벨트 정확 길이 | 321.651 / 331.596 / 341.547 | `ac_timing_belt_length_min/current/max` |
| J2 GT2 표준 후보 | 322..340, nominal 332 | `ac_timing_belt_standard_min/max/mid` |

> 스크류 길이는 NopSCADlib `screw_longer_than/shorter_than`로 표준 규격(off-the-shelf)에 스냅합니다. 벨트 길이는 `assemblies/arm_carriage_assembly.scad`의 `belt_length()` echo 기준이며, 구매 전 실제 슬롯 위치와 장력 여유를 다시 확인하세요.

## Notes

- 벨트 장력은 아이들러가 아니라 `ac_j2_motor_slot_travel` 범위에서 모터 전체를 Y축으로 이동해 조절합니다.
- 상판 모터 시트는 바디 리세스, 센터링 보스 리세스, 샤프트 보어, M3 체결 홀을 각각 슬롯화합니다.
- `GT2x60x8_pulley`는 `vitamins/pulleys.scad`, `M6_shoulder_screw`는 `vitamins/screws.scad`에 정의된 로컬 vitamin 타입입니다(NopSCADlib 패밀리를 미러링).
