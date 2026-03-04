extends Control

const GALLERY_IDS: Array[String] = [
	"opening-unknown", "silhouette", "rooftop-hana", "library-sora", "photo-discovery",
	"crane-gift", "sora-sunset-smile", "hana-sunset-promise", "three-walk-home", "busstop-silhouette",
	"sora-exhibition", "rooftop-sakura-rain", "three-hands",
	"pool-secret", "hana-unmasked", "yuu-first-meet", "sora-past-tears",
	"sora-confession", "sora-truelove", "hana-confession", "hana-truelove",
	"together-letter", "sora-warm", "hana-warm",
]

const GALLERY_FILES: Dictionary = {
	"opening-unknown": "opening.webp",
	"silhouette": "silhouette.webp",
	"rooftop-hana": "rooftop-hana.webp",
	"library-sora": "library-sora.webp",
	"photo-discovery": "photo-discovery.webp",
	"crane-gift": "crane-gift.webp",
	"sora-sunset-smile": "sora-sunset-smile.webp",
	"hana-sunset-promise": "hana-sunset-promise.webp",
	"three-walk-home": "three-walk-home.webp",
	"busstop-silhouette": "busstop-silhouette.webp",
	"sora-exhibition": "sora-exhibition.webp",
	"rooftop-sakura-rain": "rooftop-sakura-rain.webp",
	"three-hands": "three-hands.webp",
	"pool-secret": "pool-secret.webp",
	"hana-unmasked": "hana-unmasked.webp",
	"yuu-first-meet": "yuu-first-meet.webp",
	"sora-past-tears": "sora-past-tears.webp",
	"sora-confession": "sora-confession.webp",
	"sora-truelove": "sora-truelove.webp",
	"hana-confession": "hana-confession.webp",
	"hana-truelove": "hana-truelove.webp",
	"together-letter": "together-letter.webp",
	"sora-warm": "sora-warm.webp",
	"hana-warm": "hana-warm.webp",
}

@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/Grid
@onready var back_btn: Button = $VBoxContainer/TopBar/BackBtn
@onready var fullscreen_viewer: TextureRect = $FullscreenViewer


func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	_build_gallery()


func _build_gallery() -> void:
	for id in GALLERY_IDS:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(320, 180)

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
			style.bg_color = Color(0.1, 0.05, 0.15, 0.8)
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


func _view_image(id: String) -> void:
	var file_name: String = GALLERY_FILES.get(id, "")
	if file_name.is_empty():
		return
	var tex := load("res://assets/gallery/" + file_name) as Texture2D
	if tex:
		fullscreen_viewer.texture = tex
		fullscreen_viewer.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if fullscreen_viewer.visible and event is InputEventMouseButton and event.pressed:
		fullscreen_viewer.visible = false
		get_viewport().set_input_as_handled()


func _on_back() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
