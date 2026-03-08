extends Control
## CharacterLayer에 부착 - 캐릭터 슬롯, 애니메이션, 상태관리

@onready var left_slot: TextureRect = $LeftSlot
@onready var center_slot: TextureRect = $CenterSlot
@onready var right_slot: TextureRect = $RightSlot

var _character_slots: Dictionary = {} # char_id -> position
var _active_tweens: Dictionary = {}   # position_name -> Tween
var _initial_offsets: Dictionary = {}  # position_name -> Dictionary

func _ready() -> void:
	StoryManager.character_show_requested.connect(_on_show)
	StoryManager.character_hide_requested.connect(_on_hide)
	StoryManager.character_sprite_changed.connect(_on_sprite_change)
	_store_offsets("left", left_slot)
	_store_offsets("center", center_slot)
	_store_offsets("right", right_slot)


func _store_offsets(pos_name: String, slot: TextureRect) -> void:
	_initial_offsets[pos_name] = {
		"top": slot.offset_top,
		"bottom": slot.offset_bottom,
		"left": slot.offset_left,
		"right": slot.offset_right,
	}


func _prepare_slot(pos_name: String, slot: TextureRect) -> void:
	# Kill any running tween on this slot
	if pos_name in _active_tweens:
		var tw = _active_tweens[pos_name]
		if tw and tw.is_valid():
			tw.kill()
		_active_tweens.erase(pos_name)
	# Reset offsets to initial values
	if pos_name in _initial_offsets:
		var o: Dictionary = _initial_offsets[pos_name]
		slot.offset_top = o["top"]
		slot.offset_bottom = o["bottom"]
		slot.offset_left = o["left"]
		slot.offset_right = o["right"]
	slot.scale = Vector2.ONE


# === Public API ===

func get_state() -> Dictionary:
	return _character_slots.duplicate()

func restore_state(state: Dictionary) -> void:
	clear_all()
	for char_id in state:
		var position: String = state[char_id]
		var slot := _get_slot(position)
		var sprite = StoryManager.get_current_character_sprite(char_id)
		var path = StoryManager.get_character_sprite_path(char_id, sprite)
		if path.is_empty():
			continue
		var tex := load(path) as Texture2D
		if tex:
			slot.texture = tex
			slot.modulate.a = 1.0
		_character_slots[char_id] = position

func clear_all() -> void:
	_character_slots.clear()
	for pos_name in ["left", "center", "right"]:
		var slot := _get_slot(pos_name)
		_prepare_slot(pos_name, slot)
		slot.texture = null
		slot.modulate.a = 0.0


# === Signal Handlers ===

func _on_show(id: String, sprite: String, position: String, transition: String) -> void:
	DebugOverlay.log_message("Show: %s [%s] @%s" % [id, sprite, position])
	var slot := _get_slot(position)
	var path := StoryManager.get_character_sprite_path(id, sprite)
	if path.is_empty():
		return
	var tex := load(path) as Texture2D
	if not tex:
		return

	_prepare_slot(position, slot)
	slot.texture = tex
	_character_slots[id] = position

	var tw: Tween
	match transition:
		"fadeIn":
			slot.modulate.a = 0.0
			tw = create_tween()
			tw.tween_property(slot, "modulate:a", 1.0, 0.5)
		"fadeInUp":
			slot.modulate.a = 0.0
			slot.position.y += 30
			tw = create_tween().set_parallel(true)
			tw.tween_property(slot, "position:y", slot.position.y - 30, 0.5)
			tw.tween_property(slot, "modulate:a", 1.0, 0.5)
		"slideInLeft":
			slot.modulate.a = 1.0
			slot.position.x -= 200
			tw = create_tween()
			tw.tween_property(slot, "position:x", slot.position.x + 200, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		"slideInRight":
			slot.modulate.a = 1.0
			slot.position.x += 200
			tw = create_tween()
			tw.tween_property(slot, "position:x", slot.position.x - 200, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		"bounceIn":
			slot.modulate.a = 0.0
			slot.scale = Vector2(0.8, 0.8)
			tw = create_tween().set_parallel(true)
			tw.tween_property(slot, "modulate:a", 1.0, 0.3)
			tw.tween_property(slot, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		_:
			slot.modulate.a = 1.0
	if tw:
		_active_tweens[position] = tw

func _on_hide(id: String, transition: String) -> void:
	DebugOverlay.log_message("Hide: %s (%s)" % [id, transition])
	if id not in _character_slots:
		return
	var position: String = _character_slots[id]
	var slot := _get_slot(position)
	_prepare_slot(position, slot)

	var tw: Tween
	match transition:
		"fadeOut":
			tw = create_tween()
			tw.tween_property(slot, "modulate:a", 0.0, 0.5)
			tw.finished.connect(func(): slot.texture = null)
		"fadeOutLeft":
			tw = create_tween().set_parallel(true)
			tw.tween_property(slot, "modulate:a", 0.0, 0.5)
			tw.tween_property(slot, "position:x", slot.position.x - 100, 0.5)
			tw.finished.connect(func():
				_reset_slot_offsets(position, slot)
				slot.texture = null
			)
		"fadeOutRight":
			tw = create_tween().set_parallel(true)
			tw.tween_property(slot, "modulate:a", 0.0, 0.5)
			tw.tween_property(slot, "position:x", slot.position.x + 100, 0.5)
			tw.finished.connect(func():
				_reset_slot_offsets(position, slot)
				slot.texture = null
			)
		_:
			slot.modulate.a = 0.0
			slot.texture = null
	if tw:
		_active_tweens[position] = tw
	_character_slots.erase(id)

func _on_sprite_change(id: String, sprite: String) -> void:
	if id not in _character_slots:
		return
	var position: String = _character_slots[id]
	var slot := _get_slot(position)
	var path := StoryManager.get_character_sprite_path(id, sprite)
	if path.is_empty():
		return
	var tex := load(path) as Texture2D
	if tex:
		slot.texture = tex


func _reset_slot_offsets(pos_name: String, slot: TextureRect) -> void:
	if pos_name in _initial_offsets:
		var o: Dictionary = _initial_offsets[pos_name]
		slot.offset_top = o["top"]
		slot.offset_bottom = o["bottom"]
		slot.offset_left = o["left"]
		slot.offset_right = o["right"]


func _get_slot(position: String) -> TextureRect:
	match position:
		"left":
			return left_slot
		"center":
			return center_slot
		"right":
			return right_slot
		_:
			return center_slot
