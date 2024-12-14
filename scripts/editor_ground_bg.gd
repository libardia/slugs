@tool
extends Sprite2D


func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        var ground: Ground = get_parent()
        texture = ground.ground_texture
        modulate = ground.background_modulate
