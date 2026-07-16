# godot-m — 다음 과제

> **형식 계약 (훅이 파싱한다)**: 열린 과제는 `## 열린 과제` 아래 `### N. 제목`.
> 코드 repo의 SessionStart 훅이 `###` 제목들만 추출해 세션에 주입한다.
> 새 과제는 `무엇 → 왜 → 완료 기준`으로 추가하고, 종료되면 아래 종료 기록 표로 옮긴 뒤 지운다.

## 열린 과제

### 1. 스토리 JSON 변환 — script_full.md를 story/ JSON 19개 파일로
**무엇** — `docs/script_full.md`(2139줄)의 시나리오를 `story/` JSON으로 변환. 대상 목록은 plan 문서 Phase 2 체크리스트(`docs/01-plan/features/game-full-plan.plan.md` 끝부분): april 허브·이벤트 6종, crack 파트 5종, july 엔딩 분기 등 19개 파일. `opening.json` 실제 노드(Opening~Chapter1_Lunch)는 이미 시작됨.
**왜 ** — 현재 게임은 테스트 노드 중심이라 실제 플레이 불가. 프로젝트의 최대 병목.
**완료 기준** — 각 JSON이 `python3 -m json.tool` 파싱 통과 + 게임 실행으로 해당 장 진입·진행 확인. 에셋(CG/표정) 제작은 이번 범위 아님.

### 2. Supabase 선택지 통계 연동 완성 — URL 주입부터 실동작까지
**무엇** — `scenes/controller/choice_controller.gd:9`의 `_supabase_url`이 빈 문자열이라 통계 기능 전체가 조용히 비활성 상태. URL/키 주입 방식 결정(설정 파일? 환경별 분리?) 후 `/api/stats`, `/api/vote` 실동작 확인.
**왜 ** — 코드는 있는데 연결이 안 된 상태로, 죽은 코드인지 기능인지 애매하게 방치되는 중.
**완료 기준** — 게임에서 선택지 선택 → 에디터 로그에서 HTTP 200 응답 확인, 재진입 시 통계 미리보기 표시. 오프라인 시 3초 타임아웃 후 정상 진행.

### 3. opening.json의 Test_* 노드 분리
**무엇** — `story/april/opening.json` 31노드 중 24개가 Test_* 테스트 노드. 남길 실 시나리오는 7개(`Start`, `Opening`, `Prologue_Gaze`, `Prologue_Observation`, `Prologue_Awareness`, `Chapter1_Approach`, `Chapter1_Lunch`). Test_* 24개를 별도 파일(예: `story/test/`)로 분리하거나 삭제하고, Start가 실제 Opening으로 이어지게 정리.
**왜 ** — 실제 시나리오와 테스트가 한 파일에 섞여 있어 과제 1 진행 시 사고 위험.
**완료 기준** — opening.json에 실제 시나리오 노드만 남고, 게임 시작 시 프롤로그로 직행. 테스트 노드는 별도 진입 경로로 보존 여부 결정 후 처리.

### 4. 조건 분기(conditional) 동작 검증
**무엇** — Test_Cond_* 노드들(And/Or/Pass/Fail)로 distance 조건 분기가 설계대로 동작하는지 godot-mcp로 실행 검증.
**왜 ** — 균열 파트·엔딩 분기가 전부 조건 분기에 의존하는데 아직 미검증 (plan Phase 3 항목).
**완료 기준** — 각 조건 케이스에서 `godot_runtime_state`로 도달 노드 확인, 결과를 log에 기록.

## 종료 기록

| # | 과제 | 결과 | 정본·근거 |
|---|---|---|---|
