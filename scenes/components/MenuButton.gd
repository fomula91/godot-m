extends Button
class_name StyledMenuButton

func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.078, 0.39, 0.118, 0.7)
	style.border_color = Color(0.957, 0.561, 0.694, 0.3)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(12)
	add_theme_stylebox_override("normal", style)

	var hover := style.duplicate()
	hover.bg_color = Color(0.157, 0.078, 0.235, 0.9)
	hover.border_color = Color(0.957, 0.561, 0.694, 0.6)
	add_theme_stylebox_override("hover", hover)

	# Pressed 상태 스타일
	var pressed_style := style.duplicate()
	pressed_style.bg_color = Color(0.05, 0.02, 0.8, 0.95)
	pressed_style.border_color = Color(0.957, 0.561, 0.694, 0.8)
	add_theme_stylebox_override("pressed", pressed_style)

	#  disabled 상태 스타일
	var disabled_style := style.duplicate()
	disabled_style.bg_color = Color(0.1, 0.1, 0.1, 0.4)
	disabled_style.border_color = Color(0.3, 0.3, 0.3, 0.2)
	add_theme_stylebox_override("disabled", disabled_style)

	# focus: 키보드 포커스 (테두리만 강조)
	var focus_style := style.duplicate()
	focus_style.border_color = Color(0.957, 0.561, 0.694, 0.9)
	focus_style.set_border_width_all(2)
	add_theme_stylebox_override("focus", focus_style)

	#클릭 사운드
	pressed.connect(AudioManager.play_ui_click)

	# 반응형 폰트
	get_viewport().size_changed.connect(_update_font_size)
	_update_font_size()

func _update_font_size() -> void:
	var viewport_h := get_viewport().get_visible_rect().size.y
	var font_size := clampi(int(viewport_h * 0.03), 16, 36)
	add_theme_font_size_override("font_size", font_size)