extends Area2D


@onready var water_sprite: Sprite2D = $WaterSprite
@onready var water_collider: CollisionShape2D = $WaterCol

func _ready() -> void:
    # Stretch the water sprite over the whole box
    water_sprite.position = water_collider.position
    var shape_size = water_collider.shape.get_rect().size
    var sprite_size = water_sprite.texture.get_size()
    water_sprite.scale = Vector2Ex.cw_divide(shape_size, sprite_size)
