extends Control

## VN 플레이 화면 메인 컨트롤러
## StoryManager 시그널을 받아 UI 컴포넌트 업데이트

# 노드 참조
@onready var choice_panel: VBoxContainer = $UILayer/ChoicePanel
@onready var quick_menu: HBoxContainer = $UILayer/QuickMenu
@onready var auto_timer: Timer = $AutoTimer
@onready var dialogue_layer: Control = $UILayer/DialogueLayer

# 상태
var _auto_mode := false
var _skip_mode := false
var _distraction_free := false
var _advance_timer: SceneTreeTimer = null

# 모달 상태
enum ModalType { NONE, SETTINGS, SAVE_LOAD }
var _active_modal: ModalType = ModalType.NONE
var _auto_before_modal := false
var _skip_before_modal := false
var _modal_layer: CanvasLayer = null

func _ready() -> void:
	_connect_story_signals()
	_connect_ui_signals()
	_setup_mouse_passthrough()
	choice_panel.visible = false

func _connect_story_signals() -> void:
	StoryManager.gallery_unlock_requested.connect(_on_gallery_unlock)
	StoryManager.distraction_free_toggled.connect(_on_distraction_free)
	StoryManager.end_requested.connect(_on_end)


func _connect_ui_signals() -> void:
	auto_timer.timeout.connect(_on_auto_timeout)
	dialogue_layer.typing_finished.connect(_on_typing_finished)

	# QuickMenu 숨김/복원 (InputDialog, CenteredText)
	$OverlayLayer.input_dialog_shown.connect(func(): quick_menu.visible = false)
	$OverlayLayer.input_dialog_hidden.connect(func(): if not _distraction_free: quick_menu.visible = true)
	StoryManager.centered_requested.connect(func(_t): quick_menu.visible = false)
	StoryManager.dialogue_requested.connect(func(_a, _b, _c): if not _distraction_free: quick_menu.visible = true)
	StoryManager.narration_requested.connect(func(_t): if not _distraction_free: quick_menu.visible = true)

	# Quick menu
	$UILayer/QuickMenu/SaveBtn.pressed.connect(_quick_save)
	$UILayer/QuickMenu/LoadBtn.pressed.connect(_quick_load)
	$UILayer/QuickMenu/AutoBtn.toggled.connect(_toggle_auto)
	$UILayer/QuickMenu/SkipBtn.toggled.connect(_toggle_skip)
	$UILayer/QuickMenu/SettingsBtn.pressed.connect(_open_settings)


func _open_settings() -> void:
	if _active_modal != ModalType.NONE:
		return
	_active_modal = ModalType.SETTINGS
	_pause_auto_skip()
	_set_quick_menu_disabled(true)
	var settings = load("res://scenes/settings_screen.tscn").instantiate()
	settings.set_overlay_mode()
	settings.tree_exiting.connect(_on_modal_closed)
	var layer := CanvasLayer.new()
	layer.layer = 25
	layer.add_child(settings)
	_modal_layer = layer
	get_tree().root.add_child(layer)


