extends Area2D


@onready var img: Polygon2D = $Polygon2D
@onready var coll: CollisionPolygon2D = $CollisionPolygon2D


func _process(_delta):
    img.position = get_global_mouse_position()
    coll.position = get_global_mouse_position()
    if Input.is_action_pressed("debug-cut"):
        for body in get_overlapping_bodies():
            if body is GroundQuadrant:
                body.clip(coll.polygon, body.to_local(coll.global_position))
