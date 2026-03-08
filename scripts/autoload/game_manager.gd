extends Node

## 게임 상태 관리 싱글턴
## storage.js 기반 변수 관리, 세이브/로드, 갤러리 해금 추적

signal state_changed(key: String, value: Variant)
signal gallery_item_unlocked(id: String)

# 기본 상태
var _default_state: Dictionary = {
	"player": {"name": ""},
	"distance": 50,          # 거리감 (0=가장 가까움, 100=가장 멀음)
	"april_events": 0,       # 4월 이벤트 진행 횟수
	"crack_progress": 0,     # 균열 파트 진행도
	"ending_type": "",       # 엔딩 타입 (a, b, c, gameover)
}

var state: Dictionary = {}
var gallery_unlocked: Array[String] = []
var auto_mode := false

# 설정
var settings: Dictionary = {
	"text_speed": 20.0,  # ms per character
	"auto_speed": 5.0,   # seconds
	"music_volume": 1.0,
	"sound_volume": 1.0,
}

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 10


func _ready() -> void:
	reset_state()
	_ensure_save_dir()
	_load_settings()
	_load_gallery()


func reset_state() -> void:
	state = _default_state.duplicate(true)


func set_var(path: String, value: Variant, op: String = "set") -> void:
	DebugOverlay.log_message("SetVar: %s %s %s" % [path, op, str(value)])
	if "." in path:
		var parts := path.split(".")
		var dict: Dictionary = state
		for i in range(parts.size() - 1):
			if parts[i] in dict and dict[parts[i]] is Dictionary:
				dict = dict[parts[i]]
			else:
				return
		var key := parts[-1]
		match op:
			"set":
				dict[key] = value
			"add":
				dict[key] = dict.get(key, 0) + value
			"sub":
				dict[key] = dict.get(key, 0) - value
		state_changed.emit(path, dict[key])
	else:
		match op:
			"set":
				state[path] = value
			"add":
				state[path] = state.get(path, 0) + value
			"sub":
				state[path] = state.get(path, 0) - value
		state_changed.emit(path, state[path])


func get_var(path: String) -> Variant:
	if "." in path:
		var parts := path.split(".")
		var dict: Dictionary = state
		for i in range(parts.size() - 1):
			if parts[i] in dict and dict[parts[i]] is Dictionary:
				dict = dict[parts[i]]
			else:
				return null
		return dict.get(parts[-1], null)
	return state.get(path, null)


func evaluate_condition(expr: String) -> bool:
	expr = expr.strip_edges()

	# AND 복합 조건: "a >= 4 AND b >= 4"
	if " AND " in expr:
		var sub_exprs := expr.split(" AND ")
		for sub in sub_exprs:
			if not evaluate_condition(sub):
				return false
		return true

	# OR 복합 조건
	if " OR " in expr:
		var sub_exprs := expr.split(" OR ")
		for sub in sub_exprs:
			if evaluate_condition(sub):
				return true
		return false

	# 비교 연산: "var >= value", "var == value" 등
	var ops := [">=", "<=", "!=", "==", ">", "<"]
	for op in ops:
		var idx := expr.find(op)
		if idx > 0:
			var left_str := expr.substr(0, idx).strip_edges()
			var right_str := expr.substr(idx + op.length()).strip_edges()
			var left = get_var(left_str)
			var right = _parse_value(right_str)
			if left == null:
				left = 0
			match op:
				"==":
					return left == right
				"!=":
					return left != right
				">=":
					return left >= right
				"<=":
					return left <= right
				">":
					return left > right
				"<":
					return left < right
	# 단순 불리언 변수 체크
	var val = get_var(expr)
	if val is bool:
		return val
	return val != null and val != 0 and val != ""


func _parse_value(s: String) -> Variant:
	s = s.strip_edges()
	if s == "true":
		return true
	if s == "false":
		return false
	if s.is_valid_int():
		return s.to_int()
	if s.is_valid_float():
		return s.to_float()
	# 따옴표 제거
	if (s.begins_with("'") and s.ends_with("'")) or (s.begins_with('"') and s.ends_with('"')):
		return s.substr(1, s.length() - 2)
	return s


# --- 갤러리 ---

func unlock_gallery(id: String) -> void:
	if id not in gallery_unlocked:
		gallery_unlocked.append(id)
		gallery_unlocked.sort()
		_save_gallery()
		_emit_gallery_unlocked(id)


func _emit_gallery_unlocked(id: String) -> void:
	gallery_item_unlocked.emit(id)


# --- 세이브/로드 ---

func _ensure_save_dir() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func save_game(slot: int, extra: Dictionary = {}) -> void:
	var data: Dictionary = {
		"state": state.duplicate(true),
		"gallery": gallery_unlocked.duplicate(),
		"current_label": extra.get("current_label", ""),
		"line_index": extra.get("line_index", 0),
		"background": extra.get("background", ""),
		"characters": extra.get("characters", {}),
		"bgm": extra.get("bgm", ""),
		"timestamp": Time.get_datetime_string_from_system(),
		"label_display": extra.get("label_display", ""),
	}
	var path := SAVE_DIR + "slot_%d.json" % slot
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))


func load_game(slot: int) -> Dictionary:
	var path := SAVE_DIR + "slot_%d.json" % slot
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	var data: Dictionary = json.data
	if "state" in data:
		state = data["state"]
	if "gallery" in data:
		gallery_unlocked = Array(data["gallery"], TYPE_STRING, &"", null)
	return data


func get_save_meta(slot: int) -> Dictionary:
	var path := SAVE_DIR + "slot_%d.json" % slot
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	var data: Dictionary = json.data
	return {
		"timestamp": data.get("timestamp", ""),
		"label_display": data.get("label_display", ""),
		"current_label": data.get("current_label", ""),
	}


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "slot_%d.json" % slot)


func delete_save(slot: int) -> void:
	var path := SAVE_DIR + "slot_%d.json" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


# --- 설정 ---

func _load_settings() -> void:
	var path := "user://settings.json"
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		var data: Dictionary = json.data
		settings.merge(data, true)


func save_settings() -> void:
	var path := "user://settings.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings, "\t"))


func _save_gallery() -> void:
	var path := "user://gallery.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(gallery_unlocked))


func _load_gallery() -> void:
	var path := "user://gallery.json"
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK and json.data is Array:
		gallery_unlocked = Array(json.data, TYPE_STRING, &"", null)


## 템플릿 변수 치환: {{player.name}} 등
func replace_templates(text: String) -> String:
	var regex := RegEx.new()
	regex.compile("\\{\\{(\\w+(?:\\.\\w+)*)\\}\\}")
	var result := text
	for m in regex.search_all(text):
		var path: String = m.get_string(1)
		var val = get_var(path)
		if val != null:
			result = result.replace(m.get_string(0), str(val))
	return result
