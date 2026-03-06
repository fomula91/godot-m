# MainScene 심층 분석

> `scenes/main_scene.gd` (672줄) + `scenes/main_scene.tscn` (273줄)
> VN(비주얼 노벨) 플레이 화면의 메인 컨트롤러

---

## 1. 아키텍처 개요

MainScene은 **시그널 기반 Observer + Mediator 패턴**으로 동작한다. StoryManager가 JSON 스토리 데이터를 파싱하여 시그널을 발행하면, MainScene이 Mediator로서 이를 수신하고 여러 UI 노드에 분배하여 갱신한다.

- **StoryManager** = 데이터 + 로직 (시그널 발행자, Publisher)
- **MainScene** = 중재자 (시그널 수신 → UI 노드 분배, Mediator)
- **각 UI 노드** = 단순 표시 요소 (Subscriber)

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

## 2. 디자인 패턴 심층 분석

미연시/비주얼 노벨에서 전형적으로 사용되는 패턴들이 이 프로젝트에 어떻게 적용되어 있는지 분석한다.

### 2.1 Command 패턴 — 스토리 명령 체계

가장 핵심적인 패턴. 각 스토리 행위(대사, 배경변경, 캐릭터 등장 등)를 독립된 **명령 객체(JSON Dictionary)**로 표현한다.

**구조**:
```
story/day1/start.json
  └─ "Start": [
       { "cmd": "show_scene", "id": "school_front_early", "transition": "fadeIn" },
       { "cmd": "dialogue", "character": "s", "text": "안녕!" },
       { "cmd": "choice", "choices": [...] },
       ...
     ]
```

**실행 흐름** (`story_manager.gd`):
```
advance()  →  cmd = lines[line_index]  →  _dispatch_command(cmd)
                                              ↓
                                         match cmd_type:
                                           "dialogue"       → dialogue_requested.emit()
                                           "show_scene"     → scene_change_requested.emit()
                                           "show_character"  → character_show_requested.emit()
                                           "choice"         → choice_requested.emit()
                                           "jump"           → jump(target)
                                           "conditional"    → evaluate → jump/advance
                                           "fade_jump"      → fade → jump
                                           "set_var"        → GameManager.set_var()
                                           "play_music"     → AudioManager.play_music()
                                           ...
```

**장점**: 스토리 작성자가 GDScript를 몰라도 JSON만으로 연출을 제어할 수 있다. 명령 추가도 `_dispatch_command()`에 case 하나만 추가하면 된다.

### 2.2 Observer 패턴 (Signal) — 시그널 기반 이벤트 전달

StoryManager가 **16개 시그널**을 발행하고, MainScene이 구독하는 1:1 Observer 구조.

```
[StoryManager]                          [MainScene]
  dialogue_requested  ─────connect────→  _on_dialogue()
  narration_requested ─────connect────→  _on_narration()
  scene_change_requested ──connect────→  _on_scene_change()
  character_show_requested ─connect───→  _on_character_show()
  fade_requested  ─────────connect────→  _on_fade()
  choice_requested  ───────connect────→  _on_choice()
  ...                                    ...
```

**설계 의도**: StoryManager는 UI를 전혀 모른다. 시그널만 발행하므로 MainScene을 다른 프레젠터(예: 3D 씬, 미니맵 뷰)로 교체해도 StoryManager 수정이 필요 없다.

**현재 한계**: 구독자가 MainScene 하나뿐인 1:1 관계. 다중 구독자가 필요하면(예: 로그 패널이 dialogue_requested를 동시 수신) 추가 연결만 하면 되므로 확장성은 확보되어 있다.

### 2.3 Mediator 패턴 — MainScene의 중재자 역할

MainScene은 StoryManager 시그널을 받아 **여러 UI 노드에 분배**하는 Mediator다.

```
_on_dialogue(char_id, name_text, text):
    dialogue_box.visible = true       ← DialogueBox 제어
    centered_text.visible = false     ← CenteredText 제어
    name_label.text = name_text       ← NameLabel 제어
    name_label.add_theme_color...     ← NameLabel 스타일 제어
    _start_typing(text)               ← TextLabel + Tween 제어
    _dialogue_log.append(...)         ← 내부 로그 축적
```

하나의 시그널이 5개 이상의 노드 상태를 변경한다. UI 노드들은 서로를 모르고, MainScene만이 전체 상태를 파악하여 조율한다.

