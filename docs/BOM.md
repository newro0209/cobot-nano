# BOM

이 문서는 현재 `assemblies/arm_carriage_assembly.scad` 기준의 수동 BOM입니다.
스크류 길이와 스페이서 높이는 CAD 변수에서 파생되므로, 실제 구매 전에는 OpenSCAD 콘솔 출력이나 실측 조립으로 최종 확인합니다.

## Arm Carriage Assembly

| 분류 | 품목 | 사양 / CAD 기준 | 수량 | 비고 |
|------|------|------------------|------|------|
| 제작품 | Arm carriage plate | `parts/arm_carriage_plate.scad` | 1 | 상부 플레이트 |
| 제작품 | Arm carriage housing | `parts/arm_carriage_housing.scad` | 1 | 하부 플레이트 |
| 모터 | Stepper motor | `NEMA17_40` | 1 | J2 구동 모터 |
| 풀리 | Motor pulley | `GT2x20um_pulley` | 1 | 6mm GT2 벨트 |
| 풀리 | Driven pulley | `GT2x60x8_pulley` | 1 | 60T, 8mm bore, 6mm GT2 벨트 |
| 풀리 | Idler pulley | `GT2x20_toothed_idler` | 2 | 대칭 조절 슬롯 장착 |
| 벨트 | Timing belt | `GT2x6` | 1 | 길이는 `belt()` 경로에서 산출 |
| 베어링 | Ball bearing | `BB608` | 2 | J2 종동축 상하 지지 |
| 베어링 | Linear bearing | `LM8UU` | 2 | J1 가이드 로드 좌우 |
| 리드넛 | Leadnut | `LSN8x2` | 2 | 플레이트 1개, 하우징 1개 |
| 스탠드오프 | Female-female hex pillar | `M3x20_ff_hex_pillar` | 4 | 두 판 사이 간격 유지 |
| 스크류 | Standoff screw set | M3 cap screw + washer/star washer | 8 | 상하 4개씩 |
| 스크류 | Motor screw set | M3 cap screw + washer/star washer | 4 | NEMA17 체결 |
| 스크류 | Leadnut screw set | M3 cap screw + washer/star washer + nut | 4 | 리드넛 2개 기준 |
| 스크류 | Idler screw | M4 cap screw | 2 | 슬롯 조절 축 |
| 너트 | Idler locknut | M4 nyloc nut | 2 | 아이들러 위치 고정 |
| 와셔 | Idler washer | M4 washer | 8 | 아이들러 상하 스택 |
| 스페이서 | Idler spacer | M4 clearance ID, CAD-derived height | 4 | 아이들러 상하 각 1개 |
| 스크류 | Driven axis shoulder bolt | `M6_shoulder_screw` | 1 | 8mm shoulder, J2 종동축 |
| 너트 | Driven axis locknut | M6 nyloc nut | 1 | 하우징 하부 체결 |
| 와셔 | Driven axis washer | M8 washer | 4 | 숄더 볼트 스택 |
| 스페이서 | Driven axis spacer | 8mm clearance ID, CAD-derived height | 2 | 풀리와 베어링 내륜 사이 |

## Notes

- 아이들러 위치는 `ac_j2_idler_center_x`로 조절하고, 슬롯 이동 범위는 `ac_j2_idler_slot_travel`로 관리합니다.
- 스탠드오프는 `ac_j2_belt_xy_keepout` 밖에 있어야 하며, 이 조건은 `arm_carriage_plate_base.scad`의 assert로 검증합니다.
- `GT2x60x8_pulley`와 `M6_shoulder_screw`는 `config.scad`에 정의된 로컬 vitamin 타입입니다.
