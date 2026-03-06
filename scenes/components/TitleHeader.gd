extends VBoxContainer
class_name TitleHeader

@export var title_text: String = "사쿠라학원":
    set(value):
        title_text = value
        if title_label:
            title_label.text = value
@export var subtitle_text: String = "─ 봄날의 이야기 ─":
    set(value):
        subtitle_text = value
        if subtitle_label:
            subtitle_label.text = value

@onready var title_label: Label = $TitleLabel
@onready var subtitle_label: Label = $SubtitleLabel

func _ready() -> void:
    title_label.text = title_text
    subtitle_label.text = subtitle_text

    # 반응형 폰트
    get_viewport().size_changed.connect(_update_font_size)
    _update_font_size()

func _update_font_size() -> void:
    var viewport_h := get_viewport().get_visible_rect().size.y
    var title_size := clampi(int(viewport_h * 0.08), 36, 96)
    var subtitle_size := clampi(int(viewport_h * 0.03), 14, 32)
    title_label.add_theme_font_size_override("font_size", title_size)
    subtitle_label.add_theme_font_size_override("font_size", subtitle_size)