# main_scene.gd / main_scene.tscn 분석 리포트

---

## 1. 아키텍처 개요

```
[StoryManager (Autoload)]
        | signals
        v
[main_scene.gd (View Controller / Coordinator)]
        | reads
        v
[GameManager (Autoload)] <-> [AudioManager (Autoload)]
```

Observer 패턴 기반으로 StoryManager의 시그널을 구독하는 Mediator 역할.
스토리 로직과 프레젠테이션이 분리되어 있어 구조적으로 건전함.

각 레이어별 컨트롤러가 StoryManager 시그널을 직접 구독하는 구조로 리팩토링 완료.

```
[StoryManager (Autoload)]
        | signals
        +---> [character_controller.gd (CharacterLayer)]  ✅ 분리 완료
        |       character_show/hide/sprite_changed
        +---> [background_controller.gd (BackgroundLayer)] ✅ 분리 완료
        |       scene_change_requested
        +---> [overlay_controller.gd (OverlayLayer)]       ✅ 분리 완료
        |       fade/wait/input/affinity_hint_requested
        +---> [dialogue_controller.gd (DialogueLayer)]     ✅ 분리 완료
        |       dialogue/narration/centered
        +---> [main_scene.gd (Coordinator)]
                choice/gallery/distraction_free/end
```

---

## 2. 씬 트리 구조 (main_scene.tscn)

```
MainScene (Control, script=main_scene.gd) -- 루트, 전체 화면
+-- BackgroundLayer (Control, script=background_controller.gd) ✅
|   +-- Background1 (TextureRect) -- 현재 배경
|   +-- Background2 (TextureRect) -- 전환용 배경 (alpha=0)
+-- CharacterLayer (Control, script=character_controller.gd) ✅
|   +-- LeftSlot (TextureRect)    -- 왼쪽 캐릭터 (alpha=0)
|   +-- CenterSlot (TextureRect)  -- 중앙 캐릭터 (alpha=0)
|   +-- RightSlot (TextureRect)   -- 오른쪽 캐릭터 (alpha=0)
+-- UILayer (CanvasLayer, layer=10)
|   +-- DialogueLayer (Control, script=dialogue_controller.gd) ✅
|   |   +-- DialogueBox (PanelContainer) -- 하단 70%~100% 영역
|   |   |   +-- MarginContainer
|   |   |       +-- VBoxContainer
|   |   |           +-- NameLabel (Label, 24px)
|   |   |           +-- TextLabel (RichTextLabel, 22px, bbcode)
|   |   +-- CenteredText (Label, 32px)  -- 화면 중앙, 숨김 상태
|   +-- ChoicePanel (VBoxContainer) -- 화면 중앙, 숨김 상태
|   +-- QuickMenu (HBoxContainer)   -- 우상단
|       +-- SaveBtn / LoadBtn / AutoBtn(toggle) / SkipBtn(toggle) / LogBtn / SettingsBtn
+-- OverlayLayer (CanvasLayer, layer=20, script=overlay_controller.gd) ✅
|   +-- TransitionRect (ColorRect)  -- 페이드 전환용 (투명)
|   +-- AffinityHint (PanelContainer) -- 거리감 알림 (숨김)
|   |   +-- HBoxContainer -> Icon(Label) + Text(Label)
|   +-- InputDialog (PanelContainer)  -- 이름 입력 (숨김)
|       +-- VBoxContainer -> PromptLabel + InputField + WarningLabel + ConfirmBtn
+-- AutoTimer (Timer, 5초, one_shot)
```

### 레이어 순서

1. **BackgroundLayer** -- 배경 이미지 (가장 뒤)
2. **CharacterLayer** -- 캐릭터 스프라이트
3. **UILayer (layer=10)** -- 대화창, 선택지, 퀵메뉴
4. **OverlayLayer (layer=20)** -- 전환 효과, 알림, 입력 다이얼로그 (가장 앞)

---

## 3. 핵심 상태 변수

### main_scene.gd (455줄, 조율자)

