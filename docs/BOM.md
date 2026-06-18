# BOM

이 문서는 현재 `config.scad`와 `assemblies/arm_carriage_assembly.scad` 기준의 수동 BOM입니다.
수량이 실제 assembly에 배치된 항목과 config에만 선언된 상위 J1 인터페이스 항목을 분리합니다.
구매 전에는 OpenSCAD echo와 공급사 도면을 다시 확인합니다.

## Arm Carriage Assembly

`assemblies/arm_carriage_assembly.scad`에 실제 배치되는 캐리지 스택 기준입니다.

| 분류 | 품목 | CAD 타입 / 사양 | 수량 | 비고 |
|------|------|------------------|------|------|
| 제작품 | Arm carriage top plate | `parts/arm_carriage_top_plate.scad`, t=9mm | 1 | 상판, J1 리드너트와 J2 모터 슬롯 포함 |
| 제작품 | Arm carriage bottom plate | `parts/arm_carriage_bottom_plate.scad`, t=9mm | 1 | 하판, J2 종동축 하부 베어링 시트 포함 |
| 모터 | J2 stepper motor | `NEMA17_47` | 1 | 어깨 회전 구동 모터 |
| 풀리 | J2 drive pulley | `GT2x20um_pulley`, GT2 20T | 1 | NEMA17 모터축 구동 풀리 |
| 풀리 | J2 driven pulley | `GT2x60x8_pulley`, GT2 60T, 8mm bore | 1 | 3:1 감속 출력 풀리, 로컬 vitamin |
| 벨트 | J2 closed-loop timing belt | `GT2x6` | 1 | 표준 후보 298..312mm, 권장 306mm |
| 베어링 | J2 ball bearing | `BB608` (8x22x7) | 2 | J2 종동축 상/하 지지 |
| 베어링 | J1 linear bearing | `LM8UU` | 3 | 3개 가이드 로드용 캐리지 베어링 |
| 리드너트 | J1 leadnut | `LSN8x2` | 1 | 상판 아랫면 시트에 장착 |
| 스탠드오프 | Female-female hex pillar | `M3x25_ff_hex_pillar`, M3 x 25mm | 4 | 활성 인덱스 `[0, 1, 3, 4]`; 모터 슬롯 쪽 `[2, 5, 6, 7]` 제외 |
| 체결류 | Standoff screws | `M3_cap_screw`, L=16mm + washer | 8 | 필러 4개 x 상/하 2개 |
| 체결류 | Leadnut flange screws | `leadnut_screw(LSN8x2)`, L=16mm + washer + nut | 4 | 리드너트 플랜지 체결 |
| 체결류 | J2 shoulder screw | `M6_shoulder_screw`, shoulder dia 8mm, CAD shoulder length 70.6mm + `M8_washer` (머리 밑) | 1 | BB608 보어와 상/하 FC 허브를 관통하는 J2 고정 피벗 |
| 체결류 | J2 shoulder locknut | `M6_nut` (nyloc) + `M6_washer` | 1 set | 하단 FC 아래에서 스택 축방향 고정 |
| 커플링 | J2 driven flange coupling | `FC8`, 8mm bore, 4×M4 볼트원 | 2 | 어깨축 상/하단 링크 마운트, 숄더 봉을 grub screw로 죔, 로컬 vitamin |

## Configured J1 Interface

다음 항목은 `config.scad`에 J1 축 인터페이스로 선언되어 있지만, 현재 `arm_carriage_assembly.scad`에는 직접 배치되지 않습니다.
컬럼/엔드플레이트 assembly가 추가될 때 별도 수량 확정이 필요합니다.

| 분류 | 품목 | CAD 타입 / 사양 | 기준 수량 | 비고 |
|------|------|------------------|-----------|------|
| 모터 | J1 stepper motor | `NEMA17_34` | 1 | Z 병진축 구동 모터 |
| 커플링 | J1 shaft coupling | `SC_5x8_rigid` | 1 | 모터 5mm 축과 T8 리드스크류 8mm 축 직결 |
| 리드스크류 | J1 lead screw | T8x2, 8mm shaft | 1 | 길이는 아직 BOM에서 확정하지 않음 |
| 베어링 블록 | J1 flange bearing block | `KFL08`, 8mm bore | 1 | 로컬 vitamin, 리드스크류 회전 지지 |
| 가이드 로드 | J1 guide rod | 8mm shaft | 3 | `LM8UU`와 `FC8` bore 기준 |
| 플랜지 커플링 | Guide rod flange coupling | `FC8`, 8mm bore | 각 로드 끝단 수량 확정 필요 | 가이드 로드 단판 고정용 로컬 vitamin |

## 주요 CAD 파생 치수

| 항목 | 값 | 출처 |
|------|----|------|
| 캐리지 판 두께 | 9mm | `ac_thickness = bb_width(BB608) + seat_shoulder_thickness` |
| 상/하판 사이 간격 | 25mm | `ac_plate_gap = pillar_height(standoff_pillar_type)` |
| J1 중심축 - J2 어깨축 거리 | 70mm | `shoulder_mount_link_length` |
| J2 모터 슬롯 이동량 | 8mm | `ac_j2_motor_slot_travel` |
| J2 풀리 중심거리 min/current/max | 108.15 / 112.15 / 116.15mm | `ac_j2_belt_distance_*` echo (current=모터 슬롯 위치) |
| J2 벨트 정확 길이 min/current/max | 297.801 / 305.747 / 313.697mm | `ac_timing_belt_length_*` echo |
| J2 GT2 표준 폐루프 벨트 후보 | 298..312mm, nominal 306mm | `ac_timing_belt_standard_*` echo |
| 스탠드오프 체결 스크류 길이 | 16mm | `ac_standoff_screw_length` |
| 리드너트 체결 스크류 길이 | 16mm | `screw_length(leadnut_screw(j1_leadnut_type), ac_thickness, 2, nut = true)` |
| J2 숄더 길이 계산값 | 70.6mm | `ac_j2_shoulder_length` (판 스택 + 2×`fc_height(FC8)` + 머리 와셔) |

## Local Vitamins

| 파일 | 타입 | 역할 |
|------|------|------|
| `vitamins/pulleys.scad` | `GT2x60x8_pulley` | J2 60T, 8mm bore 종동 풀리 |
| `vitamins/screws.scad` | `M6_shoulder_screw` | J2 BB608 보어용 8mm shoulder screw |
| `vitamins/pillars.scad` | `M3x25_ff_hex_pillar` | 상/하판 연결용 양끝 암나사 M3 필러 |
| `vitamins/flange_bearing_blocks.scad` | `KFL08` | J1 리드스크류용 8mm 플랜지 베어링 블록 |
| `vitamins/flange_couplings.scad` | `FC8` | J1 가이드 로드 단부 고정용 8mm 플랜지 커플링 |

## Notes

- J2 벨트 장력은 아이들러가 아니라 `ac_j2_motor_slot_travel` 범위에서 모터 전체를 -Y 방향으로 이동해 조절합니다.
- `GT2x60x8_pulley`, `M6_shoulder_screw`, `M3x25_ff_hex_pillar`, `KFL08`, `FC8`은 프로젝트 로컬 vitamin입니다.
- `M6_shoulder_screw`의 70.6mm는 CAD 계산 shoulder 길이입니다. 실제 구매 규격은 가장 가까운 표준 ISO 7379 shoulder length를 선택해야 합니다.
- J1 리드스크류 길이, 가이드 로드 길이, FC8 수량은 아직 현재 캐리지 assembly만으로 확정하지 않습니다.
