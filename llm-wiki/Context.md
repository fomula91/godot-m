# godot-m — Context

Claude Code가 우선 읽는 구현 컨텍스트. "지금 무엇을 만드는가"를 한 장으로 유지한다.
낡으면 고친다 — 이 문서는 이력이 아니라 현재 상태다 (이력은 [[log]]).

## 무엇을 만드는가
- **"너를 이해하기엔, 봄이 너무 짧았다"** — 학원 로맨스 비주얼 노벨 (Godot 4.6, GL Compatibility 렌더러). 플레이어 강현우가 혼자 지내는 이수아에게 다가가는 이야기 (4월~7월, 엔딩 A/B/C + 게임오버).
- 핵심 메커니즘은 **거리감(distance)** 변수(0=가까움~100=멂, 초기 50) — 선택지가 이 값을 움직이고 조건 분기·엔딩을 결정한다.
- **스토리 진행 구조**(정본: plan §3): 프롤로그(첫 만남) → **4월 허브**(학교 일상 이벤트 6종 중 선택, 거리감 조정) → **5월 균열 도입**(수아의 회피 시작, 선형) → **5~6월 균열 파트**(방과후·점심·체육대회·기말고사·생일 — 각 이벤트에서 "정답" 선택지를 골라야 하고 실패 시 **게임오버**) → **여름방학 엔딩**(거리감 수치로 A/B/C 분기 + 게임오버). "허브"=여러 이벤트를 자유 순서로 고르는 선택 화면, "균열 파트"=관계가 틀어지는 중반 위기 구간을 가리키는 이 프로젝트 용어.
- 스토리는 JSON 노드 그래프(`story/<월>/<장>.json`)로 구동되고([[Decisions/0001-story-json-node-graph]]), 선택지 선택 통계를 Supabase로 집계한다.
- **화면 흐름**(UI): 타이틀 → 메인 씬(배경/캐릭터/대사/선택지) → 세이브·로드/설정/백로그(직전 대사 이력, 오버레이 모달 — [[Decisions/0002-overlay-modal-unification]])/갤러리.
- 종합 기획 정본: `docs/01-plan/features/game-full-plan.plan.md` (분산 문서 7종 통합본, 참조 매핑은 그 문서 §11).

## 스택 / 구조
- Godot 4.6 + GDScript, 씬·리소스는 텍스트 형식(.tscn/.tres). 에디터 연동은 godot-mcp addon.
- `scripts/autoload/` — GameManager(모달·오토모드), StoryManager(JSON 스토리 파싱·진행, 최대 모듈), AudioManager, DebugOverlay
- `scenes/` — main_scene + title/save_load/settings/gallery/backlog 화면, `scenes/components/` 공용 버튼류
- `scenes/controller/` — background / character / dialogue / choice / overlay 컨트롤러 (main_scene에서 역할 분리)
- `story/april/opening.json` — 스토리 데이터 (현재 31노드, Test_* 테스트 노드 다수)
- `assets/` — backgrounds(시간대별 webp)·characters·music·shaders 등

## 핵심 판단 (요약 — 상세는 ADR)
- main_scene의 로직을 도메인별 컨트롤러(`scenes/controller/`)로 분리 → [[Decisions/0003-main-scene-controller-split]]
- 설정·세이브/로드·백로그는 오버레이 모달 방식(ModalType enum)으로 통일 → [[Decisions/0002-overlay-modal-unification]]
- 선택지 통계는 클라이언트에서 Supabase REST로 직접 전송 — 단 `_supabase_url`이 아직 빈 문자열이라 실제로는 비활성 상태 ([[Next-Tasks]] 과제 2).

## 지금 단계
- UI 폴리싱 단계: 다이얼로그·선택지 버튼 레이아웃 미세 조정 중 (최근 커밋 흐름).
- 다음 병목: 테스트 노드 중심의 스토리 JSON을 실제 시나리오 콘텐츠로 교체.
