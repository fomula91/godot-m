extends Control

const GALLERY_IDS: Array[String] = [
	"first-lunch", "seat-assignment", "group-project", "math-class",
	"jeju-together", "jeju-delivery", "sports-festival", "birthday-gift",
	"city-outing", "sua-confession", "ending-a", "ending-b", "ending-c",
]

const GALLERY_FILES: Dictionary = {
	"first-lunch": "first_lunch.webp",
	"seat-assignment": "seat_assignment.webp",
	"group-project": "group_project.webp",
	"math-class": "math_class.webp",
	"jeju-together": "jeju_together.webp",
	"jeju-delivery": "jeju_delivery.webp",
	"sports-festival": "sports_festival.webp",
	"birthday-gift": "birthday_gift.webp",
	"city-outing": "city_outing.webp",
	"sua-confession": "sua_confession.webp",
	"ending-a": "ending_a.webp",
	"ending-b": "ending_b.webp",
	"ending-c": "ending_c.webp",
}

@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/Grid
@onready var back_btn: Button = $VBoxContainer/TopBar/BackBtn
@onready var fullscreen_bg: ColorRect = $FullscreenBG
@onready var fullscreen_viewer: TextureRect = $FullscreenViewer

var close_btn: Button


func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	_style_back_btn()
	_create_close_btn()
	_build_gallery()


func _build_gallery() -> void:
	for id in GALLERY_IDS:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(320, 180)
		panel.clip_contents = true

		var unlocked := id in GameManager.gallery_unlocked
		var file_name: String = GALLERY_FILES.get(id, "")

		if unlocked and not file_name.is_empty():
			var path := "res://assets/gallery/" + file_name
			var tex := load(path) as Texture2D
			if tex:
				var tex_rect := TextureRect.new()
				tex_rect.texture = tex
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
				tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
				panel.add_child(tex_rect)

			var btn := Button.new()
			btn.set_anchors_preset(Control.PRESET_FULL_RECT)
			btn.modulate.a = 0.0
			btn.pressed.connect(_view_image.bind(id))
			panel.add_child(btn)
		else:
			# 잠긴 CG
			var style := StyleBoxFlat.new()
			style.bg_color = Color(0.1, 0.05, 0.15, 1.0)
			style.set_corner_radius_all(8)
			panel.add_theme_stylebox_override("panel", style)

			var lock_label := Label.new()
			lock_label.text = "?"
			lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lock_label.set_anchors_preset(Control.PRESET_FULL_RECT)
			lock_label.add_theme_font_size_override("font_size", 48)
			lock_label.add_theme_color_override("font_color", Color(0.5, 0.3, 0.6, 0.5))
			panel.add_child(lock_label)

		grid.add_child(panel)


func _style_back_btn() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.078, 0.039, 0.118, 0.7)
	style.border_color = Color(0.957, 0.561, 0.694, 0.3)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(12)
	back_btn.add_theme_stylebox_override("normal", style)

	var hover := style.duplicate()
	hover.bg_color = Color(0.157, 0.078, 0.235, 0.9)
	hover.border_color = Color(0.957, 0.561, 0.694, 0.6)
	back_btn.add_theme_stylebox_override("hover", hover)


func _create_close_btn() -> void:
	close_btn = Button.new()
	close_btn.text = "✕ 닫기"
	close_btn.visible = false
	close_btn.z_index = 10
	close_btn.anchor_left = 1.0
	close_btn.anchor_top = 0.0
	close_btn.anchor_right = 1.0
	close_btn.anchor_bottom = 0.0
	close_btn.offset_left = -120
	close_btn.offset_top = 20
	close_btn.offset_right = -20
	close_btn.offset_bottom = 60
	close_btn.add_theme_font_size_override("font_size", 20)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.078, 0.039, 0.118, 0.7)
	style.border_color = Color(0.957, 0.561, 0.694, 0.3)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(8)
	close_btn.add_theme_stylebox_override("normal", style)

	var hover := style.duplicate()
	hover.bg_color = Color(0.157, 0.078, 0.235, 0.9)
	hover.border_color = Color(0.957, 0.561, 0.694, 0.6)
	close_btn.add_theme_stylebox_override("hover", hover)

	close_btn.pressed.connect(_close_fullscreen)
	add_child(close_btn)


func _close_fullscreen() -> void:
	fullscreen_bg.visible = false
	fullscreen_viewer.visible = false
	close_btn.visible = false


func _view_image(id: String) -> void:
	var file_name: String = GALLERY_FILES.get(id, "")
	if file_name.is_empty():
		return
	var tex := load("res://assets/gallery/" + file_name) as Texture2D
	if tex:
		fullscreen_viewer.texture = tex
		fullscreen_bg.visible = true
		fullscreen_viewer.visible = true
		close_btn.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if fullscreen_viewer.visible and event is InputEventMouseButton and event.pressed:
		_close_fullscreen()
		get_viewport().set_input_as_handled()


func _on_back() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
