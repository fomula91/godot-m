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

각 레이어별 컨트롤러가 StoryManager 시그널을 직접 구독하는 구조로 리팩토링 진행 중.

```
[StoryManager (Autoload)]
        | signals
        +---> [character_controller.gd (CharacterLayer)]  ✅ 분리 완료
        |       character_show/hide/sprite_changed
        +---> [background_controller.gd (BackgroundLayer)] ✅ 분리 완료
        |       scene_change_requested
        +---> [overlay_controller.gd (OverlayLayer)]       ✅ 분리 완료
        |       fade/wait/input/affinity_hint_requested
        +---> [main_scene.gd (Coordinator)]
                dialogue/narration/centered/choice/gallery/distraction_free/end
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
|   +-- DialogueBox (PanelContainer) -- 하단 70%~100% 영역
|   |   +-- MarginContainer
|   |       +-- VBoxContainer
|   |           +-- NameLabel (Label, 24px)
|   |           +-- TextLabel (RichTextLabel, 22px, bbcode)
|   +-- ChoicePanel (VBoxContainer) -- 화면 중앙, 숨김 상태
|   +-- CenteredText (Label, 32px)  -- 화면 중앙, 숨김 상태
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

### main_scene.gd (440줄, 조율자)

| 변수 | 타입 | 용도 |
|------|------|------|
| `_typing` | bool | 타이핑 애니메이션 진행 중 여부 |
| `_typing_tween` | Tween | 현재 타이핑 트윈 참조 |
| `_auto_mode` | bool | 자동 진행 모드 |
| `_skip_mode` | bool | 스킵 모드 |
| `_distraction_free` | bool | UI 숨김 모드 |
| `_dialogue_log` | Array[Dictionary] | 대화 이력 |
| `_supabase_url` | String | Supabase 통계 URL (빈 문자열이면 비활성) |
| `_stats_http` | HTTPRequest | 통계 조회용 HTTP |
| `_vote_http` | HTTPRequest | 투표 기록용 HTTP |
| `_pending_choice_data` | Dictionary | 비동기 투표 중 임시 선택 데이터 |

### character_controller.gd (139줄)

| 변수 | 타입 | 용도 |
|------|------|------|
| `_character_slots` | Dictionary | `{char_id: "left"/"center"/"right"}` 매핑 |

### background_controller.gd (70줄)

| 변수 | 타입 | 용도 |
|------|------|------|
| `_current_bg_id` | String | 현재 배경 ID (세이브용) |
| `_bg_tween` | Tween | 배경 크로스페이드 트윈 추적 (충돌 방지용) |

### overlay_controller.gd (99줄)

| 변수 | 타입 | 용도 |
|------|------|------|
| `_default_name` | String | 입력 다이얼로그 기본 이름 |
| `_affinity_config` | Dictionary | 거리감 알림 설정 (하드코딩) |

---

## 4. 입력 처리 흐름

```
vn_advance 액션 입력 (_unhandled_input) [main_scene.gd]
  +-- $OverlayLayer.is_input_active() -> 무시
  +-- play_ui_click() (항상 재생)
  +-- distraction_free 모드 -> UI 복원, return
  +-- CenteredText 표시 중 -> 숨기고 advance(), return
  +-- 타이핑 중 -> 즉시 완료 (_complete_typing), return
  +-- 선택지 표시 중 -> 무시, return
  +-- 그 외 -> StoryManager.advance()
