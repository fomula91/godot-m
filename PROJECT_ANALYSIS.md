# 사쿠라 학원 - 프로젝트 분석 보고서

> 분석일: 2026-03-06 | 브랜치: `develop` | 최신 커밋: `4aa50e1` (갤러리 뷰 버그 수정)

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 프로젝트명 | 사쿠라 학원 (봄날의 이야기) |
| 장르 | 비주얼 노벨 (Visual Novel) |
| 엔진 | Godot 4.6 |
| 렌더러 | GL Compatibility (모바일 포함) |
| 물리 엔진 | Jolt Physics 3D |
| 스크립트 언어 | GDScript |
| 해상도 | 1920 x 1080 |
| 화면 스트레치 | canvas_items |
| Windows 렌더링 | D3D12 |
| 프로젝트 용량 | 약 184MB (전체), 28MB (에셋) |

5일간의 학원 생활을 배경으로, 플레이어의 선택과 호감도에 따라 다양한 결말로 분기하는 비주얼 노벨 게임입니다.

---

## 2. 프로젝트 구조

```
godot-m/
├── project.godot              # 엔진 설정 파일
├── CLAUDE.md                  # AI 코딩 가이드
├── README.md                  # 프로젝트 문서
├── .mcp.json                  # MCP 서버 설정
│
├── scripts/                   # 게임 로직 (52KB)
│   └── autoload/              # 4개 싱글톤 매니저
│       ├── game_manager.gd        # 296줄 - 상태, 세이브/로드, 갤러리
│       ├── story_manager.gd       # 430줄 - 스토리 엔진 핵심
│       ├── audio_manager.gd       # 136줄 - BGM/SFX 관리
│       └── debug_overlay.gd       # 224줄 - 디버그 오버레이 (F3)
│
├── scenes/                    # 5개 씬 + 스크립트 (84KB)
│   ├── title_screen.tscn/gd       # 타이틀 화면
│   ├── main_scene.tscn/gd         # VN 플레이 메인 (672줄)
│   ├── gallery_screen.tscn/gd     # CG 갤러리
│   ├── save_load_screen.tscn/gd   # 세이브/로드
│   └── settings_screen.tscn/gd    # 설정
│
├── story/                     # JSON 스토리 데이터 (192KB, 7,325줄)
│   ├── day1/                  # 3파일 (common, sora, hana)
│   ├── day2/                  # 3파일 (common, sora, hana)
│   ├── day3/                  # 4파일 (common, sora, hana, together)
│   ├── day4/                  # 4파일 (common, sora, hana, together)
│   └── day5/                  # 3파일 (sora, hana, together)
│
├── assets/                    # 멀티미디어 에셋 (28MB)
│   ├── backgrounds/           # 배경 이미지 40장 (.webp)
│   ├── characters/            # 캐릭터 스프라이트 25장 (.webp + .enc)
│   │   ├── hana/              # 9장 (표정 9종)
│   │   ├── haru/              # 5장 (표정 5종)
│   │   ├── sora/              # 6장 (표정 6종)
│   │   └── unknown/           # 5장
│   ├── gallery/               # CG 이벤트 이미지 24장 (.webp)
│   ├── music/                 # BGM 5곡 (.mp3)
│   └── sounds/                # 효과음 3개 (.mp3)
│
├── addons/                    # 에디터 플러그인
│   ├── godot_mcp/             # MCP 서버 플러그인 (28개 .gd)
│   └── godot_ai_bridge/       # AI 브릿지 플러그인 (3개 .gd)
│
└── tools/
    └── convert_stories.py     # Monogatari -> Godot JSON 변환기
```

### 코드 통계

| 카테고리 | 파일 수 | 코드 줄 수 |
|----------|---------|-----------|
| 게임 스크립트 (.gd) | 9개 | 약 2,097줄 |
| 애드온 스크립트 (.gd) | 28개 | 약 6,040줄 |
| 씬 파일 (.tscn) | 6개 | - |
| 스토리 데이터 (.json) | 17개 | 7,325줄 |
| **전체 GDScript** | **37개** | **약 8,137줄** |

---

## 3. 아키텍처

### 3.1 싱글톤 (Autoload) 구조

