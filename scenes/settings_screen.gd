extends Control

@onready var music_slider: HSlider = $CenterContainer/VBoxContainer/MusicRow/MusicSlider
@onready var sound_slider: HSlider = $CenterContainer/VBoxContainer/SoundRow/SoundSlider
@onready var text_speed_slider: HSlider = $CenterContainer/VBoxContainer/TextSpeedRow/TextSpeedSlider
@onready var auto_speed_slider: HSlider = $CenterContainer/VBoxContainer/AutoSpeedRow/AutoSpeedSlider
@onready var window_mode_option: OptionButton = $CenterContainer/VBoxContainer/WindowModeRow/WindowModeOption
@onready var resolution_option: OptionButton = $CenterContainer/VBoxContainer/ResolutionRow/ResolutionOption
@onready var back_btn: Button = $CenterContainer/VBoxContainer/BackBtn

const RESOLUTIONS: Array[String] = [
	"3840x2160", "2560x1440", "1920x1080",
	"1600x900", "1280x720", "960x540",
]
const WINDOW_MODES: Array[String] = ["창모드", "전체화면(창모드)", "전체화면"]

var _overlay_mode := false


func set_overlay_mode() -> void:
	_overlay_mode = true


func _ready() -> void:
	# 현재 설정 로드
	music_slider.value = GameManager.settings["music_volume"]
	sound_slider.value = GameManager.settings["sound_volume"]
	text_speed_slider.value = GameManager.settings["text_speed"]
	auto_speed_slider.value = 10.5 - GameManager.settings["auto_speed"]

	# 화면 모드 옵션 초기화
	for mode_name in WINDOW_MODES:
		window_mode_option.add_item(mode_name)
	window_mode_option.selected = int(GameManager.settings.get("window_mode", 0))

	# 해상도 옵션 초기화
	for res in RESOLUTIONS:
		resolution_option.add_item(res)
	var current_res: String = GameManager.settings.get("resolution", "1920x1080")
	var res_idx := RESOLUTIONS.find(current_res)
	resolution_option.selected = res_idx if res_idx >= 0 else 2

	# 시그널 연결
	music_slider.value_changed.connect(_on_music_changed)
	sound_slider.value_changed.connect(_on_sound_changed)
	text_speed_slider.value_changed.connect(_on_text_speed_changed)
	auto_speed_slider.value_changed.connect(_on_auto_speed_changed)
	window_mode_option.item_selected.connect(_on_window_mode_changed)
	resolution_option.item_selected.connect(_on_resolution_changed)
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
	GameManager.settings["auto_speed"] = 10.5 - value
	GameManager.save_settings()


func _on_window_mode_changed(index: int) -> void:
	GameManager.settings["window_mode"] = index
	GameManager.apply_display_settings()
	GameManager.save_settings()


func _on_resolution_changed(index: int) -> void:
	GameManager.settings["resolution"] = RESOLUTIONS[index]
	GameManager.apply_display_settings()
	GameManager.save_settings()


func _on_back() -> void:
	AudioManager.play_ui_click()
	if _overlay_mode:
		queue_free()
	else:
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
