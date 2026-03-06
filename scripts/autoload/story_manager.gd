extends Node

## 스토리 매니저 싱글턴
## JSON 스토리 파일 로드, 명령 디스패치, 라벨 점프

signal dialogue_requested(character: String, name_text: String, text: String)
signal narration_requested(text: String)
signal centered_requested(text: String)
signal choice_requested(dialog: String, choices: Array)
signal scene_change_requested(id: String, transition: String)
signal character_show_requested(id: String, sprite: String, position: String, transition: String)
signal character_hide_requested(id: String, transition: String)
signal character_sprite_changed(id: String, sprite: String)
signal fade_requested(fade_type: String, duration: float, color: Color)
signal wait_requested(duration: float)
signal input_requested(prompt: String, warning: String)
signal affinity_hint_requested(character: String)
signal gallery_unlock_requested(id: String)
signal distraction_free_toggled()
signal end_requested()
signal command_completed()

# 캐릭터 정의 (script.js 기반)
var characters: Dictionary = {
	"p": {"name": "{{player.name}}", "color": "#ffa726", "directory": "haru", "sprites": {
		"normal": "haru_A100.webp", "happy": "haru_A101.webp",
		"angry": "haru_A102.webp", "surprised": "haru_A104.webp", "worried": "haru_A103.webp"
	}},
	"s": {"name": "소라", "color": "#4a90d9", "directory": "sora", "sprites": {
		"normal": "sora_A100.webp", "happy": "sora_A101.webp",
		"angry": "sora_A102.webp", "surprised": "sora_A104.webp",
		"worried": "sora_A103.webp", "angry2": "sora_A190.webp"
	}},
	"h": {"name": "하나", "color": "#e87ba1", "directory": "hana", "sprites": {
		"normal": "hana_A100.webp", "happy": "hana_A201.webp",
		"normal2": "hana_A200.webp",
		"angry": "hana_A202.webp", "worried": "hana_A203.webp",
		"surprised": "hana_A204.webp", "yandere": "hana_B199.webp", "shy": "hana_A199.webp"
	}},
	"u": {"name": "???", "color": "#9370db", "directory": "unknown", "sprites": {
		"normal": "unknown_B290.webp"
	}},
}