```
GameManager (*)     -> 게임 상태, 변수, 세이브/로드, 갤러리, 설정, 템플릿 치환
AudioManager (*)    -> BGM 크로스페이드, SFX, UI 클릭음, 오디오 버스 관리
StoryManager (*)    -> JSON 스토리 파싱, 명령 디스패치, 라벨 점프, 분기 처리
DebugOverlay (*)    -> 디버그 UI, 이벤트 로그, FPS 표시 (F3 토글)
MCPGameBridge       -> MCP 서버 게임 브릿지 (비 자동시작)
```

`*` 표시는 `project.godot`에서 자동 시작(`*` prefix)으로 설정된 싱글톤입니다.

### 3.2 시그널 기반 이벤트 아키텍처

게임의 핵심은 **StoryManager의 시그널 기반 명령 디스패치** 패턴입니다:

```
StoryManager (발행자)          main_scene.gd (구독자)
─────────────────────         ──────────────────────
dialogue_requested      →     _on_dialogue()
narration_requested     →     _on_narration()
centered_requested      →     _on_centered()
choice_requested        →     _on_choice()
scene_change_requested  →     _on_scene_change()
character_show_requested →    _on_character_show()
character_hide_requested →    _on_character_hide()
character_sprite_changed →    _on_character_sprite_change()
fade_requested          →     _on_fade()
wait_requested          →     _on_wait()
input_requested         →     _on_input_request()
affinity_hint_requested →     _on_affinity_hint()
gallery_unlock_requested →    _on_gallery_unlock()
distraction_free_toggled →    _on_distraction_free()
end_requested           →     _on_end()
```

### 3.3 씬 흐름도

```
title_screen.tscn
    ├── [새 게임]       → main_scene.tscn (Start 라벨)
    ├── [이어하기]      → main_scene.tscn (세이브 복원)
    ├── [갤러리]        → gallery_screen.tscn
    └── [설정]          → settings_screen.tscn

main_scene.tscn
    ├── [저장]          → save_load_screen.tscn (세이브 모드)
    ├── [불러오기]      → save_load_screen.tscn (로드 모드)
    ├── [설정]          → settings_screen.tscn
    └── [엔딩 도달]     → title_screen.tscn
```

---

## 4. 핵심 시스템 상세 분석

### 4.1 스토리 엔진 (StoryManager)

JSON 기반의 커스텀 비주얼 노벨 엔진으로, Monogatari 엔진에서 마이그레이션된 구조입니다.

**지원 명령어 (16종)**:

| 명령어 | 설명 | 자동진행 |
|--------|------|---------|
| `dialogue` | 캐릭터 대사 표시 | 수동 |
| `narration` | 나레이션 텍스트 | 수동 |
| `centered` | 중앙 텍스트 표시 | 수동 |
| `choice` | 선택지 표시 (분기) | 선택 대기 |
| `show_scene` | 배경 전환 | 자동 (0.05초) |
| `show_character` | 캐릭터 표시 | 자동 (0.05초) |
| `hide_character` | 캐릭터 숨김 | 자동 (0.05초) |
| `change_sprite` | 스프라이트 변경 | 자동 (0.05초) |
| `jump` | 라벨 점프 | 즉시 |
| `fade_jump` | 페이드 후 점프 | 대기 후 점프 |
| `fade_scene` | 페이드 씬 전환 | 대기 후 자동 |
| `play_music` / `stop_music` | BGM 제어 | 즉시 |
| `play_sound` / `stop_sound` | SFX 제어 | 즉시 |
| `wait` | 시간 대기 (ms) | 대기 후 자동 |
| `set_var` | 변수 설정 (set/add/sub) | 즉시 |
| `conditional` | 조건부 분기 | 즉시 |
| `input` | 텍스트 입력 | 입력 대기 |
| `gallery_unlock` | 갤러리 해금 | 즉시 |
| `affinity_hint` | 호감도 힌트 표시 | 즉시 |
| `distraction_free` | UI 토글 | 즉시 |
| `end` | 게임 종료 | 타이틀로 |

**스토리 데이터 구조** (17개 JSON 파일, 7,325줄):
- `day1/`: common, sora, hana (프롤로그, 캐릭터 소개)
- `day2/`: common, sora, hana (관계 심화)
- `day3/`: common, sora, hana, together (갈등, 전환점)
- `day4/`: common, sora, hana, together (클라이맥스)
- `day5/`: sora, hana, together (결말)

### 4.2 게임 상태 관리 (GameManager)

