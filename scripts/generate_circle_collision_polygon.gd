@tool
extends CollisionPolygon2D


@export var radius := 10.0:
    set(value):
        radius = value
        update()

@export var num_sides := 20:
    set(value):
        num_sides = value
        update()


func update() -> void:
    polygon = PolygonUtil.generate_circle(Vector2.ZERO, radius, num_sides)
