# 다음 리팩토링 가이드

> 기반 문서: `docs/main_scene_analysis.md`
> 현재 상태: `main_scene.gd` 440줄, 컨트롤러 3개 분리 완료

---

## 목차

1. [Phase 1] dialogue_controller.gd 분리 (우선순위 7)
2. [Phase 2] choice_controller.gd 분리 (우선순위 6)
3. [Phase 3] 버그 수정 — `_auto_advance_after` 취소 가능 타이머 (우선순위 8)
4. [Phase 4] 소규모 품질 개선 (우선순위 9~10)
5. [Phase 5] 스킵/자동재생 연동 개선 (우선순위 11~12)
6. [Phase 6] 퀵세이브 데이터 보강 (우선순위 13)

---

## Phase 1: dialogue_controller.gd 분리

### 목표
대화창 표시, 타이핑 애니메이션, 대화 로그를 `dialogue_controller.gd`로 분리.
`main_scene.gd`에서 약 100줄 제거.

### 이동 대상 (main_scene.gd → dialogue_controller.gd)

| 라인 | 함수/변수 | 역할 |
|------|-----------|------|
| 7-9 | `dialogue_box`, `name_label`, `text_label` | 노드 참조 |
| 16-17 | `_typing`, `_typing_tween` | 타이핑 상태 |
| 21 | `_dialogue_log` | 대화 이력 |
| 91-98 | `_apply_dialogue_box_style()` | 대화창 스타일 |
| 138-157 | `_on_dialogue()`, `_on_narration()` | 대사/나레이션 표시 |
| 160-167 | `_on_centered()` | 중앙 텍스트 |
| 169-213 | `_start_typing()` ~ `_auto_advance_delayed()` | 타이핑 시스템 전체 |
| 438-439 | `get_dialogue_log()` | 로그 조회 |

### 새 파일 구조

```
scenes/controller/dialogue_controller.gd
```

```gdscript
extends Control
## UILayer에 직접 배치하거나, DialogueBox의 부모 노드에 attach
## 대화창, 타이핑 애니메이션, 대화 로그 관리

signal typing_finished  # main_scene의 auto/skip 연동용

# 노드 참조 — 씬 트리에서 UILayer 하위 노드들
@onready var dialogue_box: PanelContainer = $DialogueBox
@onready var name_label: Label = $DialogueBox/MarginContainer/VBoxContainer/NameLabel
@onready var text_label: RichTextLabel = $DialogueBox/MarginContainer/VBoxContainer/TextLabel
@onready var centered_text: Label = $CenteredText

# 상태
var _typing := false
var _typing_tween: Tween
var _dialogue_log: Array[Dictionary] = []

func _ready() -> void:
	_apply_dialogue_box_style()
	StoryManager.dialogue_requested.connect(_on_dialogue)
	StoryManager.narration_requested.connect(_on_narration)
	StoryManager.centered_requested.connect(_on_centered)
	dialogue_box.visible = false
	centered_text.visible = false

# === Public API ===

func is_typing() -> bool:
	return _typing

func complete_typing() -> void:
	"""외부에서 타이핑 즉시 완료 요청 (클릭 시)"""
	if _typing_tween:
		_typing_tween.kill()
	text_label.visible_ratio = 1.0
	_on_typing_done()

func is_centered_visible() -> bool:
	return centered_text.visible

func hide_centered() -> void:
	centered_text.visible = false

func show_dialogue_box() -> void:
	dialogue_box.visible = true

func hide_dialogue_box() -> void:
	dialogue_box.visible = false

func get_dialogue_log() -> Array[Dictionary]:
	return _dialogue_log

# === Signal Handlers ===

func _on_dialogue(char_id: String, name_text: String, text: String) -> void:
	DebugOverlay.log_message("Dialogue: %s" % name_text)
	dialogue_box.visible = true
	centered_text.visible = false
	name_label.text = name_text
	name_label.add_theme_color_override("font_color", StoryManager.get_character_color(char_id))
	name_label.visible = true
	_start_typing(text)
	_dialogue_log.append({"name": name_text, "text": text})

func _on_narration(text: String) -> void:
	dialogue_box.visible = true
	centered_text.visible = false
	name_label.visible = false
	_start_typing(text)
	_dialogue_log.append({"name": "", "text": text})

func _on_centered(text: String) -> void:
	dialogue_box.visible = false
	centered_text.text = text
	centered_text.visible = true
	centered_text.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(centered_text, "modulate:a", 1.0, 0.5)

# === Typing System ===

func _start_typing(text: String) -> void:
	text_label.text = text
	text_label.visible_ratio = 0.0
	_typing = true
	if _typing_tween:
		_typing_tween.kill()
	var char_count := text.length()
	var speed_ms: float = GameManager.settings["text_speed"]
	var duration: float = char_count * speed_ms / 1000.0
	# skip_mode는 main_scene에서 제어 — 외부에서 duration 오버라이드 가능하도록
	_typing_tween = create_tween()
	_typing_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	_typing_tween.finished.connect(_on_typing_done)

func start_typing_fast() -> void:
	"""스킵 모드용: 현재 타이핑을 0.05초로 단축"""
	if _typing and _typing_tween:
		_typing_tween.kill()
		text_label.visible_ratio = 0.0
		_typing_tween = create_tween()
		_typing_tween.tween_property(text_label, "visible_ratio", 1.0, 0.05)
		_typing_tween.finished.connect(_on_typing_done)

func _on_typing_done() -> void:
	_typing = false
	typing_finished.emit()

func _apply_dialogue_box_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.078, 0.039, 0.118, 0.82)
	style.border_color = Color(0.957, 0.561, 0.694, 0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(20)
	dialogue_box.add_theme_stylebox_override("panel", style)
```