| 변수 | 타입 | 용도 |
|------|------|------|
| `_auto_mode` | bool | 자동 진행 모드 |
| `_skip_mode` | bool | 스킵 모드 |
| `_distraction_free` | bool | UI 숨김 모드 |
| `_advance_timer` | SceneTreeTimer | 취소 가능한 자동 진행 타이머 참조 |
| `_supabase_url` | String | Supabase 통계 URL (빈 문자열이면 비활성) |
| `_stats_http` | HTTPRequest | 통계 조회용 HTTP |
| `_vote_http` | HTTPRequest | 투표 기록용 HTTP |
| `_pending_choice_data` | Dictionary | 비동기 투표 중 임시 선택 데이터 |

#### 모달 상태 변수

| 변수 | 타입 | 용도 |
|------|------|------|
| `ModalType` | enum | `NONE`, `SETTINGS`, `SAVE_LOAD` — 현재 열린 모달 유형 |
| `_active_modal` | ModalType | 현재 활성 모달 (NONE이면 모달 없음) |
| `_auto_before_modal` | bool | 모달 열기 전 auto 모드 상태 (복원용) |
| `_skip_before_modal` | bool | 모달 열기 전 skip 모드 상태 (복원용) |
| `_modal_layer` | CanvasLayer | 모달 UI를 담는 CanvasLayer (layer=25) |

| @onready 참조 | 타입 | 용도 |
|----------------|------|------|
| `choice_panel` | VBoxContainer | 선택지 패널 |
| `quick_menu` | HBoxContainer | 퀵메뉴 |
| `auto_timer` | Timer | 자동 진행 타이머 |
| `dialogue_layer` | Control | DialogueLayer 참조 (dialogue_controller.gd) |

| Public API | 반환 타입 | 용도 |
|------------|-----------|------|
| `start_story(label)` | void | 새 게임 시작 (기본 라벨: "Start") |
| `get_dialogue_log()` | Array[Dictionary] | 대화 이력 반환 (dialogue_layer 위임) |

### dialogue_controller.gd (130줄)

| 시그널 | 용도 |
|--------|------|
| `typing_finished` | 타이핑 완료 시 발신 (auto/skip 모드 연동용) |

| 변수 | 타입 | 용도 |
|------|------|------|
| `_typing` | bool | 타이핑 애니메이션 진행 중 여부 |
| `_typing_tween` | Tween | 현재 타이핑 트윈 참조 |
| `_dialogue_log` | Array[Dictionary] | 대화 이력 |

| @onready 참조 | 타입 | 용도 |
|----------------|------|------|
| `dialogue_box` | PanelContainer | 대화창 패널 |
| `name_label` | Label | 화자 이름 |
| `text_label` | RichTextLabel | 대사 텍스트 |
| `centered_text` | Label | 중앙 텍스트 |

### character_controller.gd (199줄)

| 변수 | 타입 | 용도 |
|------|------|------|
| `_character_slots` | Dictionary | `{char_id: "left"/"center"/"right"}` 매핑 |
| `_active_tweens` | Dictionary | `{position_name: Tween}` 실행 중 트윈 추적 (충돌 방지) |
| `_initial_offsets` | Dictionary | `{position_name: offset_values}` 슬롯별 초기 오프셋 저장 |

| @onready 참조 | 타입 | 용도 |
|----------------|------|------|
| `left_slot` | TextureRect | 왼쪽 캐릭터 슬롯 |
| `center_slot` | TextureRect | 중앙 캐릭터 슬롯 |
| `right_slot` | TextureRect | 오른쪽 캐릭터 슬롯 |

| Public API | 반환 타입 | 용도 |
|------------|-----------|------|
| `get_state()` | Dictionary | 캐릭터 슬롯 매핑 복제본 반환 |
| `restore_state(state)` | void | 세이브 데이터로부터 캐릭터 위치 복원 |
| `clear_all()` | void | 모든 캐릭터 제거 및 슬롯 초기화 |

### background_controller.gd (69줄)

| 변수 | 타입 | 용도 |
|------|------|------|
| `_current_bg_id` | String | 현재 배경 ID (세이브용) |
| `_bg_tween` | Tween | 배경 크로스페이드 트윈 추적 (충돌 방지용) |

### overlay_controller.gd (98줄)

| 변수 | 타입 | 용도 |
|------|------|------|
| `_default_name` | String | 입력 다이얼로그 기본 이름 |
| `_affinity_config` | Dictionary | 거리감 알림 설정 (하드코딩) |