# 씬(배경) 매핑 (script.js scenes 기반)
var scene_map: Dictionary = {
	"opening_cg": "gallery/opening.webp",
	"school_front_early": "backgrounds/early01.webp",
	"school_front_day": "backgrounds/day01.webp",
	"school_grounds_early": "backgrounds/early02.webp",
	"school_grounds_day": "backgrounds/day02.webp",
	"school_grounds_evening": "backgrounds/evening02.webp",
	"classroom_day": "backgrounds/classroom_01_day.webp",
	"classroom_afternoon": "backgrounds/classroom_01_afternoon.webp",
	"classroom2_morning": "backgrounds/classroom_02_morning.webp",
	"classroom2_evening": "backgrounds/classroom_02_evening.webp",
	"classroom3_morning": "backgrounds/classroom_03_morning.webp",
	"classroom3_afternoon": "backgrounds/classroom_03_afternoon.webp",
	"classroom4_morning": "backgrounds/classroom_04_morning.webp",
	"auditorium_sunrise": "backgrounds/Auditorium_Outside_Sunrise.webp",
	"auditorium_day": "backgrounds/Auditorium_Outside_Day.webp",
	"auditorium_noon": "backgrounds/Auditorium_Outside_Noon.webp",
	"auditorium_afternoon": "backgrounds/Auditorium_Outside_Afternoon.webp",
	"auditorium_evening": "backgrounds/Auditorium_Outside_Evening.webp",
	"busstop_evening": "backgrounds/bus_stop_evening.webp",
	"busstop_night": "backgrounds/bus_stop_night.webp",
	"busstop_morning": "backgrounds/bus_stop_morning.webp",
	"busstop_noon": "backgrounds/bus_stop_noon.webp",
	"science_lab_01": "backgrounds/school_science_lab_day01.webp",
	"science_lab_02": "backgrounds/school_science_lab_day02.webp",
	"science_lab_03": "backgrounds/school_science_lab_day03.webp",
	"science_lab_04": "backgrounds/school_science_lab_day04.webp",
	"science_lab_05": "backgrounds/school_science_lab_day05.webp",
	"science_lab_06": "backgrounds/school_science_lab_day06.webp",
	"science_lab_07": "backgrounds/school_science_lab_day07.webp",
	"science_lab_08": "backgrounds/school_science_lab_day08.webp",
	"swimming_pool": "backgrounds/school_swimming_pool.webp",
	"another_building_day": "backgrounds/another_school_building_day.webp",
	"classroom_night": "backgrounds/classroom_01_night.webp",
	"classroom3_evening": "backgrounds/classroom_03_evening.webp",
	"bedroom_night": "backgrounds/classroom_01_night.webp",
	"afternoon01": "backgrounds/afternoon01.webp",
	"afternoon02": "backgrounds/afternoon02.webp",
	"noon01": "backgrounds/noon01.webp",
	"noon02": "backgrounds/noon02.webp",
	"classroom2_afternoon": "backgrounds/classroom_02_afternoon.webp",
	"classroom2_evening_alt": "backgrounds/classroom_02_evening.webp",
	"classroom4_afternoon": "backgrounds/classroom_04_afternoon.webp",
	"classroom4_evening": "backgrounds/classroom_04_evening.webp",
	# CG scenes
	"silhouette_cg": "gallery/silhouette.webp",
	"rooftop-hana_cg": "gallery/rooftop-hana.webp",
	"library-sora_cg": "gallery/library-sora.webp",
	"photo-discovery_cg": "gallery/photo-discovery.webp",
	"crane-gift_cg": "gallery/crane-gift.webp",
	"sora-sunset-smile_cg": "gallery/sora-sunset-smile.webp",
	"hana-sunset-promise_cg": "gallery/hana-sunset-promise.webp",
	"three-walk-home_cg": "gallery/three-walk-home.webp",
	"busstop-silhouette_cg": "gallery/busstop-silhouette.webp",
	"sora-exhibition_cg": "gallery/sora-exhibition.webp",
	"rooftop-sakura-rain_cg": "gallery/rooftop-sakura-rain.webp",
	"three-hands_cg": "gallery/three-hands.webp",
	"pool-secret_cg": "gallery/pool-secret.webp",
	"hana-unmasked_cg": "gallery/hana-unmasked.webp",
	"yuu-first-meet_cg": "gallery/yuu-first-meet.webp",
	"sora-past-tears_cg": "gallery/sora-past-tears.webp",
	"sora-confession_cg": "gallery/sora-confession.webp",
	"sora-truelove_cg": "gallery/sora-truelove.webp",
	"hana-confession_cg": "gallery/hana-confession.webp",
	"hana-truelove_cg": "gallery/hana-truelove.webp",
	"together-letter_cg": "gallery/together-letter.webp",
	"sora-warm_cg": "gallery/sora-warm.webp",
	"hana-warm_cg": "gallery/hana-warm.webp",
}

# 선택지 통계 추적 대상 (choice-stats.js 기반)
var tracked_scenes: Dictionary = {
	"Day1UnknownHint": true,
	"MorningEvent": true,
	"LunchTimeChoice": true,
	"Day2Morning": true,
	"Day2ScienceLab": true,
	"Day3BothHigh": true,
	"Day3SoraClimax": true,
	"Day3HanaClimax": true,
	"Day4Morning": true,
	"Day4Evening": true,
	"Day5SoraConfess2": true,
	"Day5HanaConfess2": true,
}

# 스토리 데이터
var _labels: Dictionary = {}
var current_label: String = ""
var line_index: int = 0
var _waiting: bool = false
var _choice_pending: bool = false


func _ready() -> void:
	load_all_stories()


func load_all_stories() -> void:
	var dirs: Array[String] = ["day1", "day2", "day3", "day4", "day5"]
	for dir_name in dirs:
		var dir_path: String = "res://story/" + dir_name
		var dir := DirAccess.open(dir_path)
		if not dir:
			continue
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				_load_story_file(dir_path + "/" + file_name)
			file_name = dir.get_next()
	print("[StoryManager] Loaded %d labels" % _labels.size())