### 씬 트리 변경

현재:
```
UILayer (CanvasLayer, layer=10)
├── DialogueBox
├── ChoicePanel
├── CenteredText
└── QuickMenu
```

변경 후:
```
UILayer (CanvasLayer, layer=10)
├── DialogueLayer (Control, script=dialogue_controller.gd)  ← 새 노드
│   ├── DialogueBox        ← 기존 노드 이동
│   └── CenteredText       ← 기존 노드 이동
├── ChoicePanel
└── QuickMenu
```

**또는** (씬 트리 변경 최소화):
- `UILayer`에 직접 `dialogue_controller.gd`를 적용하지 않고
- `DialogueBox` 상위에 래퍼 `Control` 노드를 추가하여 스크립트 attach
- `CenteredText`도 해당 래퍼 하위로 이동

### main_scene.gd 변경사항

```gdscript
# 제거할 변수/참조
# - dialogue_box, name_label, text_label (→ DialogueLayer가 관리)
# - centered_text (→ DialogueLayer가 관리)
# - _typing, _typing_tween (→ DialogueLayer가 관리)
# - _dialogue_log (→ DialogueLayer가 관리)

# 새로 추가할 참조
@onready var dialogue_layer = $UILayer/DialogueLayer

# _ready()에서 변경
func _ready() -> void:
	# _apply_dialogue_box_style() 제거
	_connect_story_signals()
	_connect_ui_signals()
	_setup_http_nodes()
	_setup_mouse_passthrough()
	choice_panel.visible = false
	# dialogue_box, centered_text 초기화는 DialogueLayer._ready()에서 처리

# _connect_story_signals()에서 제거
# - dialogue_requested, narration_requested, centered_requested → DialogueLayer

# _connect_ui_signals()에서 추가
dialogue_layer.typing_finished.connect(_on_typing_finished)

# 새 핸들러
func _on_typing_finished() -> void:
	if _auto_mode:
		auto_timer.wait_time = GameManager.settings["auto_speed"]
		auto_timer.start()
	elif _skip_mode:
		_auto_advance_delayed(0.05)

# _handle_advance_input() 수정
func _handle_advance_input() -> void:
	AudioManager.play_ui_click()
	if _distraction_free:
		_distraction_free = false
		dialogue_layer.show_dialogue_box()
		quick_menu.visible = true
		return
	if dialogue_layer.is_centered_visible():
		dialogue_layer.hide_centered()
		StoryManager.advance()
		return
	if dialogue_layer.is_typing():
		dialogue_layer.complete_typing()
		return
	if choice_panel.visible:
		return
	StoryManager.advance()
```