| @onready 참조 | 타입 | 용도 |
|----------------|------|------|
| `transition_rect` | ColorRect | 페이드 전환용 |
| `affinity_hint` | PanelContainer | 거리감 알림 패널 |
| `affinity_icon` | Label | 거리감 아이콘 |
| `affinity_text` | Label | 거리감 텍스트 |
| `input_dialog` | PanelContainer | 이름 입력 다이얼로그 |
| `input_prompt` | Label | 입력 프롬프트 |
| `input_field` | LineEdit | 입력 필드 |
| `input_warning` | Label | 경고 메시지 |
| `input_confirm_btn` | Button | 확인 버튼 |

---

## 4. 입력 처리 흐름

```
vn_advance 액션 입력 (_unhandled_input) [main_scene.gd]
  +-- _active_modal != ModalType.NONE -> 무시 (모달 열린 상태)
  +-- $OverlayLayer.is_input_active() -> 무시
  +-- play_ui_click() (항상 재생)
  +-- distraction_free 모드 -> UI 복원, return
  +-- CenteredText 표시 중 -> 숨기고 advance(), return  [dialogue_layer 위임]
  +-- 타이핑 중 -> 즉시 완료 (dialogue_layer.complete_typing), return
  +-- 선택지 표시 중 -> 무시, return
  +-- 그 외 -> StoryManager.advance()
```

---

## 5. 시그널 연결 매핑

### main_scene.gd (직접 구독)

| StoryManager 시그널 | 핸들러 | 동작 |
|---------------------|--------|------|
| `choice_requested` | `_on_choice` | 선택지 버튼 동적 생성 |
| `gallery_unlock_requested` | `_on_gallery_unlock` | 갤러리 해금 |
| `distraction_free_toggled` | `_on_distraction_free` | UI 토글 |
| `end_requested` | `_on_end` | 타이틀 화면으로 복귀 |

| 내부 시그널 | 핸들러 | 동작 |
|-------------|--------|------|
| `dialogue_layer.typing_finished` | `_on_typing_finished` | auto/skip 모드 자동 진행 |
| `auto_timer.timeout` | `_on_auto_timeout` | auto 모드 대기 후 advance |

### dialogue_controller.gd (DialogueLayer에서 직접 구독)

| StoryManager 시그널 | 핸들러 | 동작 |
|---------------------|--------|------|
| `dialogue_requested` | `_on_dialogue` | 이름+텍스트 표시, 타이핑 애니메이션 |
| `narration_requested` | `_on_narration` | 이름 숨김, 텍스트만 타이핑 |
| `centered_requested` | `_on_centered` | 대화창 숨김, 중앙 텍스트 페이드인 |

### background_controller.gd (BackgroundLayer에서 직접 구독)

| StoryManager 시그널 | 핸들러 | 동작 |
|---------------------|--------|------|
| `scene_change_requested` | `_on_scene_change` | 배경 교체 (크로스페이드/즉시) |

### overlay_controller.gd (OverlayLayer에서 직접 구독)

| StoryManager 시그널 | 핸들러 | 동작 |
|---------------------|--------|------|
| `fade_requested` | `_on_fade` | 화면 페이드 인/아웃 |
| `wait_requested` | `_on_wait` | 대기 (StoryManager이 타이머 처리) |
| `input_requested` | `_on_input_request` | 이름 입력 다이얼로그 |
| `affinity_hint_requested` | `_on_affinity_hint` | 거리감 변화 알림 (1.8초) |

### character_controller.gd (CharacterLayer에서 직접 구독)

| StoryManager 시그널 | 핸들러 | 동작 |
|---------------------|--------|------|
| `character_show_requested` | `_on_show` | 캐릭터 슬롯에 스프라이트 표시 |
| `character_hide_requested` | `_on_hide` | 캐릭터 페이드아웃 |
| `character_sprite_changed` | `_on_sprite_change` | 표정 교체 |

---

## 6. 주요 기능 상세

### 6.1 타이핑 시스템 (dialogue_controller.gd)

