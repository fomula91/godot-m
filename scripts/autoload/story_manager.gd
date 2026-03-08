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
signal input_requested(prompt: String, warning: String, default: String)
signal affinity_hint_requested(character: String)
signal gallery_unlock_requested(id: String)
signal distraction_free_toggled()
signal end_requested()
signal command_completed()

# 캐릭터 정의
# 임시 에셋을 사용한다. 변경 예정중
var characters: Dictionary = {
	"p": {"name": "{{player.name}}", "color": "#ffa726", "directory": "haru", "sprites": {
		"normal": "haru_A100.webp", "happy": "haru_A101.webp",
		"surprised": "haru_A102.webp", "worried": "haru_A103.webp"
	}},
	"sua": {"name": "이수아", "color": "#e87ba1", "directory": "sora", "sprites": {
		"normal": "sora_A100.webp", "happy": "sora_A101.webp",
		"shy": "sora_A101.webp", "sad": "sora_A101.webp",
		"surprised": "sora_A104.webp", "worried": "sora_A103.webp"
	}},
	"friend": {"name": "친구", "color": "#8bc34a", "directory": "unknown", "sprites": {
		"normal": "unknown_B290_A100.webp"
	}},
}

# 씬(배경) 매핑
var scene_map: Dictionary = {
	# 학교 외부
	"school_front_morning": "backgrounds/afternoon01.webp",
	"school_front_day": "backgrounds/school_front_day.webp",
	"school_front_evening": "backgrounds/school_front_evening.webp",
	# 교실
	"classroom_morning": "backgrounds/classroom_morning.webp",
	"classroom_day": "backgrounds/classroom_01_day.webp",
	"classroom_afternoon": "backgrounds/classroom_afternoon.webp",
	"classroom_evening": "backgrounds/classroom_evening.webp",
	# 급식실 / 점심
	"cafeteria_day": "backgrounds/cafeteria_day.webp",
	"lunch_spot": "backgrounds/lunch_spot.webp",
	# 복도
	"hallway_day": "backgrounds/hallway_day.webp",
	"hallway_evening": "backgrounds/hallway_evening.webp",
	# 운동장
	"school_grounds_day": "backgrounds/school_grounds_day.webp",
	"school_grounds_evening": "backgrounds/school_grounds_evening.webp",
	# 시내
	"city_day": "backgrounds/city_day.webp",
	"city_evening": "backgrounds/city_evening.webp",
	# 수학여행 (제주도)
	"jeju_scenery": "backgrounds/jeju_scenery.webp",
	"jeju_lodging": "backgrounds/jeju_lodging.webp",
	# 체육대회
	"sports_festival": "backgrounds/sports_festival.webp",
	# CG scenes
	"first_lunch_cg": "gallery/first_lunch.webp",
	"seat_assignment_cg": "gallery/seat_assignment.webp",
	"group_project_cg": "gallery/group_project.webp",
	"math_class_cg": "gallery/math_class.webp",
	"jeju_together_cg": "gallery/jeju_together.webp",
	"jeju_delivery_cg": "gallery/jeju_delivery.webp",
	"sports_festival_cg": "gallery/sports_festival.webp",
	"birthday_gift_cg": "gallery/birthday_gift.webp",
	"city_outing_cg": "gallery/city_outing.webp",
	"sua_confession_cg": "gallery/sua_confession.webp",
	"ending_a_cg": "gallery/ending_a.webp",
	"ending_b_cg": "gallery/ending_b.webp",
	"ending_c_cg": "gallery/ending_c.webp",
}

# 선택지 통계 추적 대상
var tracked_scenes: Dictionary = {
	"SeatAssignment": true,
	"GroupProject": true,
	"MathClass": true,
	"LunchTime": true,
	"SchoolTrip": true,
	"CrackAfterSchool": true,
	"CrackLunchTime": true,
	"CrackSportsFest": true,
	"CrackExam": true,
	"JulyChoice": true,
}

# 스토리 데이터
var _labels: Dictionary = {}
var current_label: String = ""
var line_index: int = 0
var _waiting: bool = false
var _choice_pending: bool = false
var _active_sprites: Dictionary = {} # cahr_id -> sprite_name


func _ready() -> void:
	load_all_stories()


func load_all_stories() -> void:
	var dirs: Array[String] = ["april", "may", "crack", "july"]
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
			_active_sprites[id] = sprite
			character_show_requested.emit(id, sprite, position, transition)
			_auto_advance_after(0.05)

		"hide_character":
			var id: String = cmd.get("id", "")
			var transition: String = cmd.get("transition", "fadeOut")
			_active_sprites.erase(id)
			character_hide_requested.emit(id, transition)
			_auto_advance_after(0.05)

		"change_sprite":
			var id: String = cmd.get("id", "")
			var sprite: String = cmd.get("sprite", "normal")
			_active_sprites[id] = sprite
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
			if target not in _labels:
				push_error("StoryManager: Label not found: " + target)
				return
			_waiting = true
			fade_requested.emit("to_black", duration, color)
			await get_tree().create_timer(duration + cmd.get("wait", 0.2)).timeout
			DebugOverlay.log_message("Jump: %s" % target)
			current_label = target
			line_index = 0
			_choice_pending = false
			fade_requested.emit("from_black", duration, color)
			await get_tree().create_timer(duration).timeout
			_waiting = false
			advance()

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
			var default: String = cmd.get("default", "")
			_waiting = true
			input_requested.emit(prompt, warning, default)

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
	_active_sprites.clear()


func is_tracked_scene() -> bool:
	return current_label in tracked_scenes

func get_current_character_sprite(char_id: String) -> String:
	return _active_sprites.get(char_id, "normal")