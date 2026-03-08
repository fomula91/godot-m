extends Control

@onready var music_slider: HSlider = $CenterContainer/VBoxContainer/MusicRow/MusicSlider
@onready var sound_slider: HSlider = $CenterContainer/VBoxContainer/SoundRow/SoundSlider
@onready var text_speed_slider: HSlider = $CenterContainer/VBoxContainer/TextSpeedRow/TextSpeedSlider
@onready var auto_speed_slider: HSlider = $CenterContainer/VBoxContainer/AutoSpeedRow/AutoSpeedSlider
@onready var back_btn: Button = $CenterContainer/VBoxContainer/BackBtn

var _overlay_mode := false


func set_overlay_mode() -> void:
	_overlay_mode = true


func _ready() -> void:
	# 현재 설정 로드
	music_slider.value = GameManager.settings["music_volume"]
	sound_slider.value = GameManager.settings["sound_volume"]
	text_speed_slider.value = GameManager.settings["text_speed"]
	auto_speed_slider.value = GameManager.settings["auto_speed"]

	# 시그널 연결
	music_slider.value_changed.connect(_on_music_changed)
	sound_slider.value_changed.connect(_on_sound_changed)
	text_speed_slider.value_changed.connect(_on_text_speed_changed)
	auto_speed_slider.value_changed.connect(_on_auto_speed_changed)
	back_btn.pressed.connect(_on_back)


func _on_music_changed(value: float) -> void:
	GameManager.settings["music_volume"] = value
	AudioManager.apply_volumes()
	GameManager.save_settings()


func _on_sound_changed(value: float) -> void:
	GameManager.settings["sound_volume"] = value
	AudioManager.apply_volumes()
	GameManager.save_settings()


func _on_text_speed_changed(value: float) -> void:
	GameManager.settings["text_speed"] = value
	GameManager.save_settings()


func _on_auto_speed_changed(value: float) -> void:
	GameManager.settings["auto_speed"] = value
	GameManager.save_settings()


func _on_back() -> void:
	AudioManager.play_ui_click()
	if _overlay_mode:
		queue_free()
	else:
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