- `visible_ratio`를 0->1로 트윈하여 글자 출력 효과
- 속도: `GameManager.settings["text_speed"]` (ms/글자)
- `start_typing_fast()`: 스킵 모드용 가속 (0.05초로 단축)
- 완료 시 `typing_finished` 시그널 발신 → main_scene.gd에서 auto/skip 처리
- `complete_typing()`: 트윈 kill 후 `_on_typing_done()` 수동 호출
- Public API: `is_typing()`, `complete_typing()`, `is_centered_visible()`, `hide_centered()`
- Public API: `show_dialogue_box()`, `hide_dialogue_box()`, `show_choice_dialog()`, `show_raw_text()`
- Public API: `get_dialogue_log()`

### 6.2 배경 전환 (background_controller.gd)

- `#000000` 형태 -> 단색 배경 + `$"../OverlayLayer".clear_transition()`
- `"instant"` -> bg1에 즉시 교체
- 그 외 -> bg2에 로드 후 1초 크로스페이드, 완료 시 bg1으로 swap
- Public API: `get_current_bg_id()`, `restore_background(id)`

### 6.3 캐릭터 애니메이션 (character_controller.gd)

- `_active_tweens` 딕셔너리로 슬롯별 트윈 추적, 새 트윈 시작 시 기존 트윈 kill
- `_initial_offsets` 딕셔너리로 슬롯별 초기 오프셋 저장, 전환 후 복원
- `_prepare_slot()`에서 트윈 정리 + 오프셋/스케일 리셋 후 새 전환 시작
- 슬라이드 전환: `EASE_OUT` + `TRANS_CUBIC` 이징
- 바운스 전환: `EASE_OUT` + `TRANS_BACK` 이징
- 퇴장 전환 완료 시 클로저 함수로 오프셋 복원

| 전환 타입 | 등장 효과 |
|-----------|-----------|
| `fadeIn` | 단순 알파 페이드 (0.5초) |
| `fadeInUp` | 아래에서 위로 30px + 페이드 |
| `slideInLeft` | 왼쪽에서 200px 슬라이드 |
| `slideInRight` | 오른쪽에서 200px 슬라이드 |
| `bounceIn` | 스케일 0.8->1.0 바운스 + 페이드 |

| 전환 타입 | 퇴장 효과 |
|-----------|-----------|
| `fadeOut` | 단순 알파 페이드아웃 (0.5초) |
| `fadeOutLeft` | 왼쪽으로 100px + 페이드아웃 |
| `fadeOutRight` | 오른쪽으로 100px + 페이드아웃 |

### 6.4 선택지 시스템 (main_scene.gd — choice_controller로 분리 예정)

- `dialog` 문자열 파싱: `"캐릭터ID 대사텍스트"` 형태 (공백 split)
- 버튼 동적 생성 + 인라인 스타일 적용
- Supabase 연동 시 선택 통계 수집/표시 (URL 미설정 시 비활성)
- 선택 완료 -> `StoryManager.on_choice_selected(key, target)`

### 6.5 마우스 패스스루 설계 (main_scene.gd)

`_setup_mouse_passthrough()`에서 BackgroundLayer, CharacterLayer, DialogueBox 등을
`MOUSE_FILTER_IGNORE`로 설정하여 클릭이 `_unhandled_input`까지 도달하도록 함.
화면 아무 곳이나 클릭해서 텍스트 진행 가능.

### 6.6 세이브/로드 (main_scene.gd + save_load_screen.gd)

- **모달 오버레이 방식**: 퀵메뉴 Save/Load 버튼 클릭 시 `save_load_screen.tscn`을 CanvasLayer(25)에 모달로 표시
- **슬롯**: 1~10번 사용 (0번 퀵세이브 전용은 제거됨)
- **세이브 데이터 수집**: `save_load_screen.gd`에서 main_scene 노드를 직접 참조하여 수집
  - 배경 상태: `main_scene.get_node("BackgroundLayer").get_current_bg_id()`
  - 캐릭터 상태: `main_scene.get_node("CharacterLayer").get_state()`
  - BGM: `AudioManager.get_current_bgm()`
  - 스토리 위치: `StoryManager.get_save_data()`
