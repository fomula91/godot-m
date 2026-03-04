extends Node
## 마우스/터치 입력 디버그 오버레이 (F3 토글)
## Autoload 싱글톤 — 모든 씬 위에 CanvasLayer(100)로 표시
##
## 스크립트 API:
##   DebugOverlay.show_overlay()
##   DebugOverlay.hide_overlay()
##   DebugOverlay.toggle_overlay()
##   DebugOverlay.overlay_visible  (읽기/쓰기)
##   DebugOverlay.log_message("텍스트")
##   DebugOverlay.clear_log()
##   DebugOverlay.enabled  (입력 추적 on/off, 오버레이 표시와 별개)

signal visibility_changed(is_visible: bool)

const MAX_LOG_ENTRIES := 8
const DEBOUNCE_MS := 100

## 오버레이 표시 여부
var overlay_visible := false:
	set(value):
		overlay_visible = value
		if _panel:
			_panel.visible = value
		visibility_changed.emit(value)

## 입력 추적 활성화 여부 (false면 입력 이벤트 무시)
var enabled := true

var _canvas_layer: CanvasLayer
var _panel: PanelContainer
var _lbl_platform: Label
var _lbl_fps: Label
var _lbl_pos: Label
var _lbl_input_type: Label
var _lbl_log: Label

var _log_entries: Array[String] = []
var _last_touch_time_ms := 0


func _ready() -> void:
	if not OS.is_debug_build():
		set_process(false)
		set_process_input(false)
		enabled = false
		return

	_build_ui()
	_panel.visible = false
	_lbl_platform.text = "Platform: %s" % _get_platform_name()


#region Public API

func show_overlay() -> void:
	overlay_visible = true


func hide_overlay() -> void:
	overlay_visible = false


func toggle_overlay() -> void:
	overlay_visible = not overlay_visible


func log_message(msg: String) -> void:
	_add_log(msg)


func clear_log() -> void:
	_log_entries.clear()
	if _lbl_log:
		_lbl_log.text = ""

#endregion


func _build_ui() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 100
	add_child(_canvas_layer)

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.set_content_margin_all(10)
	style.set_corner_radius_all(6)
	_panel.add_theme_stylebox_override("panel", style)
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 0.0
	_panel.anchor_bottom = 0.0
	_panel.offset_left = -350
	_panel.offset_right = -10
	_panel.offset_top = 10
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_canvas_layer.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(vbox)

	_lbl_platform = _make_label(vbox, "Platform: —")
	_lbl_fps = _make_label(vbox, "FPS: —")
	_lbl_pos = _make_label(vbox, "Pos: —")
	_lbl_input_type = _make_label(vbox, "Input: —")

	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(sep)

	var title := _make_label(vbox, "Event Log")
	title.add_theme_color_override("font_color", Color(1, 1, 0.6))

	_lbl_log = _make_label(vbox, "")
	_lbl_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _make_label(parent: Node, text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	parent.add_child(lbl)
	return lbl


func _get_platform_name() -> String:
	if OS.has_feature("web"):
		return "Web"
	if OS.has_feature("android"):
		return "Android"
	return "Desktop"


func _process(_delta: float) -> void:
	if overlay_visible:
		_lbl_fps.text = "FPS: %d" % Engine.get_frames_per_second()


func _input(event: InputEvent) -> void:
	# F3 토글 (enabled 무관하게 항상 동작)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		toggle_overlay()
		get_viewport().set_input_as_handled()
		return

	if not enabled or not overlay_visible:
		return

	# 마우스 이동
	if event is InputEventMouseMotion:
		_lbl_pos.text = "Pos: (%.0f, %.0f)" % [event.position.x, event.position.y]

	# 마우스 클릭
	elif event is InputEventMouseButton and event.pressed:
		# 웹 터치→마우스 시뮬레이션 중복 방지
		if OS.has_feature("web"):
			var now := Time.get_ticks_msec()
			if now - _last_touch_time_ms < DEBOUNCE_MS:
				return
		_lbl_input_type.text = "Input: Mouse"
		_lbl_pos.text = "Pos: (%.0f, %.0f)" % [event.position.x, event.position.y]
		var btn_name := _mouse_button_name(event.button_index)
		_add_log("Mouse %s @ (%.0f, %.0f)" % [btn_name, event.position.x, event.position.y])

	# 터치
	elif event is InputEventScreenTouch:
		_last_touch_time_ms = Time.get_ticks_msec()
		if event.pressed:
			_lbl_input_type.text = "Input: Touch"
			_lbl_pos.text = "Pos: (%.0f, %.0f)" % [event.position.x, event.position.y]
			_add_log("Touch DOWN finger=%d @ (%.0f, %.0f)" % [event.index, event.position.x, event.position.y])
		else:
			_add_log("Touch UP finger=%d @ (%.0f, %.0f)" % [event.index, event.position.x, event.position.y])

	# 터치 드래그
	elif event is InputEventScreenDrag:
		_lbl_input_type.text = "Input: Touch(Drag)"
		_lbl_pos.text = "Pos: (%.0f, %.0f)" % [event.position.x, event.position.y]


func _mouse_button_name(index: MouseButton) -> String:
	match index:
		MOUSE_BUTTON_LEFT:
			return "L-Click"
		MOUSE_BUTTON_RIGHT:
			return "R-Click"
		MOUSE_BUTTON_MIDDLE:
			return "M-Click"
		MOUSE_BUTTON_WHEEL_UP:
			return "WheelUp"
		MOUSE_BUTTON_WHEEL_DOWN:
			return "WheelDown"
		_:
			return "Btn%d" % index


func _add_log(msg: String) -> void:
	var timestamp := Time.get_time_string_from_system().substr(0, 8)
	_log_entries.push_front("[%s] %s" % [timestamp, msg])
	if _log_entries.size() > MAX_LOG_ENTRIES:
		_log_entries.resize(MAX_LOG_ENTRIES)
	if _lbl_log:
		_lbl_log.text = "\n".join(_log_entries)