```

---

## 5. 시그널 연결 매핑

### main_scene.gd (직접 구독)

| StoryManager 시그널 | 핸들러 | 동작 |
|---------------------|--------|------|
| `dialogue_requested` | `_on_dialogue` | 이름+텍스트 표시, 타이핑 애니메이션 |
| `narration_requested` | `_on_narration` | 이름 숨김, 텍스트만 타이핑 |
| `centered_requested` | `_on_centered` | 대화창 숨김, 중앙 텍스트 페이드인 |
| `choice_requested` | `_on_choice` | 선택지 버튼 동적 생성 |
| `gallery_unlock_requested` | `_on_gallery_unlock` | 갤러리 해금 |
| `distraction_free_toggled` | `_on_distraction_free` | UI 토글 |
| `end_requested` | `_on_end` | 타이틀 화면으로 복귀 |

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

### 6.1 타이핑 시스템 (main_scene.gd)

- `visible_ratio`를 0->1로 트윈하여 글자 출력 효과
- 속도: `GameManager.settings["text_speed"]` (ms/글자)
- 스킵 모드일 때 0.05초로 단축
- 완료 후 auto_mode면 AutoTimer 시작, skip_mode면 0.05초 후 자동 진행
- `_complete_typing()`은 트윈을 kill하고 `_on_typing_done()`을 수동 호출

### 6.2 배경 전환 (background_controller.gd)

- `#000000` 형태 -> 단색 배경 + `$"../OverlayLayer".clear_transition()`
- `"instant"` -> bg1에 즉시 교체
- 그 외 -> bg2에 로드 후 1초 크로스페이드, 완료 시 bg1으로 swap
- Public API: `get_current_bg_id()`, `restore_background(id)`

### 6.3 캐릭터 애니메이션 (character_controller.gd)

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

### 6.6 세이브/로드 (main_scene.gd)

- 퀵세이브 (slot 0): 현재 배경, BGM, 캐릭터 슬롯, 스토리 위치 저장
  - 배경 상태: `$BackgroundLayer.get_current_bg_id()`로 조회
  - 캐릭터 상태: `$CharacterLayer.get_state()`로 조회
- 퀵로드 (slot 0): 상태 복원 후 `StoryManager.advance()` 호출
  - 배경 복원: `$BackgroundLayer.restore_background(id)`
  - 캐릭터 복원: `$CharacterLayer.restore_state()`

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

#### ~~[높음] God Object~~ 개선 중 (670줄 → 573줄 → 440줄)

**위치**: main_scene.gd 전체

컨트롤러 분리로 지속적으로 개선 중:
- ~~캐릭터 관리~~ → `character_controller.gd` ✅ 분리 완료
- ~~배경 전환~~ → `background_controller.gd` ✅ 분리 완료
- ~~페이드/입력/거리감~~ → `overlay_controller.gd` ✅ 분리 완료
- 선택지 + Supabase → `choice_controller.gd` 분리 예정
- 대화창/타이핑 → `dialogue_controller.gd` 분리 예정

#### ~~[높음] 캐릭터 상태 로드 미복원 (버그)~~ ✅ 수정 완료

저장된 `characters` Dictionary를 순회하며 `StoryManager.get_current_character_sprite()`로
현재 스프라이트를 조회하고, 각 슬롯에 텍스처와 알파를 복원하도록 수정됨.

#### ~~[높음] 연속 배경 전환 시 트윈 충돌 가능~~ ✅ 수정 완료

`_bg_tween` 인스턴스 변수를 추가하여 크로스페이드 트윈을 추적.
새 전환 시작 시 이전 트윈이 실행 중이면 `kill()` 후 즉시 swap 처리하여 충돌 방지.
(현재 `background_controller.gd`에서 관리)

#### [중간] Supabase 코드가 뷰에 존재 (SRP 위반)

**위치**: main_scene.gd line 290~361 (약 70줄)

HTTP 통신, JSON 파싱, 통계 표시 로직이 뷰 컨트롤러에 직접 존재.
`choice_controller.gd` 분리 시 함께 이동 예정.

#### [중간] `_display_stats_preview` 미구현

**위치**: main_scene.gd `_display_stats_preview()`

빈 for 루프. 통계 프리뷰 표시 기능이 구현되지 않은 상태.

#### [중간] await 후 씬 유효성 미검증

**위치**: main_scene.gd `_auto_advance_delayed()`

`await get_tree().create_timer(delay).timeout` 중에 씬 전환이 발생하면
orphan coroutine이 됨. `is_inside_tree()` 체크가 필요함.

#### [낮음] 선택지 표시 중에도 클릭음 재생

**위치**: main_scene.gd `_handle_advance_input()`

`AudioManager.play_ui_click()`이 choice_panel 가시성 체크 전에 호출됨.
선택지 표시 중 빈 공간 클릭 시 불필요한 클릭음이 재생됨.

#### [낮음] 불필요한 람다 래핑

**위치**: main_scene.gd `_connect_ui_signals()`