- **로드 (오버레이 모드)**: `main_scene._restore_state(data)` 호출
- **로드 (타이틀에서)**: `main_scene.tscn` 인스턴스화 후 `_restore_state()` 호출
- `_restore_state()`: 배경/BGM/캐릭터 복원 후 `StoryManager.advance()` 호출

### 6.7 오버레이 기능 (overlay_controller.gd)

- **페이드 전환**: `_on_fade()` — to_black / from_black 트윈 애니메이션
- **입력 다이얼로그**: `_on_input_request()` / `_on_input_confirm()` — 이름 입력 UI
- **거리감 알림**: `_on_affinity_hint()` — 1.4초 표시 + 0.4초 페이드아웃
- Public API: `is_input_active()`, `clear_transition()`

### 6.8 외부 진입점

| 함수 | 호출처 | 용도 |
|------|--------|------|
| `start_story(label)` | `title_screen.gd:54` | 새 게임 시작 |
| `_restore_state(data)` | `title_screen.gd:64` | 이어하기 |

---

## 7. 코드 품질 평가

### 7.1 잘 된 점

| 항목 | 설명 |
|------|------|
| 시그널 기반 분리 | StoryManager <-> View 간 결합도가 낮음 |
| 컨트롤러 분리 패턴 | 각 레이어별 독립 스크립트로 관심사 분리 진행 중 |
| `_unhandled_input` 활용 | UI 입력 우선순위가 자연스럽게 처리됨 |
| private 함수 네이밍 | `_` prefix 관례 준수, 의도가 명확 |
| 타입 힌트 | 대부분의 변수와 매개변수에 타입 명시 |
| 트윈 활용 | Godot 4 Tween API를 적절히 사용 |
| 초기화 구조 | `_ready()`에서 역할별 private 함수로 분리 |

### 7.2 발견된 문제점

#### ~~[높음] God Object~~ 개선 중 (670줄 → 573줄 → 440줄 → 351줄 → 455줄 (모달 시스템 추가로 증가))

**위치**: main_scene.gd 전체

컨트롤러 분리로 지속적으로 개선 중:
- ~~캐릭터 관리~~ → `character_controller.gd` ✅ 분리 완료
- ~~배경 전환~~ → `background_controller.gd` ✅ 분리 완료
- ~~페이드/입력/거리감~~ → `overlay_controller.gd` ✅ 분리 완료
- ~~대화창/타이핑~~ → `dialogue_controller.gd` ✅ 분리 완료
- 선택지 + Supabase → `choice_controller.gd` 분리 예정

#### ~~[높음] 캐릭터 상태 로드 미복원 (버그)~~ ✅ 수정 완료

저장된 `characters` Dictionary를 순회하며 `StoryManager.get_current_character_sprite()`로
현재 스프라이트를 조회하고, 각 슬롯에 텍스처와 알파를 복원하도록 수정됨.

#### ~~[높음] 연속 배경 전환 시 트윈 충돌 가능~~ ✅ 수정 완료

`_bg_tween` 인스턴스 변수를 추가하여 크로스페이드 트윈을 추적.
새 전환 시작 시 이전 트윈이 실행 중이면 `kill()` 후 즉시 swap 처리하여 충돌 방지.
(현재 `background_controller.gd`에서 관리)

#### [중간] Supabase 코드가 뷰에 존재 (SRP 위반)

**위치**: main_scene.gd line 232~303 (약 70줄)

HTTP 통신, JSON 파싱, 통계 표시 로직이 뷰 컨트롤러에 직접 존재.
`choice_controller.gd` 분리 시 함께 이동 예정.

#### [중간] `_display_stats_preview` 미구현

**위치**: main_scene.gd `_display_stats_preview()`

빈 for 루프. 통계 프리뷰 표시 기능이 구현되지 않은 상태.

#### ~~[중간] await 후 씬 유효성 미검증~~ ✅ 수정 완료

`_auto_advance_delayed()`에 `_advance_timer` 참조 패턴과 `is_inside_tree()` 체크를 추가하여
취소 가능한 타이머로 교체. orphan coroutine과 다중 advance() 호출 문제 모두 해결.

#### [낮음] 선택지 표시 중에도 클릭음 재생

**위치**: main_scene.gd `_handle_advance_input()`