### 주의사항

- `_start_typing()`에서 `_skip_mode` 체크가 있었음 → `typing_finished` 시그널과 `start_typing_fast()` 메서드로 대체
- `_on_distraction_free()`에서 `dialogue_box.visible` 직접 제어 → `dialogue_layer.show/hide_dialogue_box()` 호출로 변경
- `_setup_mouse_passthrough()`에서 `dialogue_box` 참조 → `dialogue_layer` 하위 접근으로 변경
- `get_dialogue_log()`은 `dialogue_layer.get_dialogue_log()`로 위임

---

## Phase 2: choice_controller.gd 분리

### 목표
선택지 UI + Supabase 통계 코드를 `choice_controller.gd`로 분리.
`main_scene.gd`에서 약 150줄 제거.

### 이동 대상 (main_scene.gd → choice_controller.gd)

| 라인 | 함수/변수 | 역할 |
|------|-----------|------|
| 10 | `choice_panel` | 노드 참조 |
| 26-29 | `_supabase_url`, `_stats_http`, `_vote_http`, `_pending_choice_data` | Supabase 상태 |
| 64-70 | `_setup_http_nodes()` | HTTP 노드 생성 |
| 218-361 | 선택지/Supabase 관련 함수 전체 | 선택지 시스템 |

### 새 파일 구조

```
scenes/controller/choice_controller.gd
```

```gdscript
extends VBoxContainer
## ChoicePanel에 직접 attach — 선택지 UI, Supabase 통계

signal choice_finalized(choice_key: String, target: String)

# Supabase 설정
var _supabase_url: String = ""
var _stats_http: HTTPRequest
var _vote_http: HTTPRequest
var _pending_choice_data: Dictionary = {}

func _ready() -> void:
	StoryManager.choice_requested.connect(_on_choice)
	_setup_http_nodes()
	visible = false

func is_active() -> bool:
	return visible

# === Signal Handlers ===

func _on_choice(dialog: String, choices: Array) -> void:
	# dialog 대사 표시는 시그널로 main_scene에 위임하거나
	# dialogue_controller에 직접 요청
	# ... (기존 _on_choice 로직 이동)

func _on_choice_button_pressed(choice_key: String, target: String, _btn: Button) -> void:
	# ... 기존 로직

func _finalize_choice(choice_key: String, target: String) -> void:
	visible = false
	choice_finalized.emit(choice_key, target)

# === Supabase 통계 ===
# ... (기존 Supabase 관련 함수 전체 이동)
```

### 씬 트리 변경

```
UILayer (CanvasLayer, layer=10)
├── DialogueLayer (Control, script=dialogue_controller.gd)
│   ├── DialogueBox
│   └── CenteredText
├── ChoicePanel (VBoxContainer, script=choice_controller.gd)  ← 스크립트 attach
└── QuickMenu
```

### 핵심 설계 결정: 선택지 대사 표시

현재 `_on_choice()`에서 `dialog` 파싱 후 `name_label`, `text_label`에 직접 접근합니다.
분리 후 두 가지 방식이 가능합니다:

**방식 A: 시그널 위임 (권장)**
```gdscript
# choice_controller.gd
signal choice_dialog_requested(char_id: String, name_text: String, text: String)

# _on_choice()에서 dialog 파싱 후
choice_dialog_requested.emit(char_id, char_name, dialog_text)
```

```gdscript
# main_scene.gd 또는 dialogue_controller.gd에서
$UILayer/ChoicePanel.choice_dialog_requested.connect(dialogue_layer._on_dialogue_raw)
```

**방식 B: dialogue_controller 직접 참조**
```gdscript
# choice_controller.gd
@onready var dialogue_layer = $"../DialogueLayer"
dialogue_layer.show_raw_text(char_name, dialog_text, char_color)
```

