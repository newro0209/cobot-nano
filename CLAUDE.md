# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

4절 링크 팔레타이징 로봇 암. 제작 부품은 **2D 절단 시트**(합판/아크릴)만 — 3D 프린팅 없음. 기성품 최대화.

설계 특성:
- 평행사변형 링크 → 엔드이펙터 수평 유지
- 샌드위치 플레이트 → 두께가 필요하면 동일 플레이트를 적층, 가공 깊이 없음

## 기구 체인 메모

→ [docs/kinematic_chain.md](docs/kinematic_chain.md)

조립체·부품 명명은 해당 문서의 운동 체인을 기준으로 맞춘다.

## 파일 구조

```
config.scad        공통 사양값, 공차, 렌더 해상도
vitamins/
  *s.scad          NopSCADlib에 없는 로컬 vitamin 타입 배열 목록
  *.scad           NopSCADlib에 없는 로컬 vitamin 모듈과 접근자 함수
plates/            2D 절단 프로파일 — DXF 원천, links.scad는 링크 패밀리 치수/타입 목록
fabrications/      절단 프로파일을 두께·적층·간격으로 3D 제작 부품화
assemblies/        서브 어셈블리
main.scad          전체 로봇 + 애니메이션 훅
export/            DXF 네스팅 (sheet_6mm.scad)
```

## 워크플로우

```bash
# config.scad와 plates/links.scad에서 독립 치수와 비율 수정 후 미리보기
# OpenSCAD에서 main.scad 열기 → View > Animate 로 포즈 스윕 확인

# DXF 절단 파일 생성
bash export/make_dxf.sh    # → sheet_6mm.dxf
```

## 의존성

NopSCADlib 설치 필요:
```bash
git clone https://github.com/nophead/NopSCADlib.git \
  "$HOME/Documents/OpenSCAD/libraries/NopSCADlib"
```

**이 머신 실제 설치 경로:** `C:\Program Files\OpenSCAD\libraries\NopSCADlib`

## 핵심 설계 규약

### plates/ 파트 규약 (MUST)

`plates/*.scad`는 `name_2d()` 프로파일만 정의한다. 두께, 색상, 적층, 간격 배치는 넣지 않는다.

### fabrications/ 제작 부품 규약 (MUST)

`fabrications/*.scad`는 `plates/*_2d()`를 `linear_extrude()`하고, 필요하면 판재 적층이나 샌드위치 간격을 적용한다. 새 2D 형상은 만들지 않고, `plates/`의 프로파일을 사용한다.

### 설계값 배치 규약

로봇 전체 설계를 타입 배열/접근자 함수로 만들지 않는다. `config.scad`에는 판재 두께, 볼트 지름, 베이스 vitamin, 기본 포즈처럼 공통 또는 링크 밖의 기준값을 둔다. 링크 길이, 링크 폭, 링크 타입 배열, 커플러 오프셋은 `plates/links.scad`에 둔다. 단일 로봇 프로젝트이므로 `design_`, `spec_`, `cobot_` 같은 반복 접두사를 붙이지 않는다. 조립체는 `plates/`를 직접 사용하지 않고 `fabrications/`와 `vitamins/`를 배치한다.

예: `plates/links.scad`에서 `lower_link_length`는 독립 치수이고, `upper_link_length`는 `lower_link_length * upper_link_length_ratio`로 계산한다.

### vitamins/ 규약

프로젝트 `vitamins/`에는 NopSCADlib에 없는 로컬 vitamin만 둔다. NopSCADlib이 이미 제공하는 vitamin은 프로젝트 파일로 래핑하지 않는다.

- `name.scad` — 단일 vitamin의 접근자 함수와 모듈을 정의한다.
- `names.scad` — 타입 배열 목록을 정의하고 `use <name.scad>`로 단수 파일을 가져온다.

NopSCADlib 제공 부품은 `NopSCADlib/vitamins/*.scad`를 직접 include/use하고, 원래 모듈·타입 이름을 그대로 사용한다. 예: `NEMA(NEMA17_40)`.

### config.scad

공차, 렌더 해상도, 판재 두께, 체결 부품 선택, 베이스 vitamin, 기본 포즈를 관리한다. 특정 부품 패밀리의 치수와 타입 배열은 해당 plural 파일에서 관리한다.

## OpenSCAD 코딩 컨벤션

OpenSCAD 파일을 작성, 수정, 리뷰할 때는 루트의 `OPENSCAD_CONVENTIONS.md`를 기준으로 삼는다.
세부 네이밍, 타입 배열, 모듈·함수 분리, 검증, 해상도, 주석, 작업 절차, 셀프 리뷰 체크리스트는 이 파일에 반복하지 않는다.