### 2.4 State Machine 패턴 — 플레이 상태 관리

명시적 State enum은 없지만, **bool 플래그 조합**으로 암묵적 상태 머신을 구현한다.

```
┌─────────────────────────────────────────────────────┐
│                    MainScene 상태                     │
├──────────────┬──────────────────────────────────────┤
│ _typing      │ 텍스트 출력 중 (클릭→즉시 완료)        │
│ _auto_mode   │ 자동 진행 (타이머 기반)                │
│ _skip_mode   │ 고속 스킵 (0.05초 간격)               │
│ _distraction │ UI 숨김 모드 (클릭→복원)               │
│ choice_panel │ 선택지 대기 (입력 차단)                │
│ input_dialog │ 텍스트 입력 대기 (입력 차단)            │
└──────────────┴──────────────────────────────────────┘

StoryManager 측:
│ _waiting       │ fade_jump/wait/input 대기 중 (advance 차단) │
│ _choice_pending│ 선택지 응답 대기 중 (advance 차단)          │
```

**상태 전이 (입력 처리 시)**:
```
_unhandled_input("vn_advance")
    │
    ├── input_dialog.visible? → 무시 (return)
    │
    ├── _distraction_free?    → 해제, UI 복원
    │
    ├── centered_text.visible? → 숨김, advance()
    │
    ├── _typing?              → _complete_typing() (즉시 완료)
    │
    ├── choice_panel.visible? → 무시 (선택 강제)
    │
    └── else                  → StoryManager.advance()
```

### 2.5 Strategy 패턴 — 트랜지션 처리

`match transition:` 분기가 Strategy 패턴의 인라인 구현에 해당한다.

**캐릭터 표시** (`_on_character_show`):
```
transition 값에 따라 서로 다른 애니메이션 전략 선택:
  "fadeIn"       → Tween: alpha 0→1
  "fadeInUp"     → Tween: alpha 0→1 + Y -30px (병렬)
  "slideInLeft"  → Tween: X -200px→0 (EASE_OUT, CUBIC)
  "slideInRight" → Tween: X +200px→0 (EASE_OUT, CUBIC)
  "bounceIn"     → Tween: scale 0.8→1.0 (EASE_OUT, BACK) + alpha
  _              → 즉시 표시
```

동일 인터페이스(슬롯에 텍스처 설정 + 애니메이션)에 대해 전환 방식만 교체. 별도 클래스로 분리하지 않고 match문으로 처리하는 것은 Godot/VN에서 흔한 경량 구현이다.

### 2.6 Memento 패턴 — 세이브/로드

게임 상태의 **스냅샷을 캡처하고 복원**하는 구조.

**캡처 (Memento 생성)**:
```gdscript
func _quick_save():
    var extra = StoryManager.get_save_data()  # {current_label, line_index}
    extra["background"] = _current_bg_id
    extra["bgm"] = AudioManager.get_current_bgm()
    extra["characters"] = _character_slots.duplicate()
    GameManager.save_game(0, extra)           # → JSON 파일로 직렬화
```

**복원 (Memento 적용)**:
```gdscript
func _restore_state(data):
    _on_scene_change(data["background"], "instant")   # 배경 즉시 복원
    AudioManager.play_music(data["bgm"])               # BGM 복원
    # 캐릭터 슬롯 초기화
    StoryManager.restore_from_save(data)               # 라벨/인덱스 복원
    StoryManager.advance()                             # 재개
```

**저장 경로**: `user://saves/slot_0.json` (퀵 세이브), 최대 10슬롯.

### 2.7 Interpreter 패턴 — JSON 스토리 스크립트 해석

StoryManager가 JSON 배열을 순차적으로 읽어 실행하는 **인터프리터** 역할.

```
_labels["Start"] = [            ← 프로그램 (명령 배열)
    "나레이션 텍스트",             ← String → 나레이션으로 해석
    {"cmd": "dialogue", ...},    ← Dictionary → _dispatch_command()
    {"cmd": "conditional", ...}, ← 조건 분기 (if-else)
    {"cmd": "jump", ...},        ← 라벨 점프 (goto)
]
```

**프로그래밍 언어 요소와의 대응**:

| JSON 명령 | 프로그래밍 개념 |
|-----------|---------------|
| `line_index++` / `advance()` | 프로그램 카운터 (PC) |
| `"jump"` | goto / 함수 호출 |
| `"conditional"` | if-else 분기 |
| `"choice"` | switch + 사용자 입력 대기 |
| `"set_var"` | 변수 할당 |
| `"wait"` / `"fade_jump"` | sleep / blocking call |
| `current_label` | 현재 실행 중인 함수명 |

