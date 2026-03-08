extends Control
## BackgroundLayer 컨트롤러 - 배경 이미지 전환, 크로스페이드

@onready var bg1: TextureRect = $Background1
@onready var bg2: TextureRect = $Background2

var _current_bg_id: String = ""
var _bg_tween: Tween

func _ready() -> void:
    StoryManager.scene_change_requested.connect(_on_scene_change)

# === Public API ===

func get_current_bg_id() -> String:
    return _current_bg_id

func restore_background(id: String) -> void:
    _on_scene_change(id, "instant")


# === Signal Handlers ===

func _on_scene_change(id: String, transition: String) -> void:
    DebugOverlay.log_message("Scene: %s (%s)" % [id, transition])
    _current_bg_id = id

    if id.begins_with("#"):
        # 색상 배경
        var color := Color(id)
        bg1.texture = null
        bg1.modulate = color
        bg2.texture = null
        bg2.modulate = Color(1,1,1,0)
        $"../OverlayLayer".clear_transition()
        return

    var path := StoryManager.get_scene_path(id)
    if path.is_empty():
        return

    var tex := load(path) as Texture2D
    if not tex:
        push_warning("BackgroundController: Cannot load scene texture: " + path)
        return

    $"../OverlayLayer".clear_transition()

    match transition:
        "instant":
            bg1.texture = tex
            bg1.modulate.a = 1.0
        "fadeIn", "fadeFromBlack duration 1500", _:
            # 이전 트윈이 진행 중이면 즉시 완료 처리
            if _bg_tween and _bg_tween.is_running():
                _bg_tween.kill()
                bg1.texture = bg2.texture
                bg1.modulate.a = 1.0
                bg2.modulate.a = 0.0

            bg2.texture = tex
            bg2.modulate.a = 0.0
            _bg_tween = create_tween()
            _bg_tween.tween_property(bg2, "modulate:a", 1.0, 1.0)
            _bg_tween.finished.connect(func():
                bg1.texture = bg2.texture
                bg1.modulate.a = 1.0
                bg2.modulate.a = 0.0
            )
