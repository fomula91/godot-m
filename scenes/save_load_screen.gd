extends Control

@onready var title: Label = $VBoxContainer/TopBar/Title
@onready var mode_toggle: Button = $VBoxContainer/TopBar/ModeToggle
@onready var back_btn: Button = $VBoxContainer/TopBar/BackBtn
@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/Grid

var _is_load_mode := false
var _overlay_mode := false
var _return_scene: String = "res://scenes/title_screen.tscn"

# 확인 다이얼로그
var _confirm_panel: PanelContainer
var _confirm_label: Label
var _pending_slot: int = -1


func _ready() -> void:
	mode_toggle.toggled.connect(_on_mode_toggled)
	back_btn.pressed.connect(_on_back)
	mode_toggle.button_pressed = _is_load_mode
	_update_title()
	_build_slots()
	_build_confirm_panel()


func set_mode(load_mode: bool) -> void:
	_is_load_mode = load_mode
	if is_node_ready():
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
		_show_confirm("슬롯 %d을(를) 로드하시겠습니까?\n현재 진행이 초기화됩니다." % slot, slot)
	else:
		var meta := GameManager.get_save_meta(slot)
		if not meta.is_empty():
			_show_confirm("슬롯 %d에 덮어쓰시겠습니까?" % slot, slot)
		else:
			_execute_save(slot)


func _execute_load(slot: int) -> void:
	var data := GameManager.load_game(slot)
	if data.is_empty():
		return
	if _overlay_mode:
		var main_scene := get_tree().root.get_node_or_null("MainScene")
		if main_scene:
			# 시그널 연결 해제 (queue_free 시 중복 호출 방지)
			if tree_exiting.is_connected(main_scene._on_modal_closed):
				tree_exiting.disconnect(main_scene._on_modal_closed)
			main_scene._on_modal_closed()  # 모달 상태 먼저 정리
			main_scene._restore_state(data)
		queue_free()
	else:
		var scene: Node = load("res://scenes/main_scene.tscn").instantiate()
		get_tree().root.add_child(scene)
		scene._restore_state(data)
		queue_free()


func _execute_save(slot: int) -> void:
	var main_scene := get_tree().root.get_node_or_null("MainScene")
	if main_scene:
		var extra := StoryManager.get_save_data()
		extra["background"] = main_scene.get_node("BackgroundLayer").get_current_bg_id()
		extra["bgm"] = AudioManager.get_current_bgm()
		extra["characters"] = main_scene.get_node("CharacterLayer").get_state()
		GameManager.save_game(slot, extra)
	_build_slots()


# === 확인 다이얼로그 ===

func _build_confirm_panel() -> void:
	_confirm_panel = PanelContainer.new()
	_confirm_panel.visible = false
	_confirm_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_confirm_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.0, 0.0, 0.0, 0.6)
	_confirm_panel.add_theme_stylebox_override("panel", bg_style)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_confirm_panel.add_child(center)

	var inner := PanelContainer.new()
	inner.custom_minimum_size = Vector2(420, 180)
	var inner_style := StyleBoxFlat.new()
	inner_style.bg_color = Color(0.1, 0.05, 0.15, 0.95)
	inner_style.border_color = Color(0.957, 0.561, 0.694, 0.6)
	inner_style.set_border_width_all(2)
	inner_style.set_corner_radius_all(12)
	inner_style.set_content_margin_all(24)
	inner.add_theme_stylebox_override("panel", inner_style)
	center.add_child(inner)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	inner.add_child(vbox)

	_confirm_label = Label.new()
	_confirm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirm_label.add_theme_font_size_override("font_size", 22)
	vbox.add_child(_confirm_label)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 24)
	vbox.add_child(btn_row)

	var yes_btn := Button.new()
	yes_btn.text = "예"
	yes_btn.custom_minimum_size = Vector2(100, 45)
	yes_btn.add_theme_font_size_override("font_size", 20)
	yes_btn.pressed.connect(_on_confirm_yes)
	btn_row.add_child(yes_btn)

	var no_btn := Button.new()
	no_btn.text = "아니오"
	no_btn.custom_minimum_size = Vector2(100, 45)
	no_btn.add_theme_font_size_override("font_size", 20)
	no_btn.pressed.connect(_on_confirm_no)
	btn_row.add_child(no_btn)

	add_child(_confirm_panel)


func _show_confirm(message: String, slot: int) -> void:
	_pending_slot = slot
	_confirm_label.text = message
	_confirm_panel.visible = true


func _hide_confirm() -> void:
	_confirm_panel.visible = false
	_pending_slot = -1


func _on_confirm_yes() -> void:
	AudioManager.play_ui_click()
	var slot := _pending_slot
	_hide_confirm()
	if _is_load_mode:
		_execute_load(slot)
	else:
		_execute_save(slot)


func _on_confirm_no() -> void:
	AudioManager.play_ui_click()
	_hide_confirm()


func _on_back() -> void:
	AudioManager.play_ui_click()
	if _confirm_panel.visible:
		_hide_confirm()
		return
	if _overlay_mode:
		queue_free()
	else:
		get_tree().change_scene_to_file(_return_scene)
