extends Area2D


@export var time_to_live: float = 0.1

@onready var collider: CollisionPolygon2D = $ExplosionCollision


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    get_tree().create_timer(time_to_live).timeout.connect(_on_timeout)


func _on_body_entered(other: Node2D) -> void:
    if other is GroundQuadrant:
        other.clip(collider.polygon, other.to_local(global_position))


func _on_timeout():
    queue_free()
