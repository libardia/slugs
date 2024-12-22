@tool
extends Sprite2D


func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        var ground: Ground = get_parent()
        var ground_dirt_bg: Sprite2D = get_child(0)
        if ground is Ground and ground_dirt_bg is Sprite2D:
            texture = ground.ground_texture
            ground_dirt_bg.region_enabled = true
            ground_dirt_bg.region_rect = Rect2(Vector2.ZERO, texture.get_size())
            modulate = ground.background_modulate