방식 A가 결합도가 낮으므로 권장합니다.

### main_scene.gd 변경사항

```gdscript
# 제거: choice_panel, _supabase_url, _stats_http, _vote_http, _pending_choice_data
# 제거: _setup_http_nodes()
# 제거: 선택지/Supabase 관련 함수 전체 (약 150줄)

# 새로 추가
@onready var choice_panel = $UILayer/ChoicePanel  # choice_controller.gd 타입

func _connect_ui_signals() -> void:
	# ...
	choice_panel.choice_finalized.connect(_on_choice_finalized)

func _on_choice_finalized(choice_key: String, target: String) -> void:
	StoryManager.on_choice_selected(choice_key, target)

# _handle_advance_input()에서
if choice_panel.is_active():
	return
```

### 주의사항

- `_on_choice()`에서 `child.queue_free()` → `child.free()`로 변경 (분석 문서 지적사항)
- `_show_stats_result()`의 `await get_tree().create_timer(2.5).timeout` 후 `is_inside_tree()` 체크 추가
- `_finalize_choice()`에서 `StoryManager.on_choice_selected()` 직접 호출 대신 시그널 emit

---

## Phase 3: `_auto_advance_after` 취소 가능 타이머

### 문제 (분석 문서 8.4절)
`_auto_advance_delayed()`가 fire-and-forget 코루틴이라 취소 불가.
스킵 모드에서 여러 타이머가 동시 실행되어 `advance()` 다중 호출.

### 수정 위치
Phase 1 완료 후: `dialogue_controller.gd` 또는 `main_scene.gd` (auto/skip 로직 위치에 따라)

### 수정 코드

```gdscript
# main_scene.gd (auto/skip 로직이 여기 남아있으므로)

var _advance_timer: SceneTreeTimer = null

func _auto_advance_delayed(delay: float) -> void:
	_advance_timer = get_tree().create_timer(delay)
	var current := _advance_timer
	await current.timeout
	# 타이머가 교체되지 않았고 씬 트리에 있을 때만 진행
	if current == _advance_timer and is_inside_tree():
		if not choice_panel.is_active():
			StoryManager.advance()
```

### 추가: auto_timer와의 충돌 방지

```gdscript
func _on_typing_finished() -> void:
	# 이전 지연 타이머 무효화
	_advance_timer = null
	if _auto_mode:
		auto_timer.wait_time = GameManager.settings["auto_speed"]
		auto_timer.start()
	elif _skip_mode:
		_auto_advance_delayed(0.05)
```

---

## Phase 4: 소규모 품질 개선

### 4.1 await 후 `is_inside_tree()` 체크 (우선순위 9)

**대상 함수:**
- `main_scene.gd: _auto_advance_delayed()` — Phase 3에서 해결
- `choice_controller.gd: _show_stats_result()` — Phase 2 분리 시 적용
- `overlay_controller.gd` — 현재 await 없으므로 패스

```gdscript
# choice_controller.gd
func _show_stats_result(stats: Array, selected_key: String) -> void:
	# ... 퍼센티지 표시 ...
	await get_tree().create_timer(2.5).timeout
	if not is_inside_tree():
		return
	_finalize_choice(...)
```

### 4.2 선택지 표시 중 클릭음 재생 조건 수정 (우선순위 10)

**위치**: `main_scene.gd:111-113`

```gdscript
# 현재
func _handle_advance_input() -> void:
	AudioManager.play_ui_click()  # ← 항상 재생
	...
	if choice_panel.visible:      # ← 여기서 리턴
		return

# 수정
func _handle_advance_input() -> void:
	if choice_panel.is_active():
		return  # 선택지 표시 중이면 클릭음도 안 재생
	AudioManager.play_ui_click()
	DebugOverlay.log_message("Advance input")
	# ... 나머지 동일
```

### 4.3 불필요한 람다 래핑 제거

**위치**: `main_scene.gd:57-58`

