extends CanvasLayer
## OverlayLayer 컨트롤러 - 페이드 전환, 입력 다이얼로그, 거리감 알림

signal input_dialog_shown
signal input_dialog_hidden

# 노드 참조
@onready var transition_rect: ColorRect = $TransitionRect
@onready var affinity_hint: PanelContainer = $AffinityHint
@onready var affinity_icon: Label = $AffinityHint/HBoxContainer/Icon
@onready var affinity_text: Label = $AffinityHint/HBoxContainer/Text
@onready var input_dialog: PanelContainer = $InputDialog
@onready var input_prompt: Label = $InputDialog/VBoxContainer/PromptLabel
@onready var input_field: LineEdit = $InputDialog/VBoxContainer/InputField
@onready var input_warning: Label = $InputDialog/VBoxContainer/WarningLabel
@onready var input_confirm_btn: Button = $InputDialog/VBoxContainer/ConfirmBtn

# 상태
var _default_name: String = ""

# 거리감 알림 설정
var _affinity_config: Dictionary = {
	"closer": {"icon": "♡", "text": "수아와의 거리가 가까워진 것 같다."},
	"farther": {"icon": "...", "text": "수아와의 거리가 멀어진 것 같다."},
}

func _ready() -> void:
	# StoryManager 시그널 구독
	StoryManager.fade_requested.connect(_on_fade)
	StoryManager.wait_requested.connect(_on_wait)
	StoryManager.input_requested.connect(_on_input_request)
	StoryManager.affinity_hint_requested.connect(_on_affinity_hint)

	# UI 시그널
	input_confirm_btn.pressed.connect(_on_input_confirm)
	input_field.text_submitted.connect(func(_t): _on_input_confirm())


# === Pubilc API ===

func is_input_active() -> bool:
	return input_dialog.visible

func clear_transition() -> void:
	transition_rect.color = Color(0, 0, 0, 0)

# === Fade ===

func _on_fade(fade_type: String, duration: float, color: Color) -> void:
	match fade_type:
		"to_black":
			transition_rect.color = Color(color.r, color.g, color.b, 0.0)
			var tw := create_tween()
			tw.tween_property(transition_rect, "color:a", 1.0, duration)
		"from_black":
			transition_rect.color = Color(color.r, color.g, color.b, 1.0)
			var tw := create_tween()
			tw.tween_property(transition_rect, "color:a", 0.0, duration)

func _on_wait(_duration: float) -> void:
	pass # StoryManager가 타이머 처리

# === Input Dialog ===

func _on_input_request(prompt: String, warning: String, default_name: String) -> void:
	DebugOverlay.log_message("Input requested")
	_default_name = default_name
	input_prompt.text = prompt
	input_field.text = ""
	input_field.placeholder_text = default_name if default_name != "" else "이름을 입력하세요."
	input_warning.text = warning
	input_warning.visible = false
	input_dialog.visible = true
	input_field.grab_focus()
	input_dialog_shown.emit()

func _on_input_confirm() -> void:
	var text := input_field.text.strip_edges()
	if text.is_empty():
		if _default_name.is_empty():
			input_warning.visible = true
			return
		text = _default_name
	input_dialog.visible = false
	input_dialog_hidden.emit()
	StoryManager.on_input_completed(text)

# === Affinity Hint ===

func _on_affinity_hint(character: String) -> void:
	var cfg: Dictionary = _affinity_config.get(character, {})
	if cfg.is_empty():
		return
	
	affinity_icon.text = cfg["icon"]
	affinity_text.text = cfg["text"]
	affinity_hint.visible = true
	affinity_hint.modulate.a = 1.0

	var tw := create_tween()
	tw.tween_interval(1.4) # 1800ms total - 400ms fade = 1400ms visible
	tw.tween_property(affinity_hint, "modulate:a", 0.0, 0.4)
	tw.finished.connect(func(): affinity_hint.visible = false)