`AudioManager.play_ui_click()`이 choice_panel 가시성 체크 전에 호출됨.
선택지 표시 중 빈 공간 클릭 시 불필요한 클릭음이 재생됨.

#### ~~[낮음] 불필요한 람다 래핑~~ ✅ 수정 완료

직접 메서드 참조로 교체됨 (`_quick_save`, `_quick_load`, `_open_settings` 등).

#### [낮음] 레거시 match 패턴 dead code

**위치**: background_controller.gd `_on_scene_change()`

```gdscript
"fadeIn", "fadeFromBlack duration 1500", _:
```

`"fadeFromBlack duration 1500"`은 와일드카드 `_`와 같은 분기이므로 실질적 dead code.

#### ~~[낮음] 같은 position에 두 캐릭터 배치 시 ghost 상태~~ ✅ 수정 완료

**위치**: character_controller.gd `_on_show()`

같은 position에 새 캐릭터가 배치되면 이전 캐릭터의 `_character_slots` 항목을
자동으로 삭제하도록 수정됨. `_active_tweens` 딕셔너리로 트윈 충돌도 방지.

#### ~~[낮음] `queue_free` vs `free`~~ ✅ 수정 완료

`child.free()` 사용으로 수정됨. 즉시 해제되어 한 프레임 동안 기존+신규 버튼이 공존하는 문제 해결.

---

## 8. 퀵세이브 / 스킵 / 자동재생 분석

### 8.1 퀵세이브 문제점

#### [높음] 캐릭터 스프라이트 상태 유실

**위치**: main_scene.gd `_quick_save()` / `_restore_state()`

`_character_slots`에는 `{char_id: "left"/"center"/"right"}` 매핑만 저장되고,
현재 표시 중인 **스프라이트 ID**(표정 등)가 포함되지 않음.
로드 시 `StoryManager.get_current_character_sprite()`로 조회하지만,
StoryManager 자체가 스프라이트 상태를 추적하지 않으면 항상 `"normal"`로 복원됨.

```gdscript
# 현재: 슬롯 위치만 저장
"characters": $CharacterLayer.get_state()  # {char_id: slot_name}

# 필요: 스프라이트 정보도 함께 저장
# {char_id: {"slot": "left", "sprite": "happy"}}
```

#### [중간] 현재 대사 미저장

퀵세이브 시점의 대사 텍스트, 화자 이름이 저장되지 않음.
로드 후 `StoryManager.advance()`를 호출하여 **다음 대사**부터 표시되므로,
세이브 시점의 대사가 스킵됨.

### 8.2 스킵 문제점

#### [높음] 스킵 불가 명령어 존재

| 명령어 | 문제 | 원인 |
|--------|------|------|
| `fade_scene` | 스킵 무시, 강제 대기 | `await` 기반 트윈 완료 대기 |
| `fade_jump` | 스킵 무시, 강제 대기 | 페이드아웃 → 점프 → 페이드인 순차 `await` |
| `wait` | 스킵 무시, 강제 대기 | `StoryManager`에서 타이머 `await` |

스킵 모드에서도 이들 명령어를 만나면 전체 트랜지션 시간(0.5~1.5초)을
강제로 대기해야 함. 다른 비주얼 노벨 엔진에서는 스킵 모드 시
트랜지션을 즉시 완료(duration=0)하는 것이 일반적.

#### [중간] centered 텍스트 스킵 미연동

`_on_centered()`에서 페이드인 후 사용자 입력을 기다리지만,
스킵 모드에서 자동으로 넘어가는 로직이 없음.
스킵 모드에서도 수동 클릭이 필요함.

### 8.3 자동재생 문제점

#### [중간] centered 텍스트에서 자동재생 안 됨

`_on_centered()`는 대화창을 숨기고 중앙 텍스트를 표시하지만,
타이핑 완료 콜백(`_on_typing_done`)을 거치지 않으므로
AutoTimer가 시작되지 않음. 자동재생 모드에서도 수동 클릭 필요.

#### [중간] `_auto_advance_after`와 AutoTimer 동시 진행 가능

`_auto_advance_after(delay)`는 독립적인 `create_timer`를 사용하고,
`_on_typing_done()`에서 시작하는 AutoTimer와 별개로 동작함.
두 타이머가 동시에 진행되면 `advance()`가 이중 호출될 수 있음.

