# MainScene 심층 분석

> `scenes/main_scene.gd` (672줄) + `scenes/main_scene.tscn` (273줄)
> VN(비주얼 노벨) 플레이 화면의 메인 컨트롤러

---

## 1. 아키텍처 개요

MainScene은 **MVC 패턴의 View + Controller** 역할을 수행한다. StoryManager(Model)가 JSON 스토리 데이터를 파싱하여 시그널을 발생시키면, MainScene이 이를 수신하여 UI를 갱신한다.

```
[StoryManager] --시그널--> [MainScene] --노드 조작--> [UI 컴포넌트]
[GameManager]  --설정/상태-->  [MainScene]
[AudioManager] --음향-->      [MainScene]
```

### 데이터 흐름

```
사용자 입력 (클릭/터치)
    ↓
_unhandled_input()
    ↓
_handle_advance_input()
    ↓
StoryManager.advance()  ←  다음 명령 처리
    ↓
시그널 발생 (dialogue_requested, scene_change_requested 등)
    ↓
MainScene 핸들러 (_on_dialogue, _on_scene_change 등)
    ↓
UI 업데이트 (텍스트 타이핑, 배경 전환, 캐릭터 표시 등)
```

---

## 2. 씬 트리 구조 (main_scene.tscn)

```
MainScene (Control, 전체화면)
├── BackgroundLayer (Control)
│   ├── Background1 (TextureRect) ─ 현재 배경
│   └── Background2 (TextureRect) ─ 크로스페이드용 (초기 alpha=0)
│
├── CharacterLayer (Control)
│   ├── LeftSlot   (TextureRect) ─ 좌측 캐릭터 (anchor 10%~40%)
│   ├── CenterSlot (TextureRect) ─ 중앙 캐릭터 (anchor 30%~70%)
│   └── RightSlot  (TextureRect) ─ 우측 캐릭터 (anchor 60%~90%)
│
├── UILayer (CanvasLayer, layer=10)
│   ├── DialogueBox (PanelContainer) ─ 하단 70%~100% 대화창
│   │   └── MarginContainer
│   │       └── VBoxContainer
│   │           ├── NameLabel (Label, 24px)
│   │           └── TextLabel (RichTextLabel, 22px, BBCode 지원)
│   │
│   ├── ChoicePanel (VBoxContainer) ─ 중앙 선택지 패널 (초기 hidden)
│   ├── CenteredText (Label, 32px) ─ 중앙 정렬 텍스트 (초기 hidden)
│   └── QuickMenu (HBoxContainer) ─ 우상단 퀵 메뉴
│       ├── SaveBtn / LoadBtn (Button)
│       ├── AutoBtn / SkipBtn (Button, toggle_mode)
│       ├── LogBtn (Button)
│       └── SettingsBtn (Button)
│
├── OverlayLayer (CanvasLayer, layer=20)
│   ├── TransitionRect (ColorRect) ─ 페이드 인/아웃 (mouse_filter=IGNORE)
│   ├── AffinityHint (PanelContainer) ─ 호감도 알림 (초기 hidden)
│   │   └── HBoxContainer
│   │       ├── Icon (Label, 24px)
│   │       └── Text (Label, 18px)
│   └── InputDialog (PanelContainer) ─ 이름 입력 다이얼로그 (초기 hidden)
│       └── VBoxContainer
│           ├── PromptLabel (Label, 20px)
│           ├── InputField (LineEdit, 22px)
│           ├── WarningLabel (Label, 14px, 빨간색)
│           └── ConfirmBtn (Button, 18px)
│
└── AutoTimer (Timer, 5초, one_shot)
```

### 레이어 설계 의도

| 레이어 | CanvasLayer | 용도 |
|--------|-------------|------|
| BackgroundLayer | 없음 (기본) | 배경 이미지, 가장 아래 |
| CharacterLayer | 없음 (기본) | 캐릭터 스프라이트, 배경 위 |
| UILayer | layer=10 | 대화창/선택지/퀵메뉴, 캐릭터 위 |
| OverlayLayer | layer=20 | 전환 효과/알림/입력창, 최상위 |

---

## 3. 스크립트 기능별 상세 분석

### 3.1 초기화 (`_ready`)

```gdscript
func _ready() -> void:
    _apply_dialogue_box_style()    # 대화창 StyleBoxFlat 적용
    _connect_story_signals()       # StoryManager 시그널 16개 연결
    _connect_ui_signals()          # UI 버튼/타이머 시그널 연결
    _setup_http_nodes()            # Supabase 통계용 HTTPRequest 2개 생성
    _setup_mouse_passthrough()     # 배경/캐릭터/대화창 마우스 이벤트 통과 설정
```