func _load_story_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("StoryManager: Cannot open " + path)
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_warning("StoryManager: JSON parse error in " + path + ": " + json.get_error_message())
		return
	var data: Dictionary = json.data
	for label_name in data:
		_labels[label_name] = data[label_name]


func start(label: String = "Start") -> void:
	jump(label)


func jump(label: String) -> void:
	if label not in _labels:
		push_error("StoryManager: Label not found: " + label)
		return
	DebugOverlay.log_message("Jump: %s" % label)
	current_label = label
	line_index = 0
	_waiting = false
	_choice_pending = false
	advance()


func advance() -> void:
	DebugOverlay.log_message("advance() label=%s idx=%d wait=%s choice=%s" % [current_label, line_index, _waiting, _choice_pending])
	if _waiting or _choice_pending:
		return
	if current_label.is_empty():
		return
	var lines: Array = _labels[current_label]
	if line_index >= lines.size():
		push_warning("StoryManager: Reached end of label " + current_label)
		return

	var cmd = lines[line_index]
	line_index += 1

	if cmd is String:
		# 단순 내레이션 텍스트
		var text: String = GameManager.replace_templates(cmd)
		narration_requested.emit(text)
		return

	if cmd is Dictionary:
		_dispatch_command(cmd)


func _dispatch_command(cmd: Dictionary) -> void:
	var cmd_type: String = cmd.get("cmd", "")
	DebugOverlay.log_message("dispatch: %s %s" % [cmd_type, str(cmd).substr(0, 80)])

	match cmd_type:
		"dialogue":
			var char_id: String = cmd.get("character", "")
			var char_data: Dictionary = characters.get(char_id, {})
			var name_text: String = char_data.get("name", char_id)
			name_text = GameManager.replace_templates(name_text)
			var text: String = GameManager.replace_templates(cmd.get("text", ""))
			dialogue_requested.emit(char_id, name_text, text)

		"narration":
			var text: String = GameManager.replace_templates(cmd.get("text", ""))
			narration_requested.emit(text)

		"centered":
			var text: String = GameManager.replace_templates(cmd.get("text", ""))
			centered_requested.emit(text)

		"show_scene":
			var id: String = cmd.get("id", "")
			var transition: String = cmd.get("transition", "fadeIn")
			scene_change_requested.emit(id, transition)
			# 자동 진행 (씬 전환 후 다음 명령)
			_auto_advance_after(0.05)

		"show_character":
			var id: String = cmd.get("id", "")
			var sprite: String = cmd.get("sprite", "normal")
			var position: String = cmd.get("position", "center")
			var transition: String = cmd.get("transition", "fadeIn")
			character_show_requested.emit(id, sprite, position, transition)
			_auto_advance_after(0.05)

		"hide_character":
			var id: String = cmd.get("id", "")
			var transition: String = cmd.get("transition", "fadeOut")
			character_hide_requested.emit(id, transition)
			_auto_advance_after(0.05)

		"change_sprite":
			var id: String = cmd.get("id", "")
			var sprite: String = cmd.get("sprite", "normal")
			character_sprite_changed.emit(id, sprite)
			_auto_advance_after(0.05)

		"choice":
			_choice_pending = true
			var dialog: String = GameManager.replace_templates(cmd.get("dialog", ""))
			var choices: Array = cmd.get("choices", [])
			choice_requested.emit(dialog, choices)

		"jump":
			var target: String = cmd.get("target", "")
			jump(target)

		"fade_jump":
			var target: String = cmd.get("target", "")
			var duration: float = cmd.get("duration", 1.5)
			var color: Color = Color(cmd.get("color", "#000000"))
			_waiting = true
			fade_requested.emit("to_black", duration, color)
			await get_tree().create_timer(duration + cmd.get("wait", 0.2)).timeout
			_waiting = false
			jump(target)

		"fade_scene":
			var id: String = cmd.get("id", "")
			var duration: float = cmd.get("duration", 1.5)
			var color: Color = Color(cmd.get("color", "#000000"))
			_waiting = true
			fade_requested.emit("to_black", duration, color)
			await get_tree().create_timer(duration + 0.2).timeout
			scene_change_requested.emit(id, "instant")
			fade_requested.emit("from_black", duration, color)
			await get_tree().create_timer(duration).timeout
			_waiting = false
			advance()

		"play_music":
			var id: String = cmd.get("id", "")
			var loop: bool = cmd.get("loop", true)
			AudioManager.play_music(id, loop)
			advance()

		"stop_music":
			var fade: float = cmd.get("fade", 1.0)
			AudioManager.stop_music(fade)
			advance()

		"play_sound":
			var id: String = cmd.get("id", "")
			AudioManager.play_sound(id)
			advance()

		"stop_sound":
			AudioManager.stop_sound()
			advance()

		"wait":
			var duration: float = cmd.get("duration", 1.0) / 1000.0  # ms to seconds
			_waiting = true
			wait_requested.emit(duration)
			await get_tree().create_timer(duration).timeout
			_waiting = false
			advance()

		"set_var":
			var path: String = cmd.get("path", "")
			var value = cmd.get("value")
			var op: String = cmd.get("op", "set")
			GameManager.set_var(path, value, op)
			advance()

		"conditional":
			var branches: Array = cmd.get("branches", [])
			for branch in branches:
				var condition: String = branch.get("condition", "")
				if GameManager.evaluate_condition(condition):
					var target: String = branch.get("target", "")
					if branch.get("action", "") == "jump":
						jump(target)
					return
			# 기본 분기
			if cmd.has("default"):
				var default_target: String = cmd["default"]
				jump(default_target)
			else:
				advance()

		"input":
			var prompt: String = cmd.get("prompt", "")
			var warning: String = cmd.get("warning", "")
			_waiting = true
			input_requested.emit(prompt, warning)

		"gallery_unlock":
			var id: String = cmd.get("id", "")
			GameManager.unlock_gallery(id)
			advance()

		"affinity_hint":
			var character: String = cmd.get("character", "")
			affinity_hint_requested.emit(character)
			advance()

		"distraction_free":
			distraction_free_toggled.emit()
			advance()

		"end":
			end_requested.emit()

		_:
			push_warning("StoryManager: Unknown command: " + cmd_type)
			advance()


