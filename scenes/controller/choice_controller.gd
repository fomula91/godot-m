extends VBoxContainer
## 선택지 표시, 버튼 생성, Supabase 통계 처리

const CHOICE_BG := preload("res://assets/ui/choice_button.png")

@onready var dialogue_layer: Control = $"../DialogueLayer"

# Supabase 설정
var _supabase_url: String = ""
var _stats_http: HTTPRequest
var _vote_http: HTTPRequest
var _pending_choice_data: Dictionary = {}

func _ready() -> void:
	StoryManager.choice_requested.connect(_on_choice)

	_stats_http = HTTPRequest.new()
	_stats_http.timeout = 3.0
	add_child(_stats_http)
	_vote_http = HTTPRequest.new()
	_vote_http.timeout = 3.0
	add_child(_vote_http)


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
	for child in get_children():
		if child == _stats_http or child == _vote_http:
			continue
		child.free()

	for choice in choices:
		var btn := Button.new()
		btn.text = choice.get("text", "")
		btn.custom_minimum_size = Vector2(500, 120)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var choice_key: String = choice.get("key", "")
		var target: String = choice.get("target", "")

		var style := StyleBoxTexture.new()
		style.texture = CHOICE_BG
		style.set_content_margin_all(16)
		btn.add_theme_stylebox_override("normal", style)

		var hover_style: StyleBoxTexture = style.duplicate()
		hover_style.modulate_color = Color(1.2, 1.2, 1.35, 1.0)
		btn.add_theme_stylebox_override("hover", hover_style)

		var pressed_style: StyleBoxTexture = style.duplicate()
		pressed_style.modulate_color = Color(0.85, 0.85, 0.95, 1.0)
		btn.add_theme_stylebox_override("pressed", pressed_style)

		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 20)

		btn.pressed.connect(_on_choice_button_pressed.bind(choice_key, target, btn))
		add_child(btn)

	visible = true

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
	visible = false
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

	for btn in get_children():
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
	for btn in get_children():
		if not btn is Button:
			continue
		btn.disabled = true

	# 2.5초 표시
	await get_tree().create_timer(2.5).timeout
