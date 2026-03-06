extends VBoxContainer
class_name TitleHeader

@export var title_text: String = "사쿠라학원"
@export var subtitle_text: String = "─ 봄날의 이야기 ─"

var title_label: Label
var subtitle_label: Label

func _ready() -> void:
    # 타이틀 라벨
    title_label = Label.new()
    title_label.text = title_text
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    add_child(title_label)

    # 서브타이틀 라벨
    subtitle_label = Label.new()
    subtitle_label.text = subtitle_text
    subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    add_child(subtitle_label)

    # 스페이서
    var spacer = Control.new()
    spacer.custom_minimum_size = Vector2(0, 40)
    add_child(spacer)

    # 반응형 폰트
    get_viewport().size_changed.connect(_update_font_size)
    _update_font_size()

func _update_font_size() -> void:
    var viewport_h := get_viewport().get_visible_rect().size.y
    var title_size := clampi(int(viewport_h * 0.08), 36, 96)
    var subtitle_size := clampi(int(viewport_h * 0.03), 14, 32)
    title_label.add_theme_font_size_override("font_size", title_size)
    subtitle_label.add_theme_font_size_override("font_size", subtitle_size)