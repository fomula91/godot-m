extends Control
## UILayer에 직접 배치하거나, DialogueBox의 부모 노드에 attach
## 대화창, 타이핑 애니메이션, 대화 로그 관리

signal typing_finished  # main_scene의 auto/skip 연동용

# 노드 참조 — 씬 트리에서 UILayer 하위 노드들
@onready var dialogue_box: PanelContainer = $DialogueBox
@onready var name_label: Label = $DialogueBox/MarginContainer/VBoxContainer/NameLabel
@onready var text_label: RichTextLabel = $DialogueBox/MarginContainer/VBoxContainer/TextLabel
@onready var centered_text: Label = $CenteredText

# 상태
var _typing := false
var _typing_tween: Tween
var _dialogue_log: Array[Dictionary] = []

func _ready() -> void:
    _apply_dialogue_box_style()
    StoryManager.dialogue_requested.connect(_on_dialogue)
    StoryManager.narration_requested.connect(_on_narration)
    StoryManager.centered_requested.connect(_on_centered)
    dialogue_box.visible = false
    centered_text.visible = false

# === Public API ===

func is_typing() -> bool:
    return _typing

func complete_typing() -> void:
    """외부에서 타이핑 즉시 완료 요청 (클릭 시)"""
    if _typing_tween:
        _typing_tween.kill()
    text_label.visible_ratio = 1.0
    _on_typing_done()

func is_centered_visible() -> bool:
    return centered_text.visible

func hide_centered() -> void:
    centered_text.visible = false

func show_dialogue_box() -> void:
    dialogue_box.visible = true

func hide_dialogue_box() -> void:
    dialogue_box.visible = false

func show_choice_dialog(char_id: String, char_name: String, text: String) -> void:
    dialogue_box.visible = true
    name_label.text = char_name
    name_label.add_theme_color_override("font_color", StoryManager.get_character_color(char_id))
    name_label.visible = true
    text_label.text = text
    text_label.visible_ratio = 1.0

func show_raw_text(text: String) -> void:
    dialogue_box.visible = true
    name_label.visible = false
    text_label.text = text
    text_label.visible_ratio = 1.0

func get_dialogue_log() -> Array[Dictionary]:
    return _dialogue_log

# === Signal Handlers ===

func _on_dialogue(char_id: String, name_text: String, text: String) -> void:
    DebugOverlay.log_message("Dialogue: %s" % name_text)
    dialogue_box.visible = true
    centered_text.visible = false
    name_label.text = name_text
    name_label.add_theme_color_override("font_color", StoryManager.get_character_color(char_id))
    name_label.visible = true
    _start_typing(text)
    _dialogue_log.append({"name": name_text, "text": text})

func _on_narration(text: String) -> void:
    dialogue_box.visible = true
    centered_text.visible = false
    name_label.visible = false
    _start_typing(text)
    _dialogue_log.append({"name": "", "text": text})

func _on_centered(text: String) -> void:
    dialogue_box.visible = false
    centered_text.text = text
    centered_text.visible = true
    centered_text.modulate.a = 0.0
    var tw := create_tween()
    tw.tween_property(centered_text, "modulate:a", 1.0, 0.5)
    tw.finished.connect(func(): typing_finished.emit())

# === Typing System ===

func _start_typing(text: String) -> void:
    text_label.text = text
    text_label.visible_ratio = 0.0
    _typing = true
    if _typing_tween:
        _typing_tween.kill()
    var char_count := text.length()
    var speed_ms: float = GameManager.settings["text_speed"]
    var duration: float = char_count * speed_ms / 1000.0
    # skip_mode는 main_scene에서 제어 — 외부에서 duration 오버라이드 가능하도록
    _typing_tween = create_tween()
    _typing_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
    _typing_tween.finished.connect(_on_typing_done)

func start_typing_fast() -> void:
    """스킵 모드용: 현재 타이핑을 0.05초로 단축"""
    if _typing and _typing_tween:
        _typing_tween.kill()
        text_label.visible_ratio = 0.0
        _typing_tween = create_tween()
        _typing_tween.tween_property(text_label, "visible_ratio", 1.0, 0.05)
        _typing_tween.finished.connect(_on_typing_done)

func _on_typing_done() -> void:
    _typing = false
    typing_finished.emit()

func _apply_dialogue_box_style() -> void:
    var style := StyleBoxTexture.new()
    style.texture = preload("res://assets/system/dialog-background.png")
    style.set_content_margin_all(20)
    dialogue_box.add_theme_stylebox_override("panel", style)