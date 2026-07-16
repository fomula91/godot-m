# godot-m — Context

Claude Code가 우선 읽는 구현 컨텍스트. "지금 무엇을 만드는가"를 한 장으로 유지한다.
낡으면 고친다 — 이 문서는 이력이 아니라 현재 상태다 (이력은 [[log]]).

## 무엇을 만드는가
- 로맨스 비주얼 노벨 (Godot 4.6, GL Compatibility 렌더러). 학교 배경, 시간대별 배경 이미지·멀티 캐릭터 시스템.
- 스토리는 JSON 노드 그래프(`story/<월>/<장>.json`)로 구동되고, 선택지 선택 통계를 Supabase로 집계한다.
- 핵심 흐름: 타이틀 → 메인 씬(배경/캐릭터/대사/선택지) → 세이브·로드/설정(오버레이 모달)/갤러리/백로그.

## 스택 / 구조
- Godot 4.6 + GDScript, 씬·리소스는 텍스트 형식(.tscn/.tres). 에디터 연동은 godot-mcp addon.
- `scripts/autoload/` — GameManager(모달·오토모드), StoryManager(JSON 스토리 파싱·진행, 최대 모듈), AudioManager, DebugOverlay
- `scenes/` — main_scene + title/save_load/settings/gallery/backlog 화면, `scenes/components/` 공용 버튼류
- `scenes/controller/` — background / character / dialogue / choice / overlay 컨트롤러 (main_scene에서 역할 분리)
- `story/april/opening.json` — 스토리 데이터 (현재 31노드, Test_* 테스트 노드 다수)
- `assets/` — backgrounds(시간대별 webp)·characters·music·shaders 등

## 핵심 판단 (요약)
- main_scene의 로직을 도메인별 컨트롤러(`scenes/controller/`)로 분리하는 방향으로 리팩터링 진행 중.
- 설정·세이브/로드는 별도 씬 전환이 아니라 오버레이 모달 방식(ModalType enum)으로 통일.
- 선택지 통계는 클라이언트에서 Supabase REST로 직접 전송.

## 지금 단계
- UI 폴리싱 단계: 다이얼로그·선택지 버튼 레이아웃 미세 조정 중 (최근 커밋 흐름).
- 다음 병목: 테스트 노드 중심의 스토리 JSON을 실제 시나리오 콘텐츠로 교체.
