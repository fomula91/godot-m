# godot-m — Index

이 프로젝트의 진입 지도. 전체를 읽지 말고 여기서 필요한 곳으로 이동한다.

> **처음이라면**: [[Context]](무엇을 만드는가) → [[Next-Tasks]](지금 할 일) 순으로 두 장만 읽으면 착수 가능하다. 판단 배경이 궁금할 때만 아래 Decisions로 내려간다.

## Core
- [[Context]] — 지금 무엇을 만드는가 (Claude Code 우선 읽기)
- [[Next-Tasks]] — 다음 과제 (열린 과제 / 종료 기록)
- [[OpenQuestions]] — 미결정·미검증 질문

## Summaries (요약층)
- (없음 — 주제별 요약이 생기면 `Summaries/`에 추가하고 여기 링크)

## Decisions (ADR)
- [[Decisions/0001-story-json-node-graph]] — 스토리를 JSON 노드 그래프로 구동
- [[Decisions/0002-overlay-modal-unification]] — 설정·세이브/로드는 오버레이 모달로 통일
- [[Decisions/0003-main-scene-controller-split]] — main_scene을 도메인 컨트롤러로 분리
- [[Decisions/0004-april-hub-balance]] — 4월 허브의 구조와 밸런스 확정 (허점 3종 연쇄 해소)

## 상세 (Reference 정본)

문서 지도는 `docs/00.INDEX.md`. 전체를 읽지 말고 거기서 이동한다. (2026-08-02 번호 체계로 재편됨)

- (위키 밖 정본) `docs/01.new_story.md` — **원고 정본**. 프롤로그~3화, 4~6화 미작성
- (위키 밖 정본) `docs/02.characters.md` — 캐릭터·세계관 설정
- (위키 밖 정본) `docs/03.game-design.md` — 게임 기획 (구 `game_design_document.md`)
- (위키 밖 정본) `docs/04.script-engine.md` — 엔진 스크립트 (구 `script_full.md`). **구원고 기준, 재작성 대기**
- (위키 밖 정본) `docs/05.continuity.md` — 원고↔설정 충돌·미결 추적
- (위키 밖 정본) `docs/01-plan/features/game-full-plan.plan.md` — 종합 기획·로드맵·Phase 체크리스트
- 구버전 문서는 `docs/archive/`에 보존 (읽기 전용)

> ADR 0001·0003이 인용하는 `docs/script_full.md`·`docs/main_scene_analysis.md`는 각각
> `docs/04.script-engine.md`·`docs/90.main_scene_analysis.md`로 이름이 바뀌었다.
> ADR 본문은 결정 시점의 기록이므로 수정하지 않는다.

최근 변화: [[log]]
