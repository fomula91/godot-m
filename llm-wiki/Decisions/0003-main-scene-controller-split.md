---
source: "커밋 4864af3 (choice_controller 분리), docs/main_scene_analysis.md, scenes/controller/ (2026-07-16 코드 확인)"
verified: 2026-07-16
---

# 0003 — main_scene 로직을 도메인별 컨트롤러로 분리

## 상태
채택 (진행 중 — main_scene.gd 330줄까지 축소됨)

## 맥락
main_scene.gd가 배경 전환·캐릭터 연출·대사 표시·선택지 처리·오버레이 관리를 전부 떠안아 비대해졌고(분리 전 분석은 `docs/main_scene_analysis.md`), 수정 시 무관한 기능이 깨지는 일이 잦았다.

## 결정
`scenes/controller/` 아래 도메인별 컨트롤러 노드로 분리한다: background / character / dialogue / choice / overlay. 각 컨트롤러는 StoryManager 시그널을 직접 구독하고, main_scene.gd는 컨트롤러 간 조율(QuickMenu 표시 여부 등)만 담당한다.

## 근거
- 시그널 기반이라 컨트롤러 간 직접 참조가 최소화되고, 개별 수정의 영향 범위가 파일 하나로 좁혀짐.
- Supabase 통계처럼 한 도메인에만 속하는 부속 기능(HTTPRequest 관리)이 choice_controller 안에 캡슐화됨.
- 대안(autoload로 승격)은 씬 트리의 UI 노드에 강하게 결합된 로직이라 부적합해 기각.

## 결과·트레이드오프
- 얻는 것: main_scene.gd 330줄 유지, 도메인별 독립 수정.
- 감수하는 것: 흐름이 시그널로 흩어져 한눈에 따라가기 어려움. 컨트롤러가 `$"../DialogueLayer"` 식 상대 경로로 이웃을 참조하는 부분은 씬 구조 변경에 취약.

## 재검토 트리거
컨트롤러 간 상호 호출이 늘어 순환 의존이 생기면 이벤트 버스 또는 명시적 조율 레이어 도입을 검토한다.
