# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

SCARA 로봇 암. **3D 프린팅(FDM)** 제작, 기성품(NopSCADlib vitamin) 최대화.

설계 특성:
- SCARA 운동 체인: Z축 병진(J1) + 어깨·팔꿈치 수평 회전(J2·J3) + 툴 롤(J4). 상세는 [docs/kinematic_chain.md](docs/kinematic_chain.md).
- 3D 프린팅이라 리세스·카운터보어·압입 시트(press-fit seat)를 자유롭게 쓴다. 고하중 임계부는 프린트 후 절삭(`[CNC-LATER]`) 전제.

## 기구 체인 메모

→ [docs/kinematic_chain.md](docs/kinematic_chain.md)

조립체·부품 명명은 해당 문서의 운동 체인을 기준으로 맞춘다.

## 컨벤션 우선순위

구조·스타일은 **(1) NopSCADlib 실제 구조 → (2) `OPENSCAD_CONVENTIONS.md`** 순으로 따른다. 충돌하면 NopSCADlib가 이긴다. 옛 `plates/`·`fabrications/` 분리나 vitamins "단수=모듈/복수=타입목록" 분리는 적용하지 않는다(NopSCADlib는 그런 분리를 쓰지 않는다).

## 파일 구조

```
config.scad        공통 사양값, 공차, 렌더 해상도; NopSCADlib·로컬 vitamin include
vitamins/          NopSCADlib에 없는 로컬 vitamin — 패밀리당 한 파일로 NopSCADlib 패밀리 미러링
  screws.scad        로컬 M6_shoulder_screw (NopSCADlib screw 패밀리에 추가)
  pulleys.scad       로컬 GT2x60x8_pulley (NopSCADlib pulley 패밀리에 추가)
parts/             제작 부품 (NopSCADlib printed/ 대응) — 2D 프로파일 + 압출/포켓을 한 모듈에
  bearing_seat.scad             베어링 시트 포켓(음형)·내륜 보스(양형)
  arm_carriage_plate_base.scad  공유 치수 + 기본 판 블랭크(외곽 + 관통 절단)
  arm_carriage_plate.scad       상판 (모터 리세스·시트·홀)
  arm_carriage_housing.scad     하판
assemblies/        서브 어셈블리 — parts + vitamins 배치, exploded view
docs/              kinematic_chain, BOM
main.scad          전체 로봇 (미완성 스캐폴딩 — base/arm/gripper 미구현)
export/            절단 파일 생성 (아직 미연결)
```

## 워크플로우

```bash
# config.scad / parts/arm_carriage_plate_base.scad 의 독립 치수·비율 수정 후
# OpenSCAD에서 assemblies/arm_carriage_assembly.scad 열어 미리보기 (ac_exploded 슬라이더로 분해)

# 헤드리스 컴파일 검증 (경고 0 확인; NopSCADlib 내부 2p54 deprecation은 무시)
"/c/Program Files/OpenSCAD/openscad.exe" -o /tmp/out.echo assemblies/arm_carriage_assembly.scad
```

## 의존성

NopSCADlib 설치 필요:
```bash
git clone https://github.com/nophead/NopSCADlib.git \
  "$HOME/Documents/OpenSCAD/libraries/NopSCADlib"
```

**이 머신 실제 설치 경로:** `C:\Program Files\OpenSCAD\libraries\NopSCADlib`

## 핵심 구조 규약

### parts/ 제작 부품 규약 (MUST)

`parts/*.scad`는 제작 부품(2D 프로파일 + 압출/포켓)을 NopSCADlib `printed/` 스타일로 정의한다. 치수는 NopSCADlib 접근자(`bb_*`, `NEMA_*`, `leadnut_*` 등)로 읽고 하드코딩하지 않는다. 별도 `plates/`·`fabrications/` 계층은 두지 않는다.

### vitamins/ 규약 (MUST)

프로젝트 `vitamins/`에는 NopSCADlib에 없는 로컬 vitamin만 둔다. NopSCADlib이 제공하는 vitamin은 래핑하지 않고 직접 include/use한다(예: `NEMA(NEMA17_40)`).

로컬 타입은 **NopSCADlib 패밀리-당-한-파일을 미러링**한다: `vitamins/pulleys.scad`가 `include <NopSCADlib/vitamins/pulleys.scad>` 후 같은 스키마로 타입을 추가한다(경로가 달라 가림 충돌 없음). 새 접근자가 필요 없으면 NopSCADlib 접근자(`pulley_*`, `screw_*`)를 그대로 쓴다.

### 설계값 배치 규약

로봇 전체 설계를 타입 배열/접근자 레이어로 감싸지 않는다. `config.scad`에는 공차, 렌더 해상도, 체결 부품 선택처럼 여러 계층이 공유하는 기준값을 둔다. 특정 서브시스템의 치수·좌표는 해당 part 파일에서 짧은 패밀리 접두사로 둔다(예: `arm_carriage_plate_base.scad`의 `ac_*`). NopSCADlib 전역(`eps`, `hs_cap`, `silver` 등)은 중복 정의하지 않고 그대로 쓴다. 단일 로봇 프로젝트이므로 `design_`, `spec_`, `cobot_` 같은 반복 접두사는 붙이지 않는다.

### config.scad

공차, 렌더 해상도, 체결 부품 선택을 관리하고 NopSCADlib·로컬 vitamin 파일을 include한다. 특정 부품 패밀리의 치수·타입은 해당 파일에서 관리한다.

## OpenSCAD 코딩 컨벤션

OpenSCAD 파일을 작성, 수정, 리뷰할 때는 루트의 `OPENSCAD_CONVENTIONS.md`를 #2 기준으로 삼는다(#1은 NopSCADlib 실제 구조).
세부 네이밍, 타입 배열, 모듈·함수 분리, 검증, 해상도, 주석, 작업 절차, 셀프 리뷰 체크리스트는 이 파일에 반복하지 않는다.