**추적 변수**:

| 변수명 | 타입 | 설명 |
|--------|------|------|
| `player.name` | String | 플레이어 이름 (입력) |
| `sora_affection` | int | 소라 호감도 |
| `hana_affection` | int | 하나 호감도 |
| `helped_sora` | bool | 소라 도움 여부 |
| `chose_library` | bool | 도서관 선택 여부 |
| `day2_sora_walk` | bool | Day2 소라 산책 |
| `day2_studied_together` | bool | Day2 함께 공부 |
| `confessed` | bool | 고백 여부 |
| `chose_both` | bool | 둘 다 선택 |
| `unknown_interest` | int | 미스터리 캐릭터 관심도 |
| `met_unknown` | bool | ??? 만남 여부 |
| `day3_ending_type` | String | Day3 엔딩 타입 |

**조건 평가 시스템**:
- 비교 연산자: `==`, `!=`, `>=`, `<=`, `>`, `<`
- 논리 연산자: `AND`, `OR`
- 템플릿 치환: `{{player.name}}` 형식

**세이브/로드 시스템**:
- 10개 슬롯 + 퀵세이브 (슬롯 0)
- 저장 데이터: 게임 상태, 현재 라벨/라인, 배경, 캐릭터, BGM, 타임스탬프
- 저장 경로: `user://saves/slot_X.json`
- 설정: `user://settings.json`
- 갤러리: `user://gallery.json`

### 4.3 오디오 시스템 (AudioManager)

| 기능 | 구현 방식 |
|------|----------|
| BGM 재생 | 2개 AudioStreamPlayer를 이용한 크로스페이드 (1.0초) |
| BGM 정지 | Tween 기반 페이드아웃 |
| SFX 재생 | 단일 AudioStreamPlayer |
| UI 클릭음 | 전용 AudioStreamPlayer |
| 오디오 버스 | Music, SFX 분리 (동적 생성) |
| 볼륨 제어 | linear_to_db 변환, 실시간 적용 |

**BGM 목록**: acoustic-chill, sunny-day, sora-ending, hana-ending, harem-ending
**SFX 목록**: Footsteps, Japanese_School_Bell, Select

### 4.4 UI/연출 시스템 (main_scene.gd)

**레이어 구조**:
```
BackgroundLayer     → bg1, bg2 (이중 버퍼 전환)
CharacterLayer      → LeftSlot, CenterSlot, RightSlot (3위치)
UILayer             → DialogueBox, ChoicePanel, CenteredText, QuickMenu
OverlayLayer        → TransitionRect, AffinityHint, InputDialog
```

**캐릭터 전환 효과 (7종)**:
- `fadeIn`, `fadeInUp`, `slideInLeft`, `slideInRight`, `bounceIn`
- `fadeOut`, `fadeOutLeft`, `fadeOutRight`

**퀵 메뉴 기능**:
- 저장/불러오기, 자동 진행 (Auto), 스킵 (Skip), 설정

---

## 5. 캐릭터 시스템

| ID | 이름 | 고유색 | 스프라이트 수 | 표정 |
|----|------|--------|-------------|------|
| `p` | 하루 (Haru) | #ffa726 | 5장 | normal, smile, angry, surprised, worried |
| `s` | 소라 (Sora) | #4a90d9 | 6장 | normal, happy, angry, surprised, worried, angry2 |
| `h` | 하나 (Hana) | #e87ba1 | 9장 | normal, normal2, happy, laugh, angry, worried, surprised, yandere, shy |
| `u` | ??? (Yuu) | #9370db | 1장+α | normal (+ 합성 스프라이트) |

### 배경 시스템

**총 40개 배경**, 씬 ID로 매핑 (114개 매핑 엔트리):
- 교실 (4종 x 3~4 시간대)
- 강당 (5개 시간대)
- 버스 정류장 (4개 시간대)
- 과학실 (8종)
- 수영장, 다른 건물 등

---

## 6. 갤러리 시스템

총 **24개 CG 이벤트 이미지**:

| 카테고리 | CG 목록 |
|----------|---------|
| 공통 | opening-unknown, silhouette, photo-discovery, crane-gift, three-walk-home, busstop-silhouette, three-hands |
| 소라 루트 | library-sora, sora-sunset-smile, sora-exhibition, sora-past-tears, sora-confession, sora-truelove, sora-warm |
| 하나 루트 | rooftop-hana, hana-sunset-promise, rooftop-sakura-rain, pool-secret, hana-unmasked, hana-confession, hana-truelove, hana-warm |
| 기타 | yuu-first-meet, together-letter |

