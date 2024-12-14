@tool
extends Polygon2D


@export var radius: float = 10:
    set(value):
        radius = value
        update()

@export var num_sides: int = 20:
    set(value):
        num_sides = value
        update()


func update() -> void:
    polygon = PolygonUtil.generate_circle(Vector2.ZERO, radius, num_sides)
