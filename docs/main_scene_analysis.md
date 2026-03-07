# main_scene.gd / main_scene.tscn 분석 리포트

---

## 1. 아키텍처 개요

```
[StoryManager (Autoload)]
        | signals
        v
[main_scene.gd (View Controller)]
        | reads
        v
[GameManager (Autoload)] <-> [AudioManager (Autoload)]
```

Observer 패턴 기반으로 StoryManager의 시그널을 구독하는 Mediator 역할.
스토리 로직과 프레젠테이션이 분리되어 있어 구조적으로 건전함.

---

## 2. 씬 트리 구조 (main_scene.tscn)

```
MainScene (Control) -- 루트, 전체 화면
+-- BackgroundLayer (Control)
|   +-- Background1 (TextureRect) -- 현재 배경
|   +-- Background2 (TextureRect) -- 전환용 배경 (alpha=0)
+-- CharacterLayer (Control)
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
+-- OverlayLayer (CanvasLayer, layer=20)
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

| 변수 | 타입 | 용도 |
|------|------|------|
| `_typing` | bool | 타이핑 애니메이션 진행 중 여부 |
| `_typing_tween` | Tween | 현재 타이핑 트윈 참조 |
| `_auto_mode` | bool | 자동 진행 모드 |
| `_skip_mode` | bool | 스킵 모드 |
| `_distraction_free` | bool | UI 숨김 모드 |
| `_current_bg_id` | String | 현재 배경 ID (세이브용) |
| `_character_slots` | Dictionary | `{char_id: "left"/"center"/"right"}` 매핑 |
| `_dialogue_log` | Array[Dictionary] | 대화 이력 |
| `_affinity_config` | Dictionary | 거리감 알림 설정 (하드코딩) |
| `_supabase_url` | String | Supabase 통계 URL (빈 문자열이면 비활성) |
| `_stats_http` | HTTPRequest | 통계 조회용 HTTP |
| `_vote_http` | HTTPRequest | 투표 기록용 HTTP |
| `_pending_choice_data` | Dictionary | 비동기 투표 중 임시 선택 데이터 |

---

## 4. 입력 처리 흐름

```
vn_advance 액션 입력 (_unhandled_input)
  +-- InputDialog 열려있음 -> 무시
  +-- play_ui_click() (항상 재생)
  +-- distraction_free 모드 -> UI 복원, return
  +-- CenteredText 표시 중 -> 숨기고 advance(), return
  +-- 타이핑 중 -> 즉시 완료 (_complete_typing), return
  +-- 선택지 표시 중 -> 무시, return
  +-- 그 외 -> StoryManager.advance()
```

---

## 5. 시그널 연결 매핑

| StoryManager 시그널 | 핸들러 | 동작 |
|---------------------|--------|------|
| `dialogue_requested` | `_on_dialogue` | 이름+텍스트 표시, 타이핑 애니메이션 |
| `narration_requested` | `_on_narration` | 이름 숨김, 텍스트만 타이핑 |
| `centered_requested` | `_on_centered` | 대화창 숨김, 중앙 텍스트 페이드인 |
| `choice_requested` | `_on_choice` | 선택지 버튼 동적 생성 |
| `scene_change_requested` | `_on_scene_change` | 배경 교체 (크로스페이드/즉시) |
| `character_show_requested` | `_on_character_show` | 캐릭터 슬롯에 스프라이트 표시 |
| `character_hide_requested` | `_on_character_hide` | 캐릭터 페이드아웃 |
| `character_sprite_changed` | `_on_character_sprite_change` | 표정 교체 |
| `fade_requested` | `_on_fade` | 화면 페이드 인/아웃 |
| `wait_requested` | `_on_wait` | 대기 (StoryManager이 타이머 처리) |
| `input_requested` | `_on_input_request` | 이름 입력 다이얼로그 |
| `affinity_hint_requested` | `_on_affinity_hint` | 거리감 변화 알림 (1.8초) |
| `gallery_unlock_requested` | `_on_gallery_unlock` | 갤러리 해금 |
| `distraction_free_toggled` | `_on_distraction_free` | UI 토글 |
| `end_requested` | `_on_end` | 타이틀 화면으로 복귀 |

---

## 6. 주요 기능 상세

### 6.1 타이핑 시스템

- `visible_ratio`를 0->1로 트윈하여 글자 출력 효과
- 속도: `GameManager.settings["text_speed"]` (ms/글자)
- 스킵 모드일 때 0.05초로 단축
- 완료 후 auto_mode면 AutoTimer 시작, skip_mode면 0.05초 후 자동 진행
- `_complete_typing()`은 트윈을 kill하고 `_on_typing_done()`을 수동 호출

### 6.2 배경 전환

- `#000000` 형태 -> 단색 ColorRect 배경 (TransitionRect 사용)
- `"instant"` -> bg1에 즉시 교체
- 그 외 -> bg2에 로드 후 1초 크로스페이드, 완료 시 bg1으로 swap