```gdscript
# 현재
$UILayer/QuickMenu/SaveBtn.pressed.connect(func(): _quick_save())
$UILayer/QuickMenu/LoadBtn.pressed.connect(func(): _quick_load())

# 수정
$UILayer/QuickMenu/SaveBtn.pressed.connect(_quick_save)
$UILayer/QuickMenu/LoadBtn.pressed.connect(_quick_load)
```

> `toggled` 시그널의 람다는 파라미터가 있으므로 유지 또는 직접 바인드:
> `$UILayer/QuickMenu/AutoBtn.toggled.connect(_toggle_auto)`

### 4.4 같은 position에 두 캐릭터 배치 시 ghost 제거

**위치**: `character_controller.gd:58`

```gdscript
func _on_show(id: String, sprite: String, position: String, transition: String) -> void:
	# ... 텍스처 로드 후 ...

	# 같은 슬롯에 이미 다른 캐릭터가 있으면 제거
	for existing_id in _character_slots:
		if _character_slots[existing_id] == position and existing_id != id:
			_character_slots.erase(existing_id)
			break

	slot.texture = tex
	_character_slots[id] = position
	# ... 트랜지션 ...
```

### 4.5 배경 컨트롤러 dead code 정리

**위치**: `background_controller.gd:53`

```gdscript
# 현재
"fadeIn", "fadeFromBlack duration 1500", _:

# 수정: 와일드카드만 사용 (의미 없는 리터럴 제거)
_:
```

---

## Phase 5: 스킵/자동재생 연동 개선

### 5.1 스킵 모드 시 트랜지션 즉시 완료 (우선순위 11)

StoryManager 쪽에서 처리해야 하는 부분과 뷰 쪽에서 처리해야 하는 부분이 있음.

**뷰 쪽 (컨트롤러들):**

```gdscript
# overlay_controller.gd — 페이드 즉시 완료
func _on_fade(fade_type: String, duration: float, color: Color) -> void:
	var actual_duration := 0.0 if _is_skip_mode() else duration
	# ... 트윈에 actual_duration 사용

func _is_skip_mode() -> bool:
	# 방법 1: StoryManager에 skip_mode 상태를 노출
	# 방법 2: main_scene에서 시그널로 전파
	return StoryManager.is_skip_mode()  # StoryManager에 메서드 추가 필요
```

```gdscript
# background_controller.gd — 크로스페이드 즉시 완료
func _on_scene_change(id: String, transition: String) -> void:
	# ... 기존 로직 ...
	var fade_duration := 0.0 if StoryManager.is_skip_mode() else 1.0
	_bg_tween.tween_property(bg2, "modulate:a", 1.0, fade_duration)
```

**StoryManager 쪽:**
- `is_skip_mode() -> bool` 메서드 추가 필요
- `wait` 명령어에서 스킵 모드 시 대기 시간 0으로 처리
- `fade_jump`에서 스킵 모드 시 페이드 없이 즉시 점프

### 5.2 centered 텍스트 스킵/자동재생 연동 (우선순위 12)

**위치**: `dialogue_controller.gd` (Phase 1 후)

```gdscript
func _on_centered(text: String) -> void:
	dialogue_box.visible = false
	centered_text.text = text
	centered_text.visible = true
	centered_text.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(centered_text, "modulate:a", 1.0, 0.5)
	tw.finished.connect(func():
		typing_finished.emit()  # auto/skip 연동을 위해 타이핑 완료와 동일하게 처리
	)
```

이렇게 하면 `main_scene.gd`의 `_on_typing_finished()`에서:
- auto_mode → AutoTimer 시작 → 타임아웃 시 `centered_text` 숨기고 advance
- skip_mode → 0.05초 후 `centered_text` 숨기고 advance

---

## Phase 6: 퀵세이브 데이터 보강

### 6.1 캐릭터 스프라이트 ID 포함 (우선순위 13)

**character_controller.gd 수정:**

