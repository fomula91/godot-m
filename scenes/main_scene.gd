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

# Supabase 설정
var _supabase_url: String = ""
var _stats_http: HTTPRequest
var _vote_http: HTTPRequest
var _pending_choice_data: Dictionary = {}

func _ready() -> void:
	_connect_story_signals()
	_connect_ui_signals()
	_setup_http_nodes()
	_setup_mouse_passthrough()
	choice_panel.visible = false

func _connect_story_signals() -> void:
	StoryManager.choice_requested.connect(_on_choice)
	StoryManager.gallery_unlock_requested.connect(_on_gallery_unlock)
	StoryManager.distraction_free_toggled.connect(_on_distraction_free)
	StoryManager.end_requested.connect(_on_end)


func _connect_ui_signals() -> void:
	auto_timer.timeout.connect(_on_auto_timeout)
	dialogue_layer.typing_finished.connect(_on_typing_finished)

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


func _setup_http_nodes() -> void:
	_stats_http = HTTPRequest.new()
	_stats_http.timeout = 3.0
	add_child(_stats_http)
	_vote_http = HTTPRequest.new()
	_vote_http.timeout = 3.0
	add_child(_vote_http)


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


# === Choices ===

func _on_choice(dialog: String, choices: Array) -> void:
	if dialog and not dialog.is_empty():
		var parts := dialog.split(" ", true, 1)
		if parts.size() >= 2 and parts[0] in StoryManager.characters:
			var char_id := parts[0]
			var char_data: Dictionary = StoryManager.characters[char_id]
			var char_name: String = GameManager.replace_templates(char_data.get("name", ""))
			dialogue_layer.show_choice_dialog(char_id, char_name, parts[1])
		else:
			dialogue_layer.show_raw_text(dialog)
		

	# 선택지 버튼 생성
	for child in choice_panel.get_children():
		child.free()

	for choice in choices:
		var btn := Button.new()
		btn.text = choice.get("text", "")
		btn.custom_minimum_size = Vector2(500, 60)
		var choice_key: String = choice.get("key", "")
		var target: String = choice.get("target", "")

		# 스타일
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.078, 0.039, 0.118, 0.85)
		style.border_color = Color(0.957, 0.561, 0.694, 0.4)
		style.set_border_width_all(1)
		style.set_corner_radius_all(12)
		style.set_content_margin_all(16)
		btn.add_theme_stylebox_override("normal", style)

		var hover_style := style.duplicate()
		hover_style.bg_color = Color(0.157, 0.078, 0.235, 0.95)
		hover_style.border_color = Color(0.957, 0.561, 0.694, 0.8)
		btn.add_theme_stylebox_override("hover", hover_style)

		btn.add_theme_font_size_override("font_size", 20)

		btn.pressed.connect(_on_choice_button_pressed.bind(choice_key, target, btn))
		choice_panel.add_child(btn)

	choice_panel.visible = true

	# 통계 프리뷰 (추적 대상 씬일 때)
	if StoryManager.is_tracked_scene():
		_fetch_preview_stats()


func _on_choice_button_pressed(choice_key: String, target: String, _btn: Button) -> void:
	DebugOverlay.log_message("Choice: %s -> %s" % [choice_key, target])
	AudioManager.play_ui_click()

	if StoryManager.is_tracked_scene():
		_pending_choice_data = {"key": choice_key, "target": target}
		_record_vote_and_show_stats(choice_key)
	else:
		_finalize_choice(choice_key, target)


func _finalize_choice(choice_key: String, target: String) -> void:
	choice_panel.visible = false
	StoryManager.on_choice_selected(choice_key, target)


# === Supabase 선택지 통계 ===

func _fetch_preview_stats() -> void:
	if _supabase_url.is_empty():
		return
	var scene_id := StoryManager.current_label
	var url := _supabase_url + "/api/stats?scene_id=" + scene_id.uri_encode()
	_stats_http.request_completed.connect(_on_preview_stats_received, CONNECT_ONE_SHOT)
	_stats_http.request(url)


func _on_preview_stats_received(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return
	_display_stats_preview(json.data)


func _display_stats_preview(stats: Array) -> void:
	var total := 0
	for s in stats:
		total += int(s.get("vote_count", 0))
	if total == 0:
		return

	for btn in choice_panel.get_children():
		if not btn is Button:
			continue
		# 통계 바는 선택 후에 표시 (프리뷰는 호버 시)


func _record_vote_and_show_stats(choice_key: String) -> void:
	if _supabase_url.is_empty():
		_finalize_choice(_pending_choice_data["key"], _pending_choice_data["target"])
		return

	var scene_id := StoryManager.current_label
	var url := _supabase_url + "/api/vote"
	var body := JSON.stringify({"scene_id": scene_id, "choice_key": choice_key})
	var headers := PackedStringArray(["Content-Type: application/json"])
	_vote_http.request_completed.connect(_on_vote_received, CONNECT_ONE_SHOT)
	_vote_http.request(url, headers, HTTPClient.METHOD_POST, body)


func _on_vote_received(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		var json := JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			await _show_stats_result(json.data, _pending_choice_data["key"])

	_finalize_choice(_pending_choice_data["key"], _pending_choice_data["target"])
	_pending_choice_data = {}


func _show_stats_result(stats: Array, selected_key: String) -> void:
	var total := 0
	for s in stats:
		total += int(s.get("vote_count", 0))
	if total == 0:
		return

	# 각 버튼에 퍼센티지 표시
	for btn in choice_panel.get_children():
		if not btn is Button:
			continue
		btn.disabled = true

	# 2.5초 표시
	await get_tree().create_timer(2.5).timeout

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