### 6.3 캐릭터 애니메이션

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

### 6.4 선택지 시스템

- `dialog` 문자열 파싱: `"캐릭터ID 대사텍스트"` 형태 (공백 split)
- 버튼 동적 생성 + 인라인 스타일 적용
- Supabase 연동 시 선택 통계 수집/표시 (URL 미설정 시 비활성)
- 선택 완료 -> `StoryManager.on_choice_selected(key, target)`

### 6.5 마우스 패스스루 설계

`_setup_mouse_passthrough()`에서 BackgroundLayer, CharacterLayer, DialogueBox 등을
`MOUSE_FILTER_IGNORE`로 설정하여 클릭이 `_unhandled_input`까지 도달하도록 함.
화면 아무 곳이나 클릭해서 텍스트 진행 가능.

### 6.6 세이브/로드

- 퀵세이브 (slot 0): 현재 배경, BGM, 캐릭터 슬롯, 스토리 위치 저장
- 퀵로드 (slot 0): 상태 복원 후 `StoryManager.advance()` 호출

### 6.7 외부 진입점

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
| `_unhandled_input` 활용 | UI 입력 우선순위가 자연스럽게 처리됨 |
| private 함수 네이밍 | `_` prefix 관례 준수, 의도가 명확 |
| 타입 힌트 | 대부분의 변수와 매개변수에 타입 명시 |
| 트윈 활용 | Godot 4 Tween API를 적절히 사용 |
| 초기화 구조 | `_ready()`에서 역할별 private 함수로 분리 |

### 7.2 발견된 문제점

#### [높음] God Object -- 670줄, 관심사 7개 이상 혼재

**위치**: 전체 파일

하나의 스크립트가 대화창, 배경 전환, 캐릭터 관리, 선택지 UI,
세이브/로드, 입력 다이얼로그, Supabase 통계까지 모두 담당.

#### [높음] 캐릭터 상태 로드 미복원 (버그)

**위치**: `_restore_state()` (line 644~661)

세이브 데이터에 characters 정보를 저장하지만 (`_quick_save`에서 `_character_slots.duplicate()`),
로드 시 캐릭터 슬롯을 초기화만 하고 복원하지 않음.
저장 시점의 캐릭터 상태가 손실됨.

#### [높음] 연속 배경 전환 시 트윈 충돌 가능

**위치**: `_on_scene_change()` (line 428~435)

크로스페이드 트윈 완료 콜백에서 bg1/bg2를 swap하는데,
연속 빠른 씬 전환 시 이전 트윈의 콜백이 새 배경을 덮어쓸 수 있음.
트윈을 인스턴스 변수로 관리하고 새 전환 시 이전 트윈을 kill해야 함.

#### [중간] Supabase 코드가 뷰에 존재 (SRP 위반)

**위치**: line 320~391 (약 70줄)