### 2.8 Singleton 패턴 — Autoload 전역 매니저

Godot의 Autoload 시스템을 통해 4개 싱글톤이 전역 접근 가능.

```
project.godot [autoload] 섹션:
  StoryManager  → scripts/autoload/story_manager.gd
  GameManager   → scripts/autoload/game_manager.gd
  AudioManager  → scripts/autoload/audio_manager.gd
  DebugOverlay  → scripts/autoload/debug_overlay.gd
```

**책임 분리**:

| 싱글톤 | 담당 영역 | MainScene과의 관계 |
|--------|----------|-------------------|
| StoryManager | 스토리 데이터, 명령 실행, 라벨 관리 | 시그널 발행자 (16개 시그널) |
| GameManager | 게임 변수, 설정, 세이브/로드, 갤러리 | 상태 저장소 + 유틸리티 |
| AudioManager | BGM 크로스페이드, SFX 재생 | 음향 제어 위임 |
| DebugOverlay | 디버그 로그, FPS/입력 추적 | 로깅 전용 |

### 2.9 패턴 간 상호작용 다이어그램

```
사용자 클릭
    │
    ▼
[State Machine] ─── 현재 상태 확인 (typing? choice? distraction?)
    │
    ▼
[Observer] ─── StoryManager.advance() 호출
    │
    ▼
[Interpreter] ─── JSON 명령 읽기 (line_index++)
    │
    ▼
[Command] ─── _dispatch_command(cmd) → 명령 타입별 분기
    │
    ├──[Observer]──→ 시그널 발행 (dialogue_requested 등)
    │                    │
    │                    ▼
    │              [Mediator] ─── MainScene이 UI 노드들 조율
    │                    │
    │                    ▼
    │              [Strategy] ─── 트랜지션 방식 선택 (fadeIn, slideIn 등)
    │
    ├──[Singleton]──→ GameManager.set_var() / AudioManager.play_music()
    │
    └──[Interpreter]──→ jump(target) → 다른 라벨로 PC 이동
```

---

## 3. 씬 트리 구조 (main_scene.tscn)

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

## 4. 스크립트 기능별 상세 분석

### 5.1 초기화 (`_ready`)

```gdscript
func _ready() -> void:
    _apply_dialogue_box_style()    # 대화창 StyleBoxFlat 적용
    _connect_story_signals()       # StoryManager 시그널 16개 연결
    _connect_ui_signals()          # UI 버튼/타이머 시그널 연결
    _setup_http_nodes()            # Supabase 통계용 HTTPRequest 2개 생성
    _setup_mouse_passthrough()     # 배경/캐릭터/대화창 마우스 이벤트 통과 설정
```

**마우스 패스스루 전략**: 루트 Control과 배경/캐릭터 레이어를 `MOUSE_FILTER_IGNORE`로 설정하여, 클릭 이벤트가 `_unhandled_input()`까지 전파되도록 한다. 이렇게 하면 대화 진행 클릭이 UI 요소에 의해 소비되지 않는다.

### 5.2 입력 처리

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

### 5.3 텍스트 타이핑 시스템

```
텍스트 속도 = GameManager.settings["text_speed"] (ms/char)
duration = 글자수 × speed_ms / 1000.0
```

- **Tween 기반**: `visible_ratio`를 0→1로 애니메이션
- **스킵 모드**: duration = 0.05초 (거의 즉시)
- **타이핑 완료 후**: auto_mode면 타이머 시작, skip_mode면 0.05초 후 자동 진행

### 5.4 대화 처리 (3가지 모드)

| 모드 | 핸들러 | 이름 라벨 | 대화창 |
|------|--------|----------|--------|
| 캐릭터 대사 | `_on_dialogue()` | 표시 (캐릭터 색상) | 표시 |
| 나레이션 | `_on_narration()` | 숨김 | 표시 |
| 중앙 텍스트 | `_on_centered()` | - | 숨김, 중앙 라벨 페이드인 |

### 4.5 선택지 시스템

**버튼 동적 생성**:
- 기존 자식 노드 `queue_free()` 후 새로 생성
- 최소 크기: 500×60px
- 스타일: 반투명 다크 배경 + 핑크 보더 (호버 시 밝아짐)
- 폰트: 20px

