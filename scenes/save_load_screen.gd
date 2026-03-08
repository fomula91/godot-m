extends Control

@onready var title: Label = $VBoxContainer/TopBar/Title
@onready var mode_toggle: Button = $VBoxContainer/TopBar/ModeToggle
@onready var back_btn: Button = $VBoxContainer/TopBar/BackBtn
@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/Grid

var _is_load_mode := false
var _overlay_mode := false
var _return_scene: String = "res://scenes/title_screen.tscn"


func _ready() -> void:
	mode_toggle.toggled.connect(_on_mode_toggled)
	back_btn.pressed.connect(_on_back)
	_build_slots()


func set_mode(load_mode: bool) -> void:
	_is_load_mode = load_mode
	mode_toggle.button_pressed = load_mode
	_update_title()


func set_overlay_mode() -> void:
	_overlay_mode = true


func set_return_scene(scene_path: String) -> void:
	_return_scene = scene_path


func _update_title() -> void:
	title.text = "로드" if _is_load_mode else "세이브"
	mode_toggle.text = "세이브 모드" if _is_load_mode else "로드 모드"


func _on_mode_toggled(toggled: bool) -> void:
	_is_load_mode = toggled
	_update_title()
	_build_slots()


func _build_slots() -> void:
	for child in grid.get_children():
		child.queue_free()

	for i in range(1, GameManager.MAX_SLOTS + 1):
		var slot_panel := PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(500, 120)

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.05, 0.15, 0.8)
		style.border_color = Color(0.957, 0.561, 0.694, 0.2)
		style.set_border_width_all(1)
		style.set_corner_radius_all(8)
		style.set_content_margin_all(12)
		slot_panel.add_theme_stylebox_override("panel", style)

		var vbox := VBoxContainer.new()
		slot_panel.add_child(vbox)

		var meta := GameManager.get_save_meta(i)
		var header := Label.new()

		if meta.is_empty():
			header.text = "슬롯 %d - 비어 있음" % i
			header.add_theme_color_override("font_color", Color(0.5, 0.4, 0.6, 0.5))
		else:
			header.text = "슬롯 %d - %s" % [i, meta.get("current_label", "")]

			var timestamp := Label.new()
			timestamp.text = meta.get("timestamp", "")
			timestamp.add_theme_font_size_override("font_size", 14)
			timestamp.add_theme_color_override("font_color", Color(0.7, 0.6, 0.8, 0.6))
			vbox.add_child(timestamp)

		header.add_theme_font_size_override("font_size", 20)
		vbox.add_child(header)

		var btn := Button.new()
		btn.text = "로드" if _is_load_mode else "세이브"
		btn.custom_minimum_size = Vector2(100, 35)
		btn.disabled = _is_load_mode and meta.is_empty()
		btn.pressed.connect(_on_slot_pressed.bind(i))
		vbox.add_child(btn)

		grid.add_child(slot_panel)


func _on_slot_pressed(slot: int) -> void:
	AudioManager.play_ui_click()
	if _is_load_mode:
		var data := GameManager.load_game(slot)
		if data.is_empty():
			return
		if _overlay_mode:
			var main_scene := get_tree().root.get_node_or_null("MainScene")
			if main_scene:
				main_scene._restore_state(data)
			queue_free()
		else:
			var scene: Node = load("res://scenes/main_scene.tscn").instantiate()
			get_tree().root.add_child(scene)
			scene._restore_state(data)
			queue_free()
	else:
		# 세이브 - main_scene에서 데이터 가져오기
		var main_scene := get_tree().root.get_node_or_null("MainScene")
		if main_scene:
			var extra := StoryManager.get_save_data()
			extra["background"] = main_scene.get_node("BackgroundLayer").get_current_bg_id()
			extra["bgm"] = AudioManager.get_current_bgm()
			extra["characters"] = main_scene.get_node("CharacterLayer").get_state()
			GameManager.save_game(slot, extra)
		_build_slots()


func _on_back() -> void:
	AudioManager.play_ui_click()
	if _overlay_mode:
		queue_free()
	else:
		get_tree().change_scene_to_file(_return_scene)