---

## 7. 입력 시스템

| 액션 | 바인딩 | 용도 |
|------|--------|------|
| `vn_advance` | 마우스 좌클릭, Enter, Space | 텍스트 진행 |
| `vn_skip` | Ctrl | 스킵 모드 |
| F3 (하드코딩) | F3 | 디버그 오버레이 토글 |

---

## 8. 외부 연동

### 8.1 Supabase 선택지 통계 (선택적)
- 12개 주요 결정 포인트에서 선택 통계 수집/표시
- API 엔드포인트: `/api/stats`, `/api/vote`
- 현재 `_supabase_url`이 비어있어 비활성 상태

### 8.2 MCP 서버 (개발용)
- `addons/godot_mcp/`: WebSocket 기반 MCP 서버 플러그인
- `addons/godot_ai_bridge/`: AI 브릿지 플러그인
- Claude Code 등 AI 도구와의 연동을 위한 인프라

### 8.3 캐릭터 이미지 암호화
- `.webp.enc` 파일이 각 캐릭터 스프라이트와 함께 존재
- 원본 `.webp`와 암호화된 `.enc` 버전 모두 보유

---

## 9. 설정 시스템

| 설정 항목 | 기본값 | 설명 |
|-----------|--------|------|
| `text_speed` | 20.0 | 글자당 밀리초 |
| `auto_speed` | 5.0 | 자동 진행 대기 초 |
| `music_volume` | 1.0 | 음악 볼륨 (0~1 선형) |
| `sound_volume` | 1.0 | 효과음 볼륨 (0~1 선형) |

---

## 10. Git 이력

| 커밋 | 설명 |
|------|------|
| `b8465a0` | 초기 커밋 |
| `0c13e37` | 마이그레이션 완료 (Monogatari → Godot) |
| `9c6a84e` | README 파일 작성 |
| `506b1d3` | 마우스 이벤트 로그 설정 추가 |
| `83c7c43` | 마우스 인식 불량 버그 수정 |
| `4aa50e1` | 갤러리 뷰 버그 수정 (최신) |

총 6개 커밋. Monogatari(JavaScript 기반 VN 엔진)에서 Godot 4.6으로 마이그레이션된 프로젝트입니다.

---

## 11. 강점 및 특이사항

### 강점
- **깔끔한 아키텍처**: 싱글톤 + 시그널 패턴으로 모듈 간 결합도가 낮음
- **데이터 주도 설계**: 스토리가 JSON으로 분리되어 코드 변경 없이 스토리 수정 가능
- **풍부한 연출**: 7종 캐릭터 전환, BGM 크로스페이드, 페이드 전환 등
- **완성도 높은 기능셋**: 세이브/로드, 갤러리, 설정, 자동진행, 스킵 등 VN 필수 기능 구현
- **디버그 도구**: F3 오버레이로 실시간 이벤트 로그, FPS, 입력 추적

### 특이사항
- `tools/convert_stories.py`로 Monogatari에서 변환한 마이그레이션 프로젝트
- 물리 엔진(Jolt Physics 3D)이 설정되어 있으나 실제 게임에서 3D 물리를 사용하지 않음
- Supabase 통계 연동 코드가 존재하나 현재 비활성 상태
- 캐릭터 이미지에 `.enc` 암호화 버전이 함께 존재

---

## 12. 개선 가능 영역

| 영역 | 현재 상태 | 개선 방안 |
|------|----------|----------|
| 대화 로그 뷰어 | `_dialogue_log` 배열 수집만 구현 | 로그 뷰어 UI 씬 추가 |
| 세이브 슬롯 프리뷰 | 텍스트 메타만 표시 | 스크린샷 썸네일 추가 |
| 스킵 모드 | 모든 텍스트 스킵 | 읽은 텍스트만 스킵하는 옵션 |
| 다국어 지원 | 한국어 하드코딩 | Godot 번역 시스템(`.csv`) 도입 |
| 선택지 통계 | Supabase 연동 비활성 | 서버 URL 설정 또는 로컬 통계 |
| 접근성 | 기본 UI | 폰트 크기 조절, 고대비 모드 |
