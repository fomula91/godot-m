extends Control
## CharacterLayer에 부작 - 캐릭터 슬롯, 애니메이션, 상태관리

@onready var left_slot: TextureRect = $LeftSlot
@onready var center_slot: TextureRect = $CenterSlot
@onready var right_slot: TextureRect = $RightSlot

var _character_slots: Dictionary = {} # char_id -> position

func _ready() -> void:
	StoryManager.character_show_requested.connect(_on_show)
    StoryManager.character_hide_requested.connect(_on_hide)
    StoryManager.character_sprite_changed.connect(_on_sprite_change)




# === Public API ===

func get_state() -> Dictionary:
    return _character_slots.duplicate()

func restore_state(state: Dictionary) -> void:
    clear_all()
    for char_id in chars:
        var position: String = chars[char_id]
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
    for slot in [left_slot, center_slot, right_slot]:
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

    slot.texture = tex
    _character_slots[id] = position

    match transition:
        "fadeIn", "fadeInUp":
            slot.modulate.a = 0.0
            var tw := create_tween()
            if transition == "fadeInUp":
                slot.position.y += 30
                tw.set_parallel(true)
                tw.tween_property(slot, "position:y", slot.position.y - 30, 0.5)
            tw.tween_property(slot, "modulate:a", 1.0, 0.5)
        "slideInLeft":
            slot.modulate.a = 1.0
            slot.position.x -= 200
            var tw := create_tween()
            tw.tween_property(slot, "position:x", slot.position.x + 200, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
        "slideInRight":
            slot.modulate.a = 1.0
            slot.position.x += 200
            var tw := create_tween()
            tw.tween_property(slot, "position:x", slot.position.x - 200, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
        "bounceIn":
            slot.modulate.a = 0.0
            slot.scale = Vector2(0.8, 0.8)
            var tw := create_tween().set_parallel(true)
            tw.tween_property(slot, "modulate:a", 1.0, 0.3)
            tw.tween_property(slot, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
        _:
            slot.modulate.a = 1.0

func _on_hide(id: String, transition: String) -> void:
    DebugOverlay.log_message("Hide: %s (%s)" % [id, transition])
    if id not in _character_slots:
        return
    var position: String = _character_slots[id]
    var slot := _get_slot(position)
    
    match transition:
        "fadeOut":
            var tw := create_tween()
            tw.tween_property(slot, "modulate:a", 0.0, 0.5)
            tw.finished.connect(func(): slot.texture = null)
        "fadeOutLeft":
            var tw := create_tween().set_parallel(true)
            tw.tween_property(slot, "modulate:a", 0.0, 0.5)
            tw.tween_property(slot, "position:x", slot.position.x - 100, 0.5)
            tw.finished.connect(func(): slot.texture = null; slot.position.x += 100)
        "fadeOutRight":
            var tw := create_tween().set_parallel(true)
            tw.tween_property(slot, "modulate:a", 0.0, 0.5)
            tw.tween_property(slot, "position:x", slot.position.x + 100, 0.5)
            tw.finished.connect(func(): slot.texture = null; slot.position.x -= 100)
        _:
            slot.modulate.a = 0.0
            slot.texture = null

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