extends Control

## VN 플레이 화면 메인 컨트롤러
## StoryManager 시그널을 받아 UI 컴포넌트 업데이트

# 노드 참조
@onready var bg1: TextureRect = $BackgroundLayer/Background1
@onready var bg2: TextureRect = $BackgroundLayer/Background2
@onready var dialogue_box: PanelContainer = $UILayer/DialogueBox
@onready var name_label: Label = $UILayer/DialogueBox/MarginContainer/VBoxContainer/NameLabel
@onready var text_label: RichTextLabel = $UILayer/DialogueBox/MarginContainer/VBoxContainer/TextLabel
@onready var choice_panel: VBoxContainer = $UILayer/ChoicePanel
@onready var centered_text: Label = $UILayer/CenteredText
@onready var quick_menu: HBoxContainer = $UILayer/QuickMenu
@onready var auto_timer: Timer = $AutoTimer

# 상태
var _typing := false
var _typing_tween: Tween
var _auto_mode := false
var _skip_mode := false
var _distraction_free := false
var _current_bg_id: String = ""
var _dialogue_log: Array[Dictionary] = []
var _bg_tween: Tween


# Supabase 설정
var _supabase_url: String = ""
var _stats_http: HTTPRequest
var _vote_http: HTTPRequest
var _pending_choice_data: Dictionary = {}


func _ready() -> void:
	_apply_dialogue_box_style()
	_connect_story_signals()
	_connect_ui_signals()
	_setup_http_nodes()
	_setup_mouse_passthrough()
	dialogue_box.visible = false
	choice_panel.visible = false
	centered_text.visible = false


func _connect_story_signals() -> void:
	StoryManager.dialogue_requested.connect(_on_dialogue)
	StoryManager.narration_requested.connect(_on_narration)
	StoryManager.centered_requested.connect(_on_centered)
	StoryManager.choice_requested.connect(_on_choice)
	StoryManager.scene_change_requested.connect(_on_scene_change)
	StoryManager.gallery_unlock_requested.connect(_on_gallery_unlock)
	StoryManager.distraction_free_toggled.connect(_on_distraction_free)
	StoryManager.end_requested.connect(_on_end)


func _connect_ui_signals() -> void:
	auto_timer.timeout.connect(_on_auto_timeout)

	# Quick menu
	$UILayer/QuickMenu/SaveBtn.pressed.connect(func(): _quick_save())
	$UILayer/QuickMenu/LoadBtn.pressed.connect(func(): _quick_load())
	$UILayer/QuickMenu/AutoBtn.toggled.connect(func(v): _toggle_auto(v))
	$UILayer/QuickMenu/SkipBtn.toggled.connect(func(v): _toggle_skip(v))
	$UILayer/QuickMenu/SettingsBtn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/settings_screen.tscn"))


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
	_set_mouse_ignore_recursive(dialogue_box)
	centered_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	choice_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quick_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _set_mouse_ignore_recursive(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_mouse_ignore_recursive(child)


func _apply_dialogue_box_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.078, 0.039, 0.118, 0.82)  # rgba(20,10,30,0.82)
	style.border_color = Color(0.957, 0.561, 0.694, 0.2)  # rgba(244,143,177,0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(20)
	dialogue_box.add_theme_stylebox_override("panel", style)


# === Input ===

func _unhandled_input(event: InputEvent) -> void:
	if $OverlayLayer.is_input_active():
		return
	if event.is_action_pressed("vn_advance"):
		_handle_advance_input()
		get_viewport().set_input_as_handled()


func _handle_advance_input() -> void:
	AudioManager.play_ui_click()
	DebugOverlay.log_message("Advance input")

	if _distraction_free:
		_distraction_free = false
		dialogue_box.visible = true
		quick_menu.visible = true
		return

	if centered_text.visible:
		centered_text.visible = false
		StoryManager.advance()
		return

	if _typing:
		_complete_typing()
		return

	if choice_panel.visible:
		return

	StoryManager.advance()


# === Dialogue ===

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


func _start_typing(text: String) -> void:
	text_label.text = text
	text_label.visible_ratio = 0.0
	_typing = true

	if _typing_tween:
		_typing_tween.kill()

	var char_count := text.length()
	var speed_ms: float = GameManager.settings["text_speed"]
	var duration: float = char_count * speed_ms / 1000.0

	if _skip_mode:
		duration = 0.05

	_typing_tween = create_tween()
	_typing_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	_typing_tween.finished.connect(_on_typing_done)


func _complete_typing() -> void:
	if _typing_tween:
		_typing_tween.kill()
	text_label.visible_ratio = 1.0
	_on_typing_done()