func _auto_advance_after(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	advance()


func on_choice_selected(choice_key: String, target_label: String) -> void:
	_choice_pending = false
	jump(target_label)


func on_input_completed(value: String) -> void:
	DebugOverlay.log_message("input_completed: %s" % value)
	_waiting = false
	GameManager.set_var("player.name", value)
	advance()


func get_character_sprite_path(char_id: String, sprite_name: String) -> String:
	var char_data: Dictionary = characters.get(char_id, {})
	var dir_name: String = char_data.get("directory", "")
	var sprites: Dictionary = char_data.get("sprites", {})
	var file_name: String = sprites.get(sprite_name, sprites.get("normal", ""))
	if dir_name.is_empty() or file_name.is_empty():
		return ""
	return "res://assets/characters/" + dir_name + "/" + file_name


func get_scene_path(scene_id: String) -> String:
	if scene_id.begins_with("#"):
		return ""  # 색상 씬
	var relative: String = scene_map.get(scene_id, "")
	if relative.is_empty():
		push_warning("StoryManager: Unknown scene: " + scene_id)
		return ""
	return "res://assets/" + relative


func get_character_color(char_id: String) -> Color:
	var char_data: Dictionary = characters.get(char_id, {})
	return Color(char_data.get("color", "#ffffff"))


func get_save_data() -> Dictionary:
	return {
		"current_label": current_label,
		"line_index": line_index,
	}


func restore_from_save(data: Dictionary) -> void:
	current_label = data.get("current_label", "")
	line_index = data.get("line_index", 0)


func is_tracked_scene() -> bool:
	return current_label in tracked_scenes
