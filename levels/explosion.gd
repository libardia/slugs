extends Area2D


@export var time_to_live: float = 0.1

@onready var collider: CollisionPolygon2D = $ExplosionCollision


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(time_to_live).timeout.connect(_on_timeout)


func _on_body_entered(other: Node2D) -> void:
	if other is StaticBody2D and other.get_child_count() > 0:
		if other.name.match("GroundBody*"):
			var ground: Ground = other.get_parent()
			var polygon_img: Polygon2D = other.get_child(0)
			var polygon_coll: CollisionPolygon2D = other.get_child(1)

			var offset: Vector2 = other.to_local(global_position)

			var new_polys = Geometry2D.clip_polygons(polygon_img.polygon, PolygonUtil.offset_polygon(collider.polygon, offset))
			if new_polys.is_empty():
				other.queue_free()
			else:
				polygon_img.set_deferred("polygon", new_polys[0])
				polygon_coll.set_deferred("polygon", new_polys[0])
				if new_polys.size() > 1:
					for i in range(1, new_polys.size()):
						ground.add_poly_and_coll(other.position, new_polys[i], ground.total_polygons, true)
						ground.total_polygons += 1


func _on_timeout():
	queue_free()
