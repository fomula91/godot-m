extends Node

## BGM/SFX 관리 싱글턴

var _bgm_player: AudioStreamPlayer
var _bgm_player2: AudioStreamPlayer  # 크로스페이드용
var _sfx_player: AudioStreamPlayer
var _ui_sfx_player: AudioStreamPlayer

var _current_bgm: String = ""
var _crossfade_tween: Tween

const MUSIC_PATH := "res://assets/music/"
const SOUND_PATH := "res://assets/sounds/"
const CROSSFADE_DURATION := 1.0


func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Music"
	add_child(_bgm_player)

	_bgm_player2 = AudioStreamPlayer.new()
	_bgm_player2.bus = "Music"
	add_child(_bgm_player2)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	add_child(_sfx_player)

	_ui_sfx_player = AudioStreamPlayer.new()
	_ui_sfx_player.bus = "SFX"
	add_child(_ui_sfx_player)

	_setup_audio_buses()


func _setup_audio_buses() -> void:
	# Music bus
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
	# SFX bus
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
	apply_volumes()


func apply_volumes() -> void:
	var music_idx := AudioServer.get_bus_index("Music")
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(GameManager.settings["music_volume"]))
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(GameManager.settings["sound_volume"]))


func play_music(id: String, loop: bool = true) -> void:
	if id == _current_bgm:
		return
	var path := MUSIC_PATH + id
	if not path.ends_with(".mp3"):
		path += ".mp3"
	var stream := load(path) as AudioStream
	if not stream:
		push_warning("AudioManager: BGM not found: " + path)
		return

	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = loop

	if _current_bgm.is_empty():
		_bgm_player.stream = stream
		_bgm_player.play()
	else:
		# 크로스페이드
		_bgm_player2.stream = stream
		_bgm_player2.volume_db = -80.0
		_bgm_player2.play()
		if _crossfade_tween:
			_crossfade_tween.kill()
		_crossfade_tween = create_tween().set_parallel(true)
		_crossfade_tween.tween_property(_bgm_player, "volume_db", -80.0, CROSSFADE_DURATION)
		_crossfade_tween.tween_property(_bgm_player2, "volume_db", 0.0, CROSSFADE_DURATION)
		_crossfade_tween.finished.connect(_on_crossfade_done)

	_current_bgm = id


func _on_crossfade_done() -> void:
	_bgm_player.stop()
	# Swap players
	var temp := _bgm_player
	_bgm_player = _bgm_player2
	_bgm_player2 = temp


func stop_music(fade: float = 1.0) -> void:
	if _current_bgm.is_empty():
		return
	_current_bgm = ""
	if fade > 0:
		var tw := create_tween()
		tw.tween_property(_bgm_player, "volume_db", -80.0, fade)
		tw.finished.connect(_bgm_player.stop)
	else:
		_bgm_player.stop()


func play_sound(id: String) -> void:
	var path := SOUND_PATH + id
	if not path.ends_with(".mp3"):
		path += ".mp3"
	var stream := load(path) as AudioStream
	if not stream:
		push_warning("AudioManager: SFX not found: " + path)
		return
	_sfx_player.stream = stream
	_sfx_player.play()


func stop_sound() -> void:
	_sfx_player.stop()


func play_ui_click() -> void:
	var stream := load(SOUND_PATH + "Select.mp3") as AudioStream
	if stream:
		_ui_sfx_player.stream = stream
		_ui_sfx_player.play()


func get_current_bgm() -> String:
	return _current_bgm
