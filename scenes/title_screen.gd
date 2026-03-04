extends Control

@onready var start_btn: Button = $CenterContainer/VBoxContainer/StartBtn
@onready var continue_btn: Button = $CenterContainer/VBoxContainer/ContinueBtn
@onready var gallery_btn: Button = $CenterContainer/VBoxContainer/GalleryBtn
@onready var settings_btn: Button = $CenterContainer/VBoxContainer/SettingsBtn
@onready var background: TextureRect = $Background


func _ready() -> void:
	# 타이틀 배경
	var bg_tex := load("res://assets/backgrounds/Auditorium_Outside_Sunrise.webp") as Texture2D
	if bg_tex:
		background.texture = bg_tex

	# BGM
	AudioManager.play_music("sunny-day")

	# 이어하기 버튼 활성화 체크
	continue_btn.disabled = not GameManager.has_save(0)

	# 버튼 스타일
	_style_buttons()

	# 시그널 연결
	start_btn.pressed.connect(_on_start)
	continue_btn.pressed.connect(_on_continue)
	gallery_btn.pressed.connect(_on_gallery)
	settings_btn.pressed.connect(_on_settings)


func _style_buttons() -> void:
	for btn in [start_btn, continue_btn, gallery_btn, settings_btn]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.078, 0.039, 0.118, 0.7)
		style.border_color = Color(0.957, 0.561, 0.694, 0.3)
		style.set_border_width_all(1)
		style.set_corner_radius_all(12)
		style.set_content_margin_all(12)
		btn.add_theme_stylebox_override("normal", style)

		var hover := style.duplicate()
		hover.bg_color = Color(0.157, 0.078, 0.235, 0.9)
		hover.border_color = Color(0.957, 0.561, 0.694, 0.6)
		btn.add_theme_stylebox_override("hover", hover)

		btn.pressed.connect(AudioManager.play_ui_click)


func _on_start() -> void:
	GameManager.reset_state()
	var scene: Node = load("res://scenes/main_scene.tscn").instantiate()
	get_tree().root.add_child(scene)
	scene.start_story("Start")
	queue_free()


func _on_continue() -> void:
	var data := GameManager.load_game(0)
	if data.is_empty():
		return
	var scene: Node = load("res://scenes/main_scene.tscn").instantiate()
	get_tree().root.add_child(scene)
	scene._restore_state(data)
	queue_free()


func _on_gallery() -> void:
	get_tree().change_scene_to_file("res://scenes/gallery_screen.tscn")


func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_screen.tscn")
