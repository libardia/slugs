@tool
extends Sprite2D


var mask: Sprite2D
var ground: Ground


func _ready():
    if Engine.is_editor_hint():
        mask = get_parent()
        ground = mask.get_parent()


func _process(_delta):
    if Engine.is_editor_hint():
        if ground.ground_texture != null:
            mask.texture = ground.ground_texture
            region_enabled = true
            region_rect = Rect2(Vector2.ZERO, ground.ground_texture.get_size())