HTTP 통신, JSON 파싱, 통계 표시 로직이 뷰 컨트롤러에 직접 존재.
별도 매니저로 분리하는 것이 적절함.

#### [중간] `_display_stats_preview` 미구현

**위치**: line 340~351

빈 for 루프. 통계 프리뷰 표시 기능이 구현되지 않은 상태.

#### [중간] await 후 씬 유효성 미검증

**위치**: `_auto_advance_delayed()` (line 241~243)

`await get_tree().create_timer(delay).timeout` 중에 씬 전환이 발생하면
orphan coroutine이 됨. `is_inside_tree()` 체크가 필요함.

#### [낮음] 선택지 표시 중에도 클릭음 재생

**위치**: `_handle_advance_input()` (line 142)

`AudioManager.play_ui_click()`이 choice_panel 가시성 체크 전에 호출됨.
선택지 표시 중 빈 공간 클릭 시 불필요한 클릭음이 재생됨.

#### [낮음] 불필요한 람다 래핑

**위치**: `_connect_ui_signals()` (line 87~91)

```gdscript
# 현재
$UILayer/QuickMenu/SaveBtn.pressed.connect(func(): _quick_save())
# 개선 가능
$UILayer/QuickMenu/SaveBtn.pressed.connect(_quick_save)
```

#### [낮음] 세미콜론 멀티 스테이트먼트

**위치**: line 496, 655~657

```gdscript
tw.finished.connect(func(): slot.texture = null; slot.position.x += 100)
```

한 줄에 여러 문을 합치면 가독성이 떨어짐.

#### [낮음] 레거시 match 패턴 dead code

**위치**: `_on_scene_change()` (line 426)

```gdscript
"fadeIn", "fadeFromBlack duration 1500", _:
```

`"fadeFromBlack duration 1500"`은 와일드카드 `_`와 같은 분기이므로 실질적 dead code.

#### [낮음] 같은 position에 두 캐릭터 배치 시 ghost 상태

**위치**: `_on_character_show()` (line 438~478)

같은 position에 새 캐릭터가 배치되면 이전 캐릭터의 `_character_slots` 항목이
남아 있어 ghost 상태가 됨.

#### [낮음] `queue_free` vs `free`

**위치**: `_on_choice()` (line 268~269)

```gdscript
for child in choice_panel.get_children():
    child.queue_free()
```

`queue_free`는 프레임 끝에 해제되므로 한 프레임 동안 기존+신규 버튼이 공존.
`child.free()`가 더 정확함.

---

## 8. 권장 리팩토링 방향

### 현재 구조

```
main_scene.gd (670줄, 모든 것 담당)
```

### 권장 분리 구조

```
main_scene.gd              -- 초기화, 입력, 씬 전환 조율만
dialogue_controller.gd     -- 대화창, 타이핑, 로그
character_controller.gd    -- 캐릭터 슬롯, 스프라이트, 애니메이션
choice_controller.gd       -- 선택지 UI, 통계 연동
save_controller.gd         -- 퀵세이브/로드, 상태 복원
```

단, 현재 규모(670줄)에서는 당장 분리하지 않아도 유지보수가 가능한 수준.
**버그 수정(캐릭터 로드 복원, 트윈 충돌)이 리팩토링보다 우선**.

---

## 9. 우선순위별 액션 아이템

| 우선순위 | 항목 | 예상 작업량 |
|----------|------|-------------|
| 1 | 캐릭터 상태 로드 복원 버그 수정 | 소 |
| 2 | 배경 전환 트윈 충돌 방지 | 소 |
| 3 | await 후 is_inside_tree() 체크 추가 | 소 |
| 4 | 선택지 중 클릭음 재생 조건 수정 | 소 |
| 5 | Supabase 코드 분리 또는 미구현 코드 정리 | 중 |
| 6 | 전체 컨트롤러 분리 리팩토링 | 대 |