**마우스 패스스루 전략**: 루트 Control과 배경/캐릭터 레이어를 `MOUSE_FILTER_IGNORE`로 설정하여, 클릭 이벤트가 `_unhandled_input()`까지 전파되도록 한다. 이렇게 하면 대화 진행 클릭이 UI 요소에 의해 소비되지 않는다.

### 3.2 입력 처리

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if input_dialog.visible: return          # 입력창 열려있으면 무시
    if event.is_action_pressed("vn_advance"):
        _handle_advance_input()
```

**진행 우선순위**:
1. 방해금지 모드 → 해제하고 UI 복원
2. 중앙 텍스트 표시 중 → 숨기고 advance()
3. 타이핑 중 → 즉시 완료 (visible_ratio = 1.0)
4. 선택지 표시 중 → 무시 (선택 강제)
5. 그 외 → StoryManager.advance()

### 3.3 텍스트 타이핑 시스템

```
텍스트 속도 = GameManager.settings["text_speed"] (ms/char)
duration = 글자수 × speed_ms / 1000.0
```

- **Tween 기반**: `visible_ratio`를 0→1로 애니메이션
- **스킵 모드**: duration = 0.05초 (거의 즉시)
- **타이핑 완료 후**: auto_mode면 타이머 시작, skip_mode면 0.05초 후 자동 진행

### 3.4 대화 처리 (3가지 모드)

| 모드 | 핸들러 | 이름 라벨 | 대화창 |
|------|--------|----------|--------|
| 캐릭터 대사 | `_on_dialogue()` | 표시 (캐릭터 색상) | 표시 |
| 나레이션 | `_on_narration()` | 숨김 | 표시 |
| 중앙 텍스트 | `_on_centered()` | - | 숨김, 중앙 라벨 페이드인 |

### 3.5 선택지 시스템

**버튼 동적 생성**:
- 기존 자식 노드 `queue_free()` 후 새로 생성
- 최소 크기: 500×60px
- 스타일: 반투명 다크 배경 + 핑크 보더 (호버 시 밝아짐)
- 폰트: 20px

**Supabase 통계 통합** (tracked_scenes 전용):
1. 선택지 표시 시 → `_fetch_preview_stats()` (기존 통계 조회)
2. 선택 클릭 시 → `_record_vote_and_show_stats()` (투표 + 결과 표시)
3. 2.5초 대기 후 → `_finalize_choice()` (스토리 진행)

### 3.6 배경 전환

| 전환 타입 | 동작 |
|----------|------|
| `"instant"` | bg1에 즉시 교체 |
| `"fadeIn"` / 기타 | bg2에 로드 → alpha 0→1 페이드 (1초) → bg1으로 복사 |
| `"#RRGGBB"` 색상 | TransitionRect.color로 단색 배경 처리 |

**더블 버퍼링**: bg1(현재) + bg2(다음)으로 크로스페이드 구현. 페이드 완료 후 bg2 → bg1 복사.

### 3.7 캐릭터 표시/숨김 애니메이션

**표시 트랜지션 (5종)**:

| 트랜지션 | 효과 |
|----------|------|
| `fadeIn` | alpha 0→1 (0.5초) |
| `fadeInUp` | alpha 0→1 + Y축 30px 상승 (병렬) |
| `slideInLeft` | X축 -200px에서 슬라이드 (EASE_OUT, CUBIC) |
| `slideInRight` | X축 +200px에서 슬라이드 |
| `bounceIn` | scale 0.8→1.0 (EASE_OUT, BACK) + alpha 페이드 |

**숨김 트랜지션 (3종)**:

| 트랜지션 | 효과 |
|----------|------|
| `fadeOut` | alpha 1→0 (0.5초) |
| `fadeOutLeft` | alpha 페이드 + X축 -100px 이동 |
| `fadeOutRight` | alpha 페이드 + X축 +100px 이동 |

**슬롯 매핑**: `_character_slots` Dictionary로 캐릭터 ID → 포지션(left/center/right) 추적.

### 3.8 페이드 전환

```gdscript
"to_black"  → TransitionRect alpha 0→1 (어두워짐)
"from_black" → TransitionRect alpha 1→0 (밝아짐)
```

Color 파라미터로 검은색 외 다른 색상 페이드도 지원.

### 3.9 호감도 알림

4가지 캐릭터별 설정:

| 키 | 아이콘 | 메시지 |
|----|--------|--------|
| `sora` | ✧ | "소라의 마음이 가까워진 것 같다." |
| `hana` | ✨ | "하나의 마음이 가까워진 것 같다." |
| `both` | ✧✨ | "소라와 하나의 마음이 가까워진 것 같다." |
| `unknown` | ? | "누군가의 존재가 느껴진다..." |

**표시 타이밍**: 1400ms 표시 → 400ms 페이드아웃 (총 1800ms)

### 3.10 Auto/Skip 모드

- **Auto**: 타이핑 완료 후 `auto_speed` 초 대기 → 자동 advance
- **Skip**: 타이핑 duration을 0.05초로 강제 → 타이핑 완료 후 0.05초 대기 → advance
- **상호 배타**: Auto 켜면 Skip 끔, Skip 켜면 Auto 끔

### 3.11 세이브/로드

**퀵 세이브 (slot 0)**:
```
저장 데이터 = StoryManager.get_save_data() + {
    "background": 현재 배경 ID,
    "bgm": 현재 BGM ID,
    "characters": 캐릭터 슬롯 매핑
}
```

**복원 순서**:
1. 배경 복원 (`instant` 전환)
2. BGM 복원
3. 캐릭터 슬롯 초기화 (모든 슬롯 텍스처/alpha 리셋)
4. 스토리 위치 복원 → advance()

### 3.12 대화창 스타일

코드에서 동적으로 생성하는 StyleBoxFlat:
- 배경: `rgba(20, 10, 30, 0.82)` (반투명 다크 퍼플)
- 보더: `rgba(244, 143, 177, 0.2)` (연한 핑크), 2px
- 라운드: 16px
- 패딩: 20px

---

## 4. 싱글톤 의존성

### 4.1 StoryManager (`scripts/autoload/story_manager.gd`)

**역할**: JSON 스토리 파싱, 명령 디스패치, 라벨 점프

MainScene이 연결하는 시그널 16개:
- `dialogue_requested`, `narration_requested`, `centered_requested`
- `choice_requested`, `scene_change_requested`
- `character_show_requested`, `character_hide_requested`, `character_sprite_changed`
- `fade_requested`, `wait_requested`, `input_requested`
- `affinity_hint_requested`, `gallery_unlock_requested`
- `distraction_free_toggled`, `end_requested`

핵심 호출: `start()`, `advance()`, `on_choice_selected()`, `on_input_completed()`

### 4.2 GameManager (`scripts/autoload/game_manager.gd`)

**역할**: 게임 상태, 설정, 세이브/로드

사용하는 API:
- `settings["text_speed"]` / `settings["auto_speed"]` — 텍스트/자동 진행 속도
- `replace_templates()` — `{{player.name}}` 치환
- `save_game()` / `load_game()` — 세이브 슬롯
- `unlock_gallery()` — 갤러리 해금

### 4.3 AudioManager (`scripts/autoload/audio_manager.gd`)

**역할**: BGM 크로스페이드, 효과음 재생

사용하는 API:
- `play_ui_click()` — advance/선택 시 클릭음
- `play_music()` — 로드 시 BGM 복원
- `get_current_bgm()` — 세이브 시 현재 BGM 저장

### 4.4 DebugOverlay (`scripts/autoload/debug_overlay.gd`)

**역할**: 디버그 로그 (F3 토글)

사용: `log_message()` — 대사/씬변경/캐릭터/선택지/입력 등 이벤트 로깅

---

## 5. 상태 변수 정리

| 변수 | 타입 | 용도 |
|------|------|------|
| `_typing` | bool | 텍스트 타이핑 진행 중 |
| `_typing_tween` | Tween | 현재 타이핑 트윈 (kill 가능) |
| `_auto_mode` | bool | 자동 진행 모드 |
| `_skip_mode` | bool | 스킵 모드 |
| `_distraction_free` | bool | 방해금지 모드 (UI 숨김) |
| `_current_bg_id` | String | 현재 배경 씬 ID |
| `_character_slots` | Dictionary | 캐릭터 ID → 포지션 매핑 |
| `_dialogue_log` | Array[Dictionary] | 대화 히스토리 (name, text) |
| `_supabase_url` | String | Supabase 통계 API URL |
| `_pending_choice_data` | Dictionary | 투표 처리 중 선택 데이터 임시 저장 |

---

## 6. 개선 가능 포인트

### 미구현 / 부분 구현
- `_display_stats_preview()` (342줄): 통계 프리뷰 로직 본문 비어있음
- `_show_stats_result()` (378줄): 퍼센티지 표시 로직 없이 버튼 disabled만 처리
- `LogBtn` 시그널 미연결 — `_dialogue_log`은 쌓이지만 표시 UI 없음
- `_restore_state()`에서 캐릭터 복원 로직 없음 (슬롯 초기화만 수행)

### 구조적 참고사항
- 선택지 버튼 스타일이 코드에서 하드코딩 (테마/리소스 분리 가능)
- 대화창 스타일도 `_apply_dialogue_box_style()`에서 하드코딩
- HTTPRequest 노드를 코드에서 동적 생성 (씬에 배치하는 것도 가능)
- `_on_wait()`는 빈 함수 — StoryManager가 내부적으로 타이머 처리