```gdscript
# 현재
$UILayer/QuickMenu/SaveBtn.pressed.connect(func(): _quick_save())
# 개선 가능
$UILayer/QuickMenu/SaveBtn.pressed.connect(_quick_save)
```

#### [낮음] 레거시 match 패턴 dead code

**위치**: background_controller.gd `_on_scene_change()`

```gdscript
"fadeIn", "fadeFromBlack duration 1500", _:
```

`"fadeFromBlack duration 1500"`은 와일드카드 `_`와 같은 분기이므로 실질적 dead code.

#### [낮음] 같은 position에 두 캐릭터 배치 시 ghost 상태

**위치**: character_controller.gd `_on_show()`

같은 position에 새 캐릭터가 배치되면 이전 캐릭터의 `_character_slots` 항목이
남아 있어 ghost 상태가 됨.

#### [낮음] `queue_free` vs `free`

**위치**: main_scene.gd `_on_choice()`

```gdscript
for child in choice_panel.get_children():
    child.queue_free()
```

`queue_free`는 프레임 끝에 해제되므로 한 프레임 동안 기존+신규 버튼이 공존.
`child.free()`가 더 정확함.

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

### 8.4 `_auto_advance_after` 구조적 문제

#### [높음] fire-and-forget 타이머로 인한 다중 advance

**위치**: main_scene.gd `_auto_advance_delayed()`

```gdscript
func _auto_advance_after(delay: float) -> void:
    await get_tree().create_timer(delay).timeout
    StoryManager.advance()
```

이 코루틴은 생성 후 취소할 수 없음(fire-and-forget).
스킵 모드로 빠르게 진행하면 이전 타이머가 아직 대기 중인 상태에서
새 타이머가 생성되어, 완료 시 `advance()`가 여러 번 호출됨.

**개선 방향**: 취소 가능한 타이머 패턴 사용

```gdscript
var _advance_timer: SceneTreeTimer = null

func _auto_advance_after(delay: float) -> void:
    # 이전 타이머 무효화
    _advance_timer = get_tree().create_timer(delay)
    var current = _advance_timer
    await current.timeout
    if current == _advance_timer and is_inside_tree():
        StoryManager.advance()
```

### 8.5 개선 방향 요약

| 우선순위 | 항목 | 예상 작업량 |
|----------|------|-------------|
| 1 | `_auto_advance_after` 취소 가능 타이머로 교체 | 소 |
| 2 | 스킵 모드 시 트랜지션 즉시 완료 | 중 |
| 3 | centered 텍스트 스킵/자동재생 연동 | 소 |
| 4 | 퀵세이브에 스프라이트 ID 포함 | 중 |
| 5 | 퀵세이브에 현재 대사 포함 | 중 |

---

## 9. 권장 리팩토링 방향

### 현재 구조

```
main_scene.gd              (440줄, 조율자 + 대화/선택지/세이브)
character_controller.gd    (139줄, CharacterLayer 스크립트)   ✅ 분리 완료
background_controller.gd   (70줄, BackgroundLayer 스크립트)   ✅ 분리 완료
overlay_controller.gd      (99줄, OverlayLayer 스크립트)      ✅ 분리 완료
```

### 권장 분리 구조 (남은 작업)

```
main_scene.gd              -- 초기화, 입력, auto/skip, 세이브/로드 조율만 (~100줄)
dialogue_controller.gd     -- 대화창, 타이핑, 로그
choice_controller.gd       -- 선택지 UI, Supabase 통계 연동
```

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
| 7 | 대화 컨트롤러 분리 (dialogue_controller.gd) | 중 |
| 8 | `_auto_advance_after` 취소 가능 타이머로 교체 | 소 |
| 9 | await 후 is_inside_tree() 체크 추가 | 소 |
| 10 | 선택지 중 클릭음 재생 조건 수정 | 소 |
| 11 | 스킵 모드 시 트랜지션 즉시 완료 | 중 |
| 12 | centered 텍스트 스킵/자동재생 연동 | 소 |
| 13 | 퀵세이브에 스프라이트 ID 및 현재 대사 포함 | 중 |
| 14 | Supabase 미구현 코드 정리 (`_display_stats_preview`) | 소 |