```gdscript
# 현재 _character_slots: {char_id: "left"/"center"/"right"}
# 변경: {char_id: {"slot": "left", "sprite": "happy"}}

var _character_slots: Dictionary = {}  # char_id -> {"slot": position, "sprite": sprite_id}

func _on_show(id: String, sprite: String, position: String, transition: String) -> void:
	# ...
	_character_slots[id] = {"slot": position, "sprite": sprite}

func _on_sprite_change(id: String, sprite: String) -> void:
	if id not in _character_slots:
		return
	_character_slots[id]["sprite"] = sprite
	# ... 텍스처 교체

func _on_hide(id: String, transition: String) -> void:
	if id not in _character_slots:
		return
	var slot_info: Dictionary = _character_slots[id]
	var slot := _get_slot(slot_info["slot"])
	# ... 트랜지션

func get_state() -> Dictionary:
	return _character_slots.duplicate(true)  # deep copy

func restore_state(state: Dictionary) -> void:
	clear_all()
	for char_id in state:
		var info = state[char_id]
		var position: String
		var sprite: String
		if info is String:
			# 이전 저장 형식 호환 (migration)
			position = info
			sprite = StoryManager.get_current_character_sprite(char_id)
		else:
			position = info["slot"]
			sprite = info["sprite"]
		var slot := _get_slot(position)
		var path = StoryManager.get_character_sprite_path(char_id, sprite)
		if path.is_empty():
			continue
		var tex := load(path) as Texture2D
		if tex:
			slot.texture = tex
			slot.modulate.a = 1.0
		_character_slots[char_id] = {"slot": position, "sprite": sprite}
```

### 6.2 현재 대사 저장 (선택적)

```gdscript
# main_scene.gd — _quick_save()
func _quick_save() -> void:
	var extra := StoryManager.get_save_data()
	extra["background"] = $BackgroundLayer.get_current_bg_id()
	extra["bgm"] = AudioManager.get_current_bgm()
	extra["characters"] = $CharacterLayer.get_state()
	# 현재 대사 상태 추가
	extra["current_dialogue"] = {
		"name": dialogue_layer.get_current_name(),
		"text": dialogue_layer.get_current_text(),
	}
	GameManager.save_game(0, extra)
```

---

## 리팩토링 후 최종 구조 (목표)

```
main_scene.gd              (~100줄) — 초기화, 입력, auto/skip 조율, 세이브/로드
├── dialogue_controller.gd (~100줄) — 대화창, 타이핑, 로그
├── choice_controller.gd   (~120줄) — 선택지 UI, Supabase 통계
├── character_controller.gd(~140줄) — 캐릭터 슬롯, 애니메이션
├── background_controller.gd(~70줄) — 배경 전환
└── overlay_controller.gd  (~100줄) — 페이드, 입력, 알림
```

```
씬 트리:
MainScene (Control, script=main_scene.gd)
├── BackgroundLayer (Control, script=background_controller.gd)
├── CharacterLayer (Control, script=character_controller.gd)
├── UILayer (CanvasLayer, layer=10)
│   ├── DialogueLayer (Control, script=dialogue_controller.gd)
│   │   ├── DialogueBox
│   │   └── CenteredText
│   ├── ChoicePanel (VBoxContainer, script=choice_controller.gd)
│   └── QuickMenu
├── OverlayLayer (CanvasLayer, layer=20, script=overlay_controller.gd)
└── AutoTimer
```

---

## 실행 순서 권장

| 순서 | Phase | 예상 작업량 | 의존성 |
|------|-------|-------------|--------|
| 1 | Phase 1 (dialogue_controller) | 중 | 없음 |
| 2 | Phase 2 (choice_controller) | 중 | Phase 1 (선택지 대사 표시) |
| 3 | Phase 3 (타이머 버그) | 소 | Phase 1 |
| 4 | Phase 4 (품질 개선) | 소 | 독립 (Phase 1,2와 병행 가능) |
| 5 | Phase 5 (스킵/자동재생) | 중 | Phase 1 + StoryManager 수정 |
| 6 | Phase 6 (퀵세이브 보강) | 중 | Phase 1 |

Phase 4의 4.4(ghost 제거), 4.5(dead code)는 독립적이므로 언제든 먼저 작업 가능.
