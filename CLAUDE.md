# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Godot 4.6 게임 프로젝트 (GL Compatibility 렌더러, Jolt Physics 3D 물리 엔진 사용).

## Engine & Configuration

- **Godot 버전**: 4.6
- **렌더러**: GL Compatibility (모바일 포함)
- **물리 엔진**: Jolt Physics (3D)
- **Windows 렌더링 드라이버**: D3D12
- **스크립트 언어**: GDScript (`.gd` 파일)

## Project Structure

- `project.godot` - 엔진 설정 파일 (에디터 UI로 편집 권장)
- `.godot/` - 에디터 캐시 (git에서 제외됨)
- `icon.svg` - 프로젝트 아이콘

## Development

- Godot 에디터에서 F5(전체 실행) 또는 F6(현재 씬 실행)으로 테스트
- 커맨드라인 실행: `godot --path . --editor` (에디터), `godot --path .` (게임 실행)
- `.editorconfig`에 따라 UTF-8 인코딩 사용

## Conventions

- GDScript 파일은 Godot 공식 스타일 가이드를 따름 (snake_case 함수/변수, PascalCase 클래스)
- 씬 파일(`.tscn`)과 리소스 파일(`.tres`)은 텍스트 형식으로 저장

---

# LLM-WIKI 연동 규칙 (repo 내장 모드)

이 프로젝트의 **정본(설계 결정·ADR·측정 결과·과제·로그)은 repo 안의 `llm-wiki/`다.** 코드와 함께 버전 관리되고 함께 커밋된다.

- **세션 시작**: SessionStart 훅이 `llm-wiki/`의 최근 로그·열린 과제를 자동 주입한다. 상세가 필요하면 `llm-wiki/index.md`부터 진입한다(전체를 읽지 않는다).
- **세션 종료 전**: 의미 있는 작업을 했으면 `llm-wiki/log.md` 오늘 날짜 섹션(`## YYYY-MM-DD`)에 `- **제목**: 내용` 형식으로 기록한다. 코드 변경이 있는데 오늘 기록이 없으면 Stop 훅이 경고한다. 커밋은 코드와 함께 한다.
- **과제 관리**: 새 과제는 `llm-wiki/Next-Tasks.md`의 `## 열린 과제` 아래 `### N. 제목` + `무엇 → 왜 → 완료 기준`으로 추가하고, 종료되면 종료 기록 표로 옮긴다. (제목 형식은 훅이 파싱하는 계약이다.)
- **설계 결정**: ADR은 `llm-wiki/Decisions/NNNN-*.md`로 남긴다.

---

# 이 저장소의 검증 단계

이 프로젝트에는 CLI 검증 입구(테스트 러너·린터·CI)가 없다. **공식 검증 입구는 열려 있는 Godot 에디터를 통한 godot-mcp 실행**이다 — 에디터가 열려 있지 않으면 검증 불가이므로 사용자에게 에디터 실행을 요청한다. 추측으로 다른 명령을 만들어 돌리지 않는다.

| 변경한 곳 | 1차로 돌릴 것 | 비고 |
| --- | --- | --- |
| GDScript (`scripts/`, `scenes/*.gd`) | `godot_editor_edit` stop → run 후 `godot_runtime_state`로 값 확인 | 게임은 디스크에서 스크립트를 새로 로드하므로 에디터 재시작 불필요 |
| 씬 파일 (`.tscn`) | 에디터에서 해당 씬 열기 → 게임 실행 → 스크린샷 1장으로 외관 확인 | 값 확인은 스크린샷 대신 runtime_state 우선 |
| 스토리 JSON (`story/`) | `python3 -m json.tool <파일>`로 파싱 확인 → 게임 실행 후 해당 노드까지 진행 | 노드 키·target 오타는 파싱만으로 안 잡힘 |
| `project.godot` | `godot_project` check_stale → 에디터 재시작으로 적용 | 에디터는 디스크의 project.godot을 다시 읽지 않음 |
| Supabase 연동 (choice_controller 등) | 게임 실행 → 선택지 선택 → 에디터 로그에서 HTTP 응답 확인 | 네트워크 실패는 코드 문제가 아님 |

실패 시 원인 분류:

| 출력 첫 토큰 / 증상 | 분류 | 대응 |
| --- | --- | --- |
| `Parse Error` / `SCRIPT ERROR` | 코드 문제 | 해당 스크립트 수정 |
| godot-mcp 연결 실패 / 타임아웃 | 환경 문제 | 에디터·addon 활성화 여부를 사용자에게 확인, 코드로 고치려 들지 않는다 |
| HTTP 4xx/5xx (Supabase) | 외부 서비스 문제 | 키·URL 확인 후 사용자에게 보고 |
