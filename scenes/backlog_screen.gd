extends CanvasLayer
## 대화 백로그(기록) 모달 화면
## main_scene에서 get_dialogue_log()로 받은 데이터를 표시

const CLOSE_ICON := preload("res://assets/ui/gallery/close.png")
const SPEAKER_ICON := preload("res://assets/ui/backlog/speaker.png")

@onready var backdrop: ColorRect = $Root/Backdrop
@onready var log_list: VBoxContainer = $Root/Window/Margin/VBox/Scroll/LogList
@onready var close_btn: Button = $Root/Window/Margin/VBox/TopBar/CloseBtn
@onready var scroll: ScrollContainer = $Root/Window/Margin/VBox/Scroll


func _ready() -> void:
	close_btn.icon = CLOSE_ICON
	close_btn.expand_icon = true
	close_btn.pressed.connect(close)
	backdrop.gui_input.connect(_on_backdrop_input)


func show_log(entries: Array) -> void:
	for child in log_list.get_children():
		child.queue_free()

	for entry in entries:
		var entry_dict: Dictionary = entry
		log_list.add_child(_build_entry_row(entry_dict))

	await get_tree().process_frame
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)


func close() -> void:
	AudioManager.play_ui_click()
	queue_free()


func _build_entry_row(entry: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)

	var name_text: String = entry.get("name", "")
	if not name_text.is_empty():
		var name_label := Label.new()
		name_label.text = name_text
		name_label.add_theme_font_size_override("font_size", 18)
		name_label.add_theme_color_override("font_color", Color(0.957, 0.561, 0.694, 1.0))
		text_box.add_child(name_label)

	var text_label := RichTextLabel.new()
	text_label.bbcode_enabled = true
	text_label.fit_content = true
	text_label.text = entry.get("text", "")
	text_label.add_theme_font_size_override("normal_font_size", 18)
	text_label.add_theme_color_override("default_color", Color.WHITE)
	text_label.custom_minimum_size = Vector2(0, 40)
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_child(text_label)

	var voice_btn := Button.new()
	voice_btn.icon = SPEAKER_ICON
	voice_btn.expand_icon = true
	voice_btn.custom_minimum_size = Vector2(32, 32)
	voice_btn.flat = true
	voice_btn.disabled = true
	voice_btn.tooltip_text = "음성 재생(미구현)"
	row.add_child(voice_btn)

	return row


func _on_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