func _on_typing_done() -> void:
	_typing = false
	if _auto_mode:
		auto_timer.wait_time = GameManager.settings["auto_speed"]
		auto_timer.start()
	elif _skip_mode:
		_auto_advance_delayed(0.05)


func _on_auto_timeout() -> void:
	if _auto_mode and not _typing and not choice_panel.visible:
		StoryManager.advance()


func _auto_advance_delayed(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if not choice_panel.visible:
		StoryManager.advance()


# === Choices ===

func _on_choice(dialog: String, choices: Array) -> void:
	if dialog and not dialog.is_empty():
		# 선택지 대사를 대화창에 표시
		var parts := dialog.split(" ", true, 1)
		if parts.size() >= 2 and parts[0] in StoryManager.characters:
			var char_id := parts[0]
			var char_data: Dictionary = StoryManager.characters[char_id]
			var char_name: String = GameManager.replace_templates(char_data.get("name", ""))
			name_label.text = char_name
			name_label.add_theme_color_override("font_color", StoryManager.get_character_color(char_id))
			name_label.visible = true
			text_label.text = parts[1]
			text_label.visible_ratio = 1.0
		else:
			name_label.visible = false
			text_label.text = dialog
			text_label.visible_ratio = 1.0
		dialogue_box.visible = true

	# 선택지 버튼 생성
	for child in choice_panel.get_children():
		child.queue_free()

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


# === Scene & Characters ===

func _on_scene_change(id: String, transition: String) -> void:
	DebugOverlay.log_message("Scene: %s (%s)" % [id, transition])
	_current_bg_id = id

	if id.begins_with("#"):
		# 색상 배경
		var color := Color(id)
		bg1.texture = null
		bg1.modulate = color
		bg2.texture = null
		bg2.modulate = Color(1,1,1,0)
		$OverlayLayer.clear_transition()
		return

	var path := StoryManager.get_scene_path(id)
	if path.is_empty():
		return

	var tex := load(path) as Texture2D
	if not tex:
		push_warning("MainScene: Cannot load scene texture: " + path)
		return

	$OverlayLayer.clear_transition()

	match transition:
		"instant":
			bg1.texture = tex
			bg1.modulate.a = 1.0
		"fadeIn", "fadeFromBlack duration 1500", _:
			# 이전 트윈이 진행 중이면 즉시 완료 처리
			if _bg_tween and _bg_tween.is_running():
				_bg_tween.kill()
				bg1.texture = bg2.texture
				bg1.modulate.a = 1.0
				bg2.modulate.a = 0.0

			bg2.texture = tex
			bg2.modulate.a = 0.0
			_bg_tween = create_tween()
			_bg_tween.tween_property(bg2, "modulate:a", 1.0, 1.0)
			_bg_tween.finished.connect(func():
				bg1.texture = bg2.texture
				bg1.modulate.a = 1.0
				bg2.modulate.a = 0.0
			)


# === Gallery & Misc ===

func _on_gallery_unlock(id: String) -> void:
	GameManager.unlock_gallery(id)


func _on_distraction_free() -> void:
	_distraction_free = !_distraction_free
	dialogue_box.visible = !_distraction_free
	quick_menu.visible = !_distraction_free


func _on_end() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


# === Auto/Skip ===

func _toggle_auto(enabled: bool) -> void:
	_auto_mode = enabled
	if enabled:
		_skip_mode = false
		$UILayer/QuickMenu/SkipBtn.button_pressed = false
		if not _typing and not choice_panel.visible:
			auto_timer.start()
	else:
		auto_timer.stop()


func _toggle_skip(enabled: bool) -> void:
	_skip_mode = enabled
	if enabled:
		_auto_mode = false
		$UILayer/QuickMenu/AutoBtn.button_pressed = false
		if not _typing and not choice_panel.visible:
			StoryManager.advance()


# === Quick Save/Load ===

func _quick_save() -> void:
	var extra := StoryManager.get_save_data()
	extra["background"] = _current_bg_id
	extra["bgm"] = AudioManager.get_current_bgm()
	extra["characters"] = $CharacterLayer.get_state()
	GameManager.save_game(0, extra)  # slot 0 = auto/quick


func _quick_load() -> void:
	var data := GameManager.load_game(0)
	if data.is_empty():
		return
	_restore_state(data)


func _restore_state(data: Dictionary) -> void:
	# 배경 복원
	if data.has("background") and not data["background"].is_empty():
		_on_scene_change(data["background"], "instant")

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
	return _dialogue_log
