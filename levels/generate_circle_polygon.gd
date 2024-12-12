@tool
extends CollisionPolygon2D


@export var radius: float = 10
@export var num_sides: int = 20


func _ready() -> void:
	polygon = PolygonUtil.generate_circle(Vector2.ZERO, radius, num_sides)