### 8.4 자동재생/스킵 모달 가드

`_on_auto_timeout()`과 `_auto_advance_delayed()`에 `_active_modal != ModalType.NONE` 체크가 추가됨.
모달이 열린 상태에서는 자동 진행이 발생하지 않도록 방어.

모달 열기/닫기 시:
- `_pause_auto_skip()`: auto_timer 정지, `_advance_timer` 무효화, 이전 auto/skip 상태 저장
- `_resume_auto_skip()`: 모달 닫힐 때 이전 auto/skip 상태 복원

관련 함수: `_open_settings()`, `_open_save_load()`, `_on_modal_closed()`, `_pause_auto_skip()`, `_resume_auto_skip()`, `_set_quick_menu_disabled()`

### ~~8.5 `_auto_advance_after` 구조적 문제~~ ✅ 수정 완료

`_advance_timer` 인스턴스 변수를 추가하여 취소 가능한 타이머 패턴으로 교체.
`current == _advance_timer` 비교로 이전 코루틴 무효화, `is_inside_tree()` 체크로 orphan 방지.

### 8.6 개선 방향 요약

| 우선순위 | 항목 | 예상 작업량 |
|----------|------|-------------|
| ~~1~~ | ~~`_auto_advance_after` 취소 가능 타이머로 교체~~ | ✅ 완료 |
| 2 | 스킵 모드 시 트랜지션 즉시 완료 | 중 |
| 3 | centered 텍스트 스킵/자동재생 연동 | 소 |
| 4 | 퀵세이브에 스프라이트 ID 포함 | 중 |
| 5 | 퀵세이브에 현재 대사 포함 | 중 |

---

## 9. 권장 리팩토링 방향

### 현재 구조

```
main_scene.gd              (455줄, 조율자 + 선택지/세이브/모달)
dialogue_controller.gd     (130줄, DialogueLayer 스크립트)    ✅ 분리 완료
character_controller.gd    (199줄, CharacterLayer 스크립트)   ✅ 분리 완료
background_controller.gd   (69줄, BackgroundLayer 스크립트)   ✅ 분리 완료
overlay_controller.gd      (98줄, OverlayLayer 스크립트)      ✅ 분리 완료
```

### 권장 분리 구조 (남은 작업)

```
choice_controller.gd       -- 선택지 UI, Supabase 통계 연동
```

분리 완료 시 main_scene.gd는 ~200줄 (초기화, 입력, auto/skip, 세이브/로드 조율만) 예상.
모든 컨트롤러는 `scenes/controller/` 디렉토리에 위치.

---

## 10. 우선순위별 액션 아이템

| 우선순위 | 항목 | 예상 작업량 |
|----------|------|-------------|
| ~~1~~ | ~~캐릭터 상태 로드 복원 버그 수정~~ | ✅ 완료 |
| ~~2~~ | ~~배경 전환 트윈 충돌 방지~~ | ✅ 완료 |
| ~~3~~ | ~~캐릭터 컨트롤러 분리~~ | ✅ 완료 |
| ~~4~~ | ~~배경 컨트롤러 분리~~ | ✅ 완료 |
| ~~5~~ | ~~오버레이 컨트롤러 분리~~ | ✅ 완료 |
| 6 | 선택지 컨트롤러 분리 (choice_controller.gd) | 중 |
| ~~7~~ | ~~대화 컨트롤러 분리 (dialogue_controller.gd)~~ | ✅ 완료 |
| ~~8~~ | ~~`_auto_advance_after` 취소 가능 타이머로 교체~~ | ✅ 완료 |
| ~~9~~ | ~~await 후 is_inside_tree() 체크 추가~~ | ✅ 완료 |
| 10 | 선택지 중 클릭음 재생 조건 수정 | 소 |
| 11 | 스킵 모드 시 트랜지션 즉시 완료 | 중 |
| 12 | centered 텍스트 스킵/자동재생 연동 | 소 |
| 13 | 퀵세이브에 스프라이트 ID 및 현재 대사 포함 | 중 |
| 14 | Supabase 미구현 코드 정리 (`_display_stats_preview`) | 소 |
