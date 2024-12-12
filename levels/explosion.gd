extends Area2D


@export var time_to_live: float = 0.1

@onready var collider: CollisionPolygon2D = $ExplosionCollision


func _ready() -> void:
	print("I exist")
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(time_to_live).timeout.connect(_on_timeout)


func _on_body_entered(other: Node2D) -> void:
	for child in other.get_children():
		if child is Polygon2D or CollisionPolygon2D:
			var poly = child.polygon


	queue_free()


func _on_timeout() -> void:
	print("I didn't die in time")
	queue_free()