func _setup_mouse_passthrough() -> void:
	# 루트 및 배경/캐릭터 레이어: 마우스 이벤트 통과시켜 _unhandled_input 도달하도록
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_mouse_ignore_recursive($BackgroundLayer)
	_set_mouse_ignore_recursive($CharacterLayer)
	_set_mouse_ignore_recursive($UILayer/DialogueLayer)
	choice_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quick_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _set_mouse_ignore_recursive(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_mouse_ignore_recursive(child)


func _apply_dialogue_box_style() -> void:
	var style := StyleBoxTexture.new()
	style.texture = preload("res://assets/system/dialog-background.png")
	style.set_content_margin_all(20)
	dialogue_layer.dialogue_box.add_theme_stylebox_override("panel", style)


# === Input ===

func _unhandled_input(event: InputEvent) -> void:
	if _active_modal != ModalType.NONE:
		return
	if $OverlayLayer.is_input_active():
		return
	if event.is_action_pressed("vn_advance"):
		_handle_advance_input()
		get_viewport().set_input_as_handled()


func _handle_advance_input() -> void:
	if _distraction_free:
		AudioManager.play_ui_click()
		_distraction_free = false
		dialogue_layer.show_dialogue_box()
		quick_menu.visible = true
		return

	if dialogue_layer.is_centered_visible():
		AudioManager.play_ui_click()
		dialogue_layer.hide_centered()
		if not _distraction_free:
			quick_menu.visible = true
		StoryManager.advance()
		return

	if dialogue_layer.is_typing():
		AudioManager.play_ui_click()
		dialogue_layer.complete_typing()
		return

	if choice_panel.visible:
		return

	AudioManager.play_ui_click()
	DebugOverlay.log_message("Advance input")
	StoryManager.advance()


# === Dialogue ===

func _on_typing_finished() -> void:
	if _auto_mode:
		auto_timer.wait_time = GameManager.settings["auto_speed"]
		auto_timer.start()
	elif _skip_mode:
		auto_timer.stop()
		_auto_advance_delayed(0.05)


func _on_auto_timeout() -> void:
	if _active_modal != ModalType.NONE:
		return
	if _auto_mode and not dialogue_layer.is_typing() and not choice_panel.visible:
		StoryManager.advance()


func _auto_advance_delayed(delay: float) -> void:
	_advance_timer = get_tree().create_timer(delay)
	var current := _advance_timer
	await current.timeout
	if current == _advance_timer and is_inside_tree() and _active_modal == ModalType.NONE and not choice_panel.visible:
		StoryManager.advance()


# === Gallery & Misc ===

func _on_gallery_unlock(id: String) -> void:
	GameManager.unlock_gallery(id)


func _on_distraction_free() -> void:
	_distraction_free = !_distraction_free
	if _distraction_free:
		dialogue_layer.hide_dialogue_box()
	else:
		dialogue_layer.show_dialogue_box()
	quick_menu.visible = !_distraction_free


func _on_end() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


# === Auto/Skip ===

func _toggle_auto(enabled: bool) -> void:
	_auto_mode = enabled
	GameManager.auto_mode = enabled
	var auto_btn: Button = $UILayer/QuickMenu/AutoBtn
	var skip_btn: Button = $UILayer/QuickMenu/SkipBtn
	if enabled:
		_skip_mode = false
		skip_btn.button_pressed = false
		_update_toggle_style(skip_btn, false, "Skip")
		_update_toggle_style(auto_btn, true, "Auto", Color(0.1, 0.5, 0.2, 0.85))
		if not dialogue_layer.is_typing() and not choice_panel.visible:
			auto_timer.start()
	else:
		auto_timer.stop()
		_update_toggle_style(auto_btn, false, "Auto")


func _toggle_skip(enabled: bool) -> void:
	_skip_mode = enabled
	var auto_btn: Button = $UILayer/QuickMenu/AutoBtn
	var skip_btn: Button = $UILayer/QuickMenu/SkipBtn
	if enabled:
		_auto_mode = false
		auto_btn.button_pressed = false
		_update_toggle_style(auto_btn, false, "Auto")
		_update_toggle_style(skip_btn, true, "Skip", Color(0.6, 0.2, 0.1, 0.85))
		if not dialogue_layer.is_typing() and not choice_panel.visible:
			StoryManager.advance()
	else:
		_update_toggle_style(skip_btn, false, "Skip")


func _update_toggle_style(btn: Button, active: bool, label: String, bg_color: Color = Color.BLACK) -> void:
	if active:
		btn.text = label + " ●"
		var style := StyleBoxFlat.new()
		style.bg_color = bg_color
		style.set_corner_radius_all(4)
		style.set_content_margin_all(4)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
	else:
		btn.text = label
		btn.remove_theme_stylebox_override("normal")
		btn.remove_theme_stylebox_override("hover")
		btn.remove_theme_stylebox_override("pressed")


# === Quick Save/Load ===

func _quick_save() -> void:
	_open_save_load(false)


func _quick_load() -> void:
	_open_save_load(true)


func _open_save_load(load_mode: bool) -> void:
	if _active_modal != ModalType.NONE:
		return
	_active_modal = ModalType.SAVE_LOAD
	_pause_auto_skip()
	_set_quick_menu_disabled(true)
	var screen = load("res://scenes/save_load_screen.tscn").instantiate()
	screen.set_overlay_mode()
	screen.set_mode(load_mode)
	screen.tree_exiting.connect(_on_modal_closed)
	var layer := CanvasLayer.new()
	layer.layer = 25
	layer.add_child(screen)
	_modal_layer = layer
	get_tree().root.add_child(layer)


# === Modal Helpers ===

func _on_modal_closed() -> void:
	if _active_modal == ModalType.NONE:
		return  # 이미 정리됨
	_active_modal = ModalType.NONE
	_set_quick_menu_disabled(false)
	_resume_auto_skip()
	if _modal_layer:
		_modal_layer.queue_free()
		_modal_layer = null


func _pause_auto_skip() -> void:
	_auto_before_modal = _auto_mode
	_skip_before_modal = _skip_mode
	auto_timer.stop()
	_advance_timer = null


func _resume_auto_skip() -> void:
	if _auto_before_modal and _auto_mode and not dialogue_layer.is_typing() and not choice_panel.visible:
		auto_timer.start()
	if _skip_before_modal and _skip_mode and not dialogue_layer.is_typing() and not choice_panel.visible:
		_auto_advance_delayed(0.05)


func _set_quick_menu_disabled(disabled: bool) -> void:
	$UILayer/QuickMenu/SaveBtn.disabled = disabled
	$UILayer/QuickMenu/LoadBtn.disabled = disabled
	$UILayer/QuickMenu/SettingsBtn.disabled = disabled


func _restore_state(data: Dictionary) -> void:
	# 배경 복원
	if data.has("background") and not data["background"].is_empty():
		$BackgroundLayer.restore_background(data["background"])

	# BGM 복원
	if data.has("bgm") and not data["bgm"].is_empty():
		AudioManager.play_music(data["bgm"])

	# 캐릭터 복원
	$CharacterLayer.restore_state(data.get("characters", {}))

	# 스토리 위치 복원
	StoryManager.restore_from_save(data)
	StoryManager.advance()


func start_story(label: String = "Start") -> void:
	StoryManager.start(label)


func get_dialogue_log() -> Array[Dictionary]:
	return dialogue_layer.get_dialogue_log()