**Supabase 통계 통합** (tracked_scenes 전용):
1. 선택지 표시 시 → `_fetch_preview_stats()` (기존 통계 조회)
2. 선택 클릭 시 → `_record_vote_and_show_stats()` (투표 + 결과 표시)
3. 2.5초 대기 후 → `_finalize_choice()` (스토리 진행)

### 4.6 배경 전환

| 전환 타입 | 동작 |
|----------|------|
| `"instant"` | bg1에 즉시 교체 |
| `"fadeIn"` / 기타 | bg2에 로드 → alpha 0→1 페이드 (1초) → bg1으로 복사 |
| `"#RRGGBB"` 색상 | TransitionRect.color로 단색 배경 처리 |

**더블 버퍼링**: bg1(현재) + bg2(다음)으로 크로스페이드 구현. 페이드 완료 후 bg2 → bg1 복사.

### 4.7 캐릭터 표시/숨김 애니메이션

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

### 4.8 페이드 전환

```gdscript
"to_black"  → TransitionRect alpha 0→1 (어두워짐)
"from_black" → TransitionRect alpha 1→0 (밝아짐)
```

Color 파라미터로 검은색 외 다른 색상 페이드도 지원.

### 4.9 호감도 알림

4가지 캐릭터별 설정:

| 키 | 아이콘 | 메시지 |
|----|--------|--------|
| `sora` | ✧ | "소라의 마음이 가까워진 것 같다." |
| `hana` | ✨ | "하나의 마음이 가까워진 것 같다." |
| `both` | ✧✨ | "소라와 하나의 마음이 가까워진 것 같다." |
| `unknown` | ? | "누군가의 존재가 느껴진다..." |

**표시 타이밍**: 1400ms 표시 → 400ms 페이드아웃 (총 1800ms)

### 5.10 Auto/Skip 모드

- **Auto**: 타이핑 완료 후 `auto_speed` 초 대기 → 자동 advance
- **Skip**: 타이핑 duration을 0.05초로 강제 → 타이핑 완료 후 0.05초 대기 → advance
- **상호 배타**: Auto 켜면 Skip 끔, Skip 켜면 Auto 끔

### 5.11 세이브/로드

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

### 5.12 대화창 스타일

코드에서 동적으로 생성하는 StyleBoxFlat:
- 배경: `rgba(20, 10, 30, 0.82)` (반투명 다크 퍼플)
- 보더: `rgba(244, 143, 177, 0.2)` (연한 핑크), 2px
- 라운드: 16px
- 패딩: 20px

---

## 5. 싱글톤 의존성

### 5.1 StoryManager (`scripts/autoload/story_manager.gd`)

**역할**: JSON 스토리 파싱, 명령 디스패치, 라벨 점프

MainScene이 연결하는 시그널 16개:
- `dialogue_requested`, `narration_requested`, `centered_requested`
- `choice_requested`, `scene_change_requested`
- `character_show_requested`, `character_hide_requested`, `character_sprite_changed`
- `fade_requested`, `wait_requested`, `input_requested`
- `affinity_hint_requested`, `gallery_unlock_requested`
- `distraction_free_toggled`, `end_requested`

핵심 호출: `start()`, `advance()`, `on_choice_selected()`, `on_input_completed()`

### 5.2 GameManager (`scripts/autoload/game_manager.gd`)

**역할**: 게임 상태, 설정, 세이브/로드

사용하는 API:
- `settings["text_speed"]` / `settings["auto_speed"]` — 텍스트/자동 진행 속도
- `replace_templates()` — `{{player.name}}` 치환
- `save_game()` / `load_game()` — 세이브 슬롯
- `unlock_gallery()` — 갤러리 해금

### 5.3 AudioManager (`scripts/autoload/audio_manager.gd`)

**역할**: BGM 크로스페이드, 효과음 재생

사용하는 API:
- `play_ui_click()` — advance/선택 시 클릭음
- `play_music()` — 로드 시 BGM 복원
- `get_current_bgm()` — 세이브 시 현재 BGM 저장

### 5.4 DebugOverlay (`scripts/autoload/debug_overlay.gd`)

**역할**: 디버그 로그 (F3 토글)

사용: `log_message()` — 대사/씬변경/캐릭터/선택지/입력 등 이벤트 로깅

---

## 6. 상태 변수 정리

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

## 7. 개선 가능 포인트

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
